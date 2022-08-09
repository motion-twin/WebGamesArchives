class Const {

	static var WIDTH = 7;
	static var HEIGHT = 7;
	static var SIZE = 40;
	static var DX = 10;
	static var DY = 10;

	static var PLAN_BG = 0;
	static var PLAN_CASES = 0;
	static var PLAN_PERSO = 1;
	static var PLAN_CURSOR = 3;
	static var PLAN_FX = 2;

	static var SATT = 0;
	static var SDEF = 1;
	static var SNOATT = 2;
	static var SNODEF = 3;
	static var SMARK = 4;
	static var SDEF_FIRST = 5;

	static var PROBAS_MONSTERS = [20,5,1];

	static var HERO_DEATH_POINTS = KKApi.const(0);
	static var HERO_KEEP_POINTS = KKApi.const(50);
	static var MONSTER_POINTS = KKApi.aconst([200,500,1000]);
	static var MONSTER_KEEP_POINTS = KKApi.aconst([0,0,0]);
	static var GROUP_BONUS = KKApi.const(150);

	static function pos(mc,x,y) {
		mc._x = x * SIZE + DX;
		mc._y = y * SIZE + DY;
	}

}