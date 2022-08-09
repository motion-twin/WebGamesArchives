import Protocol;

class Cs {//}


	public static var mcw = 300;
	public static var mch = 300;

	public static var CS = 32;
	public static var MX = 7.0;
	public static var MY = 0.0;
	public static var XMAX = 9;//6;
	public static var YMAX = 8;//8;

	public static var COLOR_MAX = 4;
	public static var COMBO_LIMIT = 4;

	//public static var SCORE_FRUIT = KKApi.aconst([500,250,100,50,25,1]);
	//public static var SCORE_FRUIT = KKApi.aconst([500,250,100,50,25,1]);
	//public static var SCORE_FRUIT = KKApi.aconst([1,25,50,100,250,500]);
	public static var SCORE_FRUIT =    KKApi.const(150);
	public static var SCORE_PERFECT =  KKApi.const(2500);

	public static var FRUIT_COLOR = [0xFF0000,0x88FF00,0xFF8800,0x4400FF];

	public static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];
	public static var CDIR = [[1,0],[0,1]];





	public static function init(){
		MX += CS*0.5;
		MY += CS*0.5;
	}

	inline public static function getPX( x:Float){
		return  Std.int((x-MX)/CS);
	}
	inline public static function getPY( y:Float ){
		return Std.int( ((Cs.mch-y)-MY)/CS );
	}

	inline public static function getX( x:Float){
		return MX + x*CS;
	}
	inline public static function getY( y:Float ){
		return MY + y*CS;
	}


	public static function isOut(px:Float,py:Float){
		return px<0 || px>=XMAX || py<0 || py>=YMAX;
	}

	public static function getScore(n){
		return KKApi.cmult( SCORE_FRUIT, KKApi.const(2*n-2) );
	}

//{
}











