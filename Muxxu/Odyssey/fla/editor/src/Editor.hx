import mt.flash.T;
import Protocol;
using mt.flash.Event;

class StrictInterp extends hscript.Interp {

	public function new() {
		super();
		variables.set("K", _PK);
		variables.set("O", Editor.inst.objects);
		variables.set("P", Editor.inst.pnjs);
		variables.set("G", Editor.inst.groups);
		variables.set("group", Editor.inst.setTileGroup);
	}
	
	override function get( o : Dynamic, f : String ) : Dynamic {
		var v : Dynamic = Reflect.field(o, f);
		if( v == null && !Reflect.hasField(o, v) ) {
			if( o == Editor.inst.objects )
				throw "No Object " + f;
			if( o == Editor.inst.pnjs )
				throw "No PNJ " + f;
			throw Std.string(o) + " has no field '" + f + "'";
		}
		return v;
	}

}

enum Sel {
	Place( p : IslandPoint );
	Path( pid : Int );
}

class Editor {
	
	static inline var MARGIN = 30;
	static var PKINDS = ["Normal", "Blocked"];
	
	var root : MC;
	var dm : mt.DepthManager;
	var cur : MapIsland;
	var select : { s : Sel, spr : SPR };
	var mc : flash.display.Sprite;
	var bsky : flash.display.Bitmap;
	var bar : EditBar;
	var lastFile : String;
	var save : flash.net.SharedObject;
	var tileGroup : WorldData.Group;
	var render : IslandRender;
	
	public var objects : Dynamic<String>;
	public var pnjs : Dynamic<String>;
	public var groups : Dynamic<String>;
	
	function new(r) {
		this.root = r;
		dm = new mt.DepthManager(r);
		r.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		r.stage.onKeyDown(onKey);
		objects = cast {
			toString : function() return "Objects",
		};
		pnjs = cast {
			toString : function() return "PNJ",
		};
		groups = cast {
			toString : function() return "Groups",
		};

		var me = this;
		bsky = new flash.display.Bitmap(null, flash.display.PixelSnapping.ALWAYS, true);
		bsky.scaleX = 4;
		bsky.scaleY = 4;
		dm.add(bsky, 0);
		
		
		render = new IslandRender();
		render.visible = false;
		dm.add(render, 2);
		
		bar = new EditBar();
		bar.kind.addEventListener(flash.events.Event.CHANGE, function(_) me.onChangeKind());
		bar.inf.text = "";
		bar.err.text = "";
		dm.add(bar, 2);
		
		r.stage.addEventListener(flash.events.Event.RESIZE, function(_) me.onResize());
		r.stage.onMove(onMove);
		onResize();
		
		save = flash.net.SharedObject.getLocal("edsave");
		var data : String = save.data._str;
		haxe.Serializer.USE_ENUM_INDEX = true;
		try {
			cur = haxe.Unserializer.run(data);
			display();
		} catch( e : Dynamic ) {
			cur = {
				id : -1,
				name : null,
				seed : 0,
				x : 0,
				y : 0,
				w : 1,
				h : 1,
				pts : null,
				segs : null,
				bmp : null,
				tiles : null,
				e : null,
			};
			generate();
		}
	}
	
	public function setTileGroup( gid : String ) {
		if( gid == null ) {
			tileGroup = null;
			return;
		}
		for( g in DOC.groups )
			if( g.id == gid ) {
				tileGroup = g;
				initTiles(cur, Std.random(0x1000000) );
				display();
				return;
			}
		throw "No such group";
	}
	
	function onResize() {
		var width = root.stage.stageWidth;
		var height = root.stage.stageHeight;
		bar.y = height;
		bar.err.x = width - (bar.err.width + 5);
		// update SKY
		var old = bsky.bitmapData;
		if( old != null ) old.dispose();
		var sky = new Sky(Math.ceil(width / bsky.scaleX), Math.ceil(height / bsky.scaleY),0);
		bsky.bitmapData = sky.b;
		sky.update(0,0);
	}
	
