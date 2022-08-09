
import HashEx;
import IntHashEx;

import haxe.ds.IntMap;
import haxe.ds.StringMap;

import haxe.EnumFlags;
import CrossConsts;

#if js
	error(stop)
#end

import EnumEx.Freq;

using Ex;

@:native("_RoomType")
@:build(ods.Data.build("Data.ods", "roomType", "id")) 			enum RoomType { }

@:native("_RoomId")
@:build(ods.Data.build("Data.ods", "rooms", "id")) 				enum RoomId { }

@:native("_Hid")
@:build(ods.Data.build("Data.ods", "heros", "id")) 				enum HeroId { }

@:build(ods.Data.build("Data.ods", "skills", "id")) 			enum SkillId{}

@:build(ods.Data.build("DataExt2.ods", "objectives", "id", { prefix : "OI_" })) 		enum ObjectivesId{}
@:build(ods.Data.build("DataExt.ods", "deaths", "id", { prefix : "DC_" })) 				enum DeathId{}

@:build(ods.Data.build("DataExt2.ods", "books", "id")) 			enum BookId { }

@:build(ods.Data.build("DataExt.ods", "disease", "id")) 		enum DiseaseId {}
@:build(ods.Data.build("DataEvents.ods", "decay_events", "id")) enum DecayEventId { }

@:native("_Aid")
@:build(ods.Data.build("DataAction.ods", "actions", "id")) 		enum ActionId {}
@:build(ods.Data.build("Data.ods", "rebel_center", "id")) 		enum RebelsId {}
@:build(ods.Data.build("Data.ods", "xyloph_database", "id")) 	enum XylophId {}
@:build(ods.Data.build("Data.ods", "room_status", "id")) 		enum RoomStatusId {}
@:build(ods.Data.build("Data.ods", "titles", "id")) 			enum TitlesId {}
@:build(ods.Data.build("DataExt.ods", "object_status", "id")) 	enum ItemStatusId {}

@:native("_Iid")
@:build( ods.Data.build("DataExt.ods", "objects", "id")) 		enum ItemId {}
@:build( ods.Data.build("Data.ods", "PAColors", "id")) 			enum PAColors {}
@:build( ods.Data.build("Data.ods", "heros_status", "id")) 		enum HeroFlags { }

@:native("_Prjid")
@:build( ods.Data.build("Data.ods", "projets", "id"))			enum ProjectId { }

@:native("_RschId")
@:build( ods.Data.build("Data.ods", "research", "id"))			enum ResearchId{}
@:build( ods.Data.build("DataEvents.ods", "events", "id")) 		enum EventId {}
@:build( ods.Data.build("DataTuto.ods", "tutoId", "id")) 		enum TUTO_STATE {}
@:build( ods.Data.build("DataExt.ods", "wounds", "id"))			enum Wounds	{}
//@:build( ods.Data.build("DataExt.ods", "triumph", "id"))		enum TriumphCause { }
@:build( ods.Data.build("Data.ods", "ships", "id"))				enum ShipStatsId { }

@:native("_SkId")
@:build( ods.Data.build("Data.ods", "Skins", "id"))				enum SkinId{}
@:build( ods.Data.build("DataExt2.ods", "neronAdmin", "id", { prefix : "NB_" } ))	enum NeronBiosLineId { }

@:build( ods.Data.build("DataEvents.ods", "glory_event", "id" )) enum GloryId { }
@:build( ods.Data.build("DataEvents.ods", "once", "id" )) enum OnceEventId{}
@:build( ods.Data.build( "DataEvents.ods", "funFacts", "id" )) enum FFId { }

@:native("_Vn")
@:build(ods.Data.build("DataEco.ods", "vanity", "id" )) 	enum Vanity { }
@:build(ods.Data.build("DataEco.ods", "fds", "id" )) 	enum FdsActionId { }

@:build(ods.Data.build("DataEco.ods", "conf", "id" )) 		enum GameConf { }
@:build(ods.Data.build("DataEco.ods", "casting", "id" )) 	enum CastRank{}
@:build(ods.Data.build("DataEvents.ods", "trade_events", "id" )) 	enum TransportEventId { }

typedef EvtTable =
{
	var desc : String;
	var weight : Int;
	var success : Bool;
	
	@:sep("+")
	var effects : Array<OdsEffect>;
}

typedef ShipStatsData =
{
	var	id : ShipStatsId;
	
	var life : Null<Int>;
	var atk_min : Null<Int>;
	var atk_max : Null<Int>;
	var hit : Null<Int>;
	var dodge : Null<Int>;
	var charge : Null<Int>;
	var armor : Null<Int>;
	var capacity : Null<Int>;
	
	var aggro_pool_cost : Null<Int>; 
	
	var name : String;
	var footnotes : String;
	
	var max_nb : Null<Int>;
	
	var aggro :Bool;
	var weight:Int;
	
	var can_shoot : Bool;
}

typedef SurgeryEvt = EvtTable;


typedef FdsData = 
{
	var id:FdsActionId;
	var name : String;
	var desc : String;
	var points : Int;
}

enum PlayerLiveInfos
{
	Sleeping;
	Active;
	Chatting;
	HasFailed;
	HasSucceeded;
}

enum Arms
{
	BARE_HAND;
	
	RIFLE;
	BLASTER;
	BLADES;
	ROCKET;
	
	GRENADE;
	
	FLAMES;
	
}

@:native("_isf")
enum ITEM_SYS_FLAGS
{
	ISO; // means this object whence not in hero inventory, is displayed in the iso client and not in the room inventory
}

enum OdsCrits
{
	AddDmg( d : Int );
	SubDmg( d : Int );
	AddMinDmg( d : Int );
	AddMaxDmg( d : Int );
	
	SubMinDmg( d : Int );
	SubMaxDmg( d : Int );
	
	MulDmg( d : Float );
	Splash( i : Int );
	
	Fire;
	Rand(  odd : Float, c : OdsCrits );
	Iter(  n : Int, c : OdsCrits);
	
	Wound( w : Wounds );
	RandWound;
	InstaGib(d : DeathId );
	
	DmgObj;
	DecrPa( c : PAColors );
	IncrPa( c : PAColors );
	
	
	DecrMoral;
	BackFire( fx : OdsCrits ) ;//fumble,drawbacks
	
	BreakWeapon;
	DropWeapon;
	
	SplashAll( dmin:Int, dmax:Int );
	SplashWound;
}

enum _RscId
{
	O2;
	FUEL;
}

enum Rule
{
	_GARDEN_FOOD_TO_REFECTORY;
	DAEDALUS_SHIELD;
	
	FIRE_SENSOR;
	ARMOUR_CORRIDOR;
	
	RADAR_TRANS_VOID;
	
	PROJECT_BACKUP;
	NERON_CORE_ERGONOMY;
	EQUIPMENT_SENSOR;
	
	NILS_CARLSSON_CONTACT;
	SIRIUS;
	
	GRAVITY_SIMULATOR;
	STELLAR_ANTENNA;
	PLANET_SCANNER;
}


enum HeroSymptom
{
	VOMIT;
	SPASM;
	RASH;
	AGGRO;
	BITE;
	DROOL;
	FOAM;
	
	VERTIGO;
	BAD_SLEEP;
	CROWD_FEAR;
	CAT_PHOBIA;
	CAT_ALLERGY;
	
	NAUSEA;
}

enum ExploreTagFlags
{
	MET_ALIEN;
}

typedef RoomData =
{
	var id : RoomId;
	var type : RoomType;
	var name : String;
	
	var objects : Array<ItemId>;
	
	var gender : Gender;
}

typedef RoomTypeData =
{
	var id : RoomType;
	var desc : String;

	var starting_status : Null < Array < RoomStatusId >> ;
	var capacity  : Int;
	var name : String;
	var has_closet : Bool;
}



typedef HeroesData = #if data_lite SHeroesData #else FHeroesData #end;

typedef SHeroesData =
{
	var id : HeroId;
	var name : String;
	var base_gender : Null<Gender>;
}

typedef FHeroesData =
{ > SHeroesData,
	var surname:String;
	
	var skills : Array<SkillId>;
	
	@:sep("+")
	var on_start_effects : Array<OdsEffect>;
	var col : Int;
}

typedef HeroDescData =
{
	id:HeroId,
	full:String,
	intro:String,
	mini:String,
	pres:String,
	community:Null<String>,
}

@:native('_G')
enum Gender
{
	@:alias("m")
	Male;
	
	@:alias("f")
	Female;
}

@:native('_Alg')
enum Align
{
	@:alias("g")
	Good;
	
	@:alias("n")
	Neutral;
	
	@:alias("b")
	Bad;
}

enum DiseaseSpread
{
	Alien;					//nothing 65%
	PsyTrauma;				//nothing 30%
	Contact;				//nothing 60%
	HurtByAlien;			//nothing ??%
	MushInfection;			//nothing 90%
	MushGift;
	Sex;					//nothing 75%
	Board;					//nothing 0%
	SpaceTravel;			//nothing 75%
	EatAlienFood;			//TODO
	Custom;
}

typedef SkillData =
{
	var id : SkillId;
	var name : String;
	
	var desc : String;
	var footnotes : String;
	
	@:sep("+")
	var effects: Array<OdsEffect>;
	
	var mush:Bool;
	var retained:Bool;
	var beta : Bool;
}

typedef RebelData =
{
	var id : RebelsId;
	
	var short_name : String;
	
	var name : String;
	var desc : String;
	var footnotes : Null<String>;
	
	@:sep("+")
	var effects: Array<OdsEffect>;
}

enum ObjectiveClasses
{
	OCSkill(s:SkillId);
	OCTitle(t:TitlesId );
	OCHero(h : HeroId );
	OCAny;
	OCMush;
	OCAnyButMush;
	OCSkillNotMush(s:SkillId);
}

