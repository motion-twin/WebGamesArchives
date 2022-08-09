class Const {

	static var WIDTH = 8;
	static var HEIGHT = 12;

	static var PIERRE_LIFE = 3;

	static var DX = 45;
	static var DY = -45;
	static var YLIMIT = 65;

	static var NLEGS = KKApi.const(3);

	static var BULLE = 20;
	static var PIERRE = 21;

	static var GOLD = 9;

	static var C100 = KKApi.const(100);
	static var C1000 = KKApi.const(1000);
	static var C5000 = KKApi.const(5000);

	static var BONUS1 = 22;
	static var BONUS2 = 23;

	static var PLAN_BG = 0;
	static var PLAN_HERO = 1;
	static var PLAN_LEGUME = 2;
	static var PLAN_POP = 3;
	static var PLAN_INTERF = 4;

	static function setPercentColor( mc, prc, col ){
		
		var color = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		var co = new Color(mc)
		var c  = prc/100
		var ct = {
			ra:int(100-prc),
			ga:int(100-prc),
			ba:int(100-prc),
			aa:100,
			rb:int(c*color.r),
			gb:int(c*color.g),
			bb:int(c*color.b),
			ab:0
		};
		co.setTransform( ct );
	}


	
	
}
