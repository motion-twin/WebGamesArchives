import Protocol;
import WorldData.Script;
using mt.flash.Event;
import mt.flash.T;

class Quests {

	var mc : SPR;
	var zoom : Float;
	var paths : IntHash<Array<SPR>>;
	var label : TF;
	var pos : TF;
	var world : World;
	
	var viewIslands : Bool;
	var viewSeaIds : Bool;
	var viewSeaGroups : Bool;
	var rumorGroup : Int;
	var viewPnjGroups : Bool;
	
	function new() {
		var root = flash.Lib.current;
		
		var t = haxe.Timer.stamp();
		this.world = new World();
		world.fill(WorldData.DOC);
		
		zoom = 7;
		var tf = new TF();
		tf.autoSize = flash.text.TextFieldAutoSize.LEFT;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.filters = [new flash.filters.GlowFilter(0xE0E0E0, 1, 2, 2, 100, 3)];
		label = tf;
		
		var tf = new TF();
		tf.autoSize = flash.text.TextFieldAutoSize.RIGHT;
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.y = 5;
		tf.x = root.stage.stageWidth - 5;
		tf.filters = [new flash.filters.GlowFilter(0xE0E0E0, 1, 2, 2, 100, 3)];
		pos = tf;
		
		root.addChild(label);
		root.addChild(pos);
		
		viewSeaGroups = true;
		viewIslands = true;
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, onZoom);
		flash.Lib.current.stage.onMove(onMouseMove);
		flash.Lib.current.stage.onKeyDown(onKey);
		
		rumorGroup = -1;
		
