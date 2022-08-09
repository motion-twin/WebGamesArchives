class Data
{
	static var manager = null;

	static var DOC_WIDTH=420;
	static var DOC_HEIGHT=520;

	static var GAME_WIDTH=400;
	static var GAME_HEIGHT=500;

	static var LEVEL_WIDTH=20;
	static var LEVEL_HEIGHT=25;

	static var CASE_WIDTH=20;
	static var CASE_HEIGHT=20;

	static var SECOND = 32; // dur�e d'une sec en cycles de jeu

	private static var auto_inc = 0;

	// *** DEPTHS
	static var DP_SPECIAL_BG = auto_inc++;
	static var DP_BACK_LAYER = auto_inc++;
	static var DP_SPRITE_BACK_LAYER = auto_inc++;
	static var DP_FIELD_LAYER = auto_inc++;
	static var DP_SPEAR = auto_inc++;
	static var DP_PLAYER = auto_inc++
	static var DP_ITEMS = auto_inc++;
	static var DP_SHOTS = auto_inc++;
	static var DP_BADS = auto_inc++;
	static var DP_BOMBS = auto_inc++;
	static var DP_FX = auto_inc++;
	static var DP_SUPA = auto_inc++;
	static var DP_TOP_LAYER = auto_inc++;
	static var DP_SPRITE_TOP_LAYER = auto_inc++;
	static var DP_BORDERS = auto_inc++;
	static var DP_SCROLLER = auto_inc++;
	static var DP_INTERF = auto_inc++;
	static var DP_TOP = auto_inc++;
	static var DP_SOUNDS = auto_inc++;


	// *** SOUNDS
	static var CHAN_MUSIC	= 0;
	static var CHAN_BOMB	= 1;
	static var CHAN_PLAYER	= 2;
	static var CHAN_BAD		= 3;
	static var CHAN_ITEM	= 4;
	static var CHAN_FIELD	= 5;
	static var CHAN_INTERF	= 6;
	static var TRACKS = [
		"music_ingame",
		"music_boss",
	];

	// *** TYPES
	private static var type_bit = 0;
	static var ENTITY		= 1<<(type_bit++);
	static var PHYSICS		= 1<<(type_bit++);
	static var ITEM			= 1<<(type_bit++);
	static var SPECIAL_ITEM	= 1<<(type_bit++);
	static var PLAYER		= 1<<(type_bit++);
	static var PLAYER_BOMB	= 1<<(type_bit++);
	static var BAD			= 1<<(type_bit++);
	static var SHOOT		= 1<<(type_bit++);
	static var BOMB			= 1<<(type_bit++);
	static var FX			= 1<<(type_bit++);
	static var SUPA			= 1<<(type_bit++);
	static var CATCHER		= 1<<(type_bit++);
	static var BALL			= 1<<(type_bit++);
	static var HU_BAD		= 1<<(type_bit++);
	static var BOSS			= 1<<(type_bit++);
	static var BAD_BOMB		= 1<<(type_bit++);
	static var BAD_CLEAR	= 1<<(type_bit++);
	static var SOCCERBALL	= 1<<(type_bit++);
	static var PLAYER_SHOOT	= 1<<(type_bit++);
	static var PERFECT_ITEM	= 1<<(type_bit++);
	static var SPEAR		= 1<<(type_bit++);

	// *** LEVELS
	static var GROUND		= 1;
	static var WALL			= 2;
	static var OUT_WALL		= 3;
	static var HORIZONTAL	= 1;
	static var VERTICAL		= 2;
	static var SCROLL_SPEED			= 0.04//0.05 ; // incr�ment cosinus
	static var FADE_SPEED			= 8;
	static var FIELD_TELEPORT		= -6; // id dans la map du level
	static var FIELD_PORTAL			= -7;
	static var FIELD_GOAL_1			= -8;
	static var FIELD_GOAL_2			= -9;
	static var FIELD_BUMPER			= -10;
	static var FIELD_PEACE			= -11;
	static var HU_STEPS				= [35*SECOND, 25*SECOND] ; // seuils timers des hurry ups
	static var LEVEL_READ_LENGTH	= 1;
	static var MIN_DARKNESS_LEVEL	= 16;

	// *** STATS
	static var stat_inc = 0;
	static var STAT_MAX_COMBO	= stat_inc++;
	static var STAT_SUPAITEM	= stat_inc++;
	static var STAT_KICK		= stat_inc++; // inutilis� � partir d'ici...
	static var STAT_BOMB		= stat_inc++;
	static var STAT_SHOT		= stat_inc++;
	static var STAT_JUMP		= stat_inc++;
	static var STAT_ICEHIT		= stat_inc++;
	static var STAT_KNOCK		= stat_inc++;
	static var STAT_DEATH		= stat_inc++;

	// *** EXTENDS
	static var EXTEND_TIMER = 10*SECOND;
	static var EXT_MIN_COMBO = 3;
	static var EXT_MAX_BOMBS = 3;
	static var EXT_MAX_KICKS = 0;
	static var EXT_MAX_JUMPS = 10;

	// *** ANIMATIONS
	static var BLINK_DURATION = 2.5;
	static var BLINK_DURATION_FAST = 1;
	static var ANIM_PLAYER_STOP		= {id:0,loop:true};
	static var ANIM_PLAYER_WALK		= {id:1,loop:true};
	static var ANIM_PLAYER_JUMP_UP	= {id:2,loop:false};
	static var ANIM_PLAYER_JUMP_DOWN= {id:3,loop:false};
	static var ANIM_PLAYER_JUMP_LAND= {id:4,loop:false};
	static var ANIM_PLAYER_DIE		= {id:5,loop:true};
	static var ANIM_PLAYER_KICK		= {id:6,loop:false};
	static var ANIM_PLAYER_ATTACK	= {id:7,loop:false};
	static var ANIM_PLAYER_EDGE		= {id:8,loop:true};
	static var ANIM_PLAYER_WAIT1	= {id:9,loop:false};
	static var ANIM_PLAYER_WAIT2	= {id:10,loop:false};
	static var ANIM_PLAYER_KNOCK_IN	= {id:12,loop:false};
	static var ANIM_PLAYER_KNOCK_OUT= {id:13,loop:false};
	static var ANIM_PLAYER_RESURRECT= {id:14,loop:false};
	static var ANIM_PLAYER_CARROT	= {id:15,loop:true};
	static var ANIM_PLAYER_RUN		= {id:16,loop:true};
	static var ANIM_PLAYER_SOCCER	= {id:17,loop:true};
	static var ANIM_PLAYER_AIRKICK	= {id:18,loop:false};
	static var ANIM_PLAYER_STOP_V	= {id:19,loop:true};
	static var ANIM_PLAYER_WALK_V	= {id:20,loop:true};
	static var ANIM_PLAYER_STOP_L	= {id:21,loop:true};
	static var ANIM_PLAYER_WALK_L	= {id:22,loop:true};

	static var ANIM_BAD_WALK		= {id:0,loop:true};
	static var ANIM_BAD_ANGER		= {id:1,loop:true};
	static var ANIM_BAD_FREEZE		= {id:2,loop:false};
	static var ANIM_BAD_KNOCK		= {id:3,loop:true};
	static var ANIM_BAD_DIE			= {id:4,loop:true};
	static var ANIM_BAD_SHOOT_START	= {id:5,loop:false};
	static var ANIM_BAD_SHOOT_END	= {id:6,loop:false};
	static var ANIM_BAD_THINK		= {id:7,loop:false};
	static var ANIM_BAD_JUMP		= {id:8,loop:true};
	static var ANIM_BAD_SHOOT_LOOP	= {id:9,loop:true};

	static var ANIM_BAT_WAIT		= {id:0,loop:true};
	static var ANIM_BAT_MOVE		= {id:1,loop:true};
	static var ANIM_BAT_SWITCH		= {id:2,loop:false};
	static var ANIM_BAT_DIVE		= {id:3,loop:false};
	static var ANIM_BAT_INTRO		= {id:4,loop:false};
	static var ANIM_BAT_KNOCK		= {id:5,loop:true};
	static var ANIM_BAT_FINAL_DIVE	= {id:6,loop:true};
	static var ANIM_BAT_ANGER		= {id:7,loop:true};

	static var ANIM_BOSS_WAIT			= {id:0,loop:true};
	static var ANIM_BOSS_SWITCH			= {id:1,loop:false};
	static var ANIM_BOSS_JUMP_UP		= {id:2,loop:false};
	static var ANIM_BOSS_JUMP_DOWN		= {id:3,loop:false};
	static var ANIM_BOSS_JUMP_LAND		= {id:4,loop:false};
	static var ANIM_BOSS_TORNADO_START	= {id:5,loop:false};
	static var ANIM_BOSS_TORNADO_END	= {id:6,loop:false};
	static var ANIM_BOSS_BAT_FORM		= {id:7,loop:false};
	static var ANIM_BOSS_BURN_START		= {id:8,loop:false};
	static var ANIM_BOSS_DEATH			= {id:9,loop:false};
	static var ANIM_BOSS_DASH_START		= {id:10,loop:false};
	static var ANIM_BOSS_DASH			= {id:11,loop:false};
	static var ANIM_BOSS_BOMB			= {id:12,loop:false};
	static var ANIM_BOSS_HIT			= {id:13,loop:false};
	static var ANIM_BOSS_DASH_BUILD		= {id:14,loop:true};
	static var ANIM_BOSS_BURN_LOOP		= {id:15,loop:true};
	static var ANIM_BOSS_TORNADO_LOOP	= {id:16,loop:true};
	static var ANIM_BOSS_DASH_LOOP		= {id:17,loop:true};


	static var ANIM_BOMB_DROP		= {id:0,loop:false};
	static var ANIM_BOMB_LOOP		= {id:1,loop:true};
	static var ANIM_BOMB_EXPLODE	= {id:2,loop:false};

	static var ANIM_WBOMB_STOP		= {id:0,loop:true};
	static var ANIM_WBOMB_WALK		= {id:1,loop:true};

	static var ANIM_SHOOT = {id:0,loop:false};
	static var ANIM_SHOOT_LOOP = {id:0,loop:true};

	// *** IA
	static var MAX_ITERATION = 30;
	private static var flag_bit = 0;
	static var GRID_NAMES = [
		"$IA_TILE_TOP",		// 0
		"$IA_ALLOW_FALL",	// 1
		"$IA_BORDER",		// 2
		"$IA_SMALLSPOT",	// 3
		"$IA_FALL_SPOT",	// 4
		"$IA_JUMP_UP",		// 5
		"$IA_JUMP_DOWN",	// 6
		"$IA_JUMP_LEFT",	// 7
		"$IA_JUMP_RIGHT",	// 8
		"$IA_TILE",			// 9
		"$IA_CLIMB_LEFT",	// 10
		"$IA_CLIMB_RIGHT",	// 11

		"$FL_TELEPORTER",	// 12
	];
	static var IA_TILE_TOP		= 1<<(flag_bit++);
	static var IA_ALLOW_FALL	= 1<<(flag_bit++);
	static var IA_BORDER		= 1<<(flag_bit++);
	static var IA_SMALL_SPOT	= 1<<(flag_bit++);
	static var IA_FALL_SPOT		= 1<<(flag_bit++);
	static var IA_JUMP_UP		= 1<<(flag_bit++);
	static var IA_JUMP_DOWN		= 1<<(flag_bit++);
	static var IA_JUMP_LEFT		= 1<<(flag_bit++);
	static var IA_JUMP_RIGHT	= 1<<(flag_bit++);
	static var IA_TILE			= 1<<(flag_bit++);
	static var IA_CLIMB_LEFT	= 1<<(flag_bit++);
	static var IA_CLIMB_RIGHT	= 1<<(flag_bit++);

//	static var IA_CORNER_UP		= 1<<(flag_bit++);
//	static var IA_CORNER_DOWN	= 1<<(flag_bit++);
//	static var IA_CORNER_LEFT	= 1<<(flag_bit++);
//	static var IA_CORNER_RIGHT	= 1<<(flag_bit++);

	static var FL_TELEPORTER = 1<<(flag_bit++);

	static var IA_HJUMP = 2; // distance de saut horizontal
	static var IA_VJUMP = 2; // distance de saut vertical
	static var IA_CLIMB = 4; // distance d'escalade max
	static var IA_CLOSE_DISTANCE = 110;

	static var ACTION_MOVE = auto_inc++;
	static var ACTION_WALK = auto_inc++;
	static var ACTION_SHOOT = auto_inc++;
	static var ACTION_FALLBACK = auto_inc++;


	// *** INTERFACE
	static var EVENT_EXIT_RIGHT		= 1;
	static var EVENT_BACK_RIGHT		= 2;
	static var EVENT_EXIT_LEFT		= 3;
	static var EVENT_BACK_LEFT		= 4;
	static var EVENT_DEATH			= 5;
	static var EVENT_EXTEND			= 6;
	static var EVENT_TIME			= 7;

	// *** PHYSICS
	static var BORDER_MARGIN = CASE_WIDTH/2;
	static var FRICTION_X = 0.93;
	static var FRICTION_Y = 0.86;
	static var FRICTION_GROUND = 0.70;
	static var FRICTION_SLIDE = 0.97;
	static var GRAVITY = 1.0 ; // ajout� au dy en mont�e
	static var FALL_FACTOR_FROZEN = 2.3;
	static var FALL_FACTOR_KNOCK = 1.5;
	static var FALL_FACTOR_DEAD = 1.75;
	static var FALL_SPEED = 0.9 ; // ajout� au dy en descente
	static var STEP_MAX = CASE_WIDTH;
	static var DEATH_LINE = GAME_HEIGHT+50;

	// *** FX
	static var MAX_FX					= 16;
	static var DUST_FALL_HEIGHT			= CASE_HEIGHT * 4;
	static var PARTICLE_ICE				= 1;
	static var PARTICLE_CLASSIC_BOMB	= 2;
	static var PARTICLE_STONE			= 3;
	static var PARTICLE_SPARK			= 4;
	static var PARTICLE_DUST			= 5;
	static var PARTICLE_ORANGE			= 6;
	static var PARTICLE_METAL			= 7;
	static var PARTICLE_TUBERCULOZ		= 8;
	static var PARTICLE_RAIN			= 9;
	static var PARTICLE_LITCHI			= 10;
	static var PARTICLE_PORTAL			= PARTICLE_SPARK;
	static var PARTICLE_BUBBLE			= 11;
	static var PARTICLE_ICE_BAD			= 12;
	static var PARTICLE_BLOB			= 13;
	static var PARTICLE_FRAMB			= 14;
	static var PARTICLE_FRAMB_SMALL		= 14;

	static var BG_STAR			= 0;
	static var BG_FLASH			= 1;
	static var BG_ORANGE		= 2;
	static var BG_FIREBALL		= 3;
	static var BG_HYPNO			= 4;
	static var BG_CONSTEL		= 5;
	static var BG_JAP			= 6;
	static var BG_GHOSTS		= 7;
	static var BG_FIRE			= 8;
	static var BG_PYRAMID		= 9;
	static var BG_SINGER		= 10;
	static var BG_STORM			= 11;
	static var BG_GUU			= 12;
	static var BG_SOCCER		= 13;


	// *** PLAYER
	static var PLAYER_SPEED			= 4.3;
	static var PLAYER_JUMP			= 18.7 ; // 19.5
	static var PLAYER_HKICK_X		= 3.5;
	static var PLAYER_HKICK_Y		= 7.4;
	static var PLAYER_VKICK			= 18;
	static var PLAYER_AIR_JUMP		= 7;
	static var WBOMB_SPEED			= PLAYER_SPEED*1.5;

	static var KICK_DISTANCE		= CASE_WIDTH;
	static var AIR_KICK_DISTANCE	= CASE_WIDTH*1.5;

	static var SHIELD_DURATION		= SECOND*5;
	static var WEAPON_DURATION		= SECOND*30 ; // en cycles
	static var SUPA_DURATION		= SECOND*30;
	static var EXTRA_LIFE_STEPS		= [100000,500000,1000000,2000000,3000000,4000000];
	static var TELEPORTER_DISTANCE	= CASE_WIDTH*4;

	static var BASE_COLORS			= [0xffffff, 0xf4e093, 0x5555ff, 0xfbb64f ];
	static var DARK_COLORS			= [0x70658d, 0xd54000, 0x0, 0x0 ];

	static var CURSE_PEACE		= 1;
	static var CURSE_SHRINK		= 2;
	static var CURSE_SLOW		= 3;
	static var CURSE_TAUNT		= 4;
	static var CURSE_MULTIPLY	= 5;
	static var CURSE_FALL		= 6;
	static var CURSE_MARIO		= 7;
	static var CURSE_TRAITOR	= 8;
	static var CURSE_GOAL		= 9;

	static var EDGE_TIMER		= SECOND*0.2;
	static var WAIT_TIMER		= SECOND*8;

	static var WEAPON_B_CLASSIC	= 1;
	static var WEAPON_B_BLACK	= 2;
	static var WEAPON_B_BLUE	= 3;
	static var WEAPON_B_GREEN	= 4;
	static var WEAPON_B_RED		= 5;
	static var WEAPON_B_REPEL	= 9;

	static var WEAPON_NONE		= -1;

	static var WEAPON_S_ARROW	= 6;
	static var WEAPON_S_FIRE	= 7;
	static var WEAPON_S_ICE		= 8;


	static var HEAD_NORMAL		= 1;
	static var HEAD_AFRO		= 2;
	static var HEAD_CERBERE		= 3;
	static var HEAD_PIOU		= 4;
	static var HEAD_MARIO		= 5
	static var HEAD_TUB			= 6;
	static var HEAD_IGORETTE	= 7;
	static var HEAD_LOSE		= 8;
	static var HEAD_CROWN		= 9;
	static var HEAD_SANDY		= 10;
	static var HEAD_SANDY_LOSE	= 11;
	static var HEAD_SANDY_CROWN	= 12;



	// *** BADS
	static var PEACE_COOLDOWN		= SECOND*3;
	static var AUTO_ANGER			= SECOND*4;
	static var MAX_ANGER			= 3;
	static var BALL_TIMEOUT			= 2.3*SECOND;
	static var BAD_HJUMP_X			= 5.5; // 6.5
	static var BAD_HJUMP_Y			= 8.5;
	static var BAD_VJUMP_X_CLIFF	= 2.2; // utilis� pour l'escalade (pied d'un mur)
	static var BAD_VJUMP_X			= 1.3; // utilis� pour l'escalade (marches dans le vide)
	static var BAD_VJUMP_Y			= 19;
	static var BAD_VJUMP_Y_LIST		= [
		11,	// 1 case
		14,	// 2 cases
		19, // 3 cases
	];
	static var BAD_VDJUMP_Y			= 6.5;
	static var FREEZE_DURATION		= SECOND * 5;
	static var KNOCK_DURATION		= SECOND * 3.75;
	static var PLAYER_KNOCK_DURATION= SECOND * 2.5;
	static var ICE_HIT_MIN_SPEED	= 4 ; // distance par cycle (dx+dy)
	static var ICE_KNOCK_MIN_SPEED	= 2 ; // distance par cycle (dx+dy)

	static var BAD_POMME		= 0;
	static var BAD_CERISE		= 1;
	static var BAD_BANANE		= 2;
	static var BAD_FIREBALL		= 3;
	static var BAD_ANANAS		= 4;
	static var BAD_ABRICOT		= 5;
	static var BAD_ABRICOT2		= 6;
	static var BAD_POIRE		= 7;
	static var BAD_BOMBE		= 8;
	static var BAD_ORANGE		= 9;
	static var BAD_FRAISE		= 10;
	static var BAD_CITRON		= 11;
	static var BAD_BALEINE		= 12;
	static var BAD_SPEAR		= 13;
	static var BAD_CRAWLER		= 14;
	static var BAD_TZONGRE		= 15;
	static var BAD_SAW			= 16;
	static var BAD_LITCHI		= 17;
	static var BAD_KIWI			= 18;
	static var BAD_LITCHI_WEAK	= 19;
	static var BAD_FRAMBOISE	= 20;

	static var LINKAGES = initLinkages();
	static function initLinkages() {
		var tab = new Array();
		tab[BAD_POMME]			= "hammer_bad_pomme";
		tab[BAD_CERISE]			= "hammer_bad_cerise";
		tab[BAD_BANANE]			= "hammer_bad_banane";
		tab[BAD_FIREBALL]		= "hammer_bad_fireball";
		tab[BAD_ANANAS]			= "hammer_bad_ananas";
		tab[BAD_ABRICOT]		= "hammer_bad_abricot";
		tab[BAD_ABRICOT2]		= "hammer_bad_abricot";
		tab[BAD_POIRE]			= "hammer_bad_poire";
		tab[BAD_BOMBE]			= "hammer_bad_bombe";
		tab[BAD_ORANGE]			= "hammer_bad_orange";
		tab[BAD_FRAISE]			= "hammer_bad_fraise";
		tab[BAD_CITRON]			= "hammer_bad_citron";
		tab[BAD_BALEINE]		= "hammer_bad_baleine";
		tab[BAD_SPEAR]			= "hammer_bad_spear";
		tab[BAD_CRAWLER]		= "hammer_bad_crawler";
		tab[BAD_TZONGRE]		= "hammer_bad_tzongre";
		tab[BAD_SAW]			= "hammer_bad_saw";
		tab[BAD_LITCHI]			= "hammer_bad_litchi";
		tab[BAD_KIWI]			= "hammer_bad_kiwi";
		tab[BAD_LITCHI_WEAK]	= "hammer_bad_litchi_weak";
		tab[BAD_FRAMBOISE]		= "hammer_bad_framboise";
		return tab;
	}


	// *** BOSS
	static var BAT_LEVEL = 100;
	static var TUBERCULOZ_LEVEL = 101;
	static var BOSS_BAT_MIN_DIST	= CASE_WIDTH*7;
	static var BOSS_BAT_MIN_X_DIST	= CASE_WIDTH*3;


	// *** ITEMS
	static var MAX_ITEMS		= 300;
	static var ITEM_LIFE_TIME	= 8*SECOND;
	static var DIAMANT			= 8;
	static var CONVERT_DIAMANT	= 17;
	static var EXTENDS			= ["C","R","Y","S","T","A","L"];
	static var SPECIAL_ITEM_TIMER	= 8*SECOND;
	static var SCORE_ITEM_TIMER		= 12*SECOND;


	// *** ITEM RANDOMIZER
	static var __NA = 0;
	static var COMM = 2000;
	static var UNCO = 1000;
	static var RARE = 300
	static var UNIQ = 100;
	static var MYTH = 10;
	static var CANE = 60; // sp�cifique canne de bobble
	static var LEGEND = 1;
	static var RARITY = [
		0,			// never randomly spawned
		COMM,		// common
		UNCO,		// unco
		RARE,		// rare
		UNIQ,		// really rare
		MYTH,		// mythic
		LEGEND,		// urban legend
		CANE
	];

	static var RAND_EXTENDS_ID	= auto_inc++;
	static var RAND_ITEMS_ID	= auto_inc++;
	static var RAND_SCORES_ID	= auto_inc++;

	static var RAND_EXTENDS		= [10,10,6,5,5,10,4];

	static var SPECIAL_ITEM_FAMILIES	: Array<Array<ItemFamilySet>>;
	static var SCORE_ITEM_FAMILIES		: Array<Array<ItemFamilySet>>;
	static var ITEM_VALUES				: Array<int>;
	static var FAMILY_CACHE				: Array<int>;
	static var LINKS					: Array<levels.PortalLink>;
	static var LEVEL_TAG_LIST			: Array< {name:String, did:int, lid:int} >;



	/*------------------------------------------------------------------------
	INITALISATION
	------------------------------------------------------------------------*/
	static function init(m) {
		manager = m ;
		SPECIAL_ITEM_FAMILIES	= xml_readSpecialItems();
		SCORE_ITEM_FAMILIES		= xml_readScoreItems();
		FAMILY_CACHE			= cacheFamilies();
		ITEM_VALUES				= getScoreItemValues();
		LINKS					= xml_readPortalLinks();
	}


	/*------------------------------------------------------------------------
	READS XML_ITEMS, RAW FORMAT
	(transitionnal)
	------------------------------------------------------------------------*/
	static function initItemsRaw() {
		var tab = new Array();
		var raw = Std.getVar( manager.root, "xml_items" );
		var node = new Xml( raw ).firstChild;
		if ( node.nodeName!="$items".substring(1) ) {
			GameManager.fatal("XML error: invalid node '"+node.nodeName+"'");
			return null;
		}

		// DEBUG: lecture et stockage "raw" de tous les items dans une seule famille
		var family = node.firstChild;
		while ( family!=null ) {
			node = family.firstChild;
			while ( node!=null ) {
				var rarity = int(node.get("$rarity".substring(1)));
				var id = int(node.get("$id".substring(1)));
				var rand = Data.__NA;
				switch ( rarity ) {
					case 1	: rand = Data.COMM;break;
					case 2	: rand = Data.UNCO;break;
					case 3	: rand = Data.RARE;break;
					case 4	: rand = Data.UNIQ;break;
					case 5	: rand = Data.MYTH;break;
					case 6	: rand = Data.__NA;break;
					case 7	: rand = Data.CANE;break;
				}
				tab[id] = rand;
				node = node.nextSibling;
			}
			family = family.nextSibling;
		}

		return tab;
	}

	/*------------------------------------------------------------------------
	READS XML ITEMS DATA
	------------------------------------------------------------------------*/
	static function xml_readFamily(xmlName) { // note: append leading "$" for obfuscator
		var tab = new Array();
		var raw = Std.getVar( manager.root, xmlName );
		var node = new Xml( raw ).firstChild;
		if ( node.nodeName!="$items".substring(1) ) {
			GameManager.fatal("XML error ("+xmlName+" @ "+manager.root._name+"): invalid node '"+node.nodeName+"'");
			return null;
		}

		var family = node.firstChild;
		while ( family!=null ) {
			node = family.firstChild;
			var fid = int( family.get("$id".substring(1)) );
			tab[fid] = new Array();
			while ( node!=null ) {
				var id		= int(node.get("$id".substring(1)));
				var rarity	= int(node.get("$rarity".substring(1)));
				var value	= int(node.get("$value".substring(1)));
				if ( value==null ) {
					value=0;
				}
				tab[fid].push( {
						id		: id,
						r		: Data.RARITY[rarity],
						v		: value,
						name	: Lang.getItemName(id)
				} );
				node = node.nextSibling;
			}
			family = family.nextSibling;
		}

		return tab;
	}

	static function xml_readSpecialItems() {
		return xml_readFamily("xml_specialItems");
	}

	static function xml_readScoreItems() {
		return xml_readFamily("xml_scoreItems");
	}


	/*------------------------------------------------------------------------
	BUILD A RAND ITEM TABLE CONTAINING SPECIFIED FAMILIES
	------------------------------------------------------------------------*/
	static function getRandFromFamilies(familySet:Array<Array<ItemFamilySet>>, familiesId:Array<int>) {
		var tab = new Array();
		for (var i=0;i<familiesId.length;i++) {
			var family = familySet[familiesId[i]];
			var n=0;
			while ( n<family.length ) {
				tab[family[n].id] = family[n].r;
				n++;
			}
		}
		return tab;
	}


	/*------------------------------------------------------------------------
	EXTRACTS SCORE VALUES FROM FAMILIES
	------------------------------------------------------------------------*/
	static function getScoreItemValues() {
		var tab = new Array();
		for (var i=0;i<Data.SCORE_ITEM_FAMILIES.length;i++) {
			var family = Data.SCORE_ITEM_FAMILIES[i];
			var n=0;
			while ( n<family.length ) {
				tab[family[n].id] = family[n].v;
				n++;
			}
		}
		return tab;
	}



	/*------------------------------------------------------------------------
	G�N�RE LA TABLE DE CORRESPONDANCE ITEM -> FAMILLE
	------------------------------------------------------------------------*/
	static function cacheFamilies() {
		var tab = new Array();

		for (var fid=0;fid<SPECIAL_ITEM_FAMILIES.length;fid++) {
			var f= SPECIAL_ITEM_FAMILIES[fid];
			for (var i=0;i<f.length;i++) {
				tab[f[i].id] = fid;
			}
		}

		for (var fid=0;fid<SCORE_ITEM_FAMILIES.length;fid++) {
			var f= SCORE_ITEM_FAMILIES[fid];
			for (var i=0;i<f.length;i++) {
				tab[f[i].id] = fid;
			}
		}
		return tab;
	}



	/*------------------------------------------------------------------------
	CONVERSION DID+LID EN NOM DE TAG
	------------------------------------------------------------------------*/
	static function getTagFromLevel(did, lid) {
		var name = null;
		for (var i=0;i<LEVEL_TAG_LIST.length;i++) {
			var tag = LEVEL_TAG_LIST[i];
			if ( tag.did==did && tag.lid==lid ) {
				name = tag.name;
			}
		}
		return name;
	}


	/*------------------------------------------------------------------------
	CONVERSION NOM DE TAG EN DID+LID
	------------------------------------------------------------------------*/
	static function getLevelFromTag(code:String) : {did:int,lid:int} {
		code = code.toLowerCase();
		var linfo	= null;
		var name	= code.split("+")[0];
		var inc		= Std.parseInt( code.split("+")[1], 10 );
		if ( Std.isNaN(inc) ) {
			inc = 0;
		}
		for (var i=0;i<LEVEL_TAG_LIST.length;i++) {
			var tag = LEVEL_TAG_LIST[i];
			if ( tag.name == name ) {
				linfo = {did:tag.did, lid:tag.lid+inc};
			}
		}
		return linfo;
	}



	/*------------------------------------------------------------------------
	LECTURE DU XML DES PORTALS
	------------------------------------------------------------------------*/
	static function xml_readPortalLinks() {
		var list = new Array();
		var raw = Std.getVar( manager.root, "xml_portalLinks" );
		var doc = new Xml(null);
		doc.ignoreWhite = true;
		doc.parseXML( raw );
		var node = doc.firstChild;
		if ( node.nodeName!="$links".substring(1) ) {
			GameManager.fatal("XML error (xml_portals @ "+manager.root._name+"): invalid node '"+node.nodeName+"'");
			return null;
		}


		// Lecture des tags de d�but de XML
		node = node.firstChild;
		if ( node.nodeName!="$tags".substring(1) ) {
			GameManager.fatal("XML error (xml_portals @ "+manager.root._name+"): invalid node '"+node.nodeName+"'");
		}

		var tag = node.firstChild;
		LEVEL_TAG_LIST = new Array();
		while ( tag!=null ) {
			LEVEL_TAG_LIST.push(
				{
					name	: tag.get("$name".substring(1)).toLowerCase(),
					did		: Std.parseInt(tag.get("$did".substring(1)),10),
					lid		: Std.parseInt(tag.get("$lid".substring(1)),10),
				}
			);
			tag = tag.nextSibling;
		}
		node = node.nextSibling;
		if ( node.nodeName!="$ways".substring(1) ) {
			GameManager.fatal("xml_readPortalLinks: unknown node "+node.nodeName);
			return null;
		}
		node = node.firstChild;


		// Lecture des links
		while ( node!=null ) {

			var att;

			att = node.get("$from".substring(1));
			att = Tools.replace( att, "(", "," );
			att = Tools.replace( att, ")", "" );
			att = Tools.replace( att, " ", "" );
			var from	= att.split(",");

			att = node.get("$to".substring(1));
			att = Tools.replace( att, "(", "," );
			att = Tools.replace( att, ")", "" );
			att = Tools.replace( att, " ", "" );
			var to		= att.split(",");


			var link	= new levels.PortalLink();
			var linfo = getLevelFromTag( from[0] );
			link.from_did	= linfo.did;
			link.from_lid	= linfo.lid;
			link.from_pid	= Std.parseInt(from[1], 10);

			linfo = getLevelFromTag( to[0] );
			link.to_did		= linfo.did;
			link.to_lid		= linfo.lid;
			link.to_pid		= Std.parseInt(to[1], 10);

			link.cleanUp();
			list.push(link);

			// 2-way portal
			if ( node.nodeName=="$twoway".substring(1) ) {
				var backLink = new levels.PortalLink();
				backLink.from_did	= link.to_did;
				backLink.from_lid	= link.to_lid;
				backLink.from_pid	= link.to_pid;
				backLink.to_did		= link.from_did;
				backLink.to_lid		= link.from_lid;
				backLink.to_pid		= link.from_pid;
				list.push(backLink);
			}


			node = node.nextSibling;
		}


		return list;
	}



	// *** MODE OPTIONS
	static var OPT_MIRROR			= "$mirror".substring(1);
	static var OPT_MIRROR_MULTI		= "$mirrormulti".substring(1);
	static var OPT_NIGHTMARE_MULTI	= "$nightmaremulti".substring(1);
	static var OPT_NIGHTMARE		= "$nightmare".substring(1);
	static var OPT_LIFE_SHARING		= "$lifesharing".substring(1);
	static var OPT_SOCCER_BOMBS		= "$soccerbomb".substring(1);
	static var OPT_KICK_CONTROL		= "$kickcontrol".substring(1);
	static var OPT_BOMB_CONTROL		= "$bombcontrol".substring(1);
	static var OPT_NINJA			= "$ninja".substring(1);
	static var OPT_BOMB_EXPERT		= "$bombexpert".substring(1);
	static var OPT_BOOST			= "$boost".substring(1);

	static var OPT_SET_TA_0			= "$set_ta_0".substring(1);
	static var OPT_SET_TA_1			= "$set_ta_1".substring(1);
	static var OPT_SET_TA_2			= "$set_ta_2".substring(1);

	static var OPT_SET_MTA_0		= "$set_mta_0".substring(1);
	static var OPT_SET_MTA_1		= "$set_mta_1".substring(1);
	static var OPT_SET_MTA_2		= "$set_mta_2".substring(1);

	static var OPT_SET_SOC_0		= "$set_soc_0".substring(1);
	static var OPT_SET_SOC_1		= "$set_soc_1".substring(1);
	static var OPT_SET_SOC_2		= "$set_soc_2".substring(1);
	static var OPT_SET_SOC_3		= "$set_soc_3".substring(1);




	// *** EDITOR
	static var FIELDS = [null, "BASE ", "noir ", "bleu ", "vert ", "rouge ", "warp ", "portal ", "goal 1", "goal 2", "bumper ", "peace " ];
	static var MAX_TILES = 53;
	static var MAX_BG = 30;
	static var MAX_BADS = 20;
	static var MAX_FIELDS = 11;
	static var TOOL_TILE = auto_inc++;
	static var TOOL_BAD = auto_inc++;
	static var TOOL_FIELD = auto_inc++;
	static var TOOL_START = auto_inc++;
	static var TOOL_SPECIAL = auto_inc++;
	static var TOOL_SCORE = auto_inc++;



	/*------------------------------------------------------------------------
	RENVOIE UNE COPIE
	------------------------------------------------------------------------*/
	static function duplicate(o:'a) : 'a {
		var codec = new PersistCodec();
		var s = codec.encode(o);
		return codec.decode(s);
	}


	/*------------------------------------------------------------------------
	VALEUR DES CRISTAUX
	------------------------------------------------------------------------*/
	static function getCrystalValue(id):int {
		return Math.round( Math.min(50000, (5*100)*Math.round(Math.pow(id+1,2))) );
	}

	static function getCrystalTime(id):int {
		var values = [1,3,5,7,9,10];
		return values[ int(Math.min(id, values.length-1)) ]
	}


	/*------------------------------------------------------------------------
	SERIALISATION, Format:  fileName;elem:elem:elem # fileName;elem:(...)
	------------------------------------------------------------------------*/
	static function serializeHash(h:Hash<Array<String>>):String {
		var str = "";
		h.iter(
			fun(k,e:Array<String>) {
				if (str.length>0)
				str+="#";
				str += k + ";" + e.join(":");
			}
		);
		return str;
	}



	/*------------------------------------------------------------------------
	D�SERIALISATION
	------------------------------------------------------------------------*/
	static function unserializeHash(str:String): Hash<Array<String>> {
		var h = new Hash();

		if ( str==null ) {
			return h;
		}

		var pairs = str.split("#");
		for (var i=0;i<pairs.length;i++) {
			var pair : Array<String> = pairs[i].split(";");
			var k = pair[0];
			var e = pair[1];
			if (e.length!=null) {
				h.set(k, Std.cast(e.split(":")));
			}
		}

		return h;
	}


	/*------------------------------------------------------------------------
	ENL�VE LES LEADING / END SPACES
	------------------------------------------------------------------------*/
	static function cleanLeading(s:String) {
		while (s.substr(0,1)==" ") {
			s = s.substr(1,s.length);
		}
		while (s.substr(s.length-1,1)==" ") {
			s = s.substr(0,s.length-1);
		}
		return s;
	}


	/*------------------------------------------------------------------------
	NETTOYAGE LEADING + SAUTS DE LIGNE
	------------------------------------------------------------------------*/
	static function cleanString(s:String) {
		s = cleanLeading(s);
		s = Tools.replace( s, String.fromCharCode(13), " ");
		return s;
	}


	/*------------------------------------------------------------------------
	AJOUT DE LEADING ZEROS
	------------------------------------------------------------------------*/
	static function leadingZeros(n:int,zeros:int) {
		var s = ""+n;
		while (s.length<zeros) {
			s = "0"+s;
		}
		return s;
	}


	/*------------------------------------------------------------------------
	REMPLACE UN CARACT�RE DELIMITER PAR UN TAG AVEC CLOSURE
	------------------------------------------------------------------------*/
	static function replaceTag(str:String, char, start, end) {
		var arr = str.split(char);
		if ( arr.length % 2 == 0 ) {
			GameManager.warning("invalid string (splitter "+char+"): "+str);
			return str;
		}

		var final = "";
		for (var i=0;i<arr.length;i++) {
			if ( (i%2)!=0 ) {
				final += start + arr[i] + end;
			}
			else {
				final += arr[i];
			}
		}
		return final;
	}



	/*------------------------------------------------------------------------
	CHRONOM�TRE DE DEBUG
	------------------------------------------------------------------------*/

	static var WATCH	= 0;

	static function stime() {
		WATCH = Std.getTimer();
	}

	static function time(n:String) {
		var t = Std.getTimer()-WATCH;
		Log.trace(n+" : "+t);
	}


	/*------------------------------------------------------------------------
	GROUPEMENT PAR 3 CHIFFRES
	------------------------------------------------------------------------*/
	static function formatNumber(n:int) {
		var txt = n+"";
		// Groupement des chiffres
		if ( txt.indexOf("-",0)<0 ) {
			for (var i=txt.length-3;i>0;i-=3) {
				txt = txt.substr(0,i)+"."+txt.substr(i,txt.length);
			}
		}
		return txt;
	}

	static function formatNumberStr(txt:String) {
		return formatNumber( Std.parseInt(txt,10) );
	}


	/*------------------------------------------------------------------------
	RENVOIE LE LINK CORRESPONDANT � UN PORTAL DONN�
	------------------------------------------------------------------------*/
	static function getLink(did, lid, pid) {
		var link = null;
		var i=0;
		while ( i<Data.LINKS.length && link==null ) {
			var l = Data.LINKS[i];
			if ( l.from_did==did && l.from_lid==lid && l.from_pid==pid ) {
				link = l;
			}
			i++;
		}
		return link;
	}

}

