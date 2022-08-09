class Config {
	public static var SQ = 300;
	public static var W = 300;
	public static var H = 300;

	public static var CIRCLE_DARK : UInt = 0x404040;
	public static var CIRCLE_DARK_VISITED : UInt = 0x517A51;

	public static var CIRCLE_LIGHT : UInt = 0x4D4D4D;
	public static var CIRCLE_LIGHT_VISITED : UInt = 0x668F66;

	public static var LINES : UInt = 0x595959;
	public static var LINES_VISITED : UInt = 0xFF6200;
	public static var LINES_W = 16;
	public static var LINES_ALPHA = 0.4;

	public static var DRAW_BOUNDING_BOX = false;
	public static var GROUND_BOX : UInt = 0x222211;

	public static function addGroundShadow( obj:flash.display.DisplayObject ){
		if (Game.instance.slowLevel >= 2)
			return;
		obj.filters = [ new flash.filters.DropShadowFilter(1, 45, 0x000000, 2, 2) ];
	}

	public static function visitedColor( oldC:UInt ){
		if (oldC == CIRCLE_DARK)
			return CIRCLE_DARK_VISITED;
		if (oldC == CIRCLE_LIGHT)
			return CIRCLE_LIGHT_VISITED;
		if (oldC == LINES)
			return LINES_VISITED;
		return oldC;
	}
}