	function onMove() {
		var stage = root.stage;
		var mx = stage.mouseX / stage.stageWidth;
		var my = stage.mouseY / stage.stageHeight;
		var i = cur;
		var w = (i.w * Const.ISIZE * Drawer.SIZE + MARGIN) - stage.stageWidth;
		var h = (i.h * Const.ISIZE * Drawer.SIZE + MARGIN) - stage.stageHeight;
		if( w < 0 ) w = 0;
		if( h < 0 ) h = 0;
		mc.x = MARGIN - w * mx;
		mc.y = MARGIN - h * my;
	}
	
	function generate() {
		cur.pts = null;
		cur.bmp = null;
		cur.segs = null;
		cur.tiles = null;
		select = null;
		cur.seed = Std.random(0x10000000);
		display();
	}
	
	function showInfos( s : Sel ) {
		bar.err.text = "";
		if( s == null ) {
			s = (select == null) ? null : select.s;
			if( s == null ) {
				bar.inf.text = cur.w+" x "+cur.h;
				bar.kind.text = "";
				return;
			}
		}
		switch( s ) {
		case Place(p):
			var pos = 0;
			for( p2 in cur.pts ) {
				if( p == p2 ) break;
				pos++;
			}
			bar.inf.text = "#" + pos + " (" + p.x + "," + p.y + ")";
			bar.kind.text = formatKind(p.k);
			bar.kind.textColor = 0;
		case Path(pid):
			var pathKind = cur.segs.get((pid * 3) + 2);
			bar.inf.text = "Path#" + pid;
			bar.kind.text = PKINDS[pathKind];
			bar.kind.textColor = 0;
		}
	}
	
	function formatKind( k : _PK ) {
		return Type.enumConstructor(k) + switch( k ) {
			case PRumor(g, n): "(" + g + "," + n + ")";
			case PGod(g): "(" + g + ")";
			case PObject(obj): "(" + ("O." + obj) + ")";
			case PPnj(id): "(" + ("P." + id) + ")";
			case PBoss(id): "('" + id + "')";
			case PGold(n): "(" + n + ")";
			case PPort, PEmpty, PMonsters, PInn, PTest, PRuins, PDistill, PFountain, PDirection, PMerchant,PShrine,PLibrary, PUpFood: "";
		};
	}
	
	function initTiles( i : MapIsland, seed ) {
		var tl = Drawer.initTiles();
		var maxTiles = tl.tiles.length;
		var rnd = new mt.Rand(0);
		rnd.initSeed(seed);
		var tiles = [];
		if( tileGroup != null )
			maxTiles = tileGroup.tiles.length;
		while( tiles.length < Drawer.TILE_LEVELS - 1 ) {
			var t = rnd.random(maxTiles);
			if( tileGroup != null )
				t = tileGroup.tiles[t];
			for( t2 in tiles )
				if( t == t2 ) {
					t = -1;
					break;
				}
			if( t >= 0 )
				tiles.push(t);
		}
		if( tileGroup == null )
			tiles.unshift(rnd.random(tl.grounds.length));
		else
			tiles.unshift(tileGroup.ground);
		i.tiles = tiles;
	}
	
