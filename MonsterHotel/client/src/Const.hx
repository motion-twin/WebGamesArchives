class Const {
	public static var GRID = 16;
	public static var FPS = 30;
	public static var NET_BUFFER_DURATION_SEC = #if flash 3 #else 5 #end;
	#if mBase
	public static var BUILD = mt.deepnight.MacroTools.getBuild("../bin/.build", true);
	#else
	public static var BUILD = mt.deepnight.MacroTools.getBuild("bin/.build", true);
	#end

	public static var DOMAINS = [
		"fb.demo.monster-hotel.net",
		"demo.monster-hotel.net",
		"fb.local.monster-hotel.net",
		"local.monster-hotel.net",
		"fb.monster-hotel.net",
		"monster-hotel.net",
	];

	public static function seconds(s:Float) return mt.MLib.round(s*FPS);
	public static function ms(s:Float) return mt.MLib.round(s*FPS/1000);

	static var autoInc = 0;
	public static var DP_BG = autoInc++;
	public static var DP_SCROLLER = autoInc++;
	public static var DP_HOTEL = autoInc++;
	public static var DP_ROOM_WALLS = autoInc++;
	public static var DP_ROOM_BATCH = autoInc++;
	public static var DP_CLIENT = autoInc++;
	public static var DP_FURN = autoInc++;
	public static var DP_CAR = autoInc++;
	public static var DP_ROOM_BATCH_FRONT = autoInc++;
	public static var DP_GAME_FX = autoInc++;
	public static var DP_ROOM_STATUS = autoInc++;
	public static var DP_FRONT = autoInc++;
	public static var DP_GIFT = autoInc++;
	public static var DP_GAME_INTERACTIVE = autoInc++;
	public static var DP_CTX_UI = autoInc++;
	public static var DP_BARS = autoInc++;
	public static var DP_NOTIFICATION = autoInc++;
	public static var DP_POP_UP_BG = autoInc++;
	public static var DP_POP_UP = autoInc++;
	public static var DP_TOP_POP_UP = autoInc++;
	public static var DP_MASK = autoInc++;
	public static var DP_TUTORIAL = autoInc++;
	public static var DP_UNLOGGED = autoInc++;
	public static var DP_UI_FX = autoInc++;
	public static var DP_INTRO = autoInc++;
	public static var DP_WEBVIEW = autoInc++;


	public static var ROOM_WID = 512;
	public static var ROOM_HEI = 256;
	public static var EQUIPMENT_ICON = 85;

	public static var BLUE = 0x18112f;
	public static var HOVER = 0x431F2C;
	public static var TEXT_GOLD = 0xFFDF00;
	public static var TEXT_GEM = 0x82C0FF;
	public static var TEXT_LOVE = 0xFF95B3;
	public static var TEXT_BAD = 0xFF8A6C;
	public static var TEXT_XP = 0xACFF00;
	public static var TEXT_FAME = 0xFFDF00;
	public static var TEXT_GRAY = 0x8E96CC;
	public static var TEXT_PERK = 0xB6F200;
	public static var TEXT_SAVING = 0x8DBC36;


	public static function getStarFromLevel(l:Int) : Null<{frame:Int, n:Int}> {
		if( l<=0 )
			return null;
		else
			return if ( l<=5 ) { frame:0, n:l };
				else if( l<=10 ) { frame:1, n:l-5 };
				else if( l<=15 ) { frame:2, n:l-10 };
				else if( l<=20 ) { frame:3, n:l-15 };
				else { frame:4, n:mt.MLib.min(l-20, 5) };
	}
}


