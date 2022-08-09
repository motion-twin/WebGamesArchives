import Protocol;
using mt.flash.Event;

class Map {//}

	static inline var MAP_ZOOM = 8;
	static inline var SCROLL = 40;
	public static inline var SIZE = Std.int(Const.ISIZE * Drawer.SIZE / MAP_ZOOM);
	
	static inline var BMP_BORDER = 9;
	
	static inline var PLAN_BG = 0;
	static inline var PLAN_SCROLL = 1;
	static inline var PLAN_BORDERS = 2;
	static inline var PLAN_ISLAND = 3;
	static inline var PLAN_MASK = 4;
	static inline var PLAN_FX = 5;
	static inline var PLAN_BOAT = 6;

	static var islandView = new IntHash<flash.display.BitmapData>();

	var m : Main;
	public var boat : Boat;
	var scrolling : mt.DepthManager;
	var scroll : {
		var px : Int;
		var py : Int;
		var ix : Int;
		var iy : Int;
		var cx : Float;
		var cy : Float;
		var tx : Float;
		var ty : Float;
		var width : Int;
		var height : Int;
		var vx : Int;
		var vy : Int;
	};
	var light : {
		var s : flash.display.Sprite;
		var i : MapIsland;
	};
	var path : PathFinder;
	var needRecal : Bool;
	var front : MapRender;
	var sky : Sky;
	public var bsky : flash.display.Bitmap;
	var borderBmp : flash.display.BitmapData;
	var segBmp : flash.display.BitmapData;
	var prevSea : { s : MapSea, fade : Float };
	var mask : flash.display.Sprite;
	var save : { px : Int, py : Int };
	var cursor : flash.display.Sprite;

	var wind:fx.Wind;
	public var fxUnder:flash.display.Sprite;
	public var fxTop:flash.display.Sprite;
	public var fxCloudLayers:Array<flash.display.Sprite>;
	public static var me:Map;

	
	public function new(m) {
		this.m = m;
		me = this;
		front = new MapRender();
		front.noMouse();
		boat = new Boat(m.boat);

		//
		fxUnder = new flash.display.Sprite();
		fxTop = new flash.display.Sprite();
		
		fxCloudLayers = [];
		var bl = 1.2;
		var fl = new flash.filters.DropShadowFilter( -1.8, 90, 0xF4F4EE, 1, bl, bl, 40, 1, false ,true );
		for ( i in 0...4 ) {
			var lay = new flash.display.Sprite();
			lay.filters = [fl];
			fxCloudLayers.push(lay);
		}
		
		// init scroll
		var x = boat.x;
		var y = boat.y;
		var stage = flash.Lib.current.stage;
		var width = stage.stageWidth;
		var height = stage.stageHeight;
		path = new PathFinder(width, height, 4);
		path.diagonals = true;
		//var bmp = new flash.display.Bitmap(path.debugPath()); bmp.scaleX = bmp.scaleY = 4; bmp.alpha = 0.8; flash.Lib.current.stage.addChild(bmp);
		var px = x - (width >> 1);
		var py = y - (height >> 1);
		scroll = { px : px, py : py, ix : px - (px & 1), iy : py - (py & 1), cx : x * 1.0, cy : y * 1.0, tx : x * 1.0, ty : y * 1.0, width : width, height : height, vx : 0, vy : -100000000 };
		needRecal = getIsland(boat.px, boat.py) != null;
		sky = new Sky(width >> 1, height >> 1, Main.inst.curWind);
		sky.speed = 0;
		sky.zoom = 1.0;
		borderBmp = new MapBorder();
		segBmp = new MapSeg();
		cursor = new ui.Flag();
		cursor.scaleX = cursor.scaleY = 0.5;
		cursor.visible = false;
		
		//
		wind = new fx.Wind();
	}
	
	function scrollTo( x : Float, y : Float ) {
		scroll.tx = x;
		scroll.ty = y;
	}
	
	public function cleanup() {
		path.cleanup();
		borderBmp.dispose();
		sky.b.dispose();
		segBmp.dispose();
	}
	
	function getSeas() {
		var s = [m.sea];
		if( prevSea != null ) s.push(prevSea.s);
		return s;
	}
	
