import Common;
import KKApi;
import Common;
import mt.bumdum.Plasma;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.flash.PArray;
import mt.flash.Volatile;
import flash.geom.ColorTransform;

class Game {

	public var dm : mt.DepthManager;
	public var root : flash.MovieClip;
	public var gameOver : Bool;
	public var coal : Volatile<Float>;
	public var me : Volatile<Float>;
	public var opp : Volatile<Float>;
	public var oppCycles : Volatile<Float>;

	public static var game = null;
	public static var signalSent = false;
	public static var startBoom = 0;

	public var scroll : Volatile<Float>;
	var cycles : Volatile<Int>;
	var anim : PArray<Anim>;

	public function new( mc : flash.MovieClip ){
		anim = new PArray();
		game = this;
		me = 0;
		opp = 0;
		coal = 0;
		oppCycles = 0;
		coal += ( KKApi.val( Const.NEXT_STATION ) + Const.LOCO_H * 3 ) * KKApi.val( Const.STATION_COAL );
		gameOver = false;
		cycles = 0;
		haxe.Firebug.redirectTraces();
		root = mc;
		dm = new mt.DepthManager(root);
		scroll = 1;

		Man.init(this);
		SceneManager.init( this );
		RailManager.init(this);
		Loco.init( this );
		Station.init( this );
		ObjectManager.init(this);
		Gem.init(this);
		Levier.init(this);
		initKeyListener();
	}

	public function update(){
		if( Const.Ea.cheat ) KKApi.flagCheater();
		if( Const.Sa.cheat ) KKApi.flagCheater();
		if( Const.Ga.cheat ) KKApi.flagCheater();
		if( Const.Gems.cheat ) KKApi.flagCheater();

		var tmod = mt.Timer.tmod;
		scroll = tmod * Const.SPEED;

		updateCoal();
		updateOpp( tmod );

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
			return;
		}

		if( gameOver && !signalSent) {
			KKApi.gameOver({});
			signalSent = true;
		}

		if( Loco.lockSpeed ) scroll *= 4;

		// SCROLL
		updateSpeed(tmod);
		Scroller.scroll( scroll );
		SceneManager.update( scroll );
		RailManager.scroll( scroll );
		Station.scroll( scroll );

		// MAN
		updateManMove();

		// NON-GRAPHICAL
		SceneManager.clean();
		ObjectManager.update(scroll);
		Station.update(scroll);
		RailManager.update( scroll );
		RailManager.clean();
		Scroller.clean();
		Gem.update(scroll);
		updateGameplay();
		Loco.update(scroll);
	}

	function updateCoal() {
		coal -= scroll;

		if( coal <= 0 && !gameOver ) {
			if( Const.SPEED <= 0 ) {
				gameOver = true;
				return;
			}
			Const.NEXT_SPEED = 0;
			Const.STEP_SPEED = 0;
			updateSpeedoMeter();
			Levier.noMoreCoal();
		}

		Levier.updateCoal();
	}

	public function addCoal() {
		if( gameOver ) return;

		var a = new CoalAnim( this );
		var me = this;
		a.onEnd = function() {
			me.coal += ( KKApi.val( Const.NEXT_STATION ) + Const.LOCO_H * 3 ) * KKApi.val( Const.STATION_COAL );
		}
		anim.push(a);
	}

	public function boom() {
		if( startBoom--<=0 ) return;

		for( i in 0...3 ) {
			var m = game.dm.attach( "mcDebris", Const.DP_RAIL );
			m._rotation = Std.random( 360 );
			m._y = Loco.mcBad._y - Const.LOCO_H;
			m._x = Const.CENTER_X + (if(Std.random( 2 ) == 0 ) -20 else 20 );
			m.gotoAndStop( Std.random( m._totalframes -1 ) + 1 );
			var p = new Phys( m );
			p.timer = 15;
			p.vy = 3 * mt.Timer.tmod;
			p.vr = Std.random( 2 ) * mt.Timer.tmod;
			p.weight = -( m._width / 20 );
			p.vx = if( Std.random(2) == 0 ) -Std.random( 10 ) else Std.random( 10 ) * mt.Timer.tmod;
			p.fadeType = 3;
		}
	}

	function updateOpp(tmod : Float) {
		me += tmod * Const.SPEED;
		opp += tmod * KKApi.val( Const.OPP_SPEED );
		Levier.updateOpp();
	}

	public function updateGameplay() {
		cycles += Std.int( scroll );
		oppCycles += scroll;

		if( gameOver ) return;
		if( cycles > Const.FRAME_RATE ) {
			KKApi.addScore( KKApi.const( Std.int( KKApi.val( Const.BASE_SCORE ) * Const.SPEED * 0.90 ) ) );
			cycles = 0;
		}

		if( oppCycles > KKApi.val(  Const.OPP_CYCLE ) ) {
			Const.OPP_SPEED = KKApi.const( KKApi.val( Const.OPP_SPEED ) + 1 );
			oppCycles = 0;
		}
	}

	public function incSpeed() {
		if( Const.NEXT_SPEED < Const.MAX_SPEED ) {
			Const.NEXT_SPEED = Math.pow( ++Const.STEP_SPEED, 2 );
		}
	}

	public function updateSpeed(tmod : Float) {
		if( Const.SPEED <= 0 && Const.STEP_SPEED <= 0 ) {
			Const.SPEED = 0.0;
			return;
		}

		var mv = Const.SPEED_DIFF * tmod;

		if( Const.SPEED != Const.NEXT_SPEED ) {
			if( Const.NEXT_SPEED > Const.SPEED ) {
				Const.SPEED += mv;
			}
			else if( Const.NEXT_SPEED < Const.SPEED) {
				if( Const.SPEED > Const.SPEED_DIFF ) {
					Const.SPEED -= mv;
				} else {
					Const.SPEED = 0.0;
				}
			}
			else {
				Const.SPEED = if( Const.SPEED < 0 ) 0 else Std.int( Const.SPEED );
			}
		}

		Levier.updateCounter();
	}

	public function updateManMove() {
		var kd = false;

		if( flash.Key.isDown( flash.Key.LEFT ) && !Man.outside  ) {
			if( Man.left() ) kd = true;
		}

		if( flash.Key.isDown( flash.Key.RIGHT ) && !Man.outside ) {
			if( Man.right() ) kd = true;
		}

		if( flash.Key.isDown( flash.Key.UP )
			|| flash.Key.isDown( flash.Key.DOWN )
			|| flash.Key.isDown( flash.Key.LEFT )
			|| flash.Key.isDown( flash.Key.RIGHT )
			)	{
			kd = true;
			Man.go();
		}

		if( Man.inLoco() && kd && !game.gameOver) {
			kd = false;
			Man.init(this);
			Loco.move = false;
			Levier.show();
			if( Const.SPEED <= 0 ) {
				Const.NEXT_SPEED = 1;
				Const.STEP_SPEED = 1;
			}
			unlockScroll();
		}

		Man.update();		
	}

	public function unlockScroll() {
		Scroller.lock = false;
		Scroller.hideObjects();
		ObjectManager.lock = false;
		SceneManager.lock = false;
		RailManager.lock = false;
		Station.lock = false;
	}

	public function stopScroll() {
		Levier.hide();
		Scroller.lock = true;
		Scroller.showObjects();
		ObjectManager.lock = true;
		SceneManager.lock = true;
		RailManager.lock = true;
		Loco.move = true;
		Station.lock = true;
		Man.show();
	}

	public function changeSpeed() {
		//if( lockSpeed ) return;

		var n = flash.Key.getCode();
		switch( n ) {
			case flash.Key.UP :
				incSpeed();

			case flash.Key.DOWN :
				if( Const.SPEED <= 0 ) return;
				if( Const.STEP_SPEED <= 0 ) return;
				Const.NEXT_SPEED = Math.max( 0, Math.pow( --Const.STEP_SPEED, 2 ) );
		}

		updateSpeedoMeter();
	}

	public function updateSpeedoMeter() {
		Levier.update(  Const.STEP_SPEED );
	}

	public function initKeyListener() {
		var kl = {
			onKeyDown:this.onKeyDown,
			onKeyUp:null,
		}
		flash.Key.addListener(kl);
	}

	public function onKeyDown() {
		if( coal <= 0 ) return;

		if( !Man.outside ) {
			changeSpeed();
			return;
		}
	}
}

