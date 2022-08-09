import mt.bumdum.Lib;
class Cs {//}

	public static var mcw = 300;
	public static var mch = 300;

	public static var lw = 2000;
	public static var lh = 450;



	public static var PMAX = 40;
	public static var PW = 40;
	public static var EC = 8;


	public static var CS = 30;
	public static var XMAX = 0;
	public static var YMAX = 0;

	// GAMEPLAY
	public static var LAND_SPEED_LIMIT = 1.5;
	public static var SHUTTLE_CAPACITY = 3;
	public static var BONUS_RARITY = 5;
	public static var SCORE_SHUTTLE = KKApi.const(1500);
	public static var SCORE_FOLK = KKApi.aconst([200,400,800,1200]);
	public static var SCORE_BOARD = KKApi.const(50);
	public static var SCORE_BOARD_BONUS = KKApi.const(10);
	public static var SCORE_LOOP = KKApi.const(250);
	public static var SCORE_PERFECT = KKApi.const(50);


	//
	public static var CONTROL_TYPE = 1;


	public static function init(){
		PMAX = Std.int(lw/PW);
		XMAX = Math.ceil(lw/CS);
		YMAX = Math.ceil(lh/CS);
	}




	inline public static function getPX( x:Float){
		//x = Num.sMod(x,Cs.lw);
		return Std.int(x/CS);
	}
	inline public static function getPY( y:Float ){
		return Std.int(y/CS);

	}



//{
}











