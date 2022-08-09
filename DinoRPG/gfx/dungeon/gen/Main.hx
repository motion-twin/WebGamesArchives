package gen;
import gen.Data;
import DungeonCodec;

typedef K = flash.ui.Keyboard;

class Main {

	var generate : Bool;
	var inf : LevelInfos;
	var mc : flash.display.Sprite;
	var data : String;
	var fileName : String;
	var params : { w : Int, h : Int, l : Int, noise : Float, filters : Int, surface : Float };

	function new(mc) {
		this.mc = mc;
		fileName = "dungeon.xml";
		generate = true;
		// load params
		var me = this;
		var h = new haxe.Http("params.xml");
		h.onData = function(data) {
			var x = Xml.parse(data).firstElement();
			me.params = {
				w : Std.parseInt(x.get("width")),
				h : Std.parseInt(x.get("height")),
				l : Std.parseInt(x.get("levels")),
				noise : Std.parseFloat(x.get("noise")),
				filters : Std.parseInt(x.get("filters")),
				surface : Std.parseFloat(x.get("surface")),
			};
		};
		h.request(false);
	}

	function loop() {
		if( !generate )
			return;
		if( params == null )
			return;
		// generate
		var inf = new LevelInfos(params.w,params.h,params.l);
		inf.noiseAmount = params.noise;
		inf.filtersPasses = params.filters;
		var reason = new Rooms(params.surface).tryGenerate(inf,1);
		if( reason != null ) {
			trace(reason);
			return;
		}
		haxe.Log.clear();
		new Noise().noise(inf);
		new Gameplay().gameplay(inf);
		var reason = new Checker().check(inf);
		if( reason != null ) {
			trace(reason);
			return;
		}
		generate = false;
		this.inf = inf;
		draw();
	}

	function allocId(k) {
		var ids = new Array<Null<Int>>();
		if( k == IKey ) ids.push(0);
		for( l in inf.levels )
			for( r in l.rooms ) {
				if( r.item == null ) continue;
				if( r.item.k == k ) ids.push(r.item.v);
			}
		ids.sort(function(id1,id2) return id1 - id2);
		var x = 0;
		while( ids[x] == x )
			x++;
		return x;
	}

	function onKey( e : flash.events.KeyboardEvent ) {
		if( inf == null ) return;
		var me = this;
		var d = Math.min(mc.stage.stageWidth / inf.width,mc.stage.stageHeight / inf.height);
		var k = Math.ceil(Math.sqrt(inf.nlevels));
		d /= k;
		var cx = Std.int(mc.mouseX / d);
		var cy = Std.int(mc.mouseY / d);
		var lid = Std.int(cx / inf.width) + Std.int(cy / inf.height) * k;
		cx %= inf.width;
		cy %= inf.height;
		var level = inf.levels[lid];
		var room = null, door = null;
		if( level != null )
			for( r in level.rooms ) {
				if( cx >= r.x && cy >= r.y && cx < r.x2 && cy < r.y2 ) {
					room = r;
					break;
				}
				for( d in r.doors )
					if( d.x == cx && d.y == cy ) {
						door = d;
						break;
					}
			}
		switch( e.keyCode ) {
		case K.ESCAPE:
			generate = true;
			return;
		case K.INSERT:
			if( room == null ) return;
			level.table[cx][cy] = true;
		case K.DELETE:
			if( room == null ) return;
			if( room.item != null && room.item.x == cx && room.item.y == cy ) return;
			level.table[cx][cy] = false;
		case K.F1:
			var f = new flash.net.FileReference();
			f.addEventListener(flash.events.Event.SELECT,function(_) f.load());
			f.addEventListener(flash.events.Event.COMPLETE,function(_) {
				me.fileName = f.name;
				me.load(f.data.readUTFBytes(f.data.length));
			});
			f.browse();
			return;
		case "S".code:
			if( e.ctrlKey ) {
				var f = new flash.net.FileReference();
				f.addEventListener(flash.events.Event.SELECT,function(_) me.fileName = f.name);
				f.save(data,fileName);
				return;
			}
			if( room == null || !level.table[cx][cy] )
				return;
			room.item = null;
			room.item = { x : cx, y : cy, k : IScenario, v : allocId(IScenario) };
		case "H".code:
			if( room == null || !level.table[cx][cy] ) return;
			room.item = null;
			room.item = { x : cx, y : cy, k : IHeal, v : 0 };
		case "K".code:
			if( room == null || !level.table[cx][cy] ) return;
			room.item = null;
			room.item = { x : cx, y : cy, k : IKey, v : allocId(IKey) };
		case "R".code:
			if( room == null && door == null ) return;
			if( room != null ) room.item = null;
			if( door != null ) door.status = 0;
		case "D".code:
			if( door == null ) return;
			door.status++;
			door.status %= allocId(IKey);
		default:
		}
		draw();
	}

