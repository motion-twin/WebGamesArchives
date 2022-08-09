import mt.flash.Volatile;
import flash.MovieClip;

typedef EMC = {>flash.MovieClip, y : Float, x : Float }

class Const {

	public static var inc = 0;
	public static var DP_BG = ++inc;
	public static var DP_BALL = ++inc;
	public static var DP_CANON = ++inc;

	public static var HEIGHT = 300;
	public static var CANONS = 1;
	public static var CANON_STARTPOS = 10;
	public static var CANON_WIDTH = 32;
	public static var CANON_HIT_POS = 40;

	public static var MAX_CANONS = KKApi.const( 12 );
	public static var CANON_SPACE = HEIGHT / KKApi.val( MAX_CANONS );

	public static var CANON_REPLACE_CYCLE = KKApi.const( 350 );
	public static var BALL_SPEED_CYCLE = KKApi.const ( 90 );
	public static var BALL_SPEED = KKApi.const ( 100 );
	public static var BALL_SPEED_ADD = KKApi.const ( 3 );
	public static var LASER_OFF = KKApi.const( 37 );
	public static var BALL1 = KKApi.const( 100 );
	public static var BALL2 = KKApi.const( 200 );
	public static var BALL3 = KKApi.const( 400 );
	public static var BONUS_BALL = KKApi.const( 800 );
	public static var BALL1_PROBA = KKApi.const( 5 );
	public static var BALL2_PROBA = KKApi.const( 40 );
	public static var BALL3_PROBA = KKApi.const( 5 );
	public static var BONUS_BALL_PROBA = KKApi.const( 5 );
	public static var FIRE_CYCLE = KKApi.const( 700 );
	public static var FIRE_CYCLE_MINUS = KKApi.const( 2 );
	public static var CAR_CYCLE = KKApi.const( 800 );
	public static var LEARN_CYCLE = KKApi.const( 1000 );
	public static var LEARN_STEP = KKApi.const( 0 );
	public static var SHIELD = KKApi.const( 2 );
	public static var CAR_ENERGY = KKApi.const( 2 );

	public static var COLORS = [0xFFFF66,0xFF66FF,0x33FFFF];

	public static function getMatrixFromMc( mc : MovieClip, tx = 0.0, ty = 0.0 ) {
		var m = new flash.geom.Matrix();
		m.translate( mc._x + tx, mc._y + ty);
		return m;
	}

	public static function hit( m1 : flash.MovieClip, m2 : flash.MovieClip ) {
		var r1 = getRectangle( m1 );
		var r2 = getRectangle( m2 );
		return r2.intersects( r1 );
	}

	public static function getRectangle( mc : MovieClip ) {
		var b1 = mc.getBounds( Game.game.root );
		return new flash.geom.Rectangle( b1.xMin, b1.yMin, b1.xMax - b1.xMin, b1.yMax - b1.yMin );
	}

}
