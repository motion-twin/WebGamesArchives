import mt.bumdum.Sprite;
class Cs {//}


	public static var BW = 21;
	public static var BH = 10;

	public static var DIR = [ [1,0],[0,1],[-1,0],[0,-1] ];
	public static var mcw = 300;
	public static var mch = 300;


	public static var SCORE_TUBE = KKApi.aconst([ 50,-50,0 ]);
	public static var SCORE_START = KKApi.const(2500);
	public static var SCORE_LEVEL = KKApi.const(1000);

	//public static var SCORE_GREEN = KKApi.const(50);
	//public static var SCORE_GREEN = KKApi.const(50);

	public static var SIDE = 7;



	// GAMEPLAY
	public static var COL_MAX = 3;
	public static var TUBE_SPEED = 0.35;

	public static var CHRONO_MAX = 1500;
	public static var CHRONO_BONUS = 250;



	// GFX


	//TOOLS
	public static function init(){

	}
	public static function getX(px:Float,py:Float){
		return 150 + (px-py)*BW;
	}
	public static function getY(px:Float,py:Float){
		return 125+(px+py)*BH;
	}


//{
}













