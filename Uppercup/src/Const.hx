import mt.deepnight.Lib;

@:publicFields class Const {

	static var DOMAIN = "uppercup-football.com";

	static var BG_COLOR = 0x1D2F41;
	static var GLUE_THRESHOLD : UInt = 0x8D8D8D;
	static var WATER_THRESHOLD_FEW : UInt = 0x909090; //0xA0A0A0;
	static var WATER_THRESHOLD_MUCH : UInt = 0x747474;

	static var UPSCALE : Float = 3;
	static var FPS = 30;
	public static inline function seconds(v:Float) return mt.MLib.round(FPS*v);
	public static inline function frames(ms:Float) return mt.MLib.round(FPS*ms/1000);

	static var SNOW_SCALE = 3;

	private static var _uniq = 0;
	static var DP_BG1 = _uniq++;
	static var DP_SNOW = _uniq++;
	static var DP_BG2 = _uniq++;
	static var DP_FX_BG = _uniq++;
	static var DP_ZSORTABLES = _uniq++;
	static var DP_GOAL_CAGE = _uniq++;
	static var DP_FX = _uniq++;
	static var DP_INTERF = _uniq++;
	static var DP_BG_SCROLL = _uniq++;
	static var DP_MENU = _uniq++;
	static var DP_TIP = _uniq++;

	static var MAX_STARS = 3;
	static var MATCHES_BY_CUP = 5;
	#if press
	static var MAX_LEVELS = 30;
	static var FREE_LIMIT = 30;
	#elseif webDemo
	static var MAX_LEVELS = 5;
	static var FREE_LIMIT = 5;
	#else
	static var MAX_LEVELS = 100;
	static var FREE_LIMIT = 20;
	#end
	static var FINAL_LEVEL = 100; // warning: used to show game ending
	static var FIELD_RATIO = 90/120;
	static var GRID = 16;
	static var WID = 600;
	static var HEI = 460;
	static var FPADDING = 8;
	static var FWID = 45;
	static var FHEI = 34;
	static var OBSTACLE_HEIGHT = 20;

	static var BG_SCROLL_REPEAT = 3;

	static var GOAL_SCORE = 1500;
	public static var PERK_LEVELS = [2,5,7,9,11,13,15,17,19];

	public static function getRateUrl() {
		if( Lib.isIos() )
			return "https://itunes.apple.com/us/app/uppercup-football/id881006708?l=fr&ls=1&mt=8";
		else if( Lib.isAndroid() )
			return "market://details?id=air.com.motiontwin.UppercupFootball";
		else
			return "http://uppercup-football.com";
	}

	public static var PALETTE : Array<UInt> = [
		0xEAEAEA,

		// Verts
		0x406F00,
		0xABC400,

		// Bleus
		0x004488,
		0x0080FF,
		0x00E6FF,
		0x00C19B,

		// Rouges
		0x8C0000,
		0xFF0000,
		0xF29D00,
		0xFFFF00,

		// Roses / violets
		0xA200CA,
		0xEB5EFF,
		0xFFAAD9,
		0x7300F2,

		// Marrons
		0xA94949,
		0x725036,

		// Gris
		0x161616,
		0x2C2C2C,
		0x4B4B4B,
	];

}



enum Font {
	FSmall;
	FBig;
	FTime;
}

enum GameVariant {
	Normal;
	Hard;
	Epic;
}
