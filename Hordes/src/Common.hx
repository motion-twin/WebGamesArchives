typedef Coordinates		= {x: Int, y : Int}

typedef ElectionDialog = {
	@:optional var u:String;
	var t:Array<String>;
	var a:Array<ElectionDialog>;
	@:optional var count:Int;
}

typedef Notification = {
	var kind : String;
	var text : String;
}

// OLD SYSTEM ------------------------------[
typedef HomeUpgradeReqs = {
	key			: String,
	n			: Int,
}

typedef HomeUpgrade = {
	level		: Int,
	name		: String,
	def			: Int,
	icon		: String,
	reqs		: List<HomeUpgradeReqs>,
	pa			: Int,
	hasLock		: Bool,
}
// ]-----------------------------------------

typedef HUpgradeReqs = {
	key			: String,
	n			: Int,
}

typedef HUpgradeLevel = {
	pa			: Int,
	def			: Int,
	cap			: Int,
	lock		: Bool,
	hide		: Bool,
	desc		: String,
	limit		: Int,
	alarm		: Bool,
	reqs		: List<HUpgradeReqs>,
}

typedef HUpgrade = {
	key			: String,
	ikey		: Int,
	level		: HUpgradeLevel,
	name		: String,
	desc		: String,
	icon		: String,
	levels		: List<HUpgradeLevel>,
	actName		: String
}


typedef Cell = {
	id			: Int,
	threat		: Int,
	threat_mod 	: Int,
	wood		: Int,
	fusion		: Int,
	oil			: Int,
	artefact	: Bool,
	pump		: Bool,
	water		: Int,
	foundWater	: Bool,
	foundOil	: Bool,
	foundFusion	: Bool,
	foundWood	: Bool,
	checked		: Bool
}

typedef GhostRewardLevels = {
	name		: String,
	min			: Int,
}

typedef GhostRewardData = {
	key			: String,
	ikey		: Int,
	name		: String,
	rare		: Bool,
	desc		: String,
	critical	: Bool,
	levels		: List<GhostRewardLevels>,
}

typedef BookData = {
	author 		: String,
	chance		: Int,
	key			: String,
	name		: String,
	design		: String,
	bg			: String,
	content		: String,
}

typedef CityUpgradeData = {
	parent		: Building,
	levels		: Array<{
		desc		: String,
		value		: Float,
		value2		: Float,
		value3		: Float,
	}>,
}

typedef T_Graph = List<{ date : Date, count : Int }>

typedef T_HelpData = {
	key			: String,
	title		: String,
	icon		: String,
	sub			: Bool,
	content		: String,
	ph_title	: String,
	ph_content	: String,
	url			: String,
	mod			: String,
}

typedef T_HeroUpgrade = {
	days		: Int,
	key			: String,
	name		: String,
	desc		: String,
	icon		: String,
}


class Common {
	public static var EVERYWHERE		: String = "0";
	public static var OUTSIDE			: String = "1";
	public static var CITY				: String = "2";
	public static var HOME				: String = "3";
	public static var GREATER_OUTSIDE	: String = "4";
	public static var PREMIUM_MAX_JOBS	= 1;
	public static var COMMON_MAX_JOBS	= 1;
	public static var HERO_MAX_JOBS		= 1;
//	public static var STANDARD_WATER	= 2;
	public static var NO_EVENT			= 0;
	public static var EVENT				= 1;
	public static var ADMIN_LEVEL		= 0;

	public static var BIT_FORUM_READ = 0;
	public static var BIT_OUT = 1;
	public static var BIT_REFINE = 2;
	public static var BIT_BUILD = 3;
	public static var BIT_LOGIN = 4;
	public static var BIT_VOTE_SHAMAN_ELECTION = 5;
	public static var BIT_VOTE_GUIDE_ELECTION = 6;

	public static var SPREAD_MATRIX = [ 0.5,		0.5,		0.5,
										0.5,		1,			0.5,
										0.5,		0.5,		0.5 ];

	public static var REWARDS = [
		0,	// 0
		0,	// 1
		0,	// 2
		0,	// 3
		0,	// 4
		0,	// 5
		1,	// 6
		2,	// 7
		3,	// 8
		4,	// 9
		5, 	// 10
		6, 	// 11
		6, 	// 12
		6, 	// 13
		6, 	// 14
		6, 	// 15
		7, 	// 16
		7, 	// 17
		7, 	// 18
		7, 	// 19
		7,	// 20
		10, // 21
	];

/*
	public static var OBJECTIVES = [
		"killc",	// tuer un citoyen
		"ban",		// faire bannir un citoyen
		"delrsc",	// détruire des ressources
		"drugad",	// rendre un citoyen dépendant
		"infect",	// rendre un citoyen infecté
	];
	public static var ODATASEP = "|";
*/
}