		draw();
	}
	
	function onZoom( e : ME ) {
		if( e.delta > 0 )
			zoom *= 1.5;
		else
			zoom /= 1.5;
		if( zoom < 1.5 ) zoom = 1.5;
		draw();
		onMouseMove();
	}
	
	function onMouseMove() {
		var st = mc.stage;
		if( st == null )
			return;
		var px = st.mouseX / st.stageWidth;
		var py = st.mouseY / st.stageHeight;
		var scroll = mc.getBounds(st);
		scroll.width *= 0.5;
		scroll.height *= 0.5;
		var dx = scroll.width - st.stageWidth;
		if( dx < 0 ) dx = 0;
		var dy = scroll.height - st.stageHeight;
		if( dy < 0 ) dy = 0;
		mc.x = scroll.width * 0.5 - dx * px;
		mc.y = scroll.height * 0.5 - dy * py;
		var px = Math.floor(mc.mouseX / zoom);
		var py = Math.floor(mc.mouseY / zoom);
		if( px < -World.DELTA )
			px = -World.DELTA;
		else if( px >= World.DELTA )
			px = World.DELTA - 1;
		if( py < -World.DELTA )
			py = -World.DELTA;
		else if( py >= World.DELTA )
			py = World.DELTA - 1;
		var sea = try world.stbl[px + World.DELTA][py + World.DELTA] catch( e : Dynamic ) throw (px + "," + py);
		pos.text = "Sea#"+sea.id+" (" + px + "," + py + ") "+getGroup(sea.group);
	}
	
	function getGroup( gid : Int ) {
		for( g in WorldData.DOC.groups )
			if( g.index == gid )
				return g.id;
		return "group#"+gid;
	}
	
	function onKey(e:KE) {
		switch( e.keyCode ) {
		case "Z".code:
			viewSeaIds = !viewSeaIds;
		case "G".code:
			viewSeaGroups = !viewSeaGroups;
		case "P".code:
			viewPnjGroups = !viewPnjGroups;
			if( viewSeaGroups ) viewSeaGroups = false;
		case "I".code:
			viewIslands = !viewIslands;
		case "R".code:
			rumorGroup++;
			if( rumorGroup == WorldData.DOC.rumors.length )
				rumorGroup = -1;
		default:
			return;
		}
		draw();
		onMouseMove();
	}

	function getIslands( scenario : Array<Script> ) : Array<String> {
		var islands = [];
		for( p in scenario )
			switch( p ) {
			case SIsland(i): islands.push("i:"+i);
			case SHasObject(o): islands.push("o:"+o);
			case SPnj(p): islands.push("p:" + p);
			case SQuest(qid):
				var found = false;
				for( q in WorldData.DOC.quests )
					if( q.id == qid ) {
						found = true;
						for( i in getIslands(q.scenario) )
							islands.push(i);
						break;
					}
				if( !found )
					islands.push("q:" + qid);
			default: throw p;
			}
		return islands;
	}
	
	function isHero(h) {
		return try WorldData.getHeroIndex(h) >= 0 catch( e : Dynamic ) false;
	}
	
	function draw() {
		var root = flash.Lib.current;
		if( mc != null )
			root.removeChild(mc);
		mc = new SPR();
		mc.x = root.stage.stageWidth >> 1;
		mc.y = root.stage.stageHeight >> 1;
		root.addChildAt(mc, 0);
				
		var colors = [];
		var pat = [0, 0x40, 0x80, 0xFF];
		for( r in pat )
			for( g in pat )
				for( b in pat )
					colors.push((r << 16) | (g << 8) | b);
		colors.pop();
		
		var g = mc.graphics;
		var countIslands = 0, countSpecialIslands = 0;
		for( s in world.seas ) {
			g.beginFill(0xFFFFFF);
			g.drawRect(s.x * zoom, s.y * zoom, s.w * zoom, s.h * zoom);
			var rnd = new mt.Rand(0);
			rnd.initSeed(s.id);
			var active = s.id <= World.LAST_SEA;
			var scount = 0;
			for( i in s.islands )
				if( i.inf.extra != null )
					for( e in i.inf.extra.req )
						switch( e ) {
						case PRumor(_):
						case PPnj(_): scount++; break;
						default:
							if( !viewPnjGroups ) {
								scount++;
								break;
							}
						}
			if( scount > 0 ) {
				scount = viewPnjGroups ? scount + 1 : Std.int(scount * 6 / s.islands.length);
				if( scount == 0 ) scount = 1;
			}
			var c = colors[scount];
			if( active ) {
				countIslands += s.islands.length;
				countSpecialIslands += scount;
			}
			g.beginFill(c,active ? 0.3 : 0.05);
			g.drawRect(s.x * zoom, s.y * zoom, s.w * zoom - 1, s.h * zoom - 1);
			if( viewSeaIds ) {
				var tf = new TF();
				tf.mouseEnabled = false;
				tf.alpha = 0.2;
				tf.blendMode = flash.display.BlendMode.LAYER;
				tf.text = "" + s.id+", "+s.w+"x"+s.h+" d="+s.dist;
				tf.x = (s.x  + s.w * 0.5) * zoom - tf.textWidth * 0.5;
				tf.y = (s.y  + s.h * 0.5) * zoom - tf.textHeight * 0.5;
				mc.addChild(tf);
			}
			if( viewSeaGroups ) {
				g.beginFill(colors[(s.group * 11) % colors.length],active ? 0.8 : 0.2);
				g.drawRect(s.x * zoom, s.y * zoom, s.w * zoom - 1, s.h * zoom - 1);
			}
		}
		//trace((countSpecialIslands * 100) / countIslands);
	
		if( viewIslands ) {
			var hsp = new Hash();
			for( s in world.seas )
				for( i in s.islands ) {
					var sp = new SPR();
					var g = sp.graphics;
					mc.addChild(sp);
					sp.onOver(callback(showIsland, s, i, true));
					sp.onOut(callback(showIsland, s, i, false));
					sp.x = (i.x + s.x) * zoom;
					sp.y = (i.y + s.y) * zoom;
					var a = 0.8;
					var p = i.inf.extra;
					var color = 0;
					if( p != null ) {
						var prio = -1;
						function set(col, p) if( prio < p ) { color = col; prio = p; }
						for( p in p.req )
							switch( p ) {
							case PRumor(g,_): g == rumorGroup ? set(0xFFFFFF,10) : set(0x303030, 0);
							case PFountain: set(0x004000, 1);
							case PObject(_): set(0x0000FF, 2);
							case PPnj(id): set( (id == "shadow" || isHero(id)) ? 0x008000 : 0x00FF00, 3);
							case PShrine, PLibrary: set(0xFF00FF, 4);
							default: set(0xFFFFFF, 10);
							}
						if( p.id != null ) color = 0xFF0000;
					} else if( s.id > World.LAST_SEA )
						a = 0.1;
					g.beginFill(color, a);
					g.drawRect(0, 0, i.width * zoom - 1, i.height * zoom - 1);
					if( p != null ) {
						if( p.id != null )
							hsp.set("i:" + p.id, [{ i : i, s : sp }]);
						for( r in p.req )
							switch( r ) {
							case PObject(o):
								var s = hsp.get("o:" + o);
								if( s == null ) {
									s = [];
									hsp.set("o:" + o, s);
								}
								s.push( { i : i, s : sp } );
							case PPnj(p):
								hsp.set("p:" + p, [ { i : i, s : sp } ]);
							default:
							}
					}
				}
			paths = new IntHash();
			for( q in WorldData.DOC.quests ) {
				var path = new flash.display.Sprite();
				var graph = new flash.display.Shape();
				var g = graph.graphics;
				g.lineStyle(1, colors[World.hash(q.id)%colors.length] );
				mc.addChildAt(path, 0);
				var tf = new flash.text.TextField();
				tf.text = q.id;
				tf.x = -mc.x;
				tf.y = -mc.y;
				tf.filters = label.filters;
				graph.filters = [new flash.filters.GlowFilter(0, .1, 2, 2, 100)];
				path.addChild(graph);
				path.addChild(tf);
				path.visible = false;
				var first = true;
				var scenario = q.scenario.copy();
				if( q.hero )
					scenario.unshift( SPnj("oracle") );
				for( p in getIslands(scenario) ) {
					var steps = hsp.get(p);
					if( steps == null ) throw "Missing " + p;
					for( i in steps ) {
						var pa = paths.get(i.i.id);
						if( pa == null ) { pa = new Array(); paths.set(i.i.id, pa);  }
						pa.push(path);
						if( first ) {
							g.moveTo(i.s.x + i.s.width * 0.5, i.s.y + i.s.height * 0.5);
							first = false;
						} else
							g.lineTo(i.s.x + i.s.width * 0.5, i.s.y + i.s.height * 0.5);
					}
				}
			}
		}
	}
	
	function showIsland( s : World.WorldSea, i : World.WorldIsland, flag ) {
		var p = i.inf.extra;
		var iid = "#" + i.id;
		if( p != null ) {
			if( p.id != null )
				iid = p.id + iid;
			if( p.req.length > 0 )
				iid += " " + Std.string(p.req);
		}
		iid += " (" + (i.x + s.x) +" , " + (i.y + s.y) + ")";
		label.text = iid;
		label.x = (i.x + s.x) * zoom + 15 + mc.x;
		label.y = (i.y + s.y) * zoom + mc.y;
		label.visible = flag;

		var pa = paths.get(i.id);
		if( pa != null )
			for( p in pa )
				p.visible = flag;
	}
		
	
	static var inst;
	
	static function main() {
		inst = new Quests();
	}
	
}