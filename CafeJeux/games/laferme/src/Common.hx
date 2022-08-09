typedef Pos = {
	t : Bool,
	r : Bool,
	b : Bool,
	l : Bool,
	points : Int
}

typedef Point = {
	x : Int,
	y : Int
}

enum Msg {
	Init(g:Array<Array<Pos>>);
	UpdateCell( x : Int, y : Int, addedBorder : Pos );
}

class Const {

	public static var BOARD_SIZE = 6;
	public static var MARGIN = 25;

	public static var MAX_BLOCKS = BOARD_SIZE * BOARD_SIZE - 1;

	public static var WIDTH = 300;
	public static var MAX_SIZE = 12;
	public static var MIN_SIZE = 6;
	public static var CELL_SIZE = 40;
	public static var DP_BG =		0;
	public static var DP_GRASS = 	1;
	public static var DP_SQUARE = 	2;
	public static var DP_ANIMALS = 	3;
	public static var DP_SELECT = 	4;
	public static var DP_TREE = 	5;
	public static var DP_INVISIBLE =6;
	public static var WITHPOINTS = true;

	public static var COLOR1 = 0xF5CB23;
	public static var COLOR2 = 0xC66C31;
}
