import mt.bumdum.Sprite ;
import Game.Pos ;

class Cs {
	
	//GAME SIZE
	public static var mcw = 300 ;
	public static var mch = 300 ;
	
	//TIME
	public static var PLAY_TIME = 15000 ;
	
	
	//BOARD
	static public var BOARD_WIDTH = 6 ;
	static public var BOARD_HEIGHT = 6 ;
		
	static public var BOARD_X = 30 ;
	static public var BOARD_Y = 10 ;
		
	static public var BOARD_X_LIMIT = 30 ;
	static public var BOARD_Y_LIMIT = 10 ;
		
	static public var ZONE_SIZE = 40 ;
		
	static public var ALPHA_SCORE = 70 ;
	
	static public var ALPHA_SLIME = 100 ;
	static public var SCALE_SLIME = [50, 80, 100, 120] ;
	
		
	
	static public function getPos(pos : Pos, ?middle : Bool) {
		var m = if (middle) ZONE_SIZE / 2 else 0 ;
		return {x : Cs.BOARD_X + pos.x * Cs.ZONE_SIZE + m, y : Cs.BOARD_Y + pos.y * Cs.ZONE_SIZE + m} ;
	}
	
	public static var BONUS_COLOR = 0xFDDE02 ;
		
	
	//PLAYS
	public static var INIT_PLAYS = 11 ;
	public static var MAX_PLAYS = 18 ;
	public static var INIT_MEGA_PLAYS = 2 ;
	public static var MAX_MEGA_PLAYS = 4 ;

	public static var PLAYS_X = 15 ;
	public static var PLAYS_Y = 272 ;
	
	public static var BONUS_PLAYS = 6 ;
	
	//DIR
	static public var dir = [[1, 0], [0, 1], [-1, 0], [0, -1]] ;
	static public var EAST = 0 ;
	static public var SOUTH = 1 ;
	static public var WEST = 2 ;
	static public var NORTH = 3 ;

	
	//POINTS
	public static var SPOUT_POINTS = KKApi.const(250) ;
	public static var SPOUT_CHAIN = KKApi.const(10) ;
	public static var BONUS_LEVEL = KKApi.const(2000) ;
		
	public static var WIN_PLAYS = [3, 8, 15, 24, 35, 45, 60] ;


}













