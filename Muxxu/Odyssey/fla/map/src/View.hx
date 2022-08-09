import Protocol;
using mt.flash.Event;
import mt.flash.Key;
private typedef K = flash.ui.Keyboard;

private typedef Place = {
	var p : IslandPoint;
	var idx : Int;
	var dist : Int;
	var next : Array<Place>;
}

class View {
	
	static var TEST_FIGHT = "";

	static inline var SCROLL = 10;
	static inline var SKYBORDER = 10;

	public static inline var PLAN_BG = 0;
	public static inline var PLAN_ISLAND = 1;
	public static inline var PLAN_HERO = 1;
	public static inline var PLAN_FX = 2;

	public var m : Main;
	public var lock : Bool;
	var targetScroll : { x : Int, y : Int };
	var drawer : Drawer;
	var islandBorders : flash.display.BitmapData;
	var scroll : { xMin : Int, yMin : Int, xMax : Int, yMax : Int };
	var clientSWF : flash.display.Sprite;
	var front : IslandRender;
	var sky : { x : Int, y : Int, s : Sky };
	var bsky : flash.display.Bitmap;
	var pathSign : String;
	var anim : ClearAnim;
	var uiGlow : Float;
	var hero : flash.display.MovieClip;
	var heroPath : Array<Place>;
	var heroMoved : Array<Int>;
	var bg : flash.display.Sprite;
	var cursor : fl.Clicked;
	var cursorLocked : flash.display.Sprite;
	var places : Array<Place>;
	public var island : flash.display.Sprite;

	public function new(m) {
		this.m = m;
		var stage = flash.Lib.current.stage;
		var width = stage.stageWidth;
		var height = stage.stageHeight;
		sky = { x : -100, y : -100, s : new Sky(SKYBORDER + (width >> 2), SKYBORDER + (height >> 2),Main.inst.curWind) };
		sky.s.zoom = 0.5;
		cursorLocked = new flash.display.Sprite();
		cursor = new fl.Clicked();
		cursor.stop();
		cursorLocked.addChild(cursor);
		cursorLocked.mouseEnabled = false;
		cursorLocked.mouseChildren = false;
		front = new IslandRender();
		hero = new fl.HeroMc();
		hero.gotoAndStop(1);
		initPlaces();
		haxe.Timer.delay(checkFlash, 2000);
	}
	
	function checkFlash() {
		if( places[m.curPos.pid].p.k == PTest && heroPath == null ) {
			new mt.fx.Flash(hero);
			haxe.Timer.delay(checkFlash, 2000);
		}
	}
	
	function initPlaces() {
		var i = m.curIsland;
		places = [];
		for( pt in i.pts )
			places.push( { p : pt, idx : places.length, dist : 0, next : [] } );
	}
	
	function updateDist() {
		for( p in places ) {
			p.dist = -1;
			p.next = [];
		}
		var p = 0;
		var segs = m.curIsland.segs;
		while( p < segs.length ) {
			if( !m.curPos.segs.get(Std.int(p / 3)) ) {
				p += 3;
				continue;
			}
			var i1 = segs.get(p++);
			var i2 = segs.get(p++);
			places[i1].next.push(places[i2]);
			places[i2].next.push(places[i1]);
			p++;
		}
		function rec(p:Place,d:Int) {
			if( p.dist >= 0 && p.dist < d ) return;
			p.dist = d;
			for( n in p.next ) {
				var dx = n.p.x - p.p.x;
				var dy = n.p.y - p.p.y;
				if( dx < 0 ) dx = -dx;
				if( dy < 0 ) dy = -dy;
				rec(n, d + dx + dy + 1);
			}
		}
		rec(places[m.curPos.pid], 0);
	}

	public function action(id:String) {
		if( lock ) return true;
		if( id == "do_fight" || id == "do_hunt" ) {
			m.clearActions(Main.DATA.texts.get("loading"));
			lock = true;
			var me = this;
			Fight.preload(function() {
				lock = false;
				me.m.clearActions();
				me.m.command(AAction(id.substr(3)));
			});
			return true;
		}
		if( id.substr(0,3) == "do_" ) {
			m.clearActions();
			m.command(AAction(id.substr(3)));
			return true;
		}
		switch( id ) {
		case "up": startMove(0, -1); return true;
		case "down": startMove(0, 1); return true;
		case "left": startMove( -1, 0); return true;
		case "right": startMove( 1, 0); return true;
		case "potion":
			m.command(AUsePotion());
			return true;
		}
		return false;
	}

