package ;

import db.Variable;
import Protocol;

/**
 * ...
 * @author de
 */

 #if !js
class Const
{
	
	public static inline var ONE_HOUR : Float = 3600;
	
	public static inline var VERSION_MAJOR = 1; //version major is the season
	public static inline var VERSION_MINOR = 91; 
	
	public static inline var FDS_EACH = 5;
	public static inline var FDS_GAIN = 3;
	
	public static inline var PORTRAITS_OK = false;
	
	public static function 	IS_BETA()	{
		return false;
	}
		
	public static inline var MAGGIE_WORK = false;
	public static inline var GYHYOM_WORK = #if master false #else true #end;
	public static inline var BM_WORK	 = #if master false #else true #end;
	
	public static inline var LANG_FR = #if lang_fr true #else false #end;
	public static inline var LANG_ES = #if lang_es true #else false #end;
	public static inline var LANG_EN = #if lang_en true #else false #end;
	
	public static inline var ENABLE_POP = false;
	public static inline var NO_VANITIES = false;
	
	
	public static inline var MAX_PLANETS = 5;
	public static inline var CLOSE_SITE : Bool = false;
	public static inline var OPEN_BETA : Bool = true;
	
	public static inline var FAKE_DISTRIB = true;
	
	public static inline var INITIAL_O2 : Int = 30;
	public static inline var INITIAL_FUEL : Int = 30;
	
	public static inline var O2_PER_LEAK : Int = 1;
	
	public static inline var OXY_CAPS_CONTENT = 1;
	
	public static inline var MIN_OXY = 0;
	public static inline var MAX_OXY = 32;
	public static inline var MAX_FUEL = 32;
	
	public static inline var CONSUMED_O2_PER_USER_PER_DAY : Int = 8;
	
	public static inline var CYCLE_PER_DAY : Int = 8;
	public static inline var HOUR_PER_CYCLE : Int = Std.int(24/CYCLE_PER_DAY);
	
	public static inline var MAX_HERO_INV_SIZE :Int = 3;
	public static inline var MAX_RSCH_INV_SIZE :Int = 2;
	
	public static inline var PLAYER_ACCEPTANCE_THRESHOLD = 32;
	public static inline var PROJECT_FREEZE_DURATION = 0;
	
	//whence max hunger die!
	public static inline var CAN_EAT_NURTURE 	: Int = 2;
	public static inline var DEATH_NURTURE		: Int = -24;
	
	public static inline var MAX_MORAL : Int = 14;
	public static inline var MAX_HYGIENE : Int = 14;
	public static inline var MAX_HP : Int = 14;
	
	
	public static inline var EXPEDITION_DEPARTURE_CYCLE : Int = 6;
	public static inline var MAX_ENGINE_PIPELINE : Int = 9;
	public static inline var FUEL_PER_FILL : Int = 1;
	
	public static inline var SHOW_ALL_LOG = false;
	
	public static inline var MAX_SHIP_CREW_SIZE : Int = 64;
	
	
	public static inline var USE_DIRECT_DOORS = true;
	
	//game rules
	public static inline var DIE_BY_STARVATION : Bool = true;
	
	public static inline var DIE_BY_MORAL : Bool = true;
	public static inline var DIE_BY_RELOCATION : Bool = true;
	
	public static inline var ENABLE_SHIP_MAINTAIN : Bool = true;
	public static inline var ENABLE_HUNTERS : Bool = true;
	
	public static inline var DBG_EXPEDITION : Bool = false;
	public static inline var DBG_HUNTER : Bool = false;
	
	public static inline var MAX_PLANT_PER_GARDEN :Int = 10;

	public static inline var 	ENABLE_ADMIN_ACTION : Bool = #if debug true #else false #end;
	
	public static var 			FRESH_PLANT_WT_VALUES = -5;
	
	
	public static var 		CAPS_CONTENT :Array<ItemId>= [  METAL_SCRAPS, PLASTIC_SCRAPS, FUEL_CAPSULE, OXY_CAPSULE  ];
	
	//skill consts
	public static inline var BACKTRACK_RANGE		= 1;
	public static inline var BACKTRACK_EXT_RANGE	= 8;
	
	public static inline var CONTACT_ODD = 7;
	
	
	public static inline var VERSION = 0;
	
	public static inline var MAX_PATROL_HP = 14;
	
	public static inline var CACHE_LOGS = true;
	public static inline var MAKE_ADMIN_STREAM = false;
	
	//roughly one month in seconds
	public static inline var DESTROYED_DAY = 60;
	
	public static inline var BANANA = 0;
	
	public static inline var RATION = 0;
	public static inline var COOKED_RATION = 1;
	public static inline var ALIEN_MEAT = 5;
	public static inline var ANABOLYSANT = 6;
	public static inline var COFFEE = 7;
	
	public static inline var EXP_TICK_DURATION = 1800.0;
	
	public static inline var FORCE_THIRD_OF_HERO = true;
	public static inline var MAX_PAVE = 2048;
	public static inline var ENABLE_RANKING = true;
	
	public static inline var BILLER_MAX = 899815135;
	public static inline var XP_FOR_GOLD = 80;
	public static inline var GRP_XP_PER_FLY = 25;
	public static inline var GRP_GOLD_NB = 3;
	public static inline var GRP_GOLD_TICKET_NB = 2;
	
	public static inline var READY_DURATION = 3;
	public static inline var GROUP_COST = 3;
	public static inline var GOLD_6MONTH = 10;
	public static inline var SUPER_GAME_DAYS = 9;
	
	public static inline function IS_HALLOWEEN() {
		var d = Date.now();
		if ( d.getMonth() == 10)
			return true;
		else if ( d.getMonth() == 9 && d.getDay() >= 25)
			return true;
		else 
			return false;
	}
	
	public static function getIsoURL(){
		var s = "/swf/iso.swf";
		var isoVer = Variable.get("iso.swf");
		if ( isoVer != null)
			s += "?v=" + isoVer;
		return StringTools.urlEncode(Config.DATA+s);
	}
	
	public static inline var SCOPE_SHIP_DATA = "mush_ship_data";
	public static inline var NB_SHIP_TYPE = 4;
}
#end