	function display() {
		haxe.Log.clear();
		if( cur.tiles == null )
			initTiles(cur, cur.seed);
		if( cur.pts == null ) {
			var g = new Generator(cur.w * Const.ISIZE, cur.h * Const.ISIZE, cur.seed);
			while( !g.generate([]) ) {
			}
			g.saveTo(cur);
		}
		var d = new Drawer(cur);
		if( mc != null )
			mc.parent.removeChild(mc);
		mc = d.draw(true);
		mc.x = mc.y = MARGIN;
		dm.add(mc, 1);
		var old = (select == null) ? null : select.s;
		select = null;
		var paths = d.initPaths();
		var hpaths = new IntHash();
		var stride = cur.w * Const.ISIZE;
		for( x in 0...cur.w * Const.ISIZE )
			for( y in 0...cur.h * Const.ISIZE ) {
				var p = paths[x + y * stride] - 1;
				if( p < 0 ) continue;
				for( pt in cur.pts )
					if( x == pt.x && y == pt.y ) {
						p = -1;
						break;
					}
				if( p < 0 ) continue;
				var s = hpaths.get(p);
				if( s == null ) {
					s = new SPR();
					s.graphics.beginFill(0xFFFFFF);
					s.buttonMode = true;
					s.alpha = 0;
					var sel = Path(p);
					if( Type.enumEq(sel, old) )
						setSelect(sel, s);
					s.onOver(callback(showInfos, sel));
					s.onOut(callback(showInfos, null));
					s.onClick(callback(setSelect, sel, s));
					mc.addChild(s);
					hpaths.set(p, s);
				}
				s.graphics.drawRect(x * Drawer.SIZE, y * Drawer.SIZE, Drawer.SIZE, Drawer.SIZE);
			}
		for( p in cur.pts ) {
			var s = new SPR();
			s.graphics.beginFill(0xFFFFFF);
			s.graphics.drawEllipse(0, 0, 30, 20);
			s.buttonMode = true;
			s.x = p.x * Drawer.SIZE;
			s.y = p.y * Drawer.SIZE;
			mc.addChild(s);
			s.alpha = 0;
			var sel = Place(p);
			if( Type.enumEq(sel, old) )
				setSelect(sel, s);
			s.onOver(callback(showInfos, sel));
			s.onOut(callback(showInfos, null));
			s.onClick(callback(setSelect, sel, s));
		}
		onMove();
		if( root.stage.focus != bar.kind )
			root.stage.focus = root.stage;
		save.setProperty("_str", haxe.Serializer.run(cur));
	}
	
	function onChangeKind() {
		bar.err.text = "";
		if( select == null ) {
			try {
				var e = new hscript.Parser().parseString(bar.kind.text);
				var i = new StrictInterp();
				i.execute(e);
				bar.kind.textColor = 0;
			} catch( e : Dynamic ) {
				bar.err.text = Std.string(e);
				bar.kind.textColor = 0xFF0000;
			}
			return;
		}
		try {
			switch( select.s ) {
			case Place(p):
				var e = new hscript.Parser().parseString("K." + bar.kind.text);
				var i = new StrictInterp();
				var k : _PK = i.execute(e);
				if( k == null ) throw "null";
				p.k = k;
			case Path(pid):
				var kind = Lambda.indexOf(PKINDS, bar.kind.text);
				if( kind == -1 ) throw "Unknown kind";
				cur.segs.set((pid * 3) + 2, kind);
			}
			bar.kind.textColor = 0;
			display();
		} catch( e : Dynamic ) {
			bar.err.text = Std.string(e);
			bar.kind.textColor = 0xFF0000;
		}
	}
	
	function setSelect(sel, spr) {
		if( select != null ) select.spr.alpha = 0;
		select = (sel == null) ? null : { s : sel, spr : spr };
		if( select != null ) select.spr.alpha = 0.8;
	}
	
	function move( k : KE, dx : Int, dy : Int ) {
		if( select != null ) {
			switch( select.s ) {
			case Place(p):
				p.x += dx;
				p.y += dy;
			default:
			}
			display();
			return;
		}
		if( k.ctrlKey ) {
			cur.w += dx;
			cur.h += dy;
			if( cur.w < 1 ) cur.w = 1;
			if( cur.h < 1 ) cur.h = 1;
			generate();
			return;
		}
	}
	
	function deletePlace( p : IslandPoint ) {
		for( i in 0...cur.pts.length )
			if( cur.pts[i] == p ) {
				cur.pts.remove(p);
				var p = 0;
				var o = new haxe.io.BytesOutput();
				while( p < cur.segs.length ) {
					var i0 = cur.segs.get(p++);
					var i1 = cur.segs.get(p++);
					if( i0 == i || i1 == i ) {
						p++;
						continue;
					}
					if( i0 > i ) i0--;
					if( i1 > i ) i1--;
					o.writeByte(i0);
					o.writeByte(i1);
					o.writeByte(cur.segs.get(p++));
				}
				cur.segs = o.getBytes();
				break;
			}
	}
	
