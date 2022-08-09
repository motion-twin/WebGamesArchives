
class Cs {
	//URL
	public static var ALCHEMIST_SWF  = "/swf/persos_lib.swf";
	public static var MISC_SWF  = "/swf/avatar_misc.swf";
	public static var MISC_START  = 8 ;
	
	
	public static function getLib(misc : Bool) {
		return if (misc) MISC_SWF else ALCHEMIST_SWF ;
	}
	
	
	// Depth
	static public var DP_MISC 		= 6 ;
	static public var DP_			= 5 ;
	static public var DP_THUMB 		= 4 ;
	static public var DP_PERSO	 	= 3 ;
	static public var DP_FRAME 		= 2 ;
	static public var DP_BG 		= 1 ;
	
	
	// MATH VAR
	static public var RAD = 6.28;

	
	//PERSOS CONST
	static public var PMAX	:Int = 16 ;
	static public var CMAX	:Int = 11 ;
	static public var DEFPAL:Array<Int> = [
			0xFFF2DF,
			0xFFCC79,
			0xFFAA1E
		];
		

#if forum
	static public var THUMBW		= 80;
	static public var THUMBH		= 65;
#else
	static public var THUMBW		= 110;
	static public var THUMBH		= 90;
#end
	
	}
