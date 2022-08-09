class Colors {
	inline public static var LOG_COLOR = 0x000000;
	inline public static var C1_DARK = 0x363E8E;
	inline public static var TO_CONQUER : UInt          = 0xFF000000;
	inline public static var CONQUERED_ZONE : UInt      = 0xFF020301;
	inline public static var CONQUERED_ZONE_FAST : UInt = 0xFF020201;
	inline public static var CONQUERED_PATH : UInt      = 0xFFA1A301;
	inline public static var CONQUERED_PATH_FAST : UInt = 0xFF01A201;
	inline public static var OUTSIDE : UInt             = 0xFF011001;
	inline public static var DRAWING_PATH_SLOW : UInt   = 0xFFAA7777;
	inline public static var DRAWING_PATH_FAST : UInt   = 0xFF777777;
	inline public static var BORDER_GRASS_BG : UInt = 0xFF556600;
	inline public static var GRASS_BG : UInt = 0xFF557700;
	inline public static var FLASH_COLOR : UInt = 0xFFFF0000;
	public static var WILD_GRASS = [ 0x113300, 0x00EE00, 0x88FF88 ];
	public static var FAST_GRASS = [ 0x223300, 0x77EE00, 0xDDFF88 ];
	public static var SLOW_GRASS = [ 0x113300, 0x00EE00, 0x88FF88 ];
	public static var BORDER_GRASS = [ 0x223300, 0x33EE00, 0xAAFF88 ];

	inline public static function isDrawingPath( c:UInt ) : Bool {
		return c == DRAWING_PATH_SLOW || c == DRAWING_PATH_FAST;
	}

	inline public static function isConqueredZone( c:UInt ) : Bool {
		return c == CONQUERED_ZONE || c == CONQUERED_ZONE_FAST;
	}

	inline public static function isConqueredPath( c:UInt ) : Bool {
		return c == CONQUERED_PATH || c == CONQUERED_PATH_FAST;
	}

	inline public static function isConquered( c:UInt ) : Bool {
		return isConqueredZone(c) || isConqueredPath(c);
	}

	inline public static function isConqueredSlow( c:UInt ) : Bool {
		return c == CONQUERED_PATH || c == CONQUERED_ZONE;
	}

	inline public static function isConqueredFast( c:UInt ) : Bool {
		return c == CONQUERED_PATH_FAST || c == CONQUERED_ZONE_FAST;
	}
}