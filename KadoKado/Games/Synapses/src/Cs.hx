
class Cs {//}

	public static var mcw = 300;
	public static var mch = 300;

	public static var CS = 40;
	public static var XMAX = 0;
	public static var YMAX = 0;


	public static var SCORE_CEL_BASE =  KKApi.const(50);
	public static var SCORE_CEL_MULTI = KKApi.const(25);

	public static var CEL_SPEED = 0.15;
	public static var CEL_MAX = 80;
	public static var CEL_AURA = 40;
	public static var CEL_COL = false;


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

	public static function isOut(x:Float,y:Float,m:Float){
		return x<m || x>mcw-m || y<m || y>mch-m ;
	}


//{
}











