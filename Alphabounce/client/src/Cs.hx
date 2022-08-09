import mt.bumdum.Sprite;
import mt.bumdum.Lib;

typedef Info = {
	_x:Int,
	_y:Int,

	_chl:Int,
	_chs:Int,
	_minerai:Int,
	_mission:Int,

	_motor:Int,
	_droneMine:Int,
	_droneFight:Int,
	_droneCollector:Int,

	_fog:Array<Int>,
	_items:Array<Int>
}


class Cs {//}


	//public static var ADMIN = false;
	public static var DEMO = false;

	public static var BW = 28;
	public static var BH = 14;

	public static var DIR = [ [1,0],[0,1],[-1,0],[0,-1] ];
	public static var MX = 0;
	public static var MY = 0;
	public static var XMAX:Int;
	public static var YMAX:Int;
	public static var SIDE:Float;

	public static var PREF_MOUSE:Float;
	public static var PREF_GFX:Float;
	public static var PREF_BOOLS:Array<Bool>;

	public static var mcw = 400;
	public static var mch = 360;

	public static var pi:PlayerInfo;
	public static var seed:Int;

	//
	public static var COL_SPACE = 0x000050;

	//
	public static var MAX_BALL = 18;
	public static var MAX_OPTION = 6;

	public static var BALL_STANDARD =	0;
	public static var BALL_FIRE = 		1;
	public static var BALL_ICE = 		2;
	public static var BALL_DRUNK = 		3;
	public static var BALL_KAMIKAZE = 	4;
	public static var BALL_YOYO = 		5;
	public static var BALL_HALO = 		6;
	public static var BALL_SHADE = 		7;
	public static var BALL_VOLT = 		8;

	public static var PAD_STANDARD = 	0;
	public static var PAD_GLUE = 		1;
	public static var PAD_TIME = 		2;
	public static var PAD_LASER = 		3;
	public static var PAD_GENERATOR =	4;
	public static var PAD_AIMANT = 		5;

	public static var PAD_SHAKE = 		6;

	// GAMEPLAY
	public static var TEMPO = 120;
	public static var DOOR_COEF = 0.25;
	public static var OPTION_COEF = 0.1;//0.2;



	// GFX
	public static var PQ = 0.3;

	public static function init(){


		XMAX = Std.int(mcw/BW);
		YMAX = Std.int((mch-30)/BH);
		SIDE = (mcw - XMAX*BW)*0.5;
		seed = Std.random(564351);

		// CHECK PREF
		var so = flash.SharedObject.getLocal("pref");
		if( so.data.mouse == null ){
			so.data.mouse = 	0.2;
			so.data.gfx = 		1;
			so.flush();
		}
		if( so.data.bools == null ){	// POUR NE PAS EFFACER LES PARAMS DES VERSIONS ANTERIEURES.
			so.data.bools =		[false,true,true,false];
		}

		loadPref();

	}

	public static function loadPref(){
		var so = flash.SharedObject.getLocal("pref");
		PREF_MOUSE = so.data.mouse;
		PREF_GFX = so.data.gfx;
		PREF_BOOLS = so.data.bools;
	}

	//TOOLS
	public static function getX(px:Float){
		return SIDE + px*BW;
	}
	public static function getY(py:Float){
		return py*BH;
	}

	public static function getPX(x:Float){
		return Std.int((x-SIDE)/BW);
	}
	public static function getPY(y:Float){
		return Std.int(y/BH);
	}

	public static function getPerfCoef(){
		return Math.max(0,1-(Sprite.spriteList.length/120));
	}

	//
	public static function getDir(n){
		return Std.int( Num.sMod(n,4) );
	}

	//
	public static function log(str){
		Manager.log(str);
	}



//{
}













