import mt.bumdum.Sprite ;
import Game.InCase ;

class Cs {
	
	//GAME SIZE
	public static var mcw = 300 ;
	public static var mch = 300 ;
		
	
	static public var GOAL_ROLL_UPWARD = 2 ;
	static public var GOAL_UP_LEVEL = 3 ;
	static public var GOLDEN_COIN = 8 ;
	static public var CASE_PER_LINE = 5 ;
	static public var INIT_LEVEL = 5 ;
	public static var ROLL_BOTTOM = 300 ; 
	static public var ROLL_LENGTH = 20 ;
	static public var ROLL_LINE_RECAL = 25 ;
	static public var UP_LIMIT = 19 ;
	static public var DOWN_LIMIT = 3 ;
	static public var ROLL_LINE_Y = 14.5 ;
	static public var ROLL_LINE_X = 50 ;
		
	static public var HOLE_X = 315.0 ;
	static public var GOAL_X = 298.0 ;
		
	static public var AROUND_CASE = [[[0, -1], [0, 1], [1, -1], [1, 1], [0, 2], [0, -2]],
								 [[-1, -1], [-1, 1], [0, -1], [0, 1], [0, 2], [0, -2]]] ;
	
	static public var INIT_COUNT = 2 ;
	
	static public var ROLL_VOID_INFOS = [[10.0, ROLL_BOTTOM - 22], //scale, y
							[35.0, ROLL_BOTTOM - 27],
							[55.0, ROLL_BOTTOM - 34.5],
							[75.0, ROLL_BOTTOM - 44.5],
							[100, ROLL_BOTTOM - 58]] ;
	
	
	static public function getAround(c : InCase) {
		if ((cast c.l.recal) > 0)
			return AROUND_CASE[0] ;
		else
			return AROUND_CASE[1] ;
	}
	
	
	public static var POINTS = KKApi.const(200) ;
	public static var GOAL_POINTS = KKApi.const(600) ;
	public static var MULTI_BONUS = KKApi.const(50) ;
	public static var GOLDEN_BONUS = KKApi.const(12000) ;

	
	public static function getDist(x : Float, y : Float, lastX : Float, lastY : Float) : Float {
		return Math.sqrt((x - lastX) * (x - lastX) + (y - lastY) * (y - lastY)) ;
	}
	
	public static function rotateMc(mc : flash.MovieClip, x : Float, y : Float, lx : Float, ly : Float) : Float  {
		var a = Math.acos(Cs.getDist(x, 0, lx, 0) / Cs.getDist(x, y, lx, ly)) ; 
		var dg = 180 * a / 3.14;
		var p = 0 ;
		if (x <= lx && y <= ly)
			dg = 270 + dg ;
		else if (x > lx && y <= ly)
			dg = 90 - dg ;
		else if (x > lx && y > ly)
			dg = 90 +  dg ;
		else if (x <= lx && y > ly)
			dg = 270 - dg ;
		
		var r = mc._rotation ;
		if (r < 0)
			r += 360 ;
		
		if (r > 270 && dg < 90)
			dg += 360 ;
		else if (r < 90 && dg > 270)
			r += 360 ;
		
	
		
		var p = Math.min((dg - r) / 5, 30) *  mt.Timer.tmod ;
		var g = Math.min(Math.abs(p), Math.abs(dg - r)) * (if (dg > r) 1 else - 1) ;
		
		/*if (flash.Key.isDown(flash.Key.SHIFT))
			trace(r + " # " + dg + " # " + p + " # " + g) ;*/
		
		mc._rotation = r + g ;
		return mc._rotation ;
	}
	

}