enum ObjectiveValidator
{
	ACTION_DONE( a : ActionId );
	
	HEALED( hasMed: Bool);
	LOG_DONE( e : EventId );
	REPAIRED( e : ItemId );
	DROPPED(  e : ItemId , r : RoomId);
	PERSONNAL_ACHIEVEMENT( h : HeroId );
	NONE;
	HIDED(i:ItemId);
	INFECTED;
	PARASITED;
	PARASITED_COMMANDER;
}


typedef ObjectiveData =
{
	var id : ObjectivesId;
	
	var title : String;
	var desc : String;

	var type : ObjectiveClasses;

	@:sep("+")
	var cond : Array<OdsCondition>;
	
	var weight : Int;
	var important:Bool;
}

typedef DiseaseData =
{
	var id : DiseaseId;
	
	var name : String;
	var desc : String;
	
	var weight : Int;
	
	@:sep("+")
	var on_gain: Array<OdsEffect>;
	
	@:sep("+")
	var effects: Array<OdsEffect>;
	
	@:sep("+")
	var immune: Array<OdsCondition>;
	
	var dur_min : Int;
	var dur_max : Int;
	
	@:sep("+")
	var gain_on : Array<DiseaseSpread>;
	
	var need_shrink:Bool;
	var res :Int;
	var fr_cure : Bool;
	var fr_give : Bool;
}

typedef EventData =
{
	id : EventId,
	//name : String,
	line:String,
	line_f:Null<String>,
	//desc : Null<String>,
	
	line_inhib:Null<String>,
	line_crazy:Null<String>,
	line_evil:Null<String>,
	
	custom_css:Array<String>,
}

enum RdLoc
{
	Room( r: RoomId );
	RandomRoom ( r : RoomType );
	Nowhere;
	BaseLearner;
}

typedef BookData =
{
	var id : BookId;
	var title : String;
	var content : String;
	var rights:  Array<OdsCondition>;
	var cost : Int;
	
	@:sep("+")
	var effect : Array<OdsEffect>;
	var location : RdLoc;
}

typedef DeathData =
{
	id : DeathId,
	name : String,
	desc : String,
	short_desc:String,
}

typedef GlossaryData =
{
	name : String,
	desc : String,
}

typedef ActionData =
{
	var id 		: ActionId;
	var cost 	: Int;
	var name 	: String;
	
	var desc 	: String;
	var footnotes : Null<String>;
	var admin	: Bool;
	
	var proba : Null<Int>;
	var fail_coef:Null < Float>;
	var dirt: Null<Int>;
	var hurt: Null<Int>;
	
	var need_target : Bool;
	
	var filt : OdsSelector;
	
	@:sep("+")
	var enable : Array<OdsCondition>;
	
	var color  : PAColors;
	var displayInMenu : Bool;
	var confirm : Null<String>;
	var mush_confirm : Bool;
	
	var discrete : Bool;
	var stealth : Bool;
	var tracked: Bool;
	var aggro : Bool;
	
	var secteur : ActionSector;
	
	@:sep("|")
	var gmu_ok : Array<String>;
	
	@:sep("|")
	var gmu_failed : Array<String>;
}

typedef AcDataExt  = {
	>ActionData,
	var granter:InvItem;
}

typedef TitlesData =
{
	var id : TitlesId;
	var name:String;
	
	var desc:String;
	var priority : Array< HeroId >;
	
	@:sep("+")
	var effects: Array<OdsEffect>;
}

typedef ItemData = #if data_lite SItemData #else FItemData #end;

typedef SItemData =
{
	var id : ItemId;
	var name : String;
	var starting_status : Array<ItemStatusId>;
	var disassemble : Array<ItemId>;
}

typedef FItemData =
{	> SItemData,
	var gp_desc:String;
	var rep : Int;
	var actions: Array<ActionId>;
	
	@:sep("+")
	var effects: Array<OdsEffect>;
	
	var gender : Gender;
	var displayInMenu : Bool; //whether to display a selectable  icon with some attributes
	var footnotes:Null<String>;
	var sys_flags : Array<ITEM_SYS_FLAGS>;
	var electric : Null<Bool>;
}

typedef CraftEventData =
{
	var desc : String;
	var weight : Int;
	var success : Bool;
	
	@:sep("+")
	var effects: Array<OdsEffect>;
}

enum OdsItem
{
	@:alias( "i" )
	OI_Item( i : ItemId);
	
	@:alias( "r")
	OI_Ration( cs : ConsRationId );
	
	@:alias("rdBp")
	OI_RandomBluePrint;
	
	@:alias( "mb")
	OI_MageBook( sk : SkillId );
	
	@:alias( "rdMb")
	OI_RandomMageBook();
	
	@:alias("bp")
	OI_BluePrint( i : ItemId );
	
	@:alias("rdDr")
	OI_RandomDrugs;
	
	@:alias("dr")
	OI_Plant(i : Int );
	
	@:alias("rdWp")
	OI_RandomWeapon;
	
	OI_Fruit(i : Int );
}

typedef ResearchData =
{
	var id : ResearchId;
	
	var name:String;
	
	var desc:Null<String>;
	var footnotes: Null<String>;
	
	var glory:Null<GloryId>;
	var dif:Int;
	
	var samples : Array<ItemId>;
	
	var need_chun:Bool;
	var need_cryo:Bool;
	
	var actions: Array<ActionId>;
	var kill_sample : Null<ItemId>;
	
	@:sep("+")
	var effects : Array<OdsEffect>;
	
	var mush:Bool;
	
	var cond : Null<OdsCondition>;
}

typedef _DoorShipData =
{
	_id:Int,
	_x:Int,
	_y:Int,
	_di:Int,//[ 0 = E  1 =  S]
	_link:Array<_RoomShipData>,// first is in, second is out
}

typedef _RoomShipData =
{
	_id:RoomId,
	_pos:Array<{_x:Int,_y:Int}>,
	_doors:Array<_DoorShipData>,
}

typedef _SpaceShipData =
{
	_rooms:Array<_RoomShipData>,
	_doors:Array<_DoorShipData>,
}

typedef DoorShipData =
{
	id:Int,
	di:Dirs.E_DIRS,
	link:Array<RoomShipData>,// first is in, second is out
	poses:Array<V2I>,
}

typedef RoomShipData =
{
	id:RoomId,
	pos:Array<V2I>,
	doors:Array<DoorShipData>,
}

typedef SpaceShipData =
{
	rooms:Array<RoomShipData>,
	doors:Array<DoorShipData>,
	?roomsById : IntHash<RoomShipData>,
}

typedef ProjectData =
{
	var id : ProjectId;
	var name : String;
	var desc : String;
	var footnotes:String;
	
	var mod : Int;
	
	@:sep(",")
	var tags : Array<SkillId>;
	
	@:sep("+")
	var effects: Array<OdsEffect>;
	
	@:sep("+")
	var triggered : Array<OdsEffect>;
	
	var empower : Null<ItemId>;
	var plus : Bool;
	
	var beta : Bool;
}

typedef VanityData = 
{
	var id:Vanity;
	
	var name: String;
	var desc: String;
	
	var gen : Int;
}

@:native("_Dup")
enum DronePowerUp
{
	DPU_REPAIR_EQUIPMENT;
	DPU_EXTINGUISH_FIRE;
	DPU_DRIVE_SPACE_SHIP;
	DPU_PATHFIND;
	DPU_ENHANCED;
}

//this is the unique identifier of a player in the game
typedef HeroSId = Int;

typedef ProjectInfos =
{
	id : ProjectId,
	progress : Int,//[0,100]
	active : Bool,
	deleted : Bool,
	touch : { id : HeroSId, qty:Int },
}


typedef DecayEventData =
{
	var id: DecayEventId;
	var desc : String;
	var decayPoint : Int;
	var weight : Int;
}

typedef BluePrintData =
{
	var object_id : ItemId;
	
	//var need_skill : Array<SkillId>;
	var need_items : Array<ItemId>;
	
	//@:sep("+")
	//var needs : Array<OdsCondition>;
	var weight : Int;
}


typedef  ShipConsts =
{
	var MIN_DELAYS_BETWEEN_SCANS : Int;
	var PATROL_SHIP_FREE_MOVES : Int;
	
	var DAEDALUS_SHIELD_REGEN : Int;
	var ICARUS_RETRIEVE_CYCLE : Int;
	var ICARUS_CAPACITY : Int;
	var NERON_SELF_COMPUTE : Int;
	var REBEL_DECODE_FACTOR : Int;
	var AUTO_WATERING : Int;
	
}

typedef TeaseQuizzQuestion =
{
	var id:QuizzId;
	var label : String;
	var we : Int;
	var sub : Array<TeaseQuizzAnswer>;
	var n: Int;
}

typedef TeaseQuizzAnswer =
{
	var _line:String;
	var _favor:Array<String>;
	var _n:Bool;
}

enum BinOp
{
	LE;
	LT;
	GT;
	GE;
}

enum PHeroFlags
{
	AC_PUBLIC_BROADCAST_DONE;
	HAS_SLEEPED_ONCE;
	PF_NIGHTMARE;
	HUNT_LIST_PRINTED;
	ACTION_DISALLOWED;
	RUBIKS_CUBE_SOLVED;
	CAT_CARESSED;
	PF_CEASE_FIRE;
	PF_LEARN_USED;
	GOLD_ONCE;
	
	BETA_REQUESTED;
	SKIN_REFRESHED;
	
	PUTSCHIST;
}

enum OdsEffect
{
	DecrActionCost( a : ActionId , d : Int );
	MulActionCost( a : ActionId , d : Float );
	
