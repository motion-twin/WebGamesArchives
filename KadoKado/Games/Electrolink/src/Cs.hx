import mt.bumdum.Sprite;
class Cs {
	
	//GAME SIZE
	public static var mcw = 300;
	public static var mch = 300;
		
	//TIME
	public static var PLAY_TIME = 120000 ; //2min
		
	public static var TIME_X = 48 ;
	public static var TIME_Y = 12 ;
	
	
	//BOARD
	static public var BOARD_WIDTH = 8 ;
	static public var BOARD_HEIGHT = 9 ;
		
	static public var BOARD_X = 60 ;
	static public var BOARD_Y = 45 ;
	
	static public  var TILE_SIZE = 25 ;
		
	static public var PARSE_IN = 0 ;
	static public var PARSE_OUT = 1;
	static public var PARSE_LIGHT = 3 ;
	
	static public var GRAVITY = 9.81 ;
	
	//DIRECTIONS
	public static var EAST 		= 0 ;
	public static var SOUTH 	= 1 ;
	public static var WEST		= 2 ;
	public static var NORTH	= 3 ;

	
	//CASES
	static public var TILE_0 = 0 ; // ligne
	static public var TILE_1 = 1 ; // coude
	static public var TILE_2 = 2 ; // T
	static public var TILE_3 = 3 ; // croix
	static public var TILE_4 = 4 ; // impasse
		
	static public var TEST_PARSING = [[2], [1, -1], [3, 2, 1], [3, 2, 1], []] ;
	
	
	//COLORS
	static public var BLUE 	= 0x2AB9D6 ;
	static public var GREEN = 0x87CC33 ;
	

	//POINTS
	public static var GOAL_POINTS = KKApi.const(250) ;
		
	public static var COMBO_MULT = [1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 9, 9] ;
	
	//public static var GOAL_POINTS = KKApi.aconst([500, 1000, 2500, 4500]) ;
	//public static var GOAL_COUNT = [3, 6, 8, 100] ;
	


}