	function insertPlace( x : Int, y : Int ) {
		var left : Null<Int> = null, right : Null<Int> = null, top : Null<Int> = null, bottom : Null<Int> = null;
		for( i in 0...cur.pts.length ) {
			var p = cur.pts[i];
			if( p.x == x ) {
				if( p.y < y && (top == null || cur.pts[top].y < p.y) )
					top = i;
				else if( p.y > y && (bottom == null || cur.pts[bottom].y > p.y) )
					bottom = i;
			} else if( p.y == y ) {
				if( p.x < x && (left == null || cur.pts[left].x < p.x) )
					left = i;
				else if( p.x > x && (right == null || cur.pts[right].x > p.x) )
					right = i;
			}
		}
		var b = new haxe.io.BytesBuffer();
		b.add(cur.segs);
		for( p in [left, right, top, bottom] )
			if( p != null ) {
				b.addByte(p);
				b.addByte(cur.pts.length);
				b.addByte(0);
			}
		cur.pts.push( { x : x, y : y, k : PEmpty } );
		cur.segs = b.getBytes();
	}
	
	function deletePath( pid : Int ) {
		var segs = cur.segs;
		var b = haxe.io.Bytes.alloc(segs.length - 3);
		b.blit(0, segs, 0, pid * 3);
		var t = (pid + 1) * 3;
		b.blit(pid * 3, segs, t, segs.length - t);
		cur.segs = b;
	}
	
	function onKey( k : KE ) {
		if( root.stage.focus == bar.kind ) {
			if( k.keyCode == K.ENTER )
				showInfos(null);
			return;
		}
		switch( k.keyCode ) {
		case K.LEFT:
			move(k, -1, 0);
		case K.RIGHT:
			move(k,  1, 0);
		case K.UP:
			move(k, 0, -1);
		case K.DOWN:
			move(k, 0, 1);
		case K.ESCAPE:
			setSelect(null, null);
		case K.DELETE:
			if( select != null ) {
				switch( select.s ) {
				case Place(p):
					deletePlace(p);
				case Path(pid):
					deletePath(pid);
				}
				setSelect(null,null);
				display();
			}
		case K.INSERT:
			if( select == null ) {
				insertPlace(Std.int(mc.mouseX / Drawer.SIZE), Std.int(mc.mouseY / Drawer.SIZE));
				setSelect(null, null);
				display();
			}
		case "R".code:
			generate();
		case "T".code:
			initTiles(cur, Std.random(0x1000000) );
			display();
		case "I".code:
			render.visible = !render.visible;
		case K.F1:
			var me = this;
			var f = new flash.net.FileReference();
			f.addEventListener(flash.events.Event.SELECT, function(_) {
				me.lastFile = f.name;
				f.load();
			});
			f.addEventListener(flash.events.Event.COMPLETE, function(_) {
				var str = f.data.readUTFBytes(f.data.length);
				me.cur = haxe.Unserializer.run(str);
				me.display();
			});
			f.browse([new flash.net.FileFilter("Island Data", "*.id")]);
		case "S".code:
			if( !k.ctrlKey ) return;
			var f = new flash.net.FileReference();
			haxe.Serializer.USE_ENUM_INDEX = true;
			var s = new SerializerFix();
			s.serialize(cur);
			if( lastFile == null )
				lastFile = "i" + cur.seed + ".id";
			var me = this;
			f.addEventListener(flash.events.Event.COMPLETE, function(_) {
				me.lastFile = f.name;
			});
			f.save(s.toString(), lastFile);
		}
	}
		
	
	public static var inst : Editor;
	
	public static var DOC = WorldData.DOC;
		
	static function main() {
		inst = new Editor(flash.Lib.current);
		for( o in DOC.objs )
			Reflect.setField(inst.objects, o.id, o.id );
		for( p in DOC.pnjs )
			Reflect.setField(inst.pnjs, p.id, p.id );
		for( g in DOC.groups )
			Reflect.setField(inst.groups, g.id, g.id );
	}
	
}