	SpawnItem( i : ItemId, r : RoomId );						//spawn item in the room whence first renovated
	GenItem( i :OdsItem,l:RoomId );
	GiveItem( i : ItemId );
	GiveBlueprint( i : ItemId );
	EnableRule( r : Rule );
	
	
	GrantAction( a : ActionId );
	ForbidAction( a : ActionId );
	
	DeletePA( c : PAColors );
	IncrMaxPA( c : PAColors, d: Int );
	DecrMaxPA( c : PAColors, d: Int );
	
	IncrPAPerCycle( c : PAColors, d: Int );
	DecrPAPerCycle( c : PAColors, d: Int );
	
	IncrPAPerDay( c : PAColors, d: Int );
	DecrPAPerDay( c : PAColors, d: Int );
	
	IncrPMPerTransfert( v:Int );
	DecrPMPerTransfert( v:Int );
	
	IncrActionOdd( a : ActionId  , i : Int );
	MulActionOdd( a : ActionId  , v : Float );
	MulEngActionOdd( v : Float );
	BoostActionOdd( a : ActionId ); //applis the fail oef once
	
	
	StartingItem( i:ItemId );
	
	DivActionCost( a : ActionId, v : Int );
	
	@:alias('chk')
	CheckAccess( o : OdsCondition );//hero has access ONLY under conditions
	
	LoseComLink;
	LoseComLinkQual( d : Int);
	
	ToHit(b : Int);
	NoMoreHeavy;
	
	EarnMoral( d: Int );
	
	DecrMoral( d : Int );
	DecrMaxMoral( d : Int );
	DecrMaxHp( h : Int );
	

	CrewEarnMoral( d: Int );
	
	IncrHunger( d : Int);
	
	DealDmg( d : Int, ?dd : DeathId );
	GainPA( col : PAColors, d :Int );
	
	GrantSkill( s : SkillId );
	
	@:alias("oc")
	OnCycle( fx : OdsEffect );
	
	OnDay( fx : OdsEffect );
	
	@:alias("oa")
	OnAction( a : ActionId, fx : OdsEffect );
	
	@:alias("os")
	OnSpawn( fx : OdsEffect );
	
	@:alias("rd")
	Random( f : Float, fx : OdsEffect );
	
	IfMush( fx : OdsEffect );
	
	IncAcCol( c : PAColors, d : Int );
	NoAcCol( c: PAColors );
	
	LosePA( c : PAColors, d : Int );
	
	AddWound( w : Wounds );
	AddWoundR( f : Float, w : Wounds );
	
	AddDisease( d: DiseaseId);
	AddStatus( s : HeroFlags );
	
	AddDelayedDisease( d: DiseaseId, min:Int, max:Int);
	
	CureDisease( d : DiseaseId );
	DeathOnStatus(s : HeroFlags );
	
	IncrDisease;
	
	NoVoice;
	NoHear;
	
	Symptom( hs : HeroSymptom );
	
	//DecrHygiene( d : Int );
	Dirtify;
	
	GrantTriumph( c:GloryId );
	
	@:alias("gct")
	GrantCrewTriumph( c:GloryId );
	
	PrintBook( b: BookId );
	PrintItem( i : OdsItem );
	
	GrantHP( d : Int );
	
	DeltaNurture( d : Int );
	SpawnConsumable( t : SkinType,v : Int);
	
	SideEffect( e : OdsSideEffect, txt : String );
	SideEffectR( odd : Float, e : OdsSideEffect, txt : String );
	
	NTimes( n:Int, o : OdsEffect );
	MageBook;
	
	IncrCCDmg( v: Int );//increases close combat damages
	
	DecrShopPrice(v:Int);
	Mushify;
	
	MushifyProg;
	
	NeronDepress;
	
	EraseImmunity;
	
	If( oc : OdsCondition, fx : OdsEffect );
	
	RemovePStatus( pf : PHeroFlags );
	
	TryMushDisease;
	
	BreakItem;
}

enum OdsSideEffect
{
	BreakSomeDoors;
}

enum DailyProp
{
	Action( ac : ActionId );
}

enum CrossCondition
{
	CC_ProjectUnlocked( p : ProjectId );
	CC_ResearchUnlocked( r : ResearchId );
	CC_And(c1 :CrossCondition, c2 : CrossCondition);
	CC_Or(c1 :CrossCondition, c2 : CrossCondition);
	CC_TestPatrol( k : String);
	CC_True;
	CC_False;
	CC_RoomItemHas( i : ItemId );
	CC_MushBody;
	CC_PilgredUnlocked;
	CC_IcarusLanded;
	CC_Not(c:CrossCondition);
}

enum OdsCondition
{
	BeAlone;
	IsMush;
	Not( a : OdsCondition );
	Or( a : OdsCondition, b : OdsCondition );
	HasSkill( a : SkillId );
	
	IsAccessing( i : ItemId );
	
	HasTitle( a : TitlesId );
	WeakTitle( a : TitlesId );
	
	@:alias("isH")
	IsHero( h :HeroId );
	HasStatus( a :HeroFlags );
	
	HasDisease( d : DiseaseId );
	HasSymptom( s : HeroSymptom );
	
	HasPsyDisease;
	HasPhyDisease;

	RoomIs(  a : RoomId  );
	RoomTypeIs(  a : RoomType  );
	RoomStatusIs( s : RoomStatusId );
	RemoteRoomStatusIs( r:RoomType,s : RoomStatusId );

	RoomEquipmentHas( i : ItemId );
	RoomSkillHas( s :  SkillId );
	
	
	ItemIs( s : ItemId );
	ItemStatusIs( s : ItemStatusId );
	ItemHasSkin;
	ItemSkinTypeIs( s : SkinType);
	ItemCanBeBroken;
	
	InHand;
	ProjectUnlocked( p : ProjectId );
	ResearchUnlocked( r : ResearchId );
	RebelContacted( r : RebelsId );
	XylophUnlocked( x : XylophId );

	ProjectNeeds( s : SkillId );
	PilotLocked;
	RebelSignalsPending;
	
	ShipHasHunters;
	ShipHasPlanet;
	ShipEmptyPot;
	ShipLinked;
	
	ShipEquipmentBroken(d:ItemId);
	ShipEquipmentHas( i : ItemId );
	ShipHasExpe;
	ShipWasDoneOnce( a : DailyProp );

	
	And( a:OdsCondition, b :OdsCondition);
	Never;
	
	NeedItem( i : ItemId);
	NeedItems( i : ItemId, n:Int);
	HasLandedOnPlanet;
	IsTuto;
	
	RoomItemHas( i : ItemId );
	RoomHasBrokenItem;
	RoomHasBrokenEquipment;
	RemoteRoomItemHas( rid: RoomId, i : ItemId );
	
	RemoteRoomItemHasSkin( rid: RoomId, i : ItemId, sk : SkinType );

	HeroLifeLt(v:Int);
	HeroFullLife;
	HeroMoralLt(v:Int);
	HeroDiseased;
	HeroWounded;
	HeroLocked;
	HeroHasScanedPlanet;
	HeroItemHas(id : ItemId );
	HeroLvlGe( i : Int );
	
	HeroHungry;
	HeroCanEat;
	HeroModuling;
	
	PlantNeedWater;
	PlantNeedTreatment;
	
	HeroPopGt( i : Int );
	HeroPopLt( i : Int );
	HeroRoomPopEq( i : Int );
	HeroCanBroadcast;
	
	HeroMoralGt( i:Int );
	HeroMoralGe( i:Int );
	HeroMoralLe( i:Int );
	
	HeroPaLT( c : PAColors, i : Int );
	HeroPaGT( c : PAColors, i : Int );
	
	HasSpore;
	
	SomeNeedMedic;
	
	BaseAction;
	
	ItemIsChargeable;
	ItemIsRation;
	
	WasDoneToday( d: DailyProp );
	
	GameStarted;
	IsPilgredOk;
	
	HeroTest( hid : HeroId, cnd : OdsCondition );
	HeroTitleTest( t : TitlesId, cnd : OdsCondition );
	ShipHasDrone;
	
	HasDoneAction( ac : ActionId );

	IsBeta;
	
	IsEdenComputed;
	
	HeroIsNoob;
	IsCasting;
	
	IsBerzerk;
}

typedef _Pair =
{
	var first : HeroId;
	var second : RoomId;
}

typedef HeroFlagsData =
{
	var id : HeroFlags;
	var name : String;
	var desc : String;
	var visible : Bool;
	var is_public : Bool;
	
	@:sep('+')
	var effects : Array<OdsEffect>;
	
	var lost_on_mutation : Bool;
}

typedef SkinData =
{
	var id:SkinId;
	var TREE_name:String;
	var TREE_desc:String;
	var TREE_gender:Gender;
	
	var FRUIT_name:String;
	var FRUIT_desc:String;
	var FRUIT_bg:String;
	
	var FRUIT_gender:Gender;
}


enum PatrolStance
{
	Attack;
	Flee;
	Bait;
}

enum ActionTarget
{
	TgtItem( i : InvItem );
	TgtItemId( i : ItemId );
	TgtHero( h : HeroId );
	TgtRoom( i : RoomId );
	TgtPlanet( p : Int );
	TgtResearch(r: ResearchId );
	
	TgtProject( p : ProjectId );
	
	TgtForIncinerateRations();
	TgtRebel(r:RebelsId) ;
	
	TgtOrientation(o:Orientation);
	TgtStance( p : PatrolStance );
	
	TgtIndex( i : Int );
	TgtPowerUp( p : DronePowerUp );
	TgtSkill( s : SkillId );
	
	TgtPnj( pubId : Int );
	
	TgtTrade(d:TransportEventId,slot:Int );
}

enum RandCat
{
	Base;
	Store;
	SickBay;
	Refectory;
}

