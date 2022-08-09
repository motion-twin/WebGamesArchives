class Const {

	// GFX
	static var WIDTH = 300;
	static var HEIGHT = 300;

	static var COLOR_SNAKE_DEFAULT = 0x009900;
	static var COLOR_SNAKE_BORDER_DEFAULT = 0x006C00;
	static var COLOR_SNAKE_INVINCIBLE = 0x89A6B5;
	static var COLOR_SNAKE_BORDER_INVINCIBLE = 0x61869A;

	static var PLAN_FRUITS_SHADE = 1;
	static var PLAN_SNAKE = 2;
	static var PLAN_FRUITS = 3;
	static var PLAN_PARTICULES = 4;
	static var PLAN_POPSCORE = 5;
	static var PLAN_JACKPOT = 1;

	// PHYSICS

	static var SNAKE_DEFAULT_SPEED = 2.3;
	static var SNAKE_MIN_SPEED = SNAKE_DEFAULT_SPEED / 2;
	static var SNAKE_FAST_SPEED_COEF = 3;
	static var SNAKE_DEFAULT_TURN = 0.125;
	static var SNAKE_DEFAULT_LENGTH = 3;
	static var SNAKE_QUEUE_ELT_SIZE = 4;
	static var SNAKE_SPEED_INCREMENT = 0.001;

	static var FRICTION = 0.97;

	// GAMEPLAY

	static var BONUS_PROBAS = [
		100,	// CISEAUX
		40,		// COFFRE
		30,		// POTION BLEUE
		8,		// CANNE
		80,		// MOLECULE
		20,		// PLUME
		2,		// CLOCHE
		500,	// JACKPOT
	];

	static var BONUS_FREQ = 250;
	static var BONUS_MAX = 7;

	static var FRUITS_FREQ = 350;
	static var FRUITS_MAX = 200;

	static var FBARRE_MAX = 150;
	static var FBARRE_FRUIT_BASE = 20;
	static var FBARRE_FRUIT_TIMEOUT = -1.5;
	static var FBARRE_FRUIT_EAT = 2;

	static var C5 = KKApi.const(5);
	static var C10 = KKApi.const(10);
	static var C20 = KKApi.const(20);
	static var C30 = KKApi.const(30);
	static var C50 = KKApi.const(50);
	static var C100 = KKApi.const(100);
	static var C200 = KKApi.const(200);
	static var C700 = KKApi.const(700);
	static var C1900 = KKApi.const(1900);
	static var C3000 = KKApi.const(3000);
	static var C4000 = KKApi.const(4000);
	static var C6000 = KKApi.const(6000);

	static var LEVEL_BOUNDS = { left : 3, top : 3, right : 297, bottom : 267 };

}