

class Cs {//}

	public static var mcw = 300;
	public static var mch = 300;

	public static var WW = 20.5;
	public static var HH = 18;

	public static var MX = 150;
	public static var MY = -26;

	public static var DIR = [[1,0],[1,1],[0,1],[-1,0],[-1,-1],[0,-1]];


	public static var SCORE_HEX  = 		KKApi.aconst([600,800,400]);
	public static var SCORE_ALLY =		KKApi.const(50);
	public static var SCORE_VICTORY = 	KKApi.const(3000);

	//public static var HEX_POP = 	KKApi.aconst([150,200,150]);

	inline public static function getX( px:Int, py:Int ){
		return MX + (px-py)*WW*1.5;
	}
	inline public static function getY( px:Int, py:Int ){
		return MY + (px+py)*HH;
	}



//{
}







