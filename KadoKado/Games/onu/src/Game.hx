import Common;
import KKApi;
import mt.bumdum.Plasma;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import mt.flash.PArray;
import mt.flash.Volatile;
import Anim;

typedef VV = {>EMC,top:Bool,speed:Float,sleep:Float,a:Float}
typedef Ship = {>EMC,r1:flash.MovieClip,r2:flash.MovieClip}

class Game {

	public var dm : mt.DepthManager;
	public var root : flash.MovieClip;
	public var gameOver : Bool;
	public var anim : PArray<Anim>;
	public var plasma : Plasma;
	public var plasmaPart : Array<mt.bumdum.Phys>;
	public var canon1 : Int;
	public var canon2 : Int;
	public var laser : Laser;

	var shipEnergy : Volatile<Int>;
	var canons1 : PArray<Canon>;
	var canons2 : PArray<Canon>;
	var canons1Count : Volatile<Int>;
	var canons2Count : Volatile<Int>;
	var bg : flash.MovieClip;
	var ship : Ship;
	var beware : Bool;

	var cycles : Volatile<Int>;
	var ball_speed_cycles : Volatile<Float>;
	var fire_cycles : Volatile<Float>;
	var replaceCycle : Volatile<Float>;
	var ship_cycle : Volatile<Float>;
	var shipIn : Bool;
	var g1 : Array<VV>;
	var g2 : Array<VV>;

	public var balls : PArray<Ball>;

	public static var signalSent = false;
	public static var game : Game;

	public function new( mc : flash.MovieClip ){
		root = mc;
		root.useHandCursor = false;
		dm = new mt.DepthManager(root);
		haxe.Firebug.redirectTraces();

		shipEnergy = KKApi.val(  Const.CAR_ENERGY );

		g1 = new Array();
		g2 = new Array();
		
		bg = dm.attach( "mcBg", Const.DP_BG );
		bg._x = Const.HEIGHT / 2;
		bg._y = Const.HEIGHT / 2;

		for( i in 0...6 ) {
			var o : VV = cast dm.attach( "mcOnde", Const.DP_BG );
			o._x = Const.HEIGHT;
			o.gotoAndStop( Std.random( o._totalframes ) + 1 );
			if( Std.random( 2 ) == 0 ) {
				o.y = o._y = -o._height;
				o.top = true;
			} else {
				o.y = o._y = Const.HEIGHT + o._height;
				o.top = false;
			}

			o._rotation = -180;
			o.speed = Std.random( 3 ) + 1;
			o.sleep = Std.random( 20 );
			o.a = Std.random( 180 );
			g2.push( o );
		}

		for( i in 0...6 ) {
			var o : VV = cast dm.attach( "mcOnde", Const.DP_BG );
			o.gotoAndStop( Std.random( o._totalframes ) + 1 );
			if( Std.random( 2 ) == 0 ) {
				o.y = o._y = -o._height;
				o.top = true;
			} else {
				o.y = o._y = Const.HEIGHT + o._height;
				o.top = false;
			}

			o.speed = Std.random( 3 ) + 1;
			o.sleep = Std.random( 20 );
			o.a = Std.random( 180 );
			g1.push( o );
		}

		for( i in 0...3 ) {
			var d = dm.attach( "mcDock", Const.DP_BG );
			d._y = d._height + i * d._height;
			d._x = Const.HEIGHT;
			d._rotation = -180;			
		}

		for( i in 0...3 ) {
			var d = dm.attach( "mcDock", Const.DP_BG );
			d._y = i * d._height;
		}

		anim = new PArray();
		canons1 = new PArray();
		canons2 = new PArray();
		canon1 = canon2 = -1;
		balls = new PArray();
		cycles = 0;
		replaceCycle = KKApi.val( Const.CANON_REPLACE_CYCLE );
		ball_speed_cycles = 0;
		fire_cycles = 0;
		ship_cycle = KKApi.val( Const.CAR_CYCLE ) * 1.8;
		game = this;

		plasma = new Plasma(dm.empty(Const.DP_BG),300,300,0.4);
		var fl = new flash.filters.BlurFilter();
		fl.blurY = 2;
		fl.blurX = 2;
		plasma.filters.push(fl);
		plasma.ct = new flash.geom.ColorTransform( 1,1,1,1,1,1,1,-50);
		plasma.root.blendMode = "lighten";
		plasmaPart = new Array();
		
		init();
	}

