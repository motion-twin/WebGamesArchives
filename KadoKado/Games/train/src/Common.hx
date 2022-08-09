/*
	+ nitro
	+ mec qui pique un train
	+ bonus par décor
	+ décors génériques

	FIX : ombre du perso détachée du perso de la gare
	FIX : objets sous la gare
*/

import mt.flash.Volatile;
import flash.MovieClip;

typedef Ob = {>flash.MovieClip,y:Float,hit1:flash.MovieClip,hit2:flash.MovieClip}
typedef DOb = {>Ob,d:Bool,smokoff:Bool,gem:Bool, piouz : Bool, tunnel : Bool};
typedef Idx = {>flash.MovieClip,idx:Int,x:Float,y:Float,d:Bool }
typedef Bmp = {>flash.MovieClip, bmp : flash.display.BitmapData, y : Float, disposed : Bool, tr : Bool, type : Int };

enum Dir {
	Up;
	Left;
	Right;
	Down;
	UpLeft;
	UpRight;
	DownLeft;
	DownRight;
}

class Const {
	public static var inc = 0;
	public static var DP_BG	 = ++inc;
	public static var DP_SHADOW	 = ++inc;
	public static var DP_DECOR	 = ++inc;
	public static var DP_FOOT	 = ++inc;
	public static var DP_RAIL = ++inc;
	public static var DP_LIMIT = ++inc;
	public static var DP_GEM = ++inc;
	public static var DP_MAN = ++inc;
	public static var DP_PIOUZ = ++inc;
//	public static var DP_OBJECTS = ++inc;
	public static var DP_LOCO = ++inc;
	public static var DP_SPARK = ++inc;
	public static var DP_SMOKE = ++inc;
	public static var DP_OBJECTS = ++inc;
	public static var DP_TUNNEL = ++inc;
	public static var DP_STATION = ++inc;
	public static var DP_PANNEAUX = ++inc;
	public static var DP_INTER = ++inc;

	public static var CENTER_X = 150;
	public static var HEIGHT = 300;
	public static var RAIL_H = 120;
	public static var LOCO_STARTPOS = 298;
	public static var LOCO_H = 147;
	public static var DEBUG = false;
	public static var TR = 100;
	public static var ADD_OBJECTS = 120;
	public static var OBJECTS = -150;
	public static var FRAME_RATE = 40;
	public static var BASE_SCORE = KKApi.const( 3 );
	public static var MAN_OUT = 30;

	public static var MAX_SPEED = 16.0 ; // == hauteur MC
	public static var SPEED  = 0.0;
	public static var SPEED_DIFF = 0.1;
	public static var SPEED_CYCLE = 20;
	public static var NEXT_SPEED  = 1.0;
	public static var STEP_SPEED  = 1;

	public static var SCENE_RANDOM = 20; // 4
	public static var SCENE_BASE = 30; // 15

	public static var STATION_HEIGHT = 177;
	public static var STATION_TRIGGER = 400;
	public static var STATION_BASE = 800;

	public static var MAN_SPEED = 3;

	public static var P1 = 800;
	public static var P2 = 650;
	public static var P3 = 350;

	public static var PIOUZ_RANDOM = KKApi.const( 200 ) ;
	public static var COAL_BASE = KKApi.const( 300 );
	public static var STATION_COAL = KKApi.const( 2 );
	public static var NEXT_STATION = KKApi.const( 5200 );
	public static var OPP_SPEED  = KKApi.const ( 5 );
	public static var OPP_CYCLE  = KKApi.const ( 5000 );
	public static var OPP_START = KKApi.const( 20000 );
	public static var OPP_POS = KKApi.const( 40 );

	public static var ADD_GEM = KKApi.const( 1500 );
	public static var ADD_GEM_F1 = KKApi.const( 1 );
	public static var ADD_GEM_F2 = KKApi.const( 2 );
	public static var ADD_GEM_F3 = KKApi.const( 3 );

	public static var DIRECTIONS = [{x:2,y:0},{x:-2,y:0},{x:0,y:2},{x:0,y:-2}, ];

	public static var Ea : mt.flash.PArray<Int> = cast [1,1,2,2,2,2,2,3,3,3,5,5,6,6,6];
	public static var Sa : mt.flash.PArray<Int> = cast [1,1,1,2,2,2,2,2,3,3,3,4];
//	public static var Ga : mt.flash.PArray<Int> = cast [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,4,4,5,6,6,6,6,6,6,7,8,8,8,8,8,8];
	public static var Ga : mt.flash.PArray<Int> = cast [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,4,4,6,6,6,6,6,6,8,8,8,8,8,8];
	public static var Gems : mt.flash.PArray<Int> = cast [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,3,3]; 

	public static var GEM1 = KKApi.const( 5000 );
	public static var GEM2 = KKApi.const( 8000 );
	public static var GEM3 = KKApi.const( 12000 );
	public static var PIOUZ = KKApi.const( 24000 );

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

	public static function hitRect( m1 : flash.MovieClip, m2 : flash.MovieClip ) {
		var r1 = getRectangle( m1 );
		var r2 = getRectangle( m2 );
		if( r2.intersects( r1 ) ) {
			return r2.intersection( r1 );
		}
		return null;
	}

	public static function getRectangle( mc : MovieClip ) {
		var b1 = mc.getBounds( Game.game.root );
		return new flash.geom.Rectangle( b1.xMin, b1.yMin, b1.xMax - b1.xMin, b1.yMax - b1.yMin );
	}
}
