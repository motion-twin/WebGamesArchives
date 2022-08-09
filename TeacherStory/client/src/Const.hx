import flash.display.Sprite;

class Const implements haxe.Public {
	public static var LANG = "fr";
	public static var PF_PADDING = 20;
	public static var QUALITY = flash.display.StageQuality.LOW;
	
	static var BASE_TXT_COLOR = 0xD9DDEA;
	static var ATK_TXT_COLOR = 0xFF6000;
	static var DMG_TXT_COLOR = 0xEE1111;
	static var HEAL_TXT_COLOR = 0xE32857;
	static var LEARN_TXT_COLOR = 0x5999D9;
	static var ATTENTION_COLOR = 0xB3D105;
	static var AP_TXT_COLOR = 0xEF9F85;
	static var ACTIVE_COLOR = 0xFFC515;
	static var OVER_COLOR = 0x89CAFA;
	static var SHADOW_COLOR = 0x281c3c;
	static var WHITE_MASK = 0xF1EAE0;
	
	public static var EXIT = { x:-1,y:-1 };
	public static var BOARD = { x:-1,y:-1 };
	public static var DESK = { x:-1,y:-1 };
	public static var CORNER1 = {x:-1,y:-1};
	public static var CORNER2 = {x:-1,y:-1};
	public static var ACT_SPOT = {x:-1,y:-1};
	
	private static var _auto = 0;
	public static var DP_BG = _auto++;
	public static var DP_BG_FX = _auto++;
	public static var DP_BUFFER = _auto++;
	public static var DP_CHRONO = _auto++;
	public static var DP_SCROLLERS = _auto++;
	public static var DP_ITEMS = _auto++;
	public static var DP_ITEMS_OVER = _auto++;
	public static var DP_FX = _auto++;
	public static var DP_FOCUS = _auto++;
	public static var DP_MASK = _auto++;
	public static var DP_DOF = _auto++;
	public static var DP_SUB_INTERF = _auto++;
	public static var DP_INTERF = _auto++;
	public static var DP_TUTORIAL = _auto++;
	public static var DP_TIP = _auto++;
	
	public static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	public static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	public static var RWID = -1;
	public static var RHEI = -1;
	public static var UPSCALE = 2;
	
	public static var LOWQ = false;
	
	public static var GLOBAL_VOLUME = 1; // PAS TOUCHE
	public static var MUSIC_VOLUME = 0.25; // PAS TOUCHE
	public static var SFX_CHANNEL = 0;
	public static var MUSIC_CHANNEL = 1;
}


enum Font {
	FSmall;
	FBig;
}

enum GamePlace {
	Class;
	HQ;
	Home;
}

enum PotentialTargetType {
	PT_Iso(iso:Iso);
	PT_IsoGroup(list:Array<Iso>);
	PT_Box(x:Float,y:Float,wid:Float,hei:Float, spr:Sprite, detach:Bool);
}