	function getVisibleIslands( sea : MapSea ) {
		var sx = Math.ceil(scroll.width * 0.5 / SIZE);
		var sy = Math.ceil(scroll.height * 0.5 / SIZE);
		var il = [];
		for( i in sea.il ) {
			var ix = i.x + sea.x;
			var iy = i.y + sea.y;
			if( ix + i.w < boat.px - sx || iy + i.h < boat.py - sy || ix > boat.px + sx + 1 || iy > boat.py + sy + 1 )
				continue;
			il.push(i);
		}
		return il;
	}
	
	function makeBorders( sea : MapSea ) {
		var border = new flash.display.Sprite();
		var g = border.graphics;
			
		var m = new flash.geom.Matrix();
		var px1 = sea.x * SIZE;
		var px2 = (sea.x + sea.w) * SIZE  - borderBmp.width;
		var py1 = sea.y * SIZE;
		var py2 = (sea.y + sea.h) * SIZE  - borderBmp.width;
		var sw = sea.w * SIZE;
		var sh = sea.h * SIZE;
	
		var hs = segBmp.width >> 1;
		for( x in 1...sea.w ) {
			if( (x + sea.x) % 3 != 0 )
				continue;
			var px = px1 + x * SIZE - hs;
			m.createBox(1, 1, 0, px, py1);
			g.beginBitmapFill(segBmp, m, true, false);
			g.drawRect(px, py1, segBmp.width, sh);
		}
		for( y in 1...sea.h ) {
			if( (y + sea.y) % 3 != 0 )
				continue;
			var py = py1 + y * SIZE - hs;
			m.createBox(1, 1, -Math.PI/2, px1, py);
			g.beginBitmapFill(segBmp, m, true, false);
			g.drawRect(px1, py, sw, segBmp.width);
		}
		
		m.createBox( -1, 1, 0, px1, py1);
		g.beginBitmapFill(borderBmp, m, true, false);
		g.drawRect(px1, py1, borderBmp.width, sh);
		
		m.createBox(1, 1, 0, px2, py1);
		g.beginBitmapFill(borderBmp, m, true, false);
		g.drawRect(px2, py1, borderBmp.width, sh);
		
		m.createBox(1, 1, -Math.PI / 2, px1, py1);
		g.beginBitmapFill(borderBmp, m, true, false);
		g.drawRect(px1, py1, sw, borderBmp.width);
		
		m.createBox(1, 1, Math.PI / 2, px1, py2);
		g.beginBitmapFill(borderBmp, m, true, false);
		g.drawRect(px1, py2, sw, borderBmp.width);
		return border;
	}
	
	function drawMask() {
		var HIDE = 1000;
		var g = mask.graphics;
		var sea = m.sea;
		var px = sea.x * SIZE;
		var py = sea.y * SIZE;
		var sw = sea.w * SIZE;
		var sh = sea.h * SIZE;
		g.clear();
		var prev = (prevSea == null) ? null : prevSea.s;
		var pleft = (prev != null && prev.x + prev.w == sea.x);
		var pright = (prev != null && prev.x== sea.x + sea.w);
		var pup = (prev != null && prev.y + prev.h == sea.y);
		var pdown = (prev != null && prev.y == sea.y + sea.h);
		
		var col = borderBmp.getPixel(0, borderBmp.width - 1);
		g.beginFill(col);

		// 4 corners
		if( !(pleft || pup) )
			g.drawRect(px - HIDE, py - HIDE, HIDE, HIDE);
		if( !(pright || pup) )
			g.drawRect(px + sw, py - HIDE, HIDE, HIDE);
		if( !(pleft || pdown) )
			g.drawRect(px - HIDE, py + sh, HIDE, HIDE);
		if( !(pright || pdown) )
			g.drawRect(px + sw, py + sh, HIDE, HIDE);

		// 4 borders
		if( !pleft ) g.drawRect(px - HIDE, py, HIDE, sh);
		if( !pright ) g.drawRect(px + sw, py, HIDE, sh);
		if( !pup ) g.drawRect(px, py - HIDE, sw, HIDE);
		if( !pdown ) g.drawRect(px, py + sh, sw, HIDE);
			
		
		if( prev != null ) {
			var px2 = prev.x * SIZE;
			var py2 = prev.y * SIZE;
			var sw2 = prev.w * SIZE;
			var sh2 = prev.h * SIZE;
			if( pleft || pright ) {
				g.drawRect(px2, py2 - HIDE, sw2, HIDE);
				g.drawRect(px2, py2 + sh2, sw2, HIDE);
			}
			if( pup || pdown ) {
				g.drawRect(px2 - HIDE, py2, HIDE, sh2);
				g.drawRect(px2 + sw2, py2, HIDE, sh2);
			}
			g.beginFill(col, prevSea.fade);
			g.drawRect(px2, py2, sw2, sh2);
		}
		
		if( prevSea != null ) {
			g.beginFill(col, 1 - prevSea.fade);
			g.drawRect(px, py, sw, sh);
		}
	}
	
