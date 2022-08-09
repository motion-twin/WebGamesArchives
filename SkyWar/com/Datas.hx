enum _ErrorKind {
	ISLE_NOT_FOUND;
	ISLE_HAS_OWNER(iid:Int,uid:Int);
	ALREADY_SETTLED;
	UNIT_NOT_FOUND(id:Int);
	UNIT_IS_TRAVELING(id:Int);
	UNIT_NOT_THERE(uid:Int, iid:Int);
	FLEET_RANGE_TOO_SHORT(frange:Float,dist:Float);
	NO_UNIT_SELECTED;
	NOT_YOUR_ISLE(id:Int);
	NO_BUILDING_THERE(iid:Int,x:Int,y:Int); // tentative de destruction sur case vide
	SLOT_NOT_EMPTY(iid:Int,x:Int,y:Int); // tentative de construction sur une case occupée par un yard ou un building
	SLOT_NOT_ETHER(iid:Int,x:Int,y:Int); // tentative de construction sur une case non geyser (source d'ether requise)
	TRAVEL_NOT_FOUND;
	TRAVEL_CANCEL_ERROR_RETURN; // impossible d'annuler un travel déjà en phase de retour
	TRAVEL_CANCEL_ERROR_ORIGIN; // impossible d'annuler un travel si perte de contrôle de l'île d'origine
	FIGHT_NOT_FOUND;
	MAX_STARTED_PROD_LIMIT_REACHED;
	BAD_SEARCH_ORDER;
	RACE_ERROR;
	CANNOT_DESTROY_TOWNHALL;    // impossible de supprimer son bâtiment principal, cela vous ferait perdre la partie.
	END_OF_SUBSCRIPTION;
	TECHNO_NOT_FOUND;
}

enum _Shp {
	// RACE0
	APICOPTER;
	DRAKKAR;
	BALLOON;
	BOMBER;
	HARPIE;
	MIRE;
	CONDOR;
	ATLAS;
	GHOST;
	GAIA;
	// RACE1
	TURTLE;
	FISH;
	HOPLITE;
	HIPPOCAMP;
	SNAIL;
	GIANT_TURTLE;
	SQUID;
	DRAGON;
	GOLIATH;
	SKYWALKER;
}

enum _Bld {
	// RACE0
	TOWNHALL;		// 0-
	QUARRY;			// 1-
	FIELD;			// 2-
	WEAVER;			// 3-
	WORKSHOP;		// 4-
	PUMP;			// 5-
	BARRACKS;		// 6-
	WATCH_TOWER;	// 7-
	SCHOOL;			// 8-
	UNIVERSITY;		// 9-
	LABORATORY;		// 10-
	FARM;			// 11-
	WINDMILL;		// 12-
	CANON;			// 13-
	FIRE_STATION;	// 14-
	FACTORY;		// 15-
	YELLER;			// 16-
	ARCHIMORTAR;	// 17-
	FOUNDRY;		// 18-
	BUNKER;			// 19-
	ARCHITECT;		// 20-
	FORT;			// 21-
	// RACE1
	TEMPLE;
	FOUNTAIN;
	CORN;
	MENHIR;
	HUT;
	SCULPTOR;
	GARDENER;
	HOT_SPRING;
	DOJO;
	GOLEM;
	FOREST;
	MINE;
	CAULDRON;
	STONE_FORGE;
	SHRINE;
	FLOWERS;
	PURIFICATION_TANK;
	ORB;
	SPRAYER;
	SOURCE;
	MAGIC_TREE;
	GOLEM_LAUNCHER;
}

enum _BldType {
	BT_RES;
	BT_FOOD;
	BT_CONS;
	BT_TEC;
	BT_DEF;
	BT_POP;
	BT_MAIN;
	BT_SPECIAL;
}

