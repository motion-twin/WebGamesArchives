import MapCommon;

class Const implements haxe.Public {
	static var uniq			= 0;
	static var DP_CELL		= uniq++;
	static var DP_INTERFACE	= uniq++;

	static var DP_TOP		= uniq++;

	static var WID			= 300;
	static var HEI			= 300;
	static var CWID			= 100;
	static var CHEI			= 100;
	static var MWID			= 15;
	static var MHEI			= 15;
	//static var BGWID		= 6; // background texture width in squares
	//static var BGHEI		= 6;

	static var OFF_ALPHA	= 60;
	static var BLACK_ALPHA	= 90;
	
	inline public static var START_X	: Int = 8;
	inline public static var START_Y	: Int = 0;
}