	function getRecifs( sea : MapSea, stbl : Array<Array<MapIsland>> ) {
		var r = [];
		var rnd = new mt.Rand(0);
		rnd.initSeed(sea.id);
		var i0 = sea.il.first();
		var ntry = 1000;
		for( i in 0...Std.int(sea.w * sea.h * 0.05) ) {
			var x, y;
			do {
				if( ntry-- < 0 ) break;
				x = rnd.random(sea.w - 2) + 1;
				y = rnd.random(sea.h - 2) + 1;
			} while( stbl[x][y] != null || stbl[x - 1][y] != null || stbl[x + 1][y] != null || stbl[x][y - 1] != null || stbl[x][y + 1] != null );
			if( ntry < 0 ) break;
			stbl[x][y] = i0;
			r.push( { x : x, y : y, k : rnd.random(1000) } );
		}
		return r;
	}
	
	function makeSeaTable( sea : MapSea ) {
		var stbl = [];
		for( x in 0...sea.w )
			stbl[x] = [];
		for( i in sea.il )
			for( x in i.x...i.x + i.w )
				for( y in i.y...i.y + i.h )
					stbl[x][y] = i;
		return stbl;
	}
	
	public function display( world : mt.DepthManager ) {

		bsky = new flash.display.Bitmap(sky.b);
		bsky.scaleX = bsky.scaleY = 4;
		world.add(bsky, PLAN_BG);
		
		scrolling = new mt.DepthManager(new flash.display.Sprite());
		world.add(scrolling.getMC(), PLAN_SCROLL);
		
		var me = this;
		for( s in getSeas() )
			scrolling.add(makeBorders(s), PLAN_BORDERS);
		
		var redraw = null, dist = 0, count = 0;
		for( s in getSeas() ) {
			for( i in getVisibleIslands(s) )
				if( islandView.get(i.id) == null ) {
					var dx = (i.x + s.x) - boat.px;
					var dy = (i.y + s.y) - boat.py;
					var d = dx * dx + dy * dy;
					if( redraw == null || d < dist ) {
						redraw = i;
						dist = d;
					}
					count++;
				}
		}
		if( count > 1 )
			haxe.Timer.delay(function() me.m.needRedraw = true, 1);
		
		var filters = new IslandGlow().getChildAt(0).filters;
			
		for( sea in getSeas() ) {
			var stbl = makeSeaTable(sea);
			for( i in getVisibleIslands(sea) ) {
				var b = islandView.get(i.id);
				if( b == null ) {
					if( i != redraw )
						continue;
					var d = new Drawer(i);
					var s = d.draw(false);
					b = new flash.display.BitmapData(i.w * SIZE + BMP_BORDER * 2, i.h * SIZE + BMP_BORDER * 2, true, 0);
					var m = new flash.geom.Matrix();
					m.identity();
					m.scale(1 / MAP_ZOOM, 1 / MAP_ZOOM);
					m.translate(BMP_BORDER, BMP_BORDER);
					b.draw(s, m);
					d.cleanup();
					for( f in filters )
						b.applyFilter(b, b.rect, new flash.geom.Point(0, 0), f);
					islandView.set(i.id, b);
					if( needRecal ) {
						needRecal = false;
						recalBoat();
					}
				}
				var bmp = new flash.display.Bitmap(b);
				var s = new flash.display.Sprite();
				s.onMove(function() me.highlight(s, i));
				s.onOver(function() me.highlight(s, i));
				s.onOut(function() me.highlight(null, null));
				if( m.admin )
					s.onClick(function() if( me.light != null ) me.debark(me.light.i));
				s.addChild(bmp);
				var state = new ui.IslandState();
				var frame = switch( i.e ) {
					case SEFree: 1;
					case SEExplored: 2;
					case SECompleted: 3;
				};
				state.gotoAndStop(frame);
				state.x = i.w * SIZE * 0.5 + BMP_BORDER;
				state.y = i.h * SIZE * 0.5 + BMP_BORDER;
				s.addChild(state);
				s.x = (i.x + sea.x) * SIZE - BMP_BORDER;
				s.y = (i.y + sea.y) * SIZE - BMP_BORDER;
				scrolling.add(s, PLAN_ISLAND);

				var r = b.getColorBoundsRect(0xFF000000, 0xFF000000);
				var t = new flash.text.TextField();
				var fmt = m.uiClip.place.defaultTextFormat;
				t.defaultTextFormat = fmt;
				t.multiline = true;
				t.wordWrap = true;
				t.mouseEnabled = false;
				t.width = Math.max(r.width,SIZE * ((stbl[i.x-1][i.y+i.h-1] == null && stbl[i.x+i.w][i.y+i.h-1] == null) ? 1.7 : 1));
				t.height = SIZE;
				t.text = i.name;
				t.x = s.x + r.x + (r.width - t.width) * 0.5;
				t.y = s.y + r.y + r.height;
				t.textColor = 0x202020;
				t.alpha = 0.7;
				scrolling.add(t, PLAN_ISLAND);
			}
			for( r in getRecifs(sea,stbl) ) {
				var t = new SeaElements();
				t.filters = filters;
				t.x = (sea.x + r.x + 0.5) * SIZE;
				t.y = (sea.y + r.y + 0.5) * SIZE;
				t.gotoAndStop(1 + (r.k % t.totalFrames));
				scrolling.add(t, PLAN_ISLAND);
			}
		}
		if( needRecal ) {
			needRecal = false;
			recalBoat();
		}
	
		mask = new flash.display.Sprite();
		scrolling.add(mask, PLAN_MASK);
		drawMask();

		
		// DEPTHS
		scrolling.add(front, PLAN_FX);
		scrolling.add(cursor, PLAN_FX);
		scrolling.add(fxUnder, PLAN_BOAT);
		for ( i in 0...fxCloudLayers.length ) {
			var lay = fxCloudLayers[i];
			scrolling.add(lay, PLAN_BOAT);
			if ( i == 2 ) {
				scrolling.add(boat.mc, PLAN_BOAT);
				scrolling.add(boat.target, PLAN_BOAT);
			}
		}
		scrolling.add(fxTop, PLAN_BOAT);
		
		
		scroll.px += 1000;
		updateScroll();
		if( light != null )
			highlight(light.s, light.i);
	}
		
