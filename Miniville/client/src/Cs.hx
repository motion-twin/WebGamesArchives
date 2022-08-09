import mt.bumdum.Lib;

class Cs {//}



	public static var mcw = 600;
	public static var mch = 400;

	public static var WW = 24;
	public static var HH = 12;

	public static var CX = 0.0;
	public static var CY = 0.0;

	public static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];

	public static var SIDE = 30;//40;
	public static var SQUARE_SIDE = 10;
	public static var BMP_SIZE_MAX = 2000;

	//
	public static var ST_CHOMAGE = 		0;
	public static var ST_ROUTES = 		1;
	public static var ST_POLLUTION = 	2;
	public static var ST_CRIMINALITE = 	3;

	// PROBA
	public static var PROBA_SPECIAL = 500;

	public static var POP_HUGE = 	200;
	public static var POP_BIG = 	20;		// x4
	public static var POP_NORMAL = 	2;		// x4
	public static var POP_PEON = 	3;		// ALL




	public static function init(pop){


		CX = WW*SQUARE_SIDE * SIDE *0.5;
		CY = HH*0.5;
	}

	public static function getX(px:Float,py:Float){
		//px-=Game.me.displayMargin;
		//py-=Game.me.displayMargin;
		return CX + (px-py)*WW*0.5;
	}
	public static function getY(px:Float,py:Float){
		//px-=Game.me.displayMargin;
		//py-=Game.me.displayMargin;
		return CY + (px+py)*HH*0.5;
	}


//{
}
