	function load( s : String ) {
		inf = decode(s);
		draw();
	}

	static function decode( s : String ) {
		var codec = new DungeonCodec();
		if( !codec.decode(s) )
			throw "invalid data";
		var d = codec.d;
		var inf = new LevelInfos(d.width,d.height,d.levels.length);
		inf.start = d.start;
		inf.exit = d.exit;
		inf.levels = new Array();
		var rooms = new Array();
		var rtbl = new Array();
		for( l in d.levels ) {
			var rt = new Array();
			for( x in 0...d.width )
				rt[x] = new Array();
			rtbl.push(rt);
			for( r in l.rooms ) {
				var r2 = new Room(null,r.id,r.x,r.y,r.w,r.h);
				r2.item = r.item;
				rooms[r.id] = r2;
				for( x in r.x...r.x+r.w )
					for( y in r.y...r.y+r.h )
						rt[x][y] = r2;
			}
		}
		var curlevel = 0;
		for( l in d.levels ) {
			var rt = rtbl[curlevel];
			for( r in l.rooms ) {
				var r2 = rooms[r.id];
				r2.doors = new List();
				for( d in r.doors ) {
					var d2 = new Door(r2,null);
					var x = d.x;
					var y = d.y;
					var l = curlevel;
					if( d.up != null )
						l += d.up ? 1 : -1;
					else if( x == r2.x - 1 )
						x--;
					else if( x == r2.x2 )
						x++;
					else if( y == r2.y - 1 )
						y--;
					else
						y++;
					d2.r2 = rtbl[l][x][y];
					d2.status = (d.key == null) ? 0 : d.key;
					d2.x = d.x;
					d2.y = d.y;
					r2.doors.add(d2);
				}
			}
			curlevel++;
		}
		var id = 0;
		for( l in d.levels ) {
			var l2 = new Level(id++,d.width,d.height);
			l2.table = l.table;
			inf.levels.push(l2);
			for( r in l.rooms ) {
				var r2 = rooms[r.id];
				r2.level = l2;
				l2.rooms.add(r2);
			}
		}
		return inf;
	}