typedef RdObjData =
{
	id : OdsItem,
	nb : Int,
	cat : RandCat,
	checkSame : Bool,
}

typedef DaedalusObj =
{
	id : ItemId,
	where : RoomId,
}

typedef XylophData =
{
	var id : XylophId;
	
	var name : String;
	var desc : String;
	var notes : String;
	
	var weight : Int;
	
	@:sep("+")
	var effects : Array<OdsEffect>;
}



typedef ExpToolData = {
	id:ItemId,
	hitMin:Null<Int>,
	hitMax:Null<Int>,
	hitRate:Null<Int>,
	charge:Int,
	cat:Arms,
	power:Null<Int>,
	weight:Int,
}


enum TAtkEvt
{
	NORMAL;
	FUMBLE;
	CRITIC;
	MISS;
}

typedef CritData =
{
	var cat : Arms;
	var weight : Int;
	var line : String;
	
	@:sep("+")
	var effects : Array<OdsCrits>;
	
	var type : TAtkEvt;
}

enum TriumphType
{
	Mush;
	Both;
	Human;
	Character;
	None;
}

typedef GloryEventData =
{
	id	: GloryId,
	score:Int,
	type:TriumphType,
	range:String,
	name:String,
	desc:String,
	
	who:Null<HeroId>,
	brief:Null<String>,
	
	rdmt:Null<Int>,
	beta:Bool,
}

typedef WoundData =
{
	var id : Wounds;
	
	var name : String;
	var desc : String;
	
	var hp_sub : Int;
	var weight : Int;
	
	@:sep("+")
	var on_wound 	: Array<OdsEffect>;
	
	@:sep("+")
	var effects   	: Array<OdsEffect>;
	
	var over_ride : Null<Wounds>;
}

typedef Bg=
{
	id : ItemId,
	bg:String
}


typedef RoomAsString =
{
	var id:String;
	var gender:String;
}

typedef HeroesAsString =
{
	var id:String;
	var surname:String;
	var col:Int;
	var initials:String;
}

typedef RoomIdAsString =
{
	var id:String;
	var capacity:Int;
}

typedef ItemAsString =
{
	var id:String;
	var gender:String;
}

typedef ComputedMapData =
{
	//public var initialCrew : Array<HeroId>;
	public var maxCrew : Int;
}

typedef TextData =
{
	id:String,
	t:String,
}

typedef PAData =
{
	id: PAColors,
	label:String,
	name:Null<String>,
	desc:Null<String>,
}


typedef TutoData =
{
	st:TUTO_STATE,
	cmd: TUTO_CMD,
	txt : Null<String>,
	index:Null<Int>,
}

typedef  FFData =
{
	id:FFId,
	name:String,
	desc:String,
}

/*
typedef TriumphData =
{
	id:TriumphCause,
	name:String,
	desc:String,
}
*/

typedef RoomTypeIdTextData =
{
	id:String,
	desc:String,
}

typedef QuipData =
{
	var note:String;
}

typedef NeronBiosData =
{
	var id : NeronBiosLineId;
	var name : String;
	
	var value0 : String;
	var value1 : String;
	
	var value2 : Null<String>;
	var value3 : Null<String>;
	var dflt : Int;
	
	@:sep("+")
	var disp_cond : Array<OdsCondition>;
	var desc : String;
}

typedef MonsterData =
{
	var id : MonsterId;
	var str :  Int;
	var name : String;
	var desc:  String;
	var kind : PlanetTag;
	var gender : Gender;
}

typedef ActionFkData =
{
	var ac:ActionId;
	
	var cond:OdsCondition;
	var text:String;
}

typedef ProjectAsString =
{
	id:String,
	x:String,
}

typedef ResearchAsString =
{
	id:String,
	x:String,
}

typedef SongData =
{
	var name: String;
	var author: String;
	var fan: HeroId;
}

typedef LevelData =
{
	id:Int,
	xp:Int,
	nb_skill:Int,
}

typedef MushLevelData =
{
	id:Int,
	xp:Int,
	skills:Array<SkillId>,
}

typedef OnceEventData =
{
	id:OnceEventId,
	desc:String,
	centered:Bool,
	div_id:Null<String>,
	script:Null<String>,
	need_confirm:Bool,
}

typedef GameConfData = { id:GameConf, name:String,desc:String,foot:String}
typedef CastingRankData = { id:CastRank, name:String, desc:Null<String>, foot:String, 
xp_add:Int, size_add:Int, 
opt:Null<GameConf> }

typedef HeroSkinData = {
	hid:HeroId,
	sk:Int,
	y:Int,
	brief:String,
}

@:keep
class Protocol
{
	
	#if neko
	static var _dep1 = Config;
	static var _dep2 = Gen;
	
	public static function getCacheFile(str)
		return Config.TPL + str;
	#end
	

