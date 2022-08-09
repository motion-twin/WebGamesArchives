import mt.bumdum9.Lib;
import mt.flash.VarSecure;
import Protocol;

class Cs implements haxe.Public {
	
	#if dev
	public static var TEST_UPGRADES:Array<UpgradeType>  = [];
	public static var TEST_BONUS = MULTI;
	#end
	
	static var SOUND_FX = false;
	static var MOVE_ARROW = true;
	
	static var DIFFICULTY_COEF_PROGRESSION : mt.flash.Volatile<Float> = .5;// WAS 1
	
	static var DIFFICULTY_COEF_LEAGUE : mt.flash.Volatile<Float> = .6;// WAS 1
	static var DIFFICULTY_COEF_LEAGUE_MAX : mt.flash.Volatile<Float> = 1.8;
	
	static var LEAGUE_TIME_BONUS_PERCENT : mt.flash.Volatile<Float> = 0.1;
	
	static var DIFFICULTY_PROGRESS : mt.flash.Volatile<Float> =	.001;
	static var MALUS_PER_PLAY = 1;
	
	static var PT = new PT();
}
