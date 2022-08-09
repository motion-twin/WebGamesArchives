import mt.deepnight.Lib;
import Protocol;

class Const implements haxe.Public {
	static var TAX_NIGHT = Sunday; // soir à minuit

	static var ROOM_WID	= 130;
	static var FLOOR_HEI	= 105; // 96

	static var HOTEL_NAME_LIMIT = 28;
	static var MAX_WIDTH = 7;
	static var MAX_HEIGHT = 22;
	static var MAX_ROOM_LEVEL = 2;
	static var MAX_LOBBY_LEVEL = 4;
	
	static var NEON_COLORS = [
		{c:0xCF5466, t:0x9D2D3E}, // rouge pâle
		{c:0xFB7979, t:0xD90606}, // rouge
		{c:0xEEB74F, t:0xAF5410}, // orange
		{c:0xF3D91B, t:0x8C5F0B}, // jaune
		{c:0xC6F92B, t:0x687711}, // vert anis
		{c:0x6AEC1C, t:0x5A871D}, // vert sapin
		{c:0x21E798, t:0x0E836B}, // vert eau
		{c:0x07CDF8, t:0x03697E}, // bleu clair
		{c:0x7295F1, t:0x2C588F}, // bleu pale
		{c:0xA875EE, t:0x624585}, // mauve
		{c:0xE97AD8, t:0x8E177C}, // rose
		{c:0xCABB99, t:0x85684E}, // or
		{c:0xCCDCE1, t:0x546772}, // gris/blanc
	];
	
	static var WALL_MIDS = 6;
	static var WALL_BOTTOMS = 5;
	static var WALL_PAPERS = 7;
	static var WALL_COLOR_BASE = 0x697887;
	static var WALL_COLOR_DESTROY = 0x4A3E3E;
	static var WALL_COLORS_WARM = [ 0xBA2323, 0xE77105, 0xE7CA01, 0x40499F, 0x1E64CE, 0x0199CB, 0x75CED2, 0x70BD06, 0xC1CB03, 0xA547BC, 0xC55F94, 0xF480B7 ];
	static var WALL_COLORS_COOL = [ 0x633F29, 0x7C5F32, 0x98832C, 0x6B507A, 0xAA5962, 0x2D603C, 0x6DA074, 0xAEB98E, 0x84719D, 0xC0AF87, 0x2C4354, 0x91B9AF ];

	static var LEAVE_TIME = 10;
	static var SERVICE_VISIBILITY = DateTools.hours(6);
	
	static var ABSENCE_DURATION = DateTools.days(5);
	static var ABSENCE_BONUS = 250;

	static var BUILD_RESET_COST = 20;
	
	static var BASE_ATTENDING_CHANCE = 40;
	static var BASE_DROP_CHANCE = 20; // 40
	static var BASE_DIRT_CHANCE = 50;
	static var BASE_BREAK_CHANCE = 50; // 35
	
	static var JOB_ATTENDING_DURATION = DateTools.hours(4);
	static var JOB_REPAIR_DURATION = DateTools.minutes(2)+DateTools.seconds(30);
	static var BUILD_BEDROOM_DURATION = DateTools.minutes(5);
	static var BUILD_SPECIAL_DURATION = DateTools.minutes(30);
	static var LEVELUP_DURATION = DateTools.minutes(10);
	static var ACTIVITY_DURATION = Std.int( DateTools.hours(2) );
	
	static var LAB_STEP_REQ = 4;
	static var LAB_MAX_TREE_POINTS = 25;
	static var LAB_CLIENT = 1;
	static var LAB_CLIENT_SPEC = 2;
	static var LAB_NEEDED_POINTS = 5;
	static var LAB_SUPER_CLIENT = 2;
	static var LAB_DURATION = DateTools.hours(2);
	
	static var MAX_LOBBY_CAPACITY = [2,3,4,5,6];
	static var FIRST_CLIENTS = 1;
	//static var MAX_CLIENTS_IN_QUEUE = 15;
	static var HYSTERIA_LIMIT = 4;
	#if neko
	static var MAX_FRIEND_CLIENTS = if (Config.DEBUG) 15 else 3;
	#end
	static var HYPNO_MIN_HAPPYNESS = 8;

	// const : argent
	static var STARTING_MONEY = 0;
	static var BUILD_SERVICE_COST = 300; // salle de service
	//static var BUILD_SPECIAL_COST = 400; // salle spéciale
	static var BUILD_ROOM_COST = 100; // chambre
	static var BUILD_LAB_COST = 250; // labo
	static var REPAIR_COST = 6;
	static var LEVELUP_COST = [0,250,600];
	static var LEVELUP_LOBBY_COST = [0,250,500,1500,3000];
	static var ATTENDING_COST = 10;
	static var CLIENT_COST = 0;
	static var CLIENT_MONEY = 50;
	static var SPECIAL_ROOM_GAIN = 5;
	static var MONEY_PICKUP = 25;
	static var CLIENT_CALL = 5;
	
	static var MIN_BUILDING_SIZE_FAME = 9; // nb de salles à construire avant la construction ne rapporte du prestige
	static var FAME_CLIENT_HAPPY = 1;
	static var FAME_VIP = 30;
	static var FAME_RESEARCH = 1;
	static var FAME_QUEST = 5;
	static var FAME_BUILDING_SIZE = 1;
	static var FAME_LUX_BEDROOM = 1; // par level
	static var FAME_TAX = 20; // par level
	static var FAME_RETREAT = 150;

	// const : happyness
	static var H_BASE = 3;
	static var H_MOVE = -2;
	static var H_PRESENT = 1;
	static var H_PRESENT_XL = 2;
	static var H_FIREWORK = 6;
	static var H_MATTRESS = 1;
	static var H_SPECIAL_ROOM = 0;
	static var H_SERVICE_OK = 1;
	static var H_SERVICE_NOK = 0;
	static var H_LAB_HORROR = -1;
	static var H_HYSTERIC = -3;
	
	static var H_JOY = 1;
	static var H_LIKE_OK = 2;
	static var H_LIKE_NOK = -3;
	static var H_DISLIKE_OK = 2;
	static var H_DISLIKE_NOK = -3;
	static var H_STAFF_ATTENDANT = 1;

	static function allWallColors() {
		return WALL_COLORS_WARM.concat( WALL_COLORS_COOL );
	}

	static function isEquipment(i:_Item) {
		return switch (i) {
			case _RANDBOTTOM, _RANDPAINT, _RANDPAINTWARM, _RANDPAINTCOOL, _RANDTEXTURE, _RANDDECO, _PRESENT, _PRESENT_XL, _RESEARCH, _RESEARCH_GOLD,
				_REPAIR, _MONEY :
				false;
			case _BUFFET, _RADIATOR, _STINK_BOMB, _HUMIDIFIER, _HIFI_SYSTEM, _OLD_BUFFET, _DJ, _LABY_CUPBOARD,
				_MATTRESS, _FIREWORKS, _WALLET, _FRIEND, _ISOLATION :
				true;
		}
	}
}