enum _Tec {
	// RACE0
	PARACHUTE;
	FORTIFIED_CLOTH;
	SHIELDS;
	MILITARY_SERVICE;
	HELICE;
	CANON_POWDER;
	FLEXIBLE_PISTON;
	ACIETHER;
	NAPALMIEL;
	RESTORE;
	VRILLE;
	LENS;
	SEWING_MACHINE;
	FERTILIZER;
	TRACTOR;
	BOMBING_TACTIC;
	COMMUNICATION;
	MARTIAL_LAW;
	STRETCH_SAIL;
	GEOLOGY;
	ASTRONOMY;
	ETHERAL_PROPULSION;
	ETHERODUC;
	CUBIC_FUSION;
	ROYAL_CHIMNEY;
	VARNISH;
	WINCH;
	PILLAGE;			// Raser un bâtiment permet de gagner 10% de son prix en resource
	MISSILE;
	INVASION;
	// RACE1
	DANGREN_HERITAGE;	// Vous obtenez 250 matériaux
	ADV_SCULPTOR;
	TRANSLUCID_PAPER;	// Les poissons gagnent la capacité Furtivité
	RAZOR_FIN;			// Les poissons gagnent +3 en attaque
	PILON;				// Les hoplites gagnent la capacité Bomb(30)
	ETHERAL_FIST;		// Les hopiltes et Goliath gagnent +5 dégâts, Les GOLEMS gagnent +5 dégâts
	ZORETH_STONE;		// Temps de recherche diminués de 25%
	GRANIT_SKIN;		// GOLEMS gagnent +4 d'armure
	RECYCLE;			// Détruire un bâtiment => récupère 100% des resources
	FIRE_BREATH;		// Les dragons gagnent Répartition
	CONCLAVE_AID;		// Lorsqu'une recherche est achevée vous gagnez 40 matériaux et 40 Ether
	FOSSIL_SEED;		// Le temps de construction des forêts est divisé par 2
	BREEDING;			// Vos îles gagnent un bonus de 3 food
	STAKES;				// Vos îles gagnent 2 attaque
	GRAVEYARD;			// Lorsqu'une de vos unités est détruite, vous gagnez 10 Ether
	POROUS_MARBLE;		// Les Hoplites et Goliath gagnent 100 pts de speed et perdent 15 life
	STEROID_OAT;		// Les troupes organiques gagnent 20 life (TODO: vérifier qu'il s'agit bien des Invocations avec ben)
	MARTIAL_ART;		// Les Hippocamp gagnent +3 att, Vos Dojos gagnent +3 att,
	TELESCOPIC_SPEAR;	// Les Hippocamp gagnent la capacité initiative
	HARE_POTION;		// Les TURTLE et GIANT_TURTLE et HIPPOCAMP gagnent 100 vitesse
	POISON_CLAWS;		// Les TURTLE gagnent 6pt d'att et la capa Corosive
	HORN_OF_PLENTY;		// Votre temple génère 8 matériaux et 8 éther à chaque cycle
	LEVITATION;		// Permet construction de SKYWALKER
	DRAGONFLY_TROWEL;	// -30% de temps de construction sur les batiments.
	STERILIZING_BATH;	// A chaque cycle et pour chaque fontaine que vous possedez sur une ile, retirez un status négatif sur une unité stationnant sur cette ile.
	DRYAD;			// Vos forêts apportent 1 ether a chaque cycle
	ETHERUPTION;		// Vos sources sacrées apportent 4eth / cycle supplémentaire
	GOLEMISSARY;   		// Un hoplite ou goliath solitaire inflige double degats
	LASER_FIREFLY;
	ETHERAL_GATE;
	// RACE0 update
	DIVINE_HARPOON;     // Vos apicopters et vos drakkars gagnent 3 points d'attaque
	// RACE1 update
	FLEXIBLE_CUIRASS;   // Polpides & Vénéficts gagnent armor +2
	// RACE0 update
	MISSILE_STRAWMAN;   // Vos champs infligent 2x10 points de dégât à chaque attaque
	// RACE1 update
	ARCADIE_FLAME;      // +1 d'attaque à toutes vos unités
	// RACE0 update
	ESCORT;             // +1 apicopter en plus d'une unité non apicopter (si bonhomme disponible)
}

