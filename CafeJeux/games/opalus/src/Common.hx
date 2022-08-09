typedef Team = Bool

enum Msg {
	Init(c:Team,g:Array<Array<Int>>);
	Place(x:Int,y:Int);
	Extend(c:Int);
}

class Const {
	public static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];
	
	public static var SIZE = 20;
	public static var COLORS = 5;
	public static var CELL_SIZE = 15;

	public static var PLAN_TOKEN = 2;
	public static var PLAN_BLOB = 3;
	public static var PLAN_OVNI = 4;
	public static var PLAN_GLOW = 5;

	public static var GLOW_BAD_MOVE_COLOR = {r:185,g:1,b:1};
	public static var TOKEN_COLORS = [0x8568FD,0x8DC606,0x777777,0xFEC645,0xF7779E];
	public static var BLOB_COLORS =  [0x8568FD,0x8DC606,0x777777,0xFEC645,0xF7779E];
	public static var ALIEN_COLORS = [0x4A1FFA,0xDDFC94,0xA6A6A6,0xFFEDC4,0xFBBEA6];
}