	function draw() {
		while( mc.numChildren > 0 )
			mc.removeChildAt(0);
		if( inf == null )
			return;
		var d = Math.min(mc.stage.stageWidth / inf.width,mc.stage.stageHeight / inf.height);
		var k = Math.ceil(Math.sqrt(inf.nlevels));
		d /= k;
		var bg = new flash.display.Shape();
		var fg = new flash.display.Shape();
		var g = fg.graphics;
		var g2 = bg.graphics;
		mc.addChild(bg);
		mc.addChild(fg);
		var me = this;
		var getLevelPos = function(l:Level) {
			return {
				x : (l.id % k) * d * me.inf.width,
				y : Std.int(l.id/k) * d * me.inf.height,
			};
		}
		// draw cases
		for( l in inf.levels ) {
			var p = getLevelPos(l);
			g2.lineStyle(1,0x707070);
			for( x in 0...inf.width )
				for( y in 0...inf.height ) {
					g2.beginFill(l.table[x][y]?0xEEEEEE:0x808080);
					g2.drawRect(p.x + x * d,p.y + y *d,d,d);
				}
		}
		// draw levels and rooms
		for( l in inf.levels ) {
			g.lineStyle(2,0);
			var p = getLevelPos(l);
			g.drawRect(p.x,p.y,d * inf.width,d * inf.height);
			g.lineStyle();
			g.beginFill(0x00FF00,0.05);
			for( r in l.rooms )
				g.drawRect(p.x + r.x * d, p.y + r.y * d, r.w * d, r.h * d);
			g.endFill();
		}
		var filters:Array<flash.filters.BitmapFilter> = [new flash.filters.GlowFilter(0xFFFFFF,1,2,2,30)];
		var addText = function(l:Level,x,y,txt) {
			var tf = new flash.text.TextField();
			var p = getLevelPos(l);
			tf.text = txt;
			tf.x = p.x + (x + 0.5) * d - tf.textWidth / 2;
			tf.y = p.y + (y + 0.5) * d - tf.textHeight / 2;
			tf.filters = filters;
			tf.selectable = false;
			tf.alpha = 0.3;
			me.mc.addChild(tf);
			return tf;
		};
		var items = [], nrooms = 0, nmonsters = 0, nstairs = 0;
		for( _ in Type.getEnumConstructs(DungeonItem) )
			items.push(0);
		for( l in inf.levels ) {
			var p = getLevelPos(l);
			for( r in l.rooms ) {
				nrooms++;
				for( dr in r.doors ) {
					var r2 = dr.other(r);
					var l2 = r2.level;
					if( l2 != l ) {
						var dx = (dr.x + 0.5) * d;
						var dy = (dr.y + 0.5) * d;
						g.beginFill((l2.id > l.id) ? 0xFF0000 : 0x0000FF);
						g.drawCircle(p.x+dx,p.y+dy,d/3);
						g.endFill();
						if( r2.id < r.id )
							nstairs++;
						continue;
					}
					// only single traversal
					if( r2.id < r.id )
						continue;
					if( dr.status != 0 )
						addText(r.level,dr.x,dr.y,"D"+dr.status);
					else
						nmonsters++;
				}
				if( inf.width < 50 )
					addText(r.level,r.x+(r.w-1)/2,r.y+(r.h-1)/2,"R"+r.tag);
				if( r.item != null ) {
					var tf = addText(r.level,r.item.x,r.item.y,Type.enumConstructor(r.item.k).charAt(1)+r.item.v);
					tf.alpha = 0.6;
					items[Type.enumIndex(r.item.k)]++;
				}
			}
		}
		addText(inf.levels[inf.start.l],inf.start.x,inf.start.y,"Start").textColor = 0xFF0000;
		addText(inf.levels[inf.exit.l],inf.exit.x,inf.exit.y,"Exit").textColor = 0xFF0000;
		// infos
		var tf = new flash.text.TextField();
		var infos = ["start : "+inf.start.x+","+inf.start.y,nrooms+" rooms",nmonsters+" monsters",nstairs+" stairs"];
		for( i in 0...items.length )
			infos.push(items[i]+" "+Type.getEnumConstructs(DungeonItem)[i].substr(1).toLowerCase()+"s");
		var codec = new DungeonCodec();
		codec.d = {
			width : inf.width,
			height : inf.height,
			start : inf.start,
			exit : inf.exit,
			levels : new Array(),
		};
		var codeRoom = function(r:Room) {
			var doors = new Array();
			for( d in r.doors ) {
				var r2 = d.other(r);
				var delta = r2.level.id - r.level.id;
				if( delta == 0 && r.id > r2.id )
					continue;
				var up = if( delta == 0 ) null else (delta > 0);
				var key = if( d.status == 0 ) null else d.status;
				if( up != null && key != null )
					throw "assert";
				doors.push({
					x : d.x,
					y : d.y,
					up : up,
					key : key,
				});
			}
			return {
				id : r.id,
				x : r.x,
				y : r.y,
				w : r.w,
				h : r.h,
				doors : doors,
				item : r.item,
			};
		}
		for( l in inf.levels )
			codec.d.levels.push({ table : l.table, rooms : Lambda.array(l.rooms.map(codeRoom)) });
		data = codec.encode();
		flash.system.System.setClipboard(data);
		infos.push(data.length+" bytes");
		tf.height = 1000;
		tf.alpha = 0.8;
		tf.text = infos.join("\n");
		tf.filters = filters;
		tf.selectable = false;
		tf.x = 5;
		tf.y = mc.stage.stageHeight - (tf.textHeight + 5);
		mc.addChild(tf);
	}

	static var inst;

	static function main() {
		var root = new flash.display.Sprite();
		root.mouseEnabled = false;
		root.mouseChildren = false;
		flash.Lib.current.addChild(root);
		root.stage.align = flash.display.StageAlign.TOP_LEFT;
		root.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		inst = new Main(root);
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME,function(_) inst.loop());
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,inst.onKey);
		flash.Lib.current.stage.addEventListener(flash.events.Event.RESIZE,function(_) inst.draw());
		inst.loop();
	}

}