interface Anim {
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public function play() : Bool;
	public function clean() : Void;
}

class CoalAnim implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;

	var game : Game;
	var mc : flash.MovieClip;
	var s : flash.MovieClip;
	var steps : Float;
	var armCycles : Float;
	var leftArm : Int;
	var left : Bool;
	var d : flash.filters.ColorMatrixFilter;

	static var Y = 1.0;
	static var X = 1.0;
	static var SPEED = 3.0;
	static var MAX = 32;
	static var ARMS_CYCLE = 5;

	public function new( game : Game ) {
		left = true;
		leftArm = 1;
		armCycles = ARMS_CYCLE;
		steps = 0.0;
		this.game = game;
		s = game.dm.attach( "ombre_pilote", Const.DP_MAN );
		s.blendMode = "multiply";
		mc = game.dm.attach( "mcPilote", Const.DP_MAN );
		s._y = mc._y = Station.station._y - ( Station.station._y - (Loco.mc._y - Const.LOCO_H ) ) / 2;
		s._x = mc._x = Station.station._x - Station.station._width / 2;
		mc.gotoAndStop( 10 );
		var r = Math.atan2( mc._y - ( Loco.mc._y + Const.LOCO_H / 2), mc._x - Loco.mc._x );
		X = Math.sin( r );
		Y = Math.cos( r );
		d = new flash.filters.ColorMatrixFilter([1.56,0,0,0,-90.16,0,1.56,0,0,-90.16,0,0,1.56,0,-90.16,0,0,0,1,0]);
	}

	public function play() {
		mc.filters = [d];
		if( armCycles-- <= 0 ) {
			if( left )
				mc.gotoAndStop( 10 + leftArm );
			else
				mc.gotoAndStop( 4 + leftArm );

			if( ++leftArm > 2 ){
				leftArm = 0;
			}
			armCycles = ARMS_CYCLE;
		}

		if( steps < MAX / 2 ) {
			s._x = mc._x += X * SPEED;
			s._y = mc._y += Y * SPEED;
		} else {
			left = false;
			s._x = mc._x -= X * SPEED;
			s._y = mc._y -= Y * SPEED;
		}

		if( steps++ > MAX ) {
			return true;
		}
		return false;
	}

	public function clean() {
		s.removeMovieClip();
		s = null;
		mc.removeMovieClip();
		mc = null;
	}
}
