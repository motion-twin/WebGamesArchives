import mt.bumdum.Sprite ;

class Cs {
	
	//GAME SIZE
	public static var mcw = [0.0, 300.0] ;
	public static var mch = [20.0, 300.0] ;
		
	public static var LEADER_LIFE = 1 ;
	public static var FOLLOWERS_LIFE = 15 ;
		
	public static var FPS = 44 ;

	public static var repopArmyDelay = 15.0 ;
	public static var repopFollowDelay = 50.0 ;
		
	public static var HIDE_START = 30 ;
	public static var HIDE_END = 5 ;
	public static var MIN_DELTA_QUEUE = 5 ;
		
	public static var ARMY_MAX = 6 ;
	public static var GRAB_MAX = 2 ; 
		
	public static var DELTA_FOLLOW = 12.0 ;
	public static var MAX_LEADERTRACE = 50 ;
	
		
	public static var FOLLOW_POINTS = KKApi.const(800) ;
	public static var MIN_POINTS = KKApi.const(50) ;
		
	public static var TRACE_TIMER = 200 ;
	public static var TRACE_FADE = 50 ;
		
	public static var GRAB_SHIELD = 20 ;
		
	public static var FEVER_LOSE_PER_KILL = 3 ;
		
	
	
	public static function outOfBounds(x : Float, y : Float, ?d : Float = 0.0) : Bool {
		return x < mcw[0] + d || x > mcw[1] - d || y < mch[0] + d || y > mch[1] - d ;
	}
	
	
	public static function getDist(x : Float, y : Float, lastX : Float, lastY : Float) : Float {
		return Math.sqrt((x - lastX) * (x - lastX) + (y - lastY) * (y - lastY)) ;
	}
	
	public static function rotateMc(mc : flash.MovieClip, x : Float, y : Float, lx : Float, ly : Float, ?mr = 0.0) : Float  {
		var a = Math.acos(Cs.getDist(x, 0, lx, 0) / Cs.getDist(x, y, lx, ly)) ; 
		var dg = 180 * a / 3.14;
		var p = 0 ;
		if (x <= lx && y <= ly)
			dg = 0 + dg ;
		else if (x > lx && y <= ly)
			dg = 90 + (90 - dg) ;
		else if (x > lx && y > ly)
			dg = 180 + dg ;
		else if (x <= lx && y > ly)
			dg = 270 + (90 - dg) ;
		mc._rotation = dg + mr ;
		return mc._rotation ;
	}
	
	
	static public function randomProbs(t : Array<Int>) : Int {
		var n = 0 ;
		for(i in t)
		    n += i;
		n = Std.random(n) ;
		var i = 0 ;
		while( n >= t[i]) {
		    n -= t[i] ;
		    i++ ;
		}
		return i ;
	}
	
	
	static public  function elastic( pa:Float=1.0, p:Float) {
		return Math.pow(2, 10 * --p) * Math.cos(20 * p * Math.PI * pa / 3);
	}
	
	


}













