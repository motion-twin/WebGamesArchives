class Cs {//}
	public static var mcw = 300;
	public static var mch = 300;
	public static var ec = 0.0185;
	public static var bray = 12;

	public static var COEF_START = 	1.15;
	public static var COEF_END = 	0.03;

	public static var SCORE_BALL = KKApi.const(150);
	public static var SCORE_BLACK = KKApi.const(500);

	// GAMEPLAY
	public static var COMBO_LIMIT = 3;
	public static var START_CHAIN_LENGTH = 1;//32;//38;
	public static var SPEED_START= 	0.0003;
	#if prod
	public static var SPEED_INC= 	0.00000026;
	#else
	public static var SPEED_INC = 0.0;
	#end
	public static var CADENCE = 		8;
	public static var LAUNCH_SPEED = 	8;

	public static var COLORS = 	[0xCB2F18,0xBD9D16,0x3D769E,0x6B912E];
	public static var COLORS_DARK = [0x981F12,0x9D6805,0x1E4D6A,0x63741D];

	public static var GXMAX = 0;
	public static var GYMAX = 0;

	public static var SPX = 145;
	public static var SPY = 125;

	public static function init(){
		GXMAX = Math.ceil(mcw/(bray*2));
		GYMAX = Math.ceil(mch/(bray*2));
	}

	public static function getPos(cc:Float){
		var c = Math.min(cc,1);
		var a = Math.pow(c,0.65) * 14;
		var dist = 	20+Math.pow(c,0.44) * 120;
		var p = {
			x: mcw*0.5 + Math.cos(a)*dist 	-10,
			y: mch*0.5 + Math.sin(a)*dist	-8,
			a: a,
		}
		if(cc>1){
			p.x -= bray*2*(cc-1)/ec;
		}
		return p;
	}

	public static inline function getPX(x:Float){
		return Std.int( x/ (bray*2) );
	}

	public static inline function getPY(y:Float){
		return Std.int( y/ (bray*2) );
	}

	public static function isOut(x:Float,y:Float,m:Float){
		return x-m < 0 || x+m > Cs.mcw || y-m < 0 || y+m > Cs.mch;
	}
//{
}