	function highlight( s : flash.display.Sprite, i : MapIsland ) {
		if( m.admin )
			m.setAdminText((i == null) ? "" : "#"+i.id+" "+i.name + " " + i.w + " x " + i.h + " s = " + i.seed);
		if( light != null ) {
			light.s.filters = [];
			light = null;
			m.updatePlace();
		}
		if( s == null || islandView.get(i.id).getPixel32(Std.int(s.mouseX),Std.int(s.mouseY)) == 0 ) return;
		light = { s : s, i : i };
		s.filters = [new flash.filters.ColorMatrixFilter([1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1, 0 ])];
		//m.updatePlace(i.name);
	}
	
	public function click(mx, my) {
		if( m.needRedraw )
			return;
		if( boat.locked  ) {
			if( boat.targetIsland != null )
				action("cancel");
			return;
		}
		var i = (light == null) ? null : light.i;
		if( boat.targetIsland != null && boat.targetIsland != i )
			recalBoat();
		if( !drawPath(i, false) )
			return;
		var path = calcPath(mx, my);
		if( path != null )
			boat.setPath(path, i);
		else {
			if( needRecal ) {
				recalBoat(true);
			} else {
				recalBoat();
				needRecal = true;
				click(mx, my);
				needRecal = false;
			}
		}
	}
	
	function recalBoat( ?hole ) {
		drawPath(null, true);
		if( hole && (getIsland(boat.px, boat.py) == null || !path.fillHole()) )
			return;
		var p = path.getRecall(Std.int(boat.x) - scroll.ix, Std.int(boat.y) - scroll.iy);
		boat.x = p.x + scroll.ix;
		boat.y = p.y + scroll.iy;
		boat.setPath(null, null);
		m.updateTarget(boat.x / Const.BSIZE,boat.y / Const.BSIZE);
	}
	
