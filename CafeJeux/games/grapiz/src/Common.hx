enum Msg {
	Init(c:Bool);
	Move(fx:Int,fy:Int,tx:Int,ty:Int);
}

enum Direction {
	North;
	South;
	NorthWest;
	NorthEast;
	SouthWest;
	SouthEast;
}

class Const {
	public static var RADIUS = 5;
	public static var START_BLUE = [[0,0],[0,3],[1,5],[3,0],[5,1],[8,4],[4,8],[8,7],[7,8]];
	public static var START_RED = [[0,1],[1,0],[0,4],[4,0],[3,7],[5,8],[7,3],[8,5],[8,8]];

	public static var PLAN_BLOW = 1;
	public static var PLAN_TOKEN = 2;
	public static var PLAN_GLOW = 3;
	public static var PLAN_FLYING = 4;

	public static var COLOR_BLUE = 0x0ce48d;
	public static var COLOR_RED = 0xe9be16;
}