	public function init() {
		laser = new Laser(  this );

		for( i in 0...KKApi.val( Const.MAX_CANONS ) ) {
			canons1.push( null );
			canons2.push( null );
		}

		canons1Count = canons2Count = Const.CANONS;

		for( i in 0...Const.CANONS ) {
			var idx = getFreeIndex(canons1);
			var c = new Canon( this, idx * Const.CANON_SPACE + Const.CANON_STARTPOS, idx, KKApi.val( Const.SHIELD ) );
			canons1[idx] = c;
		}
		for( i in 0...Const.CANONS ) {
			var idx = getFreeIndex(canons2);
			var c = new Canon( this, idx * Const.CANON_SPACE + Const.CANON_STARTPOS, true, idx, KKApi.val( Const.SHIELD ));
			canons2[idx] = c;
		}

		initKeyListener();
		playStartAnim(  canons1 );
		playStartAnim(  canons2 );
	}

	function playStartAnim( l : PArray<Canon> ) {
		for( c in l ) {
			if( c == null ) continue;
			if( c.init ) continue;
			if( c.startAnim ) continue;
			c.startAnim = true;
			c.display();
			var a = new CanonIn( c );
			a.onEnd = c.prepare;
			anim.push( a );
		}
	}

	function getFreeIndex( a : PArray<Canon> ) : Int{
		if( a.length <= 0 ) return Std.random( KKApi.val( Const.MAX_CANONS ) );

		var s = new Array();
		for( i in 0...KKApi.val( Const.MAX_CANONS ) ){
			var c = a[i];
			if( c != null ) continue;
			s.push( i );
		}

		if( s.length <= 0 ) return null;

		return s[Std.random( s.length )];
	}

	public function update() {
		if( canons1.cheat ) KKApi.flagCheater();
		if( canons2.cheat ) KKApi.flagCheater();

		var tmod = mt.Timer.tmod;

		if( plasmaPart.length > 0 ){
			var pp = plasmaPart.copy();
			for( p in pp ) {
				if( p == null || p.root == null ) {
					plasmaPart.remove( p) ;
					continue;
				}
				plasma.drawMc( p.root, 2, 2 );
			}
		}

		if( Sprite.spriteList.length > 0 ){
			var l = Sprite.spriteList.copy();
			for( s in l ) {
				s.update();
			}
		}

		if( anim.length > 0 ){
			for( a in anim ){
				if( a.play() ){
					a.onEnd();
					a.clean();
					anim.remove( a );
				}
			}
		}
		
		laser.updatePos(root._xmouse);
		plasma.update();
		updateCanons(canons1);
		updateCanons(canons2);
		fire(canons1, getTarget( canons2 ) );
		fire(canons2, getTarget( canons1 ));
		moveBalls(tmod);
		addCanons(tmod);
		addShip(tmod);
		updateShip(tmod);
		updateVV(g1,tmod);
		updateVV(g2,tmod);
		testEnd();

		if( gameOver && !signalSent) {
			KKApi.gameOver({});
			signalSent = true;
		}	

		updateGameplay(tmod);
	}

	function updateGameplay(tmod : Float) {
		Ball.update( tmod );

		ball_speed_cycles -= tmod;
		if( ball_speed_cycles <= 0 ) {	
			Const.BALL_SPEED = KKApi.const( KKApi.val( Const.BALL_SPEED ) + KKApi.val( Const.BALL_SPEED_ADD ) );
			ball_speed_cycles = KKApi.val( Const.BALL_SPEED_CYCLE );
		}

		fire_cycles -= tmod;
		if( fire_cycles <= 0 ) {
			Const.FIRE_CYCLE = KKApi.const( KKApi.val( Const.FIRE_CYCLE ) - KKApi.val( Const.FIRE_CYCLE_MINUS ) );
			fire_cycles = KKApi.val(Const.FIRE_CYCLE);
		}
	}

	function updateVV(l : Array<VV>, tmod:Float) {
		for( o in l ) {

			o.a += tmod * 2;
			o._alpha = 40 * Math.sin( o.a * Math.PI / 180 );
			if( o.a > 180 ) o.a = 0;

			o.sleep -= tmod;
			if( o.sleep > 0 ) continue;

			o.y += ( if( o.top ) tmod else -tmod ) * 0.4 * o.speed;
			o._y = o.y;

			if( o.top && o.y > Const.HEIGHT ) {
				o.top = false;
			} else if( !o.top && o.y < 0 ) {
				o.top = false;
			}
		}
	}