enum _Struct {
	Building(b:_Bld);
	Ship(s:_Shp);
}

enum _Res{
	MATERIAL;
	CLOTH;
	IRON;
	ETHER;
}

enum ShipCapacity{
	Init;
	Raid(n:Int);
	Bomb(n:Int);
	Multi(n:Int);
	Colonization;
	Stealth;		// Ne prend pas les degats des batiments ( canon etc. )
	Sentinelle;		// Si un vaisseau défenseur possède la capacité sentinelle au debut ed la phase de bombardement celle-ci est annulée.
	Scout;			// TODO: éclaireur ?
	Regeneration;		// Regagne 1 pt de vie par cycle
	Corrosive;		// Perte d'un point de vie par cycle jusqu'à 1pt (par de mort)
	Repartition;		// Fight.hx si plus de dégâts que nécessaire à la destruction d'une cible, choisir nouvelle cible
	Pack;			// Capacité meute ?
	Aura(sc:ShipCapacity);	// Donne meute
	FleetTarget(v:Int); // Nouvelle cible possible pour la flotte
}

enum ShipStatus {
	Poison;
	Parasite;
}

enum _NewsType{
	_Attack(d:DataAttack);
	_Archimortar(d:DataAttack);
	_Colonize(pid:Int);
	_Defeat(pid:Int);
	_NewBuilding(bld:_Bld);
	_NewShip(shp:_Shp);
	_Starvation;
	_Trace(txt:String);
}

enum _PlanetAttribute{
	PA_GOLEM_LAUNCHER;
	PA_WATCH_TOWER;
}
enum _FleetAttribute{
	FA_GOLEMISSARY;
	FA_LAUNCHED;
}

typedef _Cost = {
	_material:Int,
	_cloth:Int,
	_ether:Int,
	_pop:Int,
}

enum _Lack {
	_LackBld(n:_Bld);
	_LackTec(n:_Tec);
	_LackCost(n:_Cost);
	_LackUnique(n:_Bld);
	_LackPopLimit();
}

enum _GameMode {
	MODE_INSTALL;
	MODE_WAIT;
	MODE_PLAY;
	MODE_END;
}

enum _ParamFlag {
	PAR_IN_GAME_HELP;

	PAR_FAST_LINK;
	PAR_FAST_LINK_SELF;
	PAR_TECHNO_MASK;
	PAR_STACK_SHIP;
	PAR_DISPLAY_YARD_TOTAL_TIME;

	PAR_DISPLAY_ISLAND_INFO;
	PAR_DISPLAY_UNIT_LIFE;

	PAR_CHAT_TIME;
	PAR_CHAT_PSEUDO;
	PAR_CHAT_CANAL;

	PAR_MENU_ANIM;
	PAR_BLOB;
}

//
typedef Counter = {
	_start:Float,
	_end:Float,
}

/*
typedef Activity = {
	crewMax:Int,
	crewCoef:Int,
	freq:Int,
	effect:ActivityType,
}
*/

typedef ShipCaracs = {
	lifeMax:Int,
	range:Int,
	speed:Int,
	damage:Int,
	armor:Int,
	capacity:Array<ShipCapacity>
}

typedef FleetStatus = {
	_oneshot:Bool,
	_autocol:Bool,
	_priorities:List<_BldType>,
}

typedef TecModel = {
	_name:String,
	_list:Array<_Tec>,
	_raceId:Int
}

// DATAS
typedef DataGame = {

	// FIXE
	_id:Int,
	_playerId:Int,
	_plMax:Int,

	_world:DataWorld,
	_status:DataStatus,
	_urlImg:String,

	_tecModels:Array<TecModel>

}