	function drawPath(itarget,force) {
		path.reset();
		var recif = new SeaElements();
		for( s in getSeas() )
			for( r in getRecifs(s, makeSeaTable(s)) ) {
				recif.x = (s.x + r.x + 0.5) * SIZE - scroll.ix;
				recif.y = (s.y + r.y + 0.5) * SIZE - scroll.iy;
				recif.gotoAndStop(1 + (r.k % recif.totalFrames));
				path.draw(recif);
			}
		path.glow(8);
		for( s in getSeas() )
			for( i in getVisibleIslands(s) ) {
				if( i == itarget ) continue;
				var b = islandView.get(i.id);
				if( b == null ) {
					if( force ) continue;
					return false;
				}
				var bmp = new flash.display.Bitmap(b);
				var px = (i.x + m.sea.x) * SIZE - scroll.ix;
				var py = (i.y + m.sea.y) * SIZE - scroll.iy;
				bmp.x = px - BMP_BORDER;
				bmp.y = py - BMP_BORDER;
				path.draw(bmp);
			}
		return true;
	}
	
	function calcPath( mouseX : Float, mouseY : Float ) {
		var bx = Std.int(boat.x) - scroll.ix;
		var by = Std.int(boat.y) - scroll.iy;
		var mc = scrolling.getMC();
		var p = path.getPath(bx, by, Std.int(mc.mouseX) - scroll.ix, Std.int(mc.mouseY) - scroll.iy);
		if( p == null )
			return null;
		var path = [];
		while( p.length > 0 ) {
			var x = p.shift() + scroll.ix;
			var y = p.shift() + scroll.iy;
			path.push({ x : x, y : y });
		}
		return path;
	}
	
	function updateScroll() {
		var w = scroll.width;
		var h = scroll.height;
		var mc = scrolling.getMC();
		var p = 0.95;
		scroll.cx = scroll.cx * p + scroll.tx * (1 - p);
		scroll.cy = scroll.cy * p + scroll.ty * (1 - p);
		var x = Std.int( scroll.cx - w * 0.5 );
		var y = Std.int( scroll.cy - h * 0.5 );
		if( x != scroll.px || y != scroll.py ) {
			scroll.px = x;
			scroll.py = y;
			scroll.ix = x - (x & 1);
			scroll.iy = y - (y & 1);
			mc.x = -x;
			mc.y = -y;

			var vx = Math.floor(x / w);
			var vy = Math.floor(y / h);
			if( scroll.vx != vx || scroll.vy != vy ) {
				sky.update(vx * w / 4, vy * h / 4);
				scroll.vx = vx;
				scroll.vy = vy;
			}
			
			var mx = x % w; if( mx < 0 ) mx += w;
			var my = y % h; if( my < 0) my += h;
			bsky.x = -mx;
			bsky.y = -my;
			front.x = x;
			front.y = y;
			front.tex.x = -mx;
			front.tex.y = -my;
		}
	}
	
	function getIsland( px, py ) {
		px -= m.sea.x;
		py -= m.sea.y;
		for( i in m.sea.il )
			if( px >= i.x && py >= i.y && px < i.x + i.w && py < i.y + i.h )
				return i;
		return null;
	}
	
	function updateQMap( ?sea : Bool, ?island : Bool ) {
		var q : QuickMap = { seas : null, pts : null, px : Math.floor(boat.x / SIZE), py : Math.floor(boat.y / SIZE), cur : false };
		if( sea ) {
			var s = m.sea;
			var sea = { x : s.x, y : s.y, w : s.w, h : s.h, islands : null };
			if( island ) {
				var i = boat.targetIsland;
				sea.islands = [{ x : i.x, y : i.y, w : i.w, h : i.h }];
			}
			q.seas = [sea];
		}
		m.qmap._set.call([q]);
	}
	
