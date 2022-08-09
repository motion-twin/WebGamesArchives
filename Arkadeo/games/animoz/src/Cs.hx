import api.AKApi;
import api.AKProtocol;
import Protocol;
import mt.flash.VarSecure;

typedef Grid<T> = Array<Array<T>>;

class Cs implements haxe.Public {
	
	// SPACE
	static var WIDTH = 600;
	static var HEIGHT = 460;
	static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];
	static var SQ = 40;

	// DEV
	static var FORCE_RUN_LVL = -1;
	
	// GAMEPLAY
	static var COMBO_MINIMUM 	= 4;
	static var WAVE_SIZE 		= 1;	// 1;
	static var FIRST_FILL 		= 25;	// 24;
	static var FREQ_BONUS		= 14;
	
	static var SCORE_OBJECTIVE 		= new VarSecure(7000);
	
	static var SCORE_OBJECTIVE_INC 	= new VarSecure(500);
	static var SCORE_OBJECTIVE_HARD_LEVEL 	= new VarSecure(10);
	static var SCORE_OBJECTIVE_HARD_INC 	= new VarSecure(500);
	
	static var SCORE_BALL 	 		= new VarSecure(100);
	static var SCORE_COMBO_INC  	= new VarSecure(100);
	
	static var SIZE_UP_INTERVAL		= VarSecure.makeArray([3, 8, 15, 35, 50, 100, 150]);
	static var POOL_UP_INTERVAL		= VarSecure.makeArray([5, 20, 100]);
	
	static var RUN_POOL = [_STANDARD_A, _STANDARD_B, _STANDARD_C];
	static var RUN_UPG_THRESHOLDS = [ 2, 4, 6, 10, 14, 18, 20 ];
	
	static var DISABLED_POOL = [_HIPPO, _CHEETAH];
	
	static var BONUS_ESCAPE_POINTS = api.AKApi.const(25);
	
	static var PT = new PT();
	static var MX = new MX();
}
