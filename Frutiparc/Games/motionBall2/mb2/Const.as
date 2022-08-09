class mb2.Const {

	public static var POS_X = 0;
	public static var POS_Y = 0;

	public static var MODE_CHALLENGE = 1;
	public static var MODE_CLASSIC = 3;
	public static var MODE_COURSE = 10;
	public static var MODE_AVENTURE = 20;
	public static var MODE_AIDE = 100;

	public static var TIME_CHALLENGE = 15 * 60 * 1000; // 15 min
	public static var TIME_CLASSIC = 1 * 60 * 1000; // 1 min
	public static var TIME_CLASSIC_EXTENDED = 5 * 1000; // 5 sec

	public static var CHALLENGE_DATA = "mb2data.dat";
	public static var CLASSIC_DATA = "mb2classic.dat";
	public static var TUTO_DATA = "mb2tuto.dat";
	public static function AVENTURE_DATA(n) { return "mb2adv"+(n+1)+".dat"; }
	public static function COURSE_DATA(n) { return "mb2run"+(n+1)+".dat"; }

	public static var DELTA = 4;
	public static var LVL_WIDTH = 610;
	public static var LVL_HEIGHT = 410;
	public static var MAX_BUMPERS = 50;
	public static var BORDER_SIZE = 25;
	public static var BALL_RAYSIZE = 8;
	public static var LVL_CWIDTH = int(LVL_WIDTH / DELTA);
	public static var LVL_CHEIGHT = int(LVL_HEIGHT / DELTA);
	public static var BORDER_CSIZE = int(BORDER_SIZE / DELTA);
	public static var HOLE_BORDER_SIZE = 7;
	public static var DOOR_SIZE = 110;
	public static var DOOR_CSIZE = Math.ceil(DOOR_SIZE / DELTA);
	public static var DOOR_CXPOS = int((LVL_CWIDTH - DOOR_CSIZE) / 2);
	public static var DOOR_CYPOS = int((LVL_CHEIGHT - DOOR_CSIZE) / 2);
	public static var POS_NBITS = Math.ceil( Math.log( Math.max(LVL_CWIDTH,LVL_CHEIGHT) ) / Math.LN2 );
	public static var DOORS_FRAMES = [4,3,2,1,1,2,3,4];

	public static var DOOR_COLLIDE_DELTA = 5;

	public static var BOSS_MIN_X = BORDER_SIZE*2;
	public static var BOSS_MIN_Y = BORDER_SIZE;
	public static var BOSS_MAX_Y = BORDER_SIZE;

	public static var CAUSE_NOTIME = 1;
	public static var CAUSE_NOBALLS = 2;
	public static var CAUSE_WINS = 3;

	public static var BG_PLAN = 0;
	public static var SHADE_PLAN = 1;
	public static var DECOR_PLAN = 2;
	public static var DOOR_PLAN = 2;
	public static var HOLE_PLAN = 3; // reserved
	public static var BONUS_PLAN = 4;
	public static var BALL_PLAN = 5; // reserved
	public static var BUMPER_PLAN = 6;
	public static var DUMMY_PLAN = 7;
	public static var BOSS_PLAN = 8;
	public static var ICON_PLAN = 9;
}