	function addShip(tmod : Float) {
		if( gameOver ) return;
		if( shipIn ) return;

		ship_cycle -= tmod;
		if( ship_cycle <= 0 ) {
			beware = false;
			shipIn = true;
			ship = cast game.dm.attach( "mcCar", Const.DP_CANON );
			ship.gotoAndStop( Std.random( ship._totalframes ) + 1 );
			ship._x = Const.HEIGHT / 2;
			ship.y = ship._y = -ship._height;
			var c = KKApi.val( Const.CAR_CYCLE );
			ship_cycle = c / 2 + Std.random( c * 3 );
			var color = 0xFB04D6;
			var glow = new flash.filters.GradientGlowFilter( 0, 45, [color, color], [0, 1], [0, 255], 4, 4 , 1, 3, "outer" );
			ship.filters = [glow];
			return;
		}

		if( ship_cycle < 150 && !beware ) {
			beware = true;	
			var a = new Beware( this );
			anim.push( a );
		}
	}

	function updateShip( tmod : Float ) {
		if( gameOver ) return;
		if( !shipIn ) return;

		ship.y += tmod - ship._currentframe * 0.1;
		ship._y = ship.y;


		if( ship.r1 != null ) {
			reactorFx( ship._x + ship.r1._x, ship.y + ship.r1._y );
		}

		if( ship.r2 != null ) {
			reactorFx( ship._x + ship.r2._x, ship.y + ship.r2._y );
		}

		if( laser.hitCar( ship ) ){
			destroyShip();
			return;
		}

		if( ship._y > Const.HEIGHT ) {
			ship.removeMovieClip();
			ship = null;
			shipIn = false;
		}
	}

	function addCanons(tmod : Float) {
		if( gameOver ) return;

		var needC1 = canons1Count < KKApi.val( Const.MAX_CANONS ); 
		var needC2 = canons2Count < KKApi.val( Const.MAX_CANONS );
		var needAll = needC1 && needC2;
		if( !needC1 && !needC2 ) return;

		replaceCycle -= tmod;
		if( replaceCycle <= 0 ) {
			replaceCycle = KKApi.val( Const.CANON_REPLACE_CYCLE );

			if( needAll ) {
				if( Std.random( 2 ) ==  0 ) {
					addCanon( canons1 );
					playStartAnim(  canons1 );
					addCanon( canons2, true );
					playStartAnim(  canons2 );
				} else {
					addCanon( canons2, true );
					playStartAnim(  canons2 );
					addCanon( canons1 );
					playStartAnim(  canons1 );
				}
				return;
			} 

			if( needC2 ) {
				addCanon( canons2, true );
				playStartAnim(  canons2 );
				return;
			}

			addCanon( canons1 );
			playStartAnim(  canons1 );	
		}
	}

	function addCanon( l : PArray<Canon>, invert = false ) {
		var idx = 0;
		if( invert ) {
			if( canon2 >= 0) {
				var old = l[canon2];
				canon2 = -1;
				l[canon2] = null;
				idx = getFreeIndex( l );
				var c = new Canon( this, idx * Const.CANON_SPACE + Const.CANON_STARTPOS, invert, idx, old.shield );
				old.clean();
				l[idx] = c;
				return;
			} 

			idx = getFreeIndex( l );
			canons2Count++;

		} else {
			if( canon1 >= 0 ) {
				var old = l[canon1];
				canon1 = -1;
				l[canon1] = null;
				idx = getFreeIndex( l );
				var c = new Canon( this, idx * Const.CANON_SPACE + Const.CANON_STARTPOS, invert, idx, old.shield );
				old.clean();
				l[idx] = c;
				return;
			} 

			idx = getFreeIndex( l );
			canons1Count++;
		}

		var c = new Canon( this, idx * Const.CANON_SPACE + Const.CANON_STARTPOS, invert, idx);
		l[idx] = c;
	}

	function updateCanons( l : PArray<Canon> ) {
		if( gameOver ) return;
	
		for( c in l ) {
			c.update();
		}		
	}

	function fire( l : PArray<Canon>, target : Canon ) {		
		if( target == null ) return;

		for( c in l ) {
			if( c == null ) continue;
			if( !c.init ) continue;
			if( c.destroyed ) continue;
			c.initFire( target );
		}
	}

	function getTarget( l : PArray<Canon> ) {
		var a : Array<Canon> =  new Array();
		for( c in l ){
			if( !c.init ) continue;
			if( c == null ) continue;
			if( c.destroyed ) continue;
			a.push( c );
		}

		if( a.length <= 0 ) return null;

		var r = a[Std.random( a.length )];
		return r;
	}

