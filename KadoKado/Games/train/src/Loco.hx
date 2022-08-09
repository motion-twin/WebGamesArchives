import Common;
import mt.bumdum.Lib;
class Loco {

	static var up = false;
	static var smoke = true;
	static var game : Game = null;
	static var SMOKE_CYCLE = 20.0;
	static var smokeCycle = SMOKE_CYCLE;
	static var shadow : flash.MovieClip;
	static var crash = false;
	static var initCrash = false;
	static var fBad : flash.filters.ColorMatrixFilter;

	public static var lockSpeed = false;
	public static var move = false;
	public static var mc : flash.MovieClip;
	public static var mcBad : flash.MovieClip;

	public static function init(g) {
		game = g;
		shadow = game.dm.attach( "mc_ombre_train", Const.DP_LOCO );
		shadow._x = Const.CENTER_X;
		shadow._y = Const.LOCO_STARTPOS;
		shadow.blendMode = "multiply";

		mc = game.dm.attach( "mcLoco", Const.DP_LOCO );
		mc._x = Const.CENTER_X;
		mc._y = Const.LOCO_STARTPOS;
	}

	public static function update( scroll : Float) {
		if( crash ) {
			doCrash();
		}
		else {
			if( move ) moveUp() else moveDown( scroll );
		}

		if( flash.Key.isDown(flash.Key.SPACE) && !lockSpeed){
			fxSpark();
			Const.SPEED *= 0.98;
			Const.STEP_SPEED = 0;
			Const.NEXT_SPEED = 0;
			game.updateSpeedoMeter();
		}

		Scroller.hitPiouz( mc );

		smokeCycle -= scroll;
		while( smokeCycle <= 0 ) {
			var p = makeSmoke();
			smokeCycle += 15;
		}

	}

	static function moveUp() {
		lockSpeed = true;
		doMove(-Const.SPEED);
		if( mc._y < 0 ) {
			game.gameOver = true;
			return;
		}
	}

	public static function doCrash() {
		if( !initCrash ) {
			game.unlockScroll();
			mcBad = game.dm.attach( "mcLoco", Const.DP_LOCO );
			mcBad._x = Const.CENTER_X;
			mcBad._y = Const.LOCO_STARTPOS + Const.LOCO_H;
			mcBad.blendMode = "substract";
			fBad = new flash.filters.ColorMatrixFilter([1.56,0,0,0,90.16,0,1.56,0,0,-90.16,0,0,1.56,0,-90.16,0,0,0,1,0]);
			initCrash = true;
		}

		game.scroll += 1;
		Man.fly();

		mcBad.filters = [fBad];
		crash = true;
		if( mcBad._y > mc._y && !up) {
			if( mcBad._y - Const.LOCO_H <= mc._y ) {
				mc._y -= 5;
				Game.startBoom = 40;
			}
			mcBad._y -= 5;
		}

		if( mcBad._y < Const.HEIGHT - 10) {
			game.gameOver = true;
		}

		if( mcBad._y < Const.HEIGHT - 70) {
			smoke = false;
		}

		if( mcBad._y < Const.HEIGHT - Const.LOCO_H ) {
			Game.startBoom = 0;
		}
	}

	static function moveDown( scroll : Float ) {
		if( mc._y == Const.LOCO_STARTPOS ) {
			lockSpeed = false;
			return;
		}

		if( scroll >  0 ) {
			var v = scroll / ( Const.STEP_SPEED * 2 );
			var s = if( Const.STEP_SPEED <= 0 ) 1 else Const.STEP_SPEED;
			doMove( scroll / ( s * 2 ) );
		}

		if( mc._y > Const.LOCO_STARTPOS ) {
			mc._y = Const.LOCO_STARTPOS;
			game.unlockScroll();
			lockSpeed = false;
		}
	}

	static function doMove( v : Float ) {
		if( mc._y <  0 ){
			mc._y = 0;
		}
		shadow._y = mc._y += v;
	}


	public static function makeSmoke() {
		if( !smoke ) return;

		// EFFET DE FUMEE

		for( i in 0...2 ){

			var s = game.dm.attach( "mcSmoke", Const.DP_SMOKE );
			s.smc.smc.gotoAndStop(Std.random(6)+1);
			var p = new mt.bumdum.Phys( s );

			p.x = mc._x;
			p.y = mc._y - 136;

			if( i == 0 ){
				//p.root._visible = false;
				p.vy = Const.SPEED*0.25;
				p.y -= Const.SPEED*0.35;
				p.timer = 10;
				p.setScale(75);
			}else{
				p.timer = 35;
				p.fadeLimit = 20;
				p.vy = Const.SPEED;
				p.y -= 10;
				p.root._yscale = 100+Const.SPEED*10;
				p.y += Const.SPEED*2;

				p.x += Std.random(7)-3;
				p.y += Std.random(9)-4;

				var fl = new flash.filters.BlurFilter();
				fl.blurX = 0;
				fl.blurY = Const.SPEED;
				p.root.filters = [fl];
			}
			p.updatePos();

		}

	}

	static function fxSpark(){

		var ammount = Std.int(Const.SPEED*0.3);

		for( n in 0...ammount){
			for( i in 0...2 ){
				var sens = i*2-1;
				var p = new Spark( game.dm.attach( "fxSpark", Const.DP_SPARK ) );
				p.x = mc._x + sens*16;
				p.y = mc._y + Math.random()*10 -126;
				p.vx = sens*Math.random()*3;
				p.vy = Const.SPEED + Math.random()*3 - 1;
				p.timer = 10;

			}
		}
	}
}
