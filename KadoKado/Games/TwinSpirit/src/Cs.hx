import Protocol;

class Cs {//}

	public static var mcw = 300;
	public static var mch = 300;

	public static var CS = 30;
	public static var XMAX = 0;
	public static var YMAX = 0;


	public static var CLOUD_FADE_PRC = 25;
	public static var CLOUD_FADE_COLOR = 0xE6711A;

	public static var SCORE_ROBERT = KKApi.const(5000);

	public static var DIR = [[1,0],[1,1],[0,1],[-1,0],[-1,-1],[0,-1]];


	public static function init(){
		XMAX = Math.ceil(mcw/CS);
		YMAX = Math.ceil(mch/CS);
	}

	inline public static function getPX( x:Float){
		return Std.int(x/CS);
	}
	inline public static function getPY( y:Float ){
		return Std.int(y/CS);

	}

	public static function getScore(bf){
		switch(bf){
			case DRONE : 		return KKApi.const(50);
			case KOBOLD : 		return KKApi.const(100);
			case SUPER_DRONE : 	return KKApi.const(100);
			case SENTINELLE : 	return KKApi.const(250);
			case ZILA : 		return KKApi.const(1500);
			case ASSASSIN : 	return KKApi.const(500);
			case VOLT_BALL : 	return KKApi.const(1500);
			case BEHEMOTH : 	return KKApi.const(3000);
		}
	}


	public static function isOut(x:Float,y:Float,m:Float,?my:Float){
		if(my==null)my==0;

		return x<m || x>mcw-m || y<m || y>mch-(m+my) ;
	}


//{
}