	function moveBalls(tmod : Float ) {
		if( gameOver ) return;

		for( b in balls ) {
			b.move(tmod);

			if( shipIn ) {
				if( Const.hit( b.mc, ship.smc ) ) {
					destroyShip();
					b.destroy(0);
					balls.remove( b );
				}
			}

			if( laser.hit(b) ) {
				laser.hitAnim(b);

				var s = 0;

				if( b.bonus ) {
					KKApi.addScore( Const.BONUS_BALL );
					s = KKApi.val(Const.BONUS_BALL);
				}
				else {
					var ss = switch(b.type ) { case 0 : Const.BALL1; case 1 : Const.BALL2; case 2 : Const.BALL3; };
					KKApi.addScore( ss );
					s = KKApi.val(ss);
				}

				b.destroy(s);
				balls.remove( b );
				continue;
			}

			if( b.moveLeft && b.mc.x < Const.CANON_HIT_POS ) {
				for( c in canons1 ){
					if( !c.canBeTouched() ) continue;
					if( Const.hit( b.mc, c.mc ) ) {
						c.destroy();
						c.removeMe();
						var me = this;
						var a = new CanonOut( c );
						anim.push( a );
					}
				}
				continue;
			}

			if( !b.moveLeft && b.mc.x > Const.HEIGHT - Const.CANON_HIT_POS ) {
				for( c in canons2 ){
					if( !c.canBeTouched() ) continue;
					if( Const.hit( b.mc, c.mc ) ) {
						c.destroy();
						c.removeMe();
						var me = this;
						var a = new CanonOut( c );
						anim.push( a );
					}
				}
			}
		}
	}

	public function removeCanon( idx : Int, invert : Bool) {
		if( invert ) {
			var c = canons2[idx];
			c.clean();
			c = null;
			canons2[idx] = c;
			canons2Count--;
			return;
		}

		var c = canons1[idx];
		c.clean();
		c = null;
		canons1[idx] = c;
		canons1Count--;
	}

	function testEnd() {
		if( canons1Count <= 0 ) gameOver = true;
		if( canons2Count <= 0 ) gameOver = true;
	}

	function destroyShip() {
		shipEnergy--;

		if( shipEnergy > 0 ) {
			var ct = new flash.geom.ColorTransform();
			ct.rgb = 0xFFFFFF;
			ct.blueMultiplier = 0.3;
			ct.redMultiplier = 0.3;
			ct.greenMultiplier = 0.3;
			var t = new flash.geom.Transform( ship );
			t.colorTransform = ct;	
			return;
		}
	
		shipEnergy = 0;
		var p = new Phys( ship );
		p.timer = 10;

		for( i in 0...10 ) {
			for( i in 0...30 ) {
				var m = game.dm.attach( "mcCarPart", Const.DP_BALL );
				m._x = ship._x;
				m._y = ship._y + ship._height / 2;
				m._rotation = Std.random(360);
				var p = new Phys( m );
				p.vr = 1 + Std.random( 10 );
				p.timer = 30;
				var rad = m._rotation * Math.PI / 180;
				p.vx = Math.cos( rad ) * ( if( Std.random(2) == 0 ) 1  else -1 );
				p.vy = Math.sin( rad ) * ( if( Std.random(2) == 0 ) 1 else -1 );
				p.sleep = if( i >  0 ) i * 2;
				p.frict = 1.06;
				p.vsc = 1.05;
			}
		}

		gameOver = true;
	}

	public function initKeyListener() {
		root.onPress = laser.switchType;
		root.onRelease = laser.testPress;
	}

	public function reactorFx(x,y) {
		var m = game.dm.attach( "mcSmoke", Const.DP_BG );
		m._x = x;
		m._y = y;
		m._rotation = Std.random( 25 ) * if( Std.random( 2 ) == 0 ) -1 else 1;
		var rot = m._rotation;
		var p = new Phys( m );
		p.timer = 2 + Std.random(25);
		var rad = rot * Math.PI / 180;
		p.vx = Math.sin( rad ) * if( Std.random( 2 ) == 0 ) -Std.random( 100 )  / 100 else Std.random( 100 )  / 100; 
		p.vy = Math.sin( rad ) * -1;
		p.frict = 1.03;
		Filt.glow( p.root, 8, 1, Const.COLORS[0] );
	}

}