	public function result( r : Result ) {
		switch( r ) {
		case RFight(fid, data):
			m.clearActions();
			#if !debug
			try {
			#end
			m.fight = new Fight(m, fid, data);
			#if !debug
			} catch( e : Dynamic ) {
				var phase = try untyped Fight.clientDomain.getDefinition(__unprotect__("Main")).PHASE catch( e : Dynamic ) -1;
				lock = true;
				m.onResult(RMessage("cancel", Main.DATA.texts.get("err_init_fight").split("::e::").join(Std.string(e))));
				m.command(ALogError(fid, data+" "+Std.string(e)+" phase="+phase));
			}
			#end
			m.transition();
		case RMap(m):
			onReload(m);
		case RHeal:
			for( i in 0...20 ) {
				var s = new flash.display.Sprite();
				var p = new mt.fx.Part(s);
				var a = Math.random() * Math.PI;
				var sp = 1 + Math.random() * 4;
				s.graphics.beginFill(0xDC3419, 0.8);
				s.graphics.drawCircle(0, 0, 3 - sp * 0.3);
				p.vy = -Math.sin(a) * sp;
				p.vx = Math.cos(a) * sp;
				p.frict = 0.95;
				p.timer = Std.random(30) + 30;
				p.fadeType = 1;
				p.x = 20;
				hero.addChild(p.root);
			}
		default:
			throw "assert";
		}
	}

	public function cleanup() {
		if( drawer != null ) {
			drawer.cleanup();
			drawer = null;
		}
		sky.s.b.dispose();
	}

	public function click(mx, my) {
	}

