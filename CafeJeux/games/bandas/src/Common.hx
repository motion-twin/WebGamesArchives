enum Msg {
	Init(team:Bool,a:Array<Array<Bool>>,c:Array<Int>);
	TakeCard(p:Int);
	UseCard(p:Int,x:Int,y:Int);
	Move(d:Direction);
	DoubleMove(d:Direction);
}

enum Team {
	Bananas;
	Orange;
}

enum Status {
	Free;
	Used;
	Destroy;
	Mined;
}

enum Direction {
	Up;
	Down;
	Left;
	Right;
}

typedef Pos = {
	x: Int,
	y: Int
}

class Const {
	public static var SIZE = 7;
	public static var START_FRUIT = SIZE * SIZE / 2;
	public static var START_CARD = 6;
	public static var RENFORT_FRUIT = 3;
	public static var CSIZE = 32;
	public static var BASEX = 16 + (300 - (SIZE * CSIZE)) / 2;
	public static var BASEY = 32 + 10;
	public static var PARTNUM = 30;
	
	public static var PLAN_BG = 0;
	public static var PLAN_PART = 1;
	public static var PLAN_BOARD = 2;
	public static var PLAN_FRUIT = 3;
	public static var PLAN_TARGET = 4;
	public static var PLAN_EFFECT = 5;
	public static var PLAN_CARD = 6;
	public static var PLAN_CONTROLS = 7;
	public static var PLAN_POWER = 8;
	public static var PLAN_VACHETTE = 9;
	public static var PLAN_CARD_DESC = 10;

	
}
