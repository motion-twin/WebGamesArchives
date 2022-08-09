class Const {
	public static inline var WID = 600;
	public static inline var HEI = 460;
	public static var UPSCALE = 2;
	public static inline var GRID = 20;
	
	public static inline var INVOKE = 10;
	
	static var uniq = 0;
	public static var DP_SCROLLER = uniq++;
	public static var DP_BG = uniq++;
	public static var DP_BG_FX = uniq++;
	public static var DP_ENTITY = uniq++;
	public static var DP_BAR = uniq++;
	public static var DP_BOMB = uniq++;
	public static var DP_FX = uniq++;
	public static var DP_BLOOD = uniq++;
	public static var DP_MASK = uniq++;
	public static var DP_INTERF = uniq++;
}


typedef PlayerState = {
	var life		: Int;
	var xp			: Int;
	var level		: Int;
}

enum Font {
	F_Small;
}

enum WeaponType {
	W_Basic;
	W_Lightning;
	W_Grenade;
	W_Lazer;
}

enum TurretType {
	T_Gatling;
	T_Slow;
	T_Shield;
	T_Burner;
}

enum DispenserEffect {
	D_GiveTurret(t:TurretType);
	D_GiveWeapon(w:WeaponType);
}
