
class Cs {//}

	public static var mcw = 300;
	public static var mch = 300;

	public static var SIDE = 6;
	public static var size = 36;

	public static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];

	public static var RAZOR_SPEED = 0.25;


	public static var SCORE_FRUIT_BASE = 	KKApi.const(200);
	public static var SCORE_FRUIT_INC = 	KKApi.const(50);
	public static var SCORE_PIOUPIOU = 	KKApi.const(1000);


	// GAMEPLAY
	public static var COL_MAX = 3;
	public static var POOL_MAX = 4;//4;

	public static inline function getX(x:Float){
		return (0.5+x-SIDE*0.5)*size ;
	}
	public static inline function getY(y:Float){
		return (0.5+y-SIDE*0.5)*size ;
	}



//{
}