	public function update() {
		boat.update(m.admin ? 3 : Main.DATA.boat.speed);
		m.updateTarget(boat.x / Const.BSIZE, boat.y / Const.BSIZE);

		var px = Math.floor(boat.x / SIZE);
		var py = Math.floor(boat.y / SIZE);
		var sea = m.sea;
		var out = false;
		if( px != boat.px || py != boat.py ) {
			if( px < sea.x || py < sea.y || px >= sea.x + sea.w || py >= sea.y + sea.h )
				out = true;
			else {
				boat.px = px;
				boat.py = py;
				m.needRedraw = true;
				m.updateLatLon(Math.floor(px / 3), Math.floor(py / 3));
				updateQMap();
			}
		}
		var border = 4;
		if( out && !boat.locked && (boat.x < sea.x * SIZE - border || boat.y < sea.y * SIZE - border || boat.x > (sea.x + sea.w) * SIZE + border || boat.y > (sea.y + sea.h) * SIZE + border) ) {
			boat.setPath(null, null);
			boat.locked = true;
			save = { px : px, py : py };
			m.command(ALoad(boat.x, boat.y, boat.movedDist));
		}
		if( boat.isMoving() && boat.targetIsland != null && getIsland(boat.px, boat.py) == boat.targetIsland ) {
			var i = boat.targetIsland;
			var bmp = islandView.get(i.id);
			if( bmp.getPixel32(Std.int(boat.x) - (i.x + sea.x) * SIZE, Std.int(boat.y) - (i.y + sea.y) * SIZE) != 0 ) {
				boat.setPath(null, i);
				boat.locked = true;
				m.command(ARequestDebark(i.id));
				updateQMap(true, true);
			}
		}
		if( !(boat.saving || boat.locked || out) && (boat.movedDist - boat.lastDist) > Const.FOOD_DIST / 3 ) {
			boat.saving = true;
			m.command(AMoveTo(boat.x, boat.y, boat.movedDist));
		}
		scroll.tx = boat.x;
		scroll.ty = boat.y;
		updateScroll();
		
		
		var mx = scrolling.getMC().mouseX;
		var my = scrolling.getMC().mouseY;
		cursor.x = mx + 14;
		cursor.y = my + 30;
		cursor.visible = mx < sea.x * SIZE || my < sea.y * SIZE || mx >= (sea.x + sea.w) * SIZE || my >= (sea.y + sea.h) * SIZE;
		
		if( prevSea != null ) {
			prevSea.fade += 0.1;
			if( prevSea.fade >= 1 ) {
				boat.locked = false;
				prevSea = null;
				m.displayInfos(m.sea.name);
			}
			drawMask();
		}
	}

	function popFood( n : Int ) {
		var p = new ui.Food();
		p.x = boat.mc.x + scrolling.getMC().x;
		p.y = boat.mc.y + scrolling.getMC().y;
		m.fx.add(p, 0);
	}
	
	public function result( r : Result ) {
		switch( r ) {
		case RMap(cur):
			m.curPos = cur;
			if( cur != null )
				m.transition();
		case RSea(s):
			if( s == null ) {
				boat.locked = false;
				s = m.sea;
				if( boat.x < s.x * SIZE ) boat.x = s.x * SIZE;
				if( boat.y < s.y * SIZE ) boat.y = s.y * SIZE;
				if( boat.x >= (s.x + s.w) * SIZE ) boat.x = (s.x + s.w) * SIZE - 1;
				if( boat.y >= (s.y + s.h) * SIZE ) boat.y = (s.y + s.h) * SIZE - 1;
				boat.setPath(null, null);
				return;
			}
			boat.px = save.px;
			boat.py = save.py;
			prevSea = { s : m.sea, fade : 0. };
			m.sea = s;
			m.display();
			updateQMap(true);
		case RMove(r):
			if( r != null ) {
				popFood(r.used);
				m.updateFood(r.food,r.max);
				boat.movedDist += r.dist;
			}
			boat.saving = false;
			boat.lastDist = boat.movedDist;
		default:
			throw "assert";
		}
	}
	
	function debark( i : MapIsland ) {
		m.clearActions();
		m.curIsland = i;
		m.px = boat.px;
		m.py = boat.py;
		m.boat = { x : boat.x, y : boat.y, move : boat.movedDist };
		m.command(ASelectIsland(boat.x, boat.y, boat.movedDist, i.id));
	}
	
	public function action(id) {
		switch(id) {
		case "potion":
			m.command(AUsePotion());
			return true;
		case "debark":
			if( !boat.locked ) return true;
			debark(boat.targetIsland);
		case "cancel":
			if( !boat.locked ) return true;
			m.clearActions();
			var oldx = boat.x, oldy = boat.y;
			recalBoat();
			var dx = boat.x - oldx;
			var dy = boat.y - oldy;
			var steps = Math.ceil(Math.sqrt(dx * dx + dy * dy));
			var path = [];
			for( i in 0...steps )
				path.push({ x : Std.int(oldx + dx * (i + 1) / steps), y : Std.int(oldy + dy * (i + 1) / steps) });
			boat.setPath(path, null);
			boat.target.visible = false;
			boat.locked = false;
			boat.x = oldx;
			boat.y = oldy;
		default:
			return false;
		}
		return true;
	}
	
	public function mouseMove() {
	}

//{
}






