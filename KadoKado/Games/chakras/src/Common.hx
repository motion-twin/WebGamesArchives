import mt.flash.Volatile;

enum Step { 
	Muladhara; 
	Swadhisthana; 
	Manipura; 
	Anahata; 
	Visshudha; 
	Ajna; 
	Sahasrara;
	Play; 
	GameOver;
	}

enum Chakra_Move {
	Cardioid;
	Right;
	Rotation;
	Conchoid;
	Test;
	CBounce;
	CElastic;
	CQuint;
	Null;
}

class Const {

	public static var DP_BG			=		1;
	public static var DP_KUNDALINI	=		2;
	public static var DP_CHAKRAS	=		3;
	public static var DP_SELECT		=		4;
	public static var DP_TOP		=		5;
	public static var SIZE			=		30;
	public static var ADD			= KKApi.const( 0 );
	public static var MAX_POINTS	= KKApi.const( 300 );
	public static var POINTS	= KKApi.const( 300 );
	public static var ENERGY_SUP	= KKApi.const( 4 );
	public static var ENERGY_UP		= KKApi.const( 20 );
	public static var CYCLES		= KKApi.const( 10 );
	public static var CYCLES_DESC	= KKApi.const( 5 );
	public static var ENERGY_DEC	= KKApi.const( 1 );
	public static var MISS_CHAKRA_LOOSE =	KKApi.const( 50 );
	public static var MISS_KEY_LOOSE	=	KKApi.const( 100 );
	public static var SCORE_MUL		=		KKApi.const( 3 );
	public static var PAUSE_DEC		=		KKApi.const( 20 );
	public static var MAX_GROW		=		600;
	public static var MAX_PAUSE		=		160;
	public static var MIN_PAUSE		=		10;
	public static var PAUSE_D		=		5;
	public static var COMBO_SCORE	=		KKApi.const( 5000 );
	public static var COMBO_T		=		KKApi.const( 6 );

	public static var MIN_CYCLE		=		20;
	public static var BASE_CYCLE	=		45;
	public static var CYCLE_DEC		=		KKApi.const( 2 );
	public static var CYCLE_DIV		=		KKApi.const( 42 );
	public static var CYCLE_DIV_2		=	KKApi.const( 10 );

	public static var MAX_TRIES		=		2;
	public static var MAX_GLOW		=		200;
	public static var CHAKRA_TRESHOLD =		2;
	public static var CHAKRA_MIN_DX =		50;
	public static var CHAKRA_MAX_DX =		250;
	public static var ANIMATION_THRESHOLD = 1;
	public static var X = 151;
	public static var SPEED = 2;

	public static var BONUS_CHANCE			= KKApi.const( 70 );
	public static var TRAP_CHANCE			= KKApi.const( 200 );

	public static var COLORS = [0xD71E1B,0xF49924,0xF8CE06,0x79A63F,0x2388BE,0x728DFC,0xB23FA5];

	public static var MOVES = [Rotation,Rotation,Right,Right,Conchoid,CBounce,CElastic,CQuint];
//	public static var MOVES = [Cardioid];
}