	public static var roomList 				= ods.Data.parse( "Data.ods", "rooms", RoomData );
	public static var roomTypeList 			= ods.Data.parse( "Data.ods", "roomType", RoomTypeData );
	public static var itemList 				= ods.Data.parse( "DataExt.ods", "objects", #if data_lite SItemData #else FItemData #end );
	
	public static var artefactList 			= itemList.fold(function(i, r : Array<ItemId>) {
			if (i.starting_status.has(ARTEFACT))
				r.pushBack( i.id );
			return r;
		},[]);
	
	public static var heroesList :Array<HeroesData>	=  ods.Data.parse( "Data.ods", "heros", #if data_lite SHeroesData #else FHeroesData #end );
	public static var roomIdList 					=  ods.Data.parse( "Data.ods", "rooms", RoomAsString );
	public static var roomTypeIdList 				=  ods.Data.parse( "Data.ods", "roomType", RoomIdAsString );
	public static var heroesIdList 					=  ods.Data.parse( "Data.ods", "heros", HeroesAsString );
	public static var itemIdList 					=  ods.Data.parse( "DataExt.ods", "objects", ItemAsString );
			
	public static var projectIdList 				=  ods.Data.parse( "Data.ods", "projets", ProjectAsString );
	public static var researchIdList 				=  ods.Data.parse( "Data.ods", "research", ResearchAsString );
	public static inline function roomDb( id:RoomId )				return roomList[ Type.enumIndex(id) ];
	public static inline function itemDb( id:ItemId  ) : ItemData	return itemList[ Type.enumIndex(id) ];
	
	public static var shipStatsList 								= ods.Data.parse( "Data.ods", "ships", ShipStatsData );
	public static inline function shipStatsDb(id:ShipStatsId) 		return shipStatsList[Type.enumIndex( id ) ];
	
	public static var heroSkins = ods.Data.parse( "DataEco.ods", "heroSkins", HeroSkinData );
	
	public inline static function getHeroSkin(hid:HeroId, sk:Int)
	{
		return heroSkins.find( function(ske) return ske.hid == hid && ske.sk == sk );
	}
	
	public static function getHeroes() : Array<HeroesData>
	{
		return heroesList.filter(function(h) return h.id != ADMIN);
	}
	
	#if !data_lite
	public static var paList 									= ods.Data.parse( "Data.ods", "PAColors", PAData );
	public static var skillList :Array<SkillData>				= ods.Data.parse( "Data.ods", "skills", SkillData );
	public static var actionList :Array<ActionData>				= ods.Data.parse( "DataAction.ods", "actions", ActionData );
	static var actionFkList 									= ods.Data.parse( "DataAction.ods", "fake", ActionFkData );
	public static var titleList 								= ods.Data.parse( "Data.ods", "titles", TitlesData );
	public static var eventList 								= ods.Data.parse( "DataEvents.ods", "events", EventData);
	public static var deathList 								= ods.Data.parse( "DataExt.ods", "deaths", DeathData);
	public static var glossaryDb 								= ods.Data.parse( "DataExt.ods", "glossary", GlossaryData);
	public static var researchList 								= ods.Data.parse( "Data.ods", "research", ResearchData);
	public static var heroFlagsList  							= ods.Data.parse( "Data.ods", "heros_status", HeroFlagsData );
	public static var projectList 								= ods.Data.parse( "Data.ods", "projets", ProjectData );
	public static var randomObjects 							= ods.Data.parse( "DataExt.ods", "random_objects", RdObjData );
	public static var bluePrints								= ods.Data.parse( "DataExt.ods", "blueprints", BluePrintData );
	public static var daedalus_objects  						= ods.Data.parse( "DataExt.ods", "daedalus_objects", DaedalusObj );
	public static var heroDesc			  						= ods.Data.parse( "DataDesc.ods", "char_desc", HeroDescData );
	public static var skinList 									= ods.Data.parse( "Data.ods", "Skins", SkinData);
	public static var xylophList								= ods.Data.parse( "Data.ods", "xyloph_database", XylophData);
	public static var rebelList									= ods.Data.parse( "Data.ods", "rebel_center", RebelData);
	public static var objects_bg_list 							= ods.Data.parse( "DataExt.ods", "objects_background",  Bg );
	public static var diseaseList 								= ods.Data.parse( "DataExt.ods", "disease",  DiseaseData );
	public static var atk_evt 									= ods.Data.parse( "DataEvents.ods", "atk_evt", CritData );
	public static var surgeryEvt 								= ods.Data.parse( "DataEvents.ods", "surgery_event", SurgeryEvt );
	public static var levels 									= ods.Data.parse( "DataEco.ods", "levels", LevelData);
	public static var mush_levels								= ods.Data.parse( "DataEco.ods", "mush_levels", MushLevelData);
	static var vanities 										= ods.Data.parse( "DataEco.ods", "vanity", VanityData);
	
	public static var fds 										= ods.Data.parse( "DataEco.ods", "fds", FdsData);
	public static var songs 									= ods.Data.parse( "DataEco.ods", "songs", SongData);
	
	public static var tuto 											=
	{
		var a = ods.Data.parse( "DataTuto.ods", "tutorial", TutoData );
		var i = 0;
		for ( l in a)
		{
			l.txt = TextEx.quickFormat( l.txt );
			if ( l.txt != null) {
				l.txt = StringTools.htmlUnescape(l.txt);
				l.txt = l.txt.split("$n").join( Text.neron_eye);
			}
			l.index = i++;
		}
		a;
	}
	
	public static function getGroupRankXpNeed(c: CastingRankData)
	{
		var sum = 0;
		
		for ( g in castingData)
		{
			sum += g.xp_add;
			if( g.id == c.id ) return sum;
		}
		
		return sum;
	}
	
	public static function getGroupRankOf(xp:Int)
	{
		var cur = castingData[0];
		for ( i in 0...castingData.length)
		{
			var cd = castingData[i];
			xp -= cd.xp_add;
			if ( xp < 0 ) return cur;
			cur = castingData[i];
		}
		return cur;
	}
	
	public static function getGroupRankMaxSize(c: CastingRankData)
	{
		var sum = 0;
		
		for ( g in castingData)
		{
			sum += g.size_add;
			if( g.id == c.id ) return sum;
		}
		
		return sum;
	}
	
	public static function getVanitiesId()
	{
		var g = db.Variable.getInt("vanity_gen");
		return Vanity.array().filter( function(vi) return vanities[vi.index()].gen <= g );
	}
	
	public static function allVanities()
	{
		return vanities;
	}
	
	public static function getVanities()
	{
		var g = db.Variable.getInt("vanity_gen");
		return vanities.filter( function(vd) return vd.gen <= g ).array();
	}
	
	static var descCache : EnumHash<HeroId,HeroDescData> =
	{
		var h = new EnumHash( HeroId );
		
		for ( e in heroDesc)
			h.set( e.id, e);
			
		h;
	}
	
	public static function getHeroDesc(hid:HeroId)	: HeroDescData		return descCache.get( hid );
	
	
	
	public static var quipList 											= ods.Data.parse( "DataExt2.ods", "quips", QuipData );
	public static var atk_dispatch = null;
	public static var woundList 										= ods.Data.parse( "DataExt.ods", "wounds", WoundData );
	public static var bookList 											= ods.Data.parse( "DataExt2.ods", "books", BookData );
	public static var decayEventList 									= ods.Data.parse( "DataEvents.ods", "decay_events", DecayEventData );
	public static var onceList 											= {
		var a = ods.Data.parse( "DataEvents.ods", "once", OnceEventData );
		for (v in a)
			v.desc = StringTools.htmlUnescape(TextEx.quickFormat( v.desc ));
		a;
	}
	
	public static var planetTags										= ods.Data.parse( "DataExplore.ods", "planetTags", PlanetTagData );
	public static var planetEvents										= ods.Data.parse( "DataExplore.ods","explo",ExploEventData );
	public static var planetSyl											= ods.Data.parse( "DataExplore.ods", "planet_syl", PlanetSyl );
	public static var consumables										= ods.Data.parse( "DataConsumable.ods", "consumable_effects", ConsumableEffectData );
	public static var rations											= ods.Data.parse( "DataConsumable.ods", "rations", RationData );
	public static var itemStatuses										= ods.Data.parse( "DataExt.ods", "object_status", ItemStatusData );
	public static var neronBios											= ods.Data.parse( "DataExt2.ods", "neronAdmin", NeronBiosData );
	public static var toolList											= ods.Data.parse( "DataExt2.ods", "tools_data", ExpToolData );
	public static var monsterList										= ods.Data.parse( "DataExplore.ods", "monster", MonsterData );
	public static var gloryList											= ods.Data.parse( "DataEvents.ods", "glory_event", GloryEventData );
	public static var teaseQuizz 										= ods.Data.parse( "DataTease.ods", "quizz", TeaseQuizzQuestion );
	public static var confData 											= ods.Data.parse( "DataEco.ods", "conf", GameConfData);
	public static var castingData 										= ods.Data.parse( "DataEco.ods", "casting", CastingRankData);
	public static var transportList:Array<TransportEventData> 			= ods.Data.parse( "DataEvents.ods", "trade_events", TransportEventData);
	
	public static inline function heroFlagsDb( id )						return heroFlagsList[ Type.enumIndex(id) ];
	public static var worldItems 										= Protocol.itemList.filter(function(i) return i.starting_status.has(WORLD))
																		.map(function(i) return i.id);
									
	public static function isSkillRetained(s){
		return skillDb( s ).retained;
	}
	
	static function qn(id)
	{
		return Protocol.heroesDb( id ).surname;
	}
	
	//BEGIN MODULE
	public static var validQuizzTags : Array<Array<Dynamic>>=
	[
		["EW", "img/icons/portraits/mini/eleesha_williams.png", qn(ELEESHA_WILLIAMS) ,	ELEESHA_WILLIAMS],
		["FK", "img/icons/portraits/mini/finola_keegan.png"    ,qn(FINOLA_KEEGAN)	,	FINOLA_KEEGAN	],
		["FB", "img/icons/portraits/mini/frieda_bergmann.png"  ,qn(FRIEDA_BERGMANN)	,	FRIEDA_BERGMANN	],
		["GR", "img/icons/portraits/mini/gioele_rinaldo.png"   ,qn(GIOELE_RINALDO)	,	GIOELE_RINALDO	],
		["IS", "img/icons/portraits/mini/ian_soulton.png"      ,qn(IAN_SOULTON)		,	IAN_SOULTON	],
		["JK", "img/icons/portraits/mini/janice_kent.png"      ,qn(JANICE_KENT)		,	JANICE_KENT	],
		["JH", "img/icons/portraits/mini/jiang_hua.png"        ,qn(JIANG_HUA)		,	JIANG_HUA	],
		["KJS","img/icons/portraits/mini/kim_jin_su.png"       ,qn(KIM_JIN_SU)		,	KIM_JIN_SU	],
		["LKT","img/icons/portraits/mini/lai_kuan_ti.png"      ,qn(LAI_KUAN_TI)		,	LAI_KUAN_TI	],
		["PR", "img/icons/portraits/mini/paola_rinaldo.png"    ,qn(PAOLA_RINALDO)	,	PAOLA_RINALDO	],
		["RT", "img/icons/portraits/mini/raluca_tomescu.png"   ,qn(RALUCA_TOMESCU)	,	RALUCA_TOMESCU	],
		["RZ", "img/icons/portraits/mini/roland_zuccali.png"   ,qn(ROLAND_ZUCCALI)	,	ROLAND_ZUCCALI	],
		["SS", "img/icons/portraits/mini/stephen_seagull.png"  ,qn(STEPHEN_SEAGULL)	,	STEPHEN_SEAGULL	],
		["TA", "img/icons/portraits/mini/terrence_archer.png"  ,qn(TERRENCE_ARCHER)	,	TERRENCE_ARCHER	],
		["WC", "img/icons/portraits/mini/wang_chao.png"        ,qn(WANG_CHAO),			WANG_CHAO	],
		["ZC", "img/icons/portraits/mini/zhong_chun.png"      ,qn(ZHONG_CHUN),		ZHONG_CHUN		],
		["SCH","img/icons/ui/cat.png",Text.cat_name,         						null	 	],
	];
	
	public static var drugsName											= Text.drug_name.split(",");
	
	public static var funFacts	:EnumHash<FFId,FFData>										=
	{
		var e = new EnumHash(FFId );
		var a = ods.Data.parse( "DataEvents.ods", "funFacts", FFData);
		for (v in a)
		{
			v.desc = StringTools.htmlUnescape(TextEx.quickFormat( v.desc ));
			e.set( v.id, v );
		}
		e;
	}
	
	
	
	public static function worldItem2Rules(it:ItemId) : Rule
	{
		try
		{
			return Type.createEnum( Rule, Std.string(it) );
		}
		catch(d:Dynamic)
		{
			return null;
		}
	}
	
	public static var objectivesList 									= ods.Data.parse( "DataExt2.ods", "objectives", ObjectiveData );
	public static function getHeroesData() 								return heroesList.filter(function(h) return h.id != ADMIN);
	
	static var mkData =
	{
		diseaseList.iter(function(e) e.effects.iter( function(fx) e.desc += TextLogic.textEffect(fx)));
		woundList.iter(function(e) e.effects.iter( function(fx) e.desc += TextLogic.textEffect(fx)));
		
		eventList.iter(function(e:EventData){
			if(e.line!=null) 		e.line = (StringTools.htmlUnescape(e.line));
			
			if(e.line_evil!=null) 	e.line_evil	 = (StringTools.htmlUnescape(e.line_evil));
			if(e.line_inhib!=null) 	e.line_inhib = (StringTools.htmlUnescape(e.line_inhib));
			if(e.line_crazy!=null) 	e.line_crazy = (StringTools.htmlUnescape(e.line_crazy));
			if(e.line_f!=null) 		e.line_f	 = (StringTools.htmlUnescape(e.line_f));
		});
		
	heroDesc.iter( function(e) { e.full = StringTools.htmlUnescape(e.full ); } );
	heroFlagsList.iter( function(e) { e.desc = StringTools.htmlUnescape(e.desc ); } );
	
	itemList.iter(function(e){
		e.gp_desc = StringTools.htmlUnescape(e.gp_desc);
		e.gp_desc = TextEx.quickFormat( e.gp_desc );
		
		var tdb = toolDb( e.id );
		var powLit = "";
		
		if ( tdb != null )
			powLit = "<li>" + Text.expe_weapon_pow( { x:tdb.power } ) + "</li>";
			
		if ( e.footnotes != null )
		{
			e.gp_desc += "<ul>" +
			ArrayEx.wrap( TextEx.quickFormat( e.footnotes ).split("\n"), "<li>", "</li>").join("")
			+powLit+"</ul>";
		}
		else
		{
			if( powLit.length > 0)
				e.gp_desc += "<ul>" + powLit +"</ul>";
		}
	});
		
		researchList.iter( function(e)
		{
			if ( e.footnotes == null) e.footnotes = "";
			if ( e.glory != null )
				e.footnotes += Text.rschGlory( { t:gloryList[e.glory.index()].score } );
				
			e.footnotes = TextEx.quickFormat( e.footnotes );
		});
		
		researchList.iter( function(e)
		{
			e.desc = TextEx.quickFormat( StringTools.htmlUnescape(e.desc) );
			e.footnotes = TextEx.quickFormat( StringTools.htmlUnescape(e.footnotes) );
		});
		
		bookList.iter( function(e) {
			if(e.content!=null)
				e.content = StringTools.htmlUnescape(e.content);
		});
		
		paList.iter( function(e) {
			if(e.desc!=null)
				e.desc = StringTools.htmlUnescape(e.desc);
		});
		
		projectList.iter( function(e)
		{
			e.desc = TextEx.quickFormat( StringTools.htmlUnescape(e.desc));
			if ( e.footnotes == null) e.footnotes = "";
			e.footnotes = TextEx.quickFormat( StringTools.htmlUnescape(e.footnotes) );
		});
		

		heroFlagsList.iter(function(e) e.desc = TextEx.quickFormat( e.desc ) );
		itemStatuses.iter(function(e) e.desc = TextEx.quickFormat( e.desc ) );
		
		objectivesList.iter( function( l ) { l.desc = TextEx.quickFormat( l.desc ); l.desc = StringTools.htmlUnescape(l.desc);  } );
		
//		throw objectivesList[ DISHEARTENING_CONTACT.index() ];
		rebelList.iter( function(e)
		{
			if (e.footnotes == null )
				e.footnotes = e.effects.map( TextLogic.textEffect ).join("\n");
				
			if ( e.footnotes !=null)
				e.desc += "<ul>" + ArrayEx.wrap( TextEx.quickFormat( e.footnotes ).split("\n"), "<li>", "</li>").join("") + "</ul>";
			e.desc =  TextEx.quickFormat( e.desc );
		});
		
		for ( a in actionList)
		{
			if (a.stealth)			a.desc += StringTools.htmlUnescape(Text.ac_stealth);
			if (a.discrete)			a.desc += StringTools.htmlUnescape(Text.ac_discrete);
			if (a.aggro)			a.desc += StringTools.htmlUnescape(Text.ac_aggressive);
			
			if (a.footnotes != null)
			{
				var ft = StringTools.htmlUnescape(a.footnotes).split("\n");
				a.desc +=  "<ul>" + ft.map(function(s) return "<li>"+s+"</li>").join("") +"</ul>";
			}
			
			if(a.confirm!=null)
				a.confirm = StringTools.htmlUnescape( a.confirm);
			a.desc = StringTools.htmlUnescape( a.desc);
			a.desc = TextEx.quickFormat( a.desc );
			
		}
		
		onceList.iter(function(e)
		{
			e.desc = TextEx.quickFormat( e.desc );
		});
		
		skillList.iter(function(e)
		{
			var ft = e.footnotes.split("\n");
			e.desc = StringTools.htmlUnescape(e.desc);
			e.desc +=  "<ul>" + ft.map(function(s) return "<li>"+s+"</li>").join("") +"</ul>";
			e.desc = TextEx.quickFormat( e.desc );
			e.desc = TextEx.attrify(e.desc);
		});
		
		for( l in teaseQuizz)
			for (s in l.sub)
				for ( f in s._favor)
					mt.gx.Debug.assert( Protocol.validQuizzTags.test( function(e) return e[0] == f || f == "OTHERS" ), "no such tag as "+f);
			
		var csz = 0;
		castingData.iter(function(e)
		{
			csz += e.size_add;
			if ( e.desc == null) e.desc = "";
				e.desc += Text.grp_max_size( { nb : csz } );
			e.desc += "<br/><em>"+e.foot+"</em>";
		});
		
		confData.iter(function(e)
		{
			e.desc += "<br/><em>"+e.foot + "</em>";
		});
		
		var _ = criticalDb(BLASTER);
		
		
		null;
		
	}
								
	static var fkCache : algo.MultiEnumHash<ActionId,ActionFkData> =
	{
		var r = new algo.MultiEnumHash(ActionId);
		for ( a in actionFkList)
			r.set( a.ac, a );
		r;
	}
	
	public static function actionFkDb( ac : ActionId )
	{
		return fkCache.get( ac );
	}
	
	public static function objectBg( i : ItemId ) : String
	{
		for( x in Protocol.objects_bg_list)
			if(x.id == i)
				return x.bg;
		return "#NO_BG";
	}
	
	
	public static inline function diseaseDb( id )	return diseaseList[ Type.enumIndex(id) ];
	public static inline function woundDb( id )		return woundList[ Type.enumIndex(id) ];
	public static inline function xylophDb( id )	return xylophList[ Type.enumIndex(id) ];
	public static inline function rebelDb( id )		return rebelList[ Type.enumIndex(id) ];
	public static function bookDb( id )				return bookList.find( function(t) return t.id == id );
	static var blueprintHash : EnumHash<ItemId,	BluePrintData> = null;
	
	public static function toolDb(id)
	{
		for ( i in toolList)
			if( i.id == id )
				return i;
		return null;
	}
	
	public static function criticalDb( id  : Arms ) : Array<CritData>
	{
		if ( atk_dispatch == null )
		{
			atk_dispatch = new EnumHash( Arms );
			for(d in Arms)
				atk_dispatch.set(d, []);
			
			for (x in atk_evt)
				atk_dispatch.get( x.cat ).pushBack( x );
			
			for ( d in Arms )
				for ( i in TAtkEvt.array())
					if ( atk_dispatch.get(d).filter( function( m ) return m.type == i ).length == 0 )
						throw "missing " + i + " in weapon cat " + d;
		}
		
		return atk_dispatch.get(id);
	}


	public static inline function blueprintGet( id : ItemId ) : BluePrintData
	{
		if ( blueprintHash == null)
		{
			blueprintHash = new EnumHash( ItemId);
			for(x in bluePrints)
				blueprintHash.set( x.object_id, x);
		}
		
		return blueprintHash.get(id);
	}
	
	public static inline function titleDb( id:TitlesId  )			return titleList[ Type.enumIndex(id) ];
	
	public static inline function eventDb( id  )					return eventList[ Type.enumIndex(id) ];
	public static inline function researchDb( id : ResearchId  )	return researchList[ Type.enumIndex(id) ];
	public static inline function actionDb( id :ActionId )			return actionList[ Type.enumIndex(id) ];
	public static inline function projectDb( id  )					return projectList[ Type.enumIndex(id) ];
	public static inline function skillDb( id  : SkillId)			return skillList[ Type.enumIndex(id) ];
	
	public static inline function roomTypeDb( id : RoomType )		return roomTypeList[ Type.enumIndex(id) ];
	public static inline function heroesDb( id  )	: HeroesData	return heroesList[ Type.enumIndex(id) ];
	
	public static inline function event( e : EventId ) : EventData 	return Protocol.eventList[ Type.enumIndex(e) ];
	public static inline function transportDb( e : TransportEventId ) : TransportEventData 	return Protocol.transportList[ Type.enumIndex(e) ];

	public static inline function roomType( r : RoomId ) : RoomTypeData
	{
		var data = roomDb(r);
		return Protocol.roomTypeList[ Type.enumIndex(data.type) ];
	}
	
	public static var baseActionList =
	{
		Protocol.actionList.filter( function(a) return a.enable.test( function(fx) return Type.enumConstructor(fx) == Type.enumConstructor(BaseAction)) );
	}
	
	
	public static inline function gloryDb( id  )					return gloryList[ Type.enumIndex(id) ];
	public static var maxXp =
	{
		var d = 0;
		d += mush_levels.last().xp;
		
		var techableHeroes = heroesList.count(function(h) return h.id != ADMIN);
		d += techableHeroes * levels.last().xp;
		
		d;
	}
	#end
	
	public static var txt : Array< TextData >								= ods.Data.parse( "DataExt.ods", "text", TextData );

	static var txtH : StringMap<String>;
	public static inline function txtDb(id)
	{
		if ( txtH == null)
		{
			txtH = new StringMap();
			for( t in txt )
				txtH.set( t.id, t.t);
		}
		
		return txtH.get( id ) ;
	}
	
	//public static var shipChunk = "oy6:_roomsaoy6:_doorsaoy5:_linkar2oR1aoR2ar6oR1aoR2ar10oR1ar12oR2ar14oR1ar16oR2ar18oR1ar20oR2aoR1ar24hy4:_posaoy2:_xi15y2:_yi9goR4i16R5i9ghy3:_idjy7:_RoomId:39:0gr22hy3:_dii1R4i15R6i14R5i9goR2aoR1ar32oR2ar34oR1ar36hR3aoR4i15R5i6goR4i16R5i6goR4i17R5i6goR4i17R5i7goR4i17R5i8goR4i16R5i8goR4i15R5i8goR4i15R5i7goR4i16R5i7ghR6jR7:7:0ghR8zR4i14R6i19R5i7goR2aoR1aoR2aoR1ar55oR2ar57oR1aoR2aoR1ar63oR6i35R8i1R4i11R2ar65r6hR5i6ghR3aoR4i10R5i5goR4i11R5i5goR4i11R5i6goR4i10R5i6ghR6jR7:8:0gr61hR8zR4i11R6i13R5i6gr59oR2ar61r6hR8i1R4i12R6i30R5i6ghR3aoR4i12R5i5goR4i13R5i5goR4i13R5i6goR4i12R5i6ghR6jR7:36:0ghR8i1R4i13R6i21R5i4ghR3aoR4i13R5i4ghR6jR7:11:0gr53hR8zR4i13R6zR5i4goR2ar53oR1aoR2ar88oR1aoR2ar92oR1aoR2ar96oR1ar98oR2aoR1aoR2ar96r104hR8i1R4i22R6i10R5i9gr102oR6i36R8zR4i19R2aoR1aoR2aoR1ar112hR3aoR4i18R5i7ghR6jR7:4:0gr110hR8zR4i18R6i16R5i7goR2ar110oR1aoR2ar121r96hR8zR4i21R6i9R5i9gr119hR3aoR4i20R5i9goR4i21R5i9ghR6jR7:40:0ghR8zR4i19R6i17R5i9goR2ar22r110hR8zR4i18R6i22R5i10goR2aoR1ar131oR2ar133r22hR8i1R4i17R6i24R5i9ghR3aoR4i17R5i9goR4i18R5i9goR4i18R5i8ghR6jR7:35:0gr110hR8zR4i18R6i23R5i9goR2aoR1aoR2ar53r144hR8i1R4i17R6i25R5i4gr142hR3aoR4i17R5i5goR4i18R5i5goR4i18R5i6ghR6jR7:34:0gr110hR8zR4i18R6i26R5i5goR2ar110oR1ar153oR2ar155r96hR8zR4i21R6i29R5i5ghR3aoR4i20R5i5goR4i21R5i5ghR6jR7:38:0ghR8zR4i19R6i28R5i5gr108oR6i37R8i1R4i19R2ar88r110hR5i4ghR3aoR4i19R5i5goR4i19R5i6goR4i19R5i7goR4i19R5i8goR4i19R5i9goR4i19R5i10goR4i19R5i11ghR6jR7:31:0gr104hR5i10ghR3aoR4i20R5i10goR4i21R5i10goR4i22R5i10goR4i22R5i11goR4i21R5i11goR4i20R5i11ghR6jR7:33:0gr100hR8zR4i22R6i15R5i10ghR3aoR4i23R5i10ghR6jR7:15:0ghR8i1R4i23R6i4R5i9gr94oR2ar88r96hR8i1R4i22R6i7R5i4gr123r106r157hR3aoR4i22R5i5goR4i23R5i5goR4i23R5i6goR4i23R5i7goR4i23R5i8goR4i23R5i9goR4i22R5i9goR4i22R5i8goR4i22R5i7goR4i22R5i6ghR6jR7:9:0ghR8i1R4i23R6i5R5i4gr90hR3aoR4i23R5i4ghR6jR7:12:0ghR8zR4i22R6i6R5i4gr185r86r163hR3aoR4i19R5i3goR4i20R5i3goR4i21R5i3goR4i22R5i3goR4i22R5i4goR4i21R5i4goR4i20R5i4goR4i19R5i4ghR6jR7:3:0ghR8zR4i18R6i8R5i4gr51r146oR2ar53oR1ar212hR3aoR4i15R5i5goR4i16R5i5ghR6jR7:37:0ghR8i1R4i15R6i27R5i4ghR3aoR4i14R5i4goR4i15R5i4goR4i16R5i4goR4i17R5i4goR4i18R5i4goR4i18R5i3goR4i17R5i3goR4i16R5i3goR4i15R5i3ghR6jR7:1:0gr34hR8i1R4i14R6i20R5i4goR2ar6r34hR8zR4i13R6i31R5i7ghR3aoR4i14R5i5goR4i14R5i6goR4i14R5i7goR4i14R5i8goR4i14R5i9ghR6jR7:30:0gr22hR8i1R4i14R6i18R5i9gr129r135hR3aoR4i14R5i10goR4i15R5i10goR4i16R5i10goR4i17R5i10goR4i18R5i10goR4i18R5i11goR4i17R5i11goR4i16R5i11goR4i15R5i11ghR6jR7:2:0ghR8zR4i13R6i3R5i10ghR3aoR4i13R5i10ghR6jR7:14:0ghR8i1R4i13R6i2R5i9goR2ar6r14hR8i1R4i12R6i12R5i7ghR3aoR4i12R5i8goR4i13R5i8goR4i13R5i9goR4i12R5i9ghR6jR7:5:0ghR8zR4i11R6i1R5i8gr8hR3aoR4i10R5i8goR4i11R5i8goR4i11R5i9goR4i10R5i9ghR6jR7:6:0ghR8i1R4i11R6i11R5i7gr254r75r231r4r67hR3aoR4i9R5i5goR4i9R5i6goR4i9R5i7goR4i10R5i7goR4i11R5i7goR4i12R5i7goR4i13R5i7goR4i9R5i8goR4i9R5i9ghR6jR7:29:0ghR8zR4i8R6i32R5i7goR2aoR1ar279hR3aoR4i8R5i5ghR6jR7:10:0gr2hR8i1R4i8R6i33R5i5goR2ar2oR1ar286hR3aoR4i8R5i9ghR6jR7:13:0ghR8i1R4i8R6i34R5i8ghR3aoR4i6R5i7goR4i7R5i7goR4i8R5i7goR4i8R5i8goR4i7R5i8goR4i8R5i6goR4i7R5i6ghR6jR7:0:0gr281r288r6r65r10r61r14r57r18r53r34r22r214r38r26r144r133r114r88r110r155r121r104r96r92r100hR1ar55r12r16r20r98r94r90r185r86r123r106r8r254r63r24r102r112r119r32r36r51r59r129r131r135r146r142r212r153r157r75r231r4r279r286r67r108r163hg";
}

//becareful of the order
@:keep
@:native("_Iio")
enum ItemInfos
{
	Hidder( h : HeroId );
	Door( doorId : Int ); //door index
	PlantCtrlInfos( v:{w: Int, t: Int} );
	Skin( type : SkinType, id:Int );
	Autonomy( dt : Int );
	BodyOf( h : HeroId, ?mush : Bool);
	Message( t : String );
	Book( b : BookId );
	Charges( level:Int, max:Int );
	Signaled(h:HeroId);
	Skilled( sk : SkillId );
	ProjectPower( pr : ProjectId );
	
	Name( n : String );
	BluePrint( i : ItemId );
	
	Drone( df : DroneInfos );
	RoomLink( r : RoomId );
	_Key( _s : String ); //a unique key that will make its way to flash
	
	Reserved( h:HeroId );
	
	Hacked(h:HeroId);
	Spored(h:HeroId);
	
	PNJVal( p : Int );//pnj key to fastrack matching
	Song( s : Int );
	
	DelayedEffect( d:Int, fx: OdsEffect );
}

typedef DroneInfos =
{
	pawa : List<DronePowerUp>,
	seed : Int,
	touch : { ac:ActionId, nb:Int },
	name : String,
	predict : Null<RoomId>,
}

@:native("_Skt")
enum SkinType {
	SK_RATION;
	SK_PLANT;
	SK_FRUIT;
	SK_DRUG;
}

typedef TreeData = {
	grow:Int,		// Cycles nécéssaires pour que la jeune pousse se transforme en arbre fruitier
	effects:Array<OdsEffect>,
}



typedef ItemDesc =
{
	uid:Int,
	id : ItemId,
	status : EnumFlags<ItemStatusId>,
	customInfos : List<ItemInfos>,
}

@:keep
typedef _ItemDesc =
{
	uid:Int,
	id : ItemId,
	status : Int,
	customInfos : List<ItemInfos>,
}


typedef _RoomInfos =
{
	id : RoomId,//maps to _RoomLocData
	status : Int,
	inventory :  Array<_ItemDesc>,
}

@:keep
@:native('_cc')
typedef ClientChar  =
{
	id:HeroId,
	skin:Int,
	room:RoomId,
	serial:String,
	items : List<_ItemDesc>,
	mutant:Bool,
	life: Float,
	vanities:List<Vanity>,
	diseases:List<Int>,
}

@:native("_CPS")
enum PNJState
{
	CatOccupation( itemUid:Int );
}

@:native("_CN")
@:keep
typedef ClientNPC =
{
	id:PNJClass,
	uid:Int,
	room:RoomId,
	state:List<PNJState>,
	life:Float,
}

typedef DaeInfos =
{
	traveling : Bool,
}

@:keep
typedef _RoomsClientData =
{
	shipMap : IntMap<_RoomInfos>,
	debug : Bool,
	
	hunters : Array < FlashView_Hunter >,
	patrolShips : Array< FlashView_PatrolShip >,
	turrets : Array <FlashView_Turret> ,
	people : Array < ClientChar > ,
	npc:Array<ClientNPC>,
	al : Array<FlashMoveData>,
	
	me : ClientChar,
	
	daedalus :  DaeInfos,
	
	projects : Array<Int>,
	researches : Array<Int>,
	uiFlags : Int,
	flags: Int,
	isoHiFi : Bool,
	//showPatrol:Hash<Bool>,
	showPatrol: Array<{_first:String,_second:Bool}>,
	add :
		{
			plasmaShield : Float,
			?planet :
			{
				imgName:String,
				name : String,
				size : Int,
				seed :Int,
			},
		}
}


typedef ActionDesc =
{
	ac:ActionId,
	acData: ActionData,
	ac_params:ActionTarget,
	link_params:String,
	link:String,
	name:String,
	desc:String,
	cost:Int,
	fake:Bool,
	item : InvItem,
	cl : String,
	webData : String,
	odds : Int,
	sel : CurrentSelection,
	?desc_short:String,
}

typedef FlashMoveData =
{
	ac:ActionId,
	dest:Int,
	confirm: String,
	desc:String,
	fake:Bool,
	cost:Array<Int>,
}

@:native("_HuSt")
enum HunterState
{
	Move;
	LockRoom( r : RoomId );//deprecated
	LockPatrol( r : RoomId );
	LockHuman( i : HeroId );//deprecated
	LockEquipment( id : ItemId );//deprecated
	LockHunter( h : Int );
	Stalled;
	
	LockDaedalus;
	
	LockTransport(t:Int);
}

typedef FlashView_Hunter 		= { id : Int, state : HunterState, hp:Int, type : Int, ?charges:Int, ?subtype :Int }
typedef FlashView_PatrolShip 	= { id : RoomId, hp : Int, pilot : HeroId, charges : Int, state : Int }
typedef FlashView_Turret 		= { id : RoomId, pilot: HeroId , charges:Int, ok:Bool  }

//js friendly
enum CurrentSelection
{
	CSHero( id : HeroId );
	CSHeroItem( it : InvItem, id : HeroId );
	CSRoomItem( it : InvItem, r : RoomId );
	CSPNJ( id : Int );
}

@:native("_CPC")
enum PNJClass
{
	Cat;
}

enum OdsSelector
{
	@:alias("h")
	OSHero;
	@:alias("i")
	OSItem;
	@:alias("o")
	OSOther;
	@:alias("n")
	OSNone;
	
	@:alias("pnj")
	OSPnj( t : PNJClass );
}

typedef InvItem = { var it : ItemDesc; var qty : Int; var uid : Int; }
enum Orientation
{
	North;
	East;
	South;
	West;
}

enum PUB_TUTO_STATE
{
	PRINCIPLES;
	UI;
	FIRST_STEP;
	GO_NORMAL;
}


enum TUTO_CMD
{
	SET_HUNGRY;
	
	@:alias("wait")
	DELAY( f : Float );
	
	@:alias("confirm")
	DO_CONFIRM(divId : String, fl : Int);
	
	CUSTOM_CONFIRM(from:String,divId : String, fl : Int);
	
	SELECT_MASK_I( i : ItemId );
	RESET_SELECT_MASK;
	
	@:alias("ns")
	NEXT_STATE( st : TUTO_STATE );
	
	ENABLE_ACTION( b : Bool );
	ENABLE_LOCATION( rid :RoomId, onOff:Bool);
	
	EXPECT_ACTION( a : ActionId, divId : String );
	EXPECT_LOCATION( rid : RoomId, divId:String);
	EXPECT_NORMAL_MODE_LINK;
	
	EXPECT_CLOSET_OPENED(divId:String);
	EXPECT_IN_INVENTORY( i : ItemId, divId:String);
	EXPECT_CHAT( divId:String);
	HIDE_CLOSET;
	CANCEL_SELECTION;
	OUTLINE(sel:String);
	
	REFILL_PA;
	
	@:alias("uif")
	DO_UI_FLAGS( i:UI_FLAGS, onOff:Bool);
	
	RESERVE_ITEM( i : ItemId, hidden:Bool );
	RESERVE_HUNTER;
	
	
	@:alias("dbl")
	DEBLACKLIST_ACTION(ac  : ActionId);
	
	@:alias("bla")
	BLACKLIST_ACTION( ac  : ActionId );
	BLACKLIST_ALL_ACTION;
	
	EXPECT_SELECTION( i : ItemId , divId : String );
	
	CLEAN_TUTO_MESS;
	
	SPAWN_ITEM( i : OdsItem, r : RoomId, broken : Bool, reserved : Bool);
	PUB_STEP(  st : PUB_TUTO_STATE );
	
	NORMAL_CHOICE_BOX( txtLeft:String, txtRight:String,urlLeft:String,urlRight:String );
	IDLE;
	END_OF_STORY;
	
	BL_NOT_RESERVED;
	DBL_NOT_RESERVED;
	
	BL_ALL_ITEMS;
	DBL_ITEM(i:ItemId);
	
	EXPECT_OBJECTIVE_TAB(divId:String);
	
	RELOAD;
	AJAX(id:String);
}


enum PatrolClass
{
	PC_PATROL;
	PC_PASIPHAE;
}

enum ActionSector
{
	Agression;
	Recherche;
	Projet;
	Hydroponie;
	Guerison;
	Reparation;
	Hunters;
	Mouvement;
	Autre;
	Pilgred;
	Confort;
	AstroNavigation;
	Exploration;
	Comm;
	Mush;
	Social;
	Traque;
	AutresObjets;
	Commerce;
}
	

enum TagState
{
	TS_Unknown;
	TS_Known;
	TS_Explored;
}

//### MODULE EXPLORATION 3
@:build(ods.Data.build("DataExplore.ods", "planetTags", "id" )) 	enum PlanetTag { }


@:build(ods.Data.build("DataExplore.ods", "monster", "id" )) 		enum MonsterId { }
@:build(ods.Data.buildComplex("DataExplore.ods", "explo", "id" )) 	enum ExploEventType { }
@:build(ods.Data.buildComplex("DataTease.ods", "quizz", "id" )) 	enum QuizzId { }


typedef Planet = {
	name:String,
	size:Int,
	tags:Array <
	{
		tg:PlanetTag,
		ts:TagState,
	}>,
}
typedef PlanetTagData = {
	id:PlanetTag,
	we:Int,
	seek:Int,
	explo:Int,
	name:String,
	desc:String,
	max:Int,
	events:Array<ExploreEventSlot>,
	cond:Null<OdsCondition>,
}
typedef ExploreEventSlot = {
	_type:ExploEventType,
	_desc:String,
	_flags:Array<ExploreTagFlags>,
}

typedef TransportEventData = {
	var id:TransportEventId;
	var text : String;
	var lines : Array<TransportEventSlot>;
	var num : Int;
}

typedef TransportEventSlot = {
	var _answer : String;
	var _deal_in:Null<String>; //small interpreted chunk
	var _deal_out:Null<String>; //small interpreted chunk
	var _num : Int;
	var need_skills:Null<SkillId>;
}

typedef SemanticData = {
	link:String,
	list:Array<String>,
}

typedef PlanetSyl = {
	id:Int,
	text:Array<String>,
}

typedef ExploEventData = {
	//id:ExploEventType,
	name:String,
	desc:String,
	align:Align,
}

typedef ExploEventDesc = {
	id:PlanetTag,
	txt:String,
}

//#### CONSUMABLE
@:build( ods.Data.buildComplex("DataConsumable.ods", "consumable_effects", "id") ) 		enum ConsumableEffectType { }
@:build( ods.Data.build("DataConsumable.ods", "rations", "cons_id", { prefix : "CID_" }) ) 	enum ConsRationId { }



typedef ConsumableEffectData = {
	desc:String,
	good:Null<Bool>,
}

typedef RationData =
{
	var name:String;
	var desc:String;
	
	@:sep("+")
	var effect:Array<ConsumableEffectType>;
	
	var gender : Gender;
}

typedef ItemStatusData =
{
	var id : ItemStatusId;
	var name : String;
	var desc : String;
	
}

@:native('_Nti')
enum NT_ISO_EVENT
{
	IE_DO_THE_THING(h1:HeroId, h2:HeroId, r:RoomId);
	IE_MASSGGEDON;
	IE_SHAKE;
	IE_HURT(hid:HeroId);
}

enum Notif
{
	NT_MSG( msg:String );
	NT_CHANGE_CHAN( pvId : PrivChanId );
	NT_NEW_CHAN( pvId : PrivChanId );
	NT_ISO_EVENT( ev : NT_ISO_EVENT );
	NT_ONCE( ev :OnceEventId );
}


enum Medals
{
	MD_FIRST;
	MD_SECOND;
	MD_THIRD;
	MD_FOURTH;
	
	MD_SPECIAL;
	MD_FIGURANT;
}


// 1 sms = 10 jeton
enum ShopItem
{
	//perso
	//Blanquette Spatiale 3jeton
	//1 riz proactif : 1 jeton
	
	//
	//1 lunchbox : 2 ration 2 jeton
	//levelup : 
	
	// vanity little hearts perma ? 5 jeton 
	// vanity little heart temp 1 jeton
	
	//social
	//banjo 3 PA apprendre 1 PA jouer, + 1 moral a qui ne l'a jamais ecouté		
	//thermos contient 4 café													
	//rd alien fruit 2 jeton
	//P2W ? bidouilleur a usage limité : +100% de hack 8 usage !
	
	//projet+ afficher qui est ou dans le traqueur pour tous
	//projet+ 5 debris met 5 depris plastique ( trop pointu terrence ) 
	//projet+ renvoie 4 projet définis ratés en pile  ( trop pointu ) 
	
	//trouver quels point de gameplay sont suffisament gén
	//REM projet+ 3 apprentron random 1apprentron par personne par partie
	
	//1 sms 
	
	//5
	SI_Item(i:OdsItem);		//2
	SI_ProjectPlus( p : ProjectId ); //5
	SI_Vanity(v : Vanity); //3
	
	SI_Skin( hid : HeroId, sk:Int);
	
	SI_Ticket;
	//10
	//4
	//8
	//6 avec la baisse 
	
	//VanityItem(v:Vanity);
	//ProjectPlus(p:ProjectPlusId);
}



enum Tradable {
	RandomCrewMember;
	OneCrewMember( hid:HeroId );
	
	TradeItem( nb:Int, i : ItemId );
	
	TradeResearch( r : ResearchId );
	TradeProject( r : ProjectId );
	
	RepairPilgred;
	
	RandomProject;
}

enum SeasonFlag {
	SF_ANDREK;
	SF_EXHAUSTED;
	SF_HUNGRY;
	SF_START_PLANET;
	SF_REPRIEVE;
}