enum Modes {
	Premium;
	Hero;
}

enum ToolType {
	ToDo;
	Critical;
	Bag;
	Furniture;
	Weapon;
	Beverage;
	Jerrycan;
	Food;
	Slasher;
	BookBox;
	Animal;
	Drug;
	Opener;
	Box;
	FragileBox;
	OpenBox;
	Battery;
	ZombiePart;
	EmptyWeapon;
	Radar;
	Lock;
	Armor;
	SoulLocked;
	Alcohol;
	Tasty;
	Camo;
	Stealthy;
	Playable;
	Toxic;
	Refinable;
	Guard;
	Control;
	Fake;
	Rsc;
	BannedTool;
	ObjectiveTool;
	CampBonus;
	Lamp;
	HumanMeat;
	JobTool;
	Gadget;
	Special;
	Scary;
	Hidden;
}

enum ZoneDomination {
	Absent;
	UnderControl;
	LostControl;
	Feist;
}

enum MapStatus {
	MapIsVirgin;	// 0
	GameIsOpened;	// 1
	GameIsClosed;	// 2
	EndGame;		// 3
	Quarantine;		// 4
}

enum Exception {
	UserHasNoMap;
}

enum CityLogKey {
	CL_OpenDoor;
	CL_CloseDoor;
	CL_GiveInventory;
	CL_TakeInventory;
	CL_Thief;
	CL_NewBuilding;
	CL_Death;
	CL_DeadGarbaged;
	CL_Well;
	CL_NewBuildingFailed;
	CL_Attack;
	CL_AttackEvent;
	CL_HomeUpgraded;
	CL_HangDown;
	CL_GiveWater;
	CL_OutsideMessage;
	CL_OutsideEvent;
	CL_OutsideTempEvent;
	CL_NewUser;
	CL_HeroRescue;
	CL_Ban;
	CL_Refined;
	CL_OutsideChat;
	CL_Catapult;
	CL_WellExtra;
	CL_Building;
	CL_BankRob;
	CL_Dump;
	CL_Crucified;
	CL_UseBlueSoul;//unused
	CL_Heal;
	CL_Special;
}

/* /!\ WARNING : à CHAQUE rajout de type de mort
	- xml/locale.xml : ajouter message correspondant
	- Cadaver.hx  : ajouter le test dans la méthode getDeathReason
*/
enum DeathType {
	DT_Unknown;
	DT_Dehydrated;
	DT_Abandon;
	DT_Cyanure;
	DT_HangedDown;
	DT_KilledOutside;
	DT_Eaten;
	DT_Drugged;
	DT_Infected;
	DT_Banned;
	DT_Deleted;
	DT_Poison;
	DT_GhoulAttack;
	DT_GhoulWounded;
	DT_GhoulHungry;
	DT_MeatCage;
	DT_Crucified;//paques
	DT_Exploded;
	DT_Haunted;//SHAMAN_SOULS
}

enum InfoTags {
	IT_Nothing;		// 0
	IT_Help;		// 1
	IT_Rsc;			// 2
	IT_Item;		// 3
	IT_GoodItem;	// 4
	IT_Empty;		// 5
	IT_Secured;		// 6
	IT_Dig;			// 7
	IT_Zombie5;		// 8
	IT_Zombie9;		// 9
	IT_Camp;		// 10
	IT_Explo;		// 11
	IT_Soul; 		// 12
}

enum WoundType {
	W_Arm;	// 0
	W_Hand;	// 1
	W_Foot;	// 2
	W_Leg;	// 3
	W_Eye;	// 4
	W_Head;	// 5
}

enum EventState {
	ES_horde;
	ES_revolution;
	ES_chaos;
}

/* Events qui touchent tout le site :) */
enum GlobalEvent {
	H_Attack;
}

enum BuildingUpgrades {
	BU_Def1;
	BU_Def2;
	BU_Water1;
	BU_Water2;
	BU_Regen;
	BU_Tower;
	BU_BankDef;
	BU_AquaDef;
}