	public function display( world : mt.DepthManager ) {
		if( drawer != null ) {
			drawer.cleanup();
			drawer = null;
		}

		updateDist();
		
		bg = new flash.display.Sprite();
		var stage = flash.Lib.current.stage;
		bg.graphics.beginFill(0x9AB2B6);
		bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		world.add(bg, PLAN_BG);

		drawer = new Drawer(m.curIsland);
		drawer.pathBits = m.curPos.segs;
		drawer.placeBits = m.curPos.pts;
		if( pathSign == null )
			pathSign = haxe.Serializer.run(m.curPos.segs);
		island = drawer.draw(true);

		var bmp = drawer.getBitmap();
		var mat = new flash.geom.Matrix();
		mat.identity();
		mat.scale(0.25, 0.25);
		islandBorders = new flash.display.BitmapData(bmp.width >> 2, bmp.height >> 2, true, 0);
		islandBorders.draw(bmp, mat, new flash.geom.ColorTransform(0, 0, 0, 1));
		islandBorders.applyFilter(islandBorders, islandBorders.rect, new flash.geom.Point(0, 0), new flash.filters.ColorMatrixFilter(
			[1, 0, 0, 0, 0,
			 0, 1, 0, 0, 0,
			 0, 0, 1, 0, 0,
			 0, 0, 0, -1, 255]
		));
		islandBorders.applyFilter(islandBorders, islandBorders.rect, new flash.geom.Point(0, 0), new flash.filters.GlowFilter(0, 1, 15, 15, 3));
		islandBorders.applyFilter(islandBorders, islandBorders.rect, new flash.geom.Point(0, 0), new flash.filters.BlurFilter(5, 2, 2));

		world.add(island, PLAN_ISLAND);
		//world.add(front, PLAN_FX);

		bsky = new flash.display.Bitmap(sky.s.b);
		bsky.scaleX = bsky.scaleY = 4;
		world.add(bsky, PLAN_ISLAND);

		// make list of clickable places
		for( p in places ) {
			if( p.dist < 0 ) continue;
			for( n in p.next ) {
				if( n.idx < p.idx ) continue;
				var p1 = p.p, p2 = n.p;
				var x = p1.x < p2.x ? [p1.x, p2.x] : [p2.x, p1.x];
				var y = p1.y < p2.y ? [p1.y, p2.y] : [p2.y, p1.y];
				var mc = new flash.display.Sprite();
				var g = mc.graphics;
				g.beginFill(0,0);
				g.drawRect((x[0] + 1) * Drawer.SIZE, (y[0] + 1) * Drawer.SIZE, (x[1] - x[0] - 1) * Drawer.SIZE, (y[1] - y[0] - 1) * Drawer.SIZE);
				mc.mouseEnabled = true;
				mc.mouseChildren = true;
				mc.buttonMode = true;
				mc.addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(_) cursor.visible = true);
				mc.addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(_) cursor.visible = false);
				mc.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(_) moveTo(p,n));
				world.add(mc, PLAN_FX);
			}
		}
		for( p in places ) {
			if( p.dist < 0 ) continue;
			var mc = new flash.display.Sprite();
			var g = mc.graphics;
			g.beginFill(0, 0);
			g.drawCircle((p.p.x + 0.5) * Drawer.SIZE, (p.p.y + 0.5) * Drawer.SIZE - 5, Drawer.SIZE + 3);
			mc.mouseEnabled = true;
			mc.mouseChildren = true;
			mc.buttonMode = true;
			mc.addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(_) cursor.visible = true);
			mc.addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(_) cursor.visible = false);
			mc.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(_) moveTo(p,p));
			world.add(mc, PLAN_FX);
		}

		// place selection
		scroll = { xMin : 0, yMin : 0, xMax : 0, yMax : 0 };
		var curp = m.curIsland.pts[m.curPos.pid];
		hero.x = curp.x * Drawer.SIZE;
		hero.y = curp.y * Drawer.SIZE;
		world.add(hero, PLAN_HERO);

		cursor.visible = false;
		world.add(cursorLocked, PLAN_FX);

		// add margin
		var margin = Std.int(Drawer.SIZE * 1.5);
		scroll.xMin -= margin;
		scroll.yMin -= margin;
		scroll.xMax += margin;
		scroll.yMax += margin;

		// add half screen
		var stage = flash.Lib.current.stage;
		var w = stage.stageWidth >> 1;
		var h = (stage.stageHeight >> 1) - 30; // up/down bars
		scroll.xMin += w;
		scroll.yMin += h;
		scroll.xMax -= w;
		scroll.yMax -= h;

		// ensure minimals
		if( scroll.xMax < SCROLL ) scroll.xMax = SCROLL;
		if( scroll.yMax < SCROLL ) scroll.yMax = SCROLL;
		if( scroll.xMin > -SCROLL ) scroll.xMin = -SCROLL;
		if( scroll.yMin > -SCROLL ) scroll.yMin = -SCROLL;

		mouseMove();
	}

	function startMove( dx : Int, dy : Int ) {
		var i = m.curIsland;
		var pl = places[m.curPos.pid];
		for( n in pl.next ) {
			var t = n.p, p = pl.p;
			if( (dx != 0 && (t.x - p.x) * dx > 0) || (dy != 0 && (t.y - p.y) * dy > 0) ) {
				moveTo(n,n);
				break;
			}
		}
	}
	
	function moveTo( p1 : Place, p2 : Place ) {
		if( lock && heroPath == null )
			return;
		if( lock )
			updateDist();
		var p = p1.dist > p2.dist ? p1 : p2;
		if( p.dist == 0 && heroPath == null ) {
			m.js.flashActions.call([]);
			return;
		}
		var old = heroPath == null ? null : heroPath[0];
		heroPath = [];
		if( heroMoved == null )
			heroMoved = [];
		while( p.idx != m.curPos.pid ) {
			heroPath.unshift(p);
			var min = p.next[0];
			for( n in p.next )
				if( n.dist < min.dist )
					min = n;
			p = min;
		}
		// first, back to start point
		if( old != null && old != heroPath[0] )
			heroPath.unshift(places[m.curPos.pid]);
		if( cursor.visible ) {
			var canim = new fl.Clicked();
			canim.gotoAndStop(2);
			canim.x = cursor.x;
			canim.y = cursor.y;
			cursor.parent.addChild(canim);
		}
		cursorLocked.visible = false;
		lock = true;
		m.clearActions();
		hero.gotoAndStop(2);
	}

	function onReload( cur:MapCurrent ) {
		if( cur == null ) {
			m.curIsland = null;
			m.transition();
			return;
		}
		m.curPos = cur;
		for( i in m.sea.il )
			if( i.id == cur.iid ) {
				i.e = cur.e;
				break;
			}
		lock = false;
		var newSign = haxe.Serializer.run(cur.segs);
		var animate = pathSign != newSign;
		var w = m.world.getMC();
		var ox = w.x, oy = w.y;
		var animDrawer = null;
		if( anim != null ) {
			anim.cleanup();
			anim = null;
		}
		if( animate ) {
			animDrawer = this.drawer;
			this.drawer = null;
			this.pathSign = newSign;
		}
		m.display();
		// restore scroll
		setScroll(ox, oy);
		if( animate )
			anim = new ClearAnim(this, animDrawer);
	}

	function setScroll(x, y) {
		var mc = m.world.getMC();
		mc.x = x;
		mc.y = y;
		bg.x = front.x = -x;
		bg.y = front.y = -y;
		var stage = mc.stage;
		var w = stage.stageWidth;
		var h = stage.stageHeight;
		var mx = (-x) % w; if( mx < 0 ) mx += w;
		var my = (-y) % h; if( my < 0) my += h;
		front.tex.x = -mx;
		front.tex.y = -my;
		var sx = Math.floor( -x / 4 );
		var sy = Math.floor( -y / 4 );
		sx -= (sx + SKYBORDER * 1000) % SKYBORDER;
		sy -= (sy + SKYBORDER * 1000) % SKYBORDER;
		if( sx != sky.x || sy != sky.y ) {
			sky.x = sx;
			sky.y = sy;
			sky.s.setAlpha(islandBorders, sx, sy);
		}
		bsky.x = sx * 4;
		bsky.y = sy * 4;
	}

	public function mouseMove() {
		var stage = flash.Lib.current.stage;
		var i = m.curIsland;
		var width = stage.stageWidth;
		var height = stage.stageHeight - 35; // bottom bar
		var mx = stage.mouseX / width;
		var my = stage.mouseY / height;
		mx = (mx - 0.5) * 2; if( mx < -1 ) mx = -1 else if( mx > 1 ) mx = 1;
		my = (my - 0.5) * 2; if( my < -1 ) my = -1 else if( my > 1 ) my = 1;
		if( mx < 0 ) mx *= SCROLL;
		if( mx > 0 ) mx *= SCROLL;
		if( my < 0 ) my *= SCROLL;
		if( my > 0 ) my *= SCROLL;
		var px = Std.int(hero.x + mx) - (width>>1);
		var py = Std.int(hero.y + my) - (height>>1);
		if( targetScroll == null )
			setScroll( -px, -py );
		targetScroll = { x : -px, y : -py };
		var smc = m.world.getMC();
		cursor.x = smc.mouseX;
		cursor.y = smc.mouseY;
	}

	public function update() {
		if( anim != null && !anim.update() )
			anim = null;
		if( heroPath != null ) {
			var t = heroPath[0];
			var tx = t.p.x * Drawer.SIZE;
			var ty = t.p.y * Drawer.SIZE;
			var ds = 4., move = false;
			if( hero.x < tx ) {
				hero.x += ds;
				if( hero.x > tx ) hero.x = tx else move = true;
			}
			if( hero.x > tx ) {
				hero.x -= ds;
				if( hero.x < tx ) hero.x = tx else move = true;
			}
			if( hero.y < ty ) {
				hero.y += ds;
				if( hero.y > ty ) hero.y = ty else move = true;
			}
			if( hero.y > ty ) {
				hero.y -= ds;
				if( hero.y < ty ) hero.y = ty else move = true;
			}
			if( !move ) {
				heroPath.shift();
				heroMoved.push(t.idx);
				m.curPos.pid = t.idx;
				if( heroPath.length == 0 ) {
					hero.gotoAndStop(1);
					m.command(AMoveToPlaces(heroMoved));
					heroPath = null;
					heroMoved = null;
					cursorLocked.visible = true;
				}
			}
			mouseMove();
		}
		if( !lock && Main.DATA.adm && Key.isDown("F".code) ) {
			m.onResult(RFight(0, TEST_FIGHT));
			return;
		}
		/*
		if( !lock ) {
			if( Key.isDown(K.UP) )
				startMove(0,-1);
			else if( Key.isDown(K.DOWN) )
				startMove(0, 1);
			else if( Key.isDown(K.LEFT) )
				startMove( -1, 0);
			else if( Key.isDown(K.RIGHT) )
				startMove( 1, 0);
		}
		*/
		if( targetScroll != null ) {
			var mc = m.world.getMC();
			var dx = targetScroll.x - mc.x;
			var dy = targetScroll.y - mc.y;
			setScroll(mc.x + Math.ceil(dx * 0.15), mc.y + Math.ceil(dy * 0.15));
		}
		sky.s.update(sky.x,sky.y);
		/*
		if( Math.abs(dx) < 10 && Math.abs(dy) < 10 && m.curPos.html != null ) {
			m.setMenuHTML(m.curPos.html);
			m.curPos.html = null;
		}
		*/
	}
	
	public function popGold( n : Int, g : Int ) {
		var f = new fx.Gold(n, 2, function() {
			g++;
			m.uiClip.money.text = m.makeNum(g);
		});
		var mc = m.world.getMC();
		f.root.x = hero.x + mc.x + 10;
		f.root.y = hero.y + mc.y + 10;
		m.fx.add(f.root, 0);
	}
		

}