typedef DataWorld = {
	_time:Float,
	_mode:_GameMode,
	_planets:Array<DataMapPlanet>,
	_ships:Array<DataShip>,
	_travels:Array<DataTravel>,
	_players:Array<DataPlayer>,

}

typedef DataStatus = {
	_maj:Counter,
	_res:_Cost,
	_unitMax:Int,
	_units:Int,
	_tickMaterial:Int,
	_tickEther:Int,
	_tec:Array<_Tec>,
	_disabledTec:Array<_Tec>,
	_research:Array<DataResearch>,
	_searchRate:Float
}

enum _PlayerStatus {
	ALIVE;
	ABANDON;
	DEAD;
}

typedef DataPlayer = {
	_id:Int,
	_skin:String,
	_color:Int,
	_race:Int,
	_name:String,
	_tec:Array<_Tec>,
	_tprio:Array<Int>,
	_status:_PlayerStatus,
	_frags:Int,
}

typedef DataMapPlanet = {
	_id:Int,
	_owner:Int,
	_view:Int,
	_attributes:List<_PlanetAttribute>,
}

typedef DataPlanet = {

	_id:Int,
	_x:Int,
	_y:Int,
	_seed:Int,

	_owner:Int,
	_pop:Int,
	_food:Int,

	_bld:Array<DataBuilding>,
	_ship:Array<DataShip>,
	_yard:Array<DataConstruct>,
	_news:Array<DataNews>,
	_ruins:Array<DataBuilding>,

	_breed:Counter,
	_def:Int,
	_att:Int
}

typedef DataAttack = {
	_from:Int,
	_to:Int,
	_fightId:Int,

	_damageAtt:Int,
	_damageDef:Int,
	_damageTwr:Int,

	_casualtyAtt:Array<_Shp>,
	_casualtyDef:Array<_Shp>,

	_damageBld:Int,
	_damageYard:Int,
	_casualtyBld:Array<_Bld>,
	_casualtyPop:Int,
	_damagePop:Int,
}

typedef DataNews = {
	_date:Float,
	_type:_NewsType,
}

typedef DataBuilding = {
	_id:Int,
	_type:_Bld,
	_life:Int,
	_x:Int,
	_y:Int,
	_progress:Float,
}

typedef DataShip = {
	_id:Int,
	_type:_Shp,
	_owner:Int,
	_life:Int,
	_pid:Int,		// PLANET ID
	_tid:Int,		// TRAVEL ID
	_status:Int		// BIT MASK FOR ShipStatus ENUM
}

typedef DataTravel = {
	_owner:Int,
	_id:Int,
	_move:Counter,
	_start:Int,
	_dest:Int,
	_origin:Int,
	_status:FleetStatus,
	_attributes:List<_FleetAttribute>,
}

typedef DataConstruct = {
	_type:_Struct,
	_counter:Counter,
	_progress:Float,
}

typedef DataResearch = {
	_type:_Tec,
	_counter:Counter,
	_progress:Float,
}


typedef DataMsg = {
	_canal:Int,
	_from:Int,
	_txt:String,
	_time:Float,

}

// FIGHT
typedef DataFight = {
	_defenderId:Int,
	_bld:Array<DataBuilding>,
	_ships:Array<DataShip>,
	_history:Array<_FightEvent>,
}
enum _FightEvent {
	Assault( a:Array<DataAssault> );
	Flower( a:Array<DataAssault> );
	Stakes( a:Array<DataAssault> );
	Destroy( a:Array<Int> );
}
typedef DataAssault = {
	_id:Int,
	_trg:Int,
	_damage:Int,
}

// BATIMENTS



/*
typedef DataMan = {
	cost:Array<Cost>,
	base:Bld
}
typedef DataBld = {
	cost:Array<Cost>,
	size:Int
}
typedef DataShp = {
	cost:Array<Cost>,
	base:Bld
}
typedef DataTec = {
	cost:Array<Cost>,
	base:Bld
}
*/
