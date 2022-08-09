import Protocol;

class Cs {//}


	public static var mcw = 300;
	public static var mch = 300;

	public static var CS = 40;
	public static var MX = 50.0;
	public static var MY = 50.0;
	public static var XMAX = 5;//6;
	public static var YMAX = 5;//8;

	public static var COLOR_MAX = 4;
	public static var COMBO_LIMIT = 4;

	public static var DIR = [[0,1],[1,0],[-1,0],[0,-1]];
	public static var CDIR = [[1,0],[0,1]];

	//public static var SCORE_STEP = KKApi.aconst([50,75,100]);
	//public static var SCORE_BALL = KKApi.aconst([50,50,50,50,75,100,150,200,300,400,500]);
	public static var SCORE_BALL = KKApi.aconst([100,100,100,100,150,200,300,400,500,600,800,1000]);

	public static var COLOR_LIST = [0xFF0000,0x00CC00,0x5555FF,0xCC8800,0xCCCC00,0xFF00FF,0x8800FF,0x00BBBB,0x448800,0x882200];



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
		return Cs.mch - (MY+y*CS);
	}

//{
}











