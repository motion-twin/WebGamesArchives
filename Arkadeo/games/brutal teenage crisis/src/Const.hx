class Const {
	public static var WID = 600;
	public static var HEI = 460;

	public static var LWID = 23;
	public static var LHEI = 17;
	public static var GRID = 26;

	public static var GRAVITY = 0.07;
	public static var AUTODIFF = 30;
	public static var FRICTION = 0.85;
	public static var PHASE_CD = seconds(15);
	public static var PHASE_DURATION = seconds(2.5);

	public static var UID = 0;

	static var uniq_ = 0;
	public static var DP_BG = uniq_++;
	public static var DP_BG_FX = uniq_++;
	public static var DP_ENTITY = uniq_++;
	public static var DP_MOB = uniq_++;
	public static var DP_PHASE = uniq_++;
	public static var DP_FX = uniq_++;
	public static var DP_ITEM = uniq_++;
	public static var DP_HERO = uniq_++;
	public static var DP_INTERF = uniq_++;

	public static var FPS = 30;
	public static inline function seconds(sec:Float) return mt.MLib.round(FPS*sec);
}
