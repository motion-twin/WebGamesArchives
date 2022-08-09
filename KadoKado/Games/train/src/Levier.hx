import mt.flash.Volatile;
import Common;

typedef L = {>flash.MovieClip,m:flash.MovieClip,c:flash.MovieClip,p:flash.MovieClip,f:flash.MovieClip}

class Levier {

	static var mc : L;
	static var game : Game;
	static var curSpeed = 0; 
	static var speed = 0.0;
	static var pStartPos = 0.0;
	static var diff : Volatile<Float> = 0.0;

	public static function init( g ) {
		game = g;
		mc = cast game.dm.attach("mcLevier", Const.DP_INTER );
		mc._x = 5;
		mc._y = 220;
		mc.m.gotoAndStop( mc.m._totalframes -1 );
		mc.c.gotoAndStop( 3 );
		pStartPos = mc.p._y;
		updateCounter();
		diff = KKApi.val( Const.OPP_POS );
	}

	public static function updateOpp() {
		if( Game.startBoom > 0) {
			game.boom();
		}

		if( game.gameOver ) return;

		if( game.opp > game.me ) {
			var diff = game.opp - game.me;
			var dist = KKApi.val(  Const.OPP_START ) - diff;
			var pcd = 100 - dist / KKApi.val(  Const.OPP_START )  * 100;
			var v = pStartPos - KKApi.val( Const.OPP_POS ) * pcd / 100;
			mc.p._y = v;
			
			if( v <= pStartPos - KKApi.val( Const.OPP_POS ) ){
				mc.p._y = pStartPos - KKApi.val( Const.OPP_POS );
				Man.lock = true;
				Loco.doCrash();
				return;
			}

			if( v >= pStartPos ) {
				mc.p._y = pStartPos;
				game.opp = game.me = 0;
			}
		} 
	}

	public static function updateCoal() {
		mc.c.gotoAndStop( Math.floor( game.coal / KKApi.val( Const.NEXT_STATION ) )  + 1 );
	}

	public static function updateCounter() {
		if( Const.SPEED <= 0 ) {
			mc.f._rotation = -90;
			return;
		}

		var s = Math.floor( Const.SPEED * 10 );
		var cs = s / Const.MAX_SPEED * 10;
		var a = -90 + Std.int( 180 * cs / 100 );
		mc.f._rotation = a;
		mc.f._x = mc.c._x - 8;
		mc.f._y = mc.c._y;
	}

	public static function update( speed : Int ) {
		if( speed == curSpeed ) return;

		if( speed < mc.m._totalframes ) {
			mc.m.gotoAndStop( 5 - speed );
		}
		curSpeed = speed;
	}

	public static function hide() {
		mc._visible = false;
	}

	public static function show() {
		mc._visible = true;
	}

	public static function noMoreCoal() {
		mc.c.gotoAndStop( 5 );
	}
	
}
