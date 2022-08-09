import mt.bumdum.Sprite;
class Cs {//}
	
	
	public static var BW = 28;
	public static var BH = 12;
	
	public static var DIR = [ [1,0],[0,1],[-1,0],[0,-1] ];
	public static var XMAX:Int;
	public static var YMAX:Int;
	public static var SIDE:Float;

	public static var mcw = 300;
	public static var mch = 300;
	
	public static var SCORE_BONUS = KKApi.aconst([ 250,1000,5000 ]);
	public static var SCORE_BLOCK = KKApi.const(50);
	public static var SCORE_BOUNCE = KKApi.const(5);
	public static var SCORE_ICE = KKApi.const(120);
	public static var SCORE_0 = KKApi.const(0);
	
	public static var MAX_BALL = 32;
	public static var MAX_OPTION = 6;
	
	public static var BALL_STANDARD =	0;
	public static var BALL_FIRE = 		1;
	public static var BALL_ICE = 		2;
	public static var BALL_DRUNK = 		3;
	public static var BALL_KAMIKAZE = 	4;
	public static var BALL_YOYO = 		5;
	public static var BALL_HALO = 		6;
	public static var BALL_SHADE = 		7;
	
	public static var PAD_STANDARD = 	0;
	public static var PAD_GLUE = 		1;
	public static var PAD_TIME = 		2;
	public static var PAD_LASER = 		3;
	public static var PAD_PROTECTION = 	4;
	public static var PAD_AIMANT = 		5;
	public static var PAD_SHAKE = 		6;
	
	
	// GAMEPLAY
	public static var TEMPO = 100;
	public static var DOOR_COEF = 0.25;
	public static var OPTION_COEF = 0.2;
	
	// GFX
	public static var PQ = 0.3;
	public static var SKIN = [
		{	back:0x888888,	br:55, rr:200, bg:55, rg:200, bb:55, rb:200 },
		{	back:0xAAAA22,	br:90, rr:140, bg:155,	rg:100,	bb:0, rb:50 }
	];
	
	//TOOLS
	public static function init(){
		XMAX = Std.int((mcw-10)/BW);
		YMAX = Std.int((mch-30)/BH);
		SIDE = (mcw - XMAX*BW)*0.5;
	}
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
		return Std.int(y/BW);
	}
	
	public static function getPerfCoef(){
		return Math.max(0,1-(Sprite.spriteList.length/120));
	}
	
	
//{
}













	