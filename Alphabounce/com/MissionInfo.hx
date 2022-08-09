import mt.OldRandom;

typedef Mission = {
	name:String,
	desc:String,
	end:String,
	conditions:Array<Array<Int>>,
	startConditions:Array<Array<Int>>,
	startItem:Array<Array<Int>>,
	endItem:Array<Array<Int>>
}

class MissionInfo{//}

	// CONDITIONS
	public static var GOT_ITEM = 		0;
	public static var GOT_SHOPITEM =	1;
	public static var GOT_PLANET =		2;
	public static var ENTER_ZONE =		3;
	public static var LEAVE_ZONE =		4;
	public static var GOT_MISSION = 	5;
	public static var GOT_MISSILE = 	6;
	public static var GOT_MINERAI = 	7;
	public static var NOT_ITEM = 		8;
	public static var IS_LEVEL = 		9;

	// ITEM STATUS
	public static var INVISIBLE = 		0;	// NON-VISIBLE	/ NON-COLLECTABLE
	public static var VISIBLE = 		1;	// VISIBLE 	/ COLLECTABLE / INV
	public static var COLLECTED = 		2;      // COLLECTED
	public static var COLLECTED_INV = 	3;      // COLLECTED BUT NOT VISIBLE
	public static var TRIGGER = 		4;	// NON-VISIBLE	/ AUTO-COLLECTABLE / NO INV
	public static var SURPRISE = 		5;	// NON-VISIBLE	/ COLLECTABLE / INV
	public static var GROUND = 		6;

	// ITEMS
	public static var MISSILE_MAX =		40;

	public static var DISABLE_LEVEL_MISSIONS =	-11;
	public static var RESET_MISSION =	 	-10;
	public static var ENABLE_REBEL_MISSIONS = 	-9;
	public static var ENABLE_LEVEL_MISSIONS = 	-8;
	public static var LOSS_RADAR = 			-7;
	public static var NEW_RADAR = 			-6;
	public static var CHS = 			-5;
	public static var LOSS_LIFE = 			-4;
	public static var NEW_LIFE = 			-3;

	public static var MINERAI = 		-1;
	public static var FIRST_LEVEL = 	0;
	public static var CARD_RED = 		1;
	public static var CARD_GREEN = 		2;
	public static var CARD_BLUE = 		3;
	public static var BALL_DRILL = 		4;
	public static var HELP_SHIP = 		5;
	public static var DOUGLAS = 		6;
	public static var DEBRIS = 		7;

	public static var EXTENSION = 		14;
	public static var SYMBOLES = 		15;
	public static var SALMEEN = 		16;

	public static var LIFE_TODO = 		17;

	public static var MISSILE = 		18;

	public static var MAP_SHOP = 		58;
	public static var MISSILE_BLUE = 	59;	// RAY +
	public static var MISSILE_BLACK = 	60;	// DETRUIT STEEL
	public static var STONE_LYCANS = 	61;
	public static var STONE_SPIGNYSOS = 	62;
	public static var STAR_RED = 		63;
	public static var STAR_ORANGE = 	64;
	public static var STAR_YELLOW = 	65;
	public static var STAR_GREEN = 		66;
	public static var STAR_SKY = 		67;
	public static var STAR_BLUE = 		68;
	public static var STAR_PURPLE =		69;
	public static var EDITOR =		70;
	public static var MEDAL_0 =		71;
	public static var MEDAL_1 =		72;
	public static var MEDAL_2 =		73;
	public static var MEDAL =		74;
	public static var BALL_SOLDAT =		75;	// KILL MOLECULE
	public static var BALL_POWER =		76;	// DEGAT X2
	public static var BALL_BLACK =		77;	// DEGAT X3 traverse
	public static var MISSILE_RED =		78;	// RAY ++
	public static var SUPER_RADAR =		79;
	public static var RADAR_OK =		80;
	public static var GENERATOR =		81;
	public static var ANTIMAT_0 =		82;
	public static var ANTIMAT_1 =		83;
	public static var ANTIMAT_2 =		84;
	public static var ANTIMAT_3 =		85;
	public static var EVASION =		86;
	public static var WRECK_0 =		87;
	public static var WRECK_1 =		88;
	public static var WRECK_2 =		89;
	public static var WRECK_3 =		90;
	public static var LANDER_REACTOR =	91;
	public static var COMBINAISON =		92;
	public static var SALMEEN_COUSIN =	93;
	public static var BADGE_FURI =		94;
	public static var BELT_PASS =		95;
	public static var EXTENSION_2 =		96;
	public static var CRYSTAL_0 =		97;
	public static var CRYSTAL_1 =		98;
	public static var CRYSTAL_2 =		99;
	public static var CRYSTAL_3 =		100;
	public static var CRYSTAL_4 =		101;
	public static var SCROLL_0 =		102;
	public static var SCROLL_1 =		103;
	public static var SCROLL_2 =		104;
	public static var SCROLL_3 =		105;
	public static var SCROLL_4 =		106;
	public static var SCROLL_5 =		107;
	public static var SCROLL_6 =		108;
	public static var SCROLL_7 =		109;
	public static var SYNTROGEN =		110;
	public static var EXTENSION_3 =		111;
	public static var BALL_DOUBLE =		112;
	public static var RETROFUSER =		113;

	public static var TBL_0 =		114;
	public static var TBL_1 =		115;
	public static var TBL_2 =		116;
	public static var TBL_3 =		117;
	public static var TBL_4 =		118;
	public static var TBL_5 =		119;
	public static var TBL_6 =		120;
	public static var TBL_7 =		121;
	public static var TBL_8 =		122;
	public static var TBL_9 =		123;
	public static var TBL_10 =		124;
	public static var TBL_11 =		125;

	public static var KARBONITE =		126;
	public static var MINES =		127;

	public static var EMAP_0 =		128;
	// [...]
	public static var EMAP_41 =		169;

	public static var EARTH_PASS = 		170;
	public static var MODE_DIF = 		171;




	public static var encryptedList = haxe.Resource.getString("MissionInfo");


	public static var ITEMS:Array<{x:Int,y:Int,fam:Int}> = [];

	public static var LIST : Array<Mission> = [
		{	// 0 *0 Test d'entrée
			name:"mission_name_0",
			desc:"mission_desc_0",
			end:"mission_end_0",
			startConditions:[],
			conditions:[[ GOT_ITEM,FIRST_LEVEL ]],
			startItem:[ [FIRST_LEVEL,TRIGGER],[RADAR_OK,COLLECTED_INV] ],
			endItem:[[RADAR_OK,COLLECTED_INV]],
		},
		{	// 1 *1 Licence forage
			name:"mission_name_1",
			desc:"mission_desc_1",
			end:"mission_end_1",
			startConditions:[[GOT_MISSION,0]],
			conditions:[[ GOT_ITEM,CARD_RED,CARD_GREEN,CARD_BLUE ]],
			startItem:[ [CARD_RED,VISIBLE], [CARD_GREEN,VISIBLE], [CARD_BLUE,VISIBLE] ],
			endItem:[ [ENABLE_LEVEL_MISSIONS], [ BALL_DRILL, COLLECTED_INV ] ]

		},
		{	// 2 Une nouvelle colonie
			name:"mission_name_2",
			desc:"mission_desc_2",
			end:"mission_end_2",
			startConditions:[[GOT_MISSION,3]],
			conditions:[[ GOT_PLANET, ZoneInfo.SOUPALINE ]],
			startItem:[],
			endItem:[ [MINERAI,200], [CHS,12] ]
		},
		{	// 3 Appel de détresse
			name:"mission_name_3",
			desc:"mission_desc_3",
			end:"mission_end_3",
			startConditions:[[GOT_MISSION,1]],
			conditions:[[ GOT_ITEM, HELP_SHIP ]],
			startItem:[ [HELP_SHIP,TRIGGER] ],
			endItem:[ [DOUGLAS,COLLECTED] , [CHS,5] ]
		},
		{	// 4 *3 Lycans la rousse
			name:"mission_name_4",
			desc:"mission_desc_4",
			end:"mission_end_4",
			startConditions:[[GOT_MISSION,3]],
			conditions:[ [GOT_ITEM,DEBRIS+0], [GOT_ITEM,DEBRIS+1], [GOT_ITEM,DEBRIS+2], [GOT_ITEM,DEBRIS+3], [GOT_ITEM,DEBRIS+4], [GOT_ITEM,DEBRIS+5], [GOT_ITEM,DEBRIS+6] ],

			startItem:[ [DEBRIS+0,VISIBLE], [DEBRIS+1,VISIBLE], [DEBRIS+2,VISIBLE], [DEBRIS+3,VISIBLE], [DEBRIS+4,VISIBLE], [DEBRIS+5,VISIBLE], [DEBRIS+6,VISIBLE] ],
			endItem:[ [EXTENSION,VISIBLE], [DEBRIS+0,INVISIBLE], [DEBRIS+1,INVISIBLE], [DEBRIS+2,INVISIBLE], [DEBRIS+3,INVISIBLE], [DEBRIS+4,INVISIBLE], [DEBRIS+5,INVISIBLE], [DEBRIS+6,INVISIBLE] ]
		},
		{	// 5 Dans un dernier souffle...
			name:"mission_name_5",
			desc:null,
			end:"mission_end_5",
			startConditions:[[GOT_MISSION,3]],
			conditions:[[ LEAVE_ZONE, 4, -4, 7 ]],
			startItem:[],
			endItem:[ [DOUGLAS,INVISIBLE],[NEW_LIFE] ]
		},
		{	// 6 Des symboles etranges // 0
			name:"mission_name_6",
			desc:null,
			end:"mission_end_6",
			startConditions:[[GOT_MISSION,0]],		// ERREUR A CORRIGER
			conditions:[[ GOT_ITEM, SYMBOLES ]],
			startItem:[ [SYMBOLES, TRIGGER] ],
			endItem:[]
		},
		{	// 7 De la vie sur Tiboon // 0
			name:"mission_name_7",
			desc:"mission_desc_7",
			end:"mission_end_7",
			startConditions:[[GOT_MISSION,6]],
			conditions:[[ GOT_ITEM, SALMEEN ]],
			startItem:[[SALMEEN, TRIGGER ]],
			endItem:[]
		},
		{	// 8 Salmeen // 1
			name:"mission_name_8",
			desc:null,
			end:"mission_end_8",
			startConditions:[[GOT_MISSION,7]],
			conditions:[[ LEAVE_ZONE, 7, -10, 5 ]],
			startItem:[],
			endItem:[[CHS,10]]
		},
		{	// 9 TODO					// ERREUR A CORRIGER
			name:"mission_name_9",
			desc:"mission_desc_9",
			end:"mission_end_9",
			startConditions:[[GOT_MISSION,120]],
			conditions:[],
			startItem:[],
			endItem:[]
		},
		{	// 10 *6 Sur la route de Balixt
			name:"mission_name_10",
			desc:"mission_desc_10",
			end:"mission_end_10",
			startConditions:[[GOT_MISSION,14]],
			conditions:[[ ENTER_ZONE, -9, -39, 12 ]],
			startItem:[],
			endItem:[]
		},
		{	// 11 *6.5 Invasion de Balixt
			name:"mission_name_11",
			desc:"mission_desc_11",
			end:"mission_end_11",
			startConditions:[[GOT_MISSION,10]],
			conditions:[[ GOT_PLANET, ZoneInfo.BALIXT ]],
			startItem:[],
			endItem:[[NEW_LIFE]]
		},
		{	// 12 *2 Missile abandonné

			name:"mission_name_12",
			desc:"mission_desc_12",
			end:"mission_end_12",
			startConditions:[[GOT_MISSION,1]],
			conditions:[ [GOT_ITEM,MISSILE] ],
			startItem:[ [MISSILE,VISIBLE] ],
			endItem:[]
		},
		{	// 13 Un nouveau générateur
			name:"mission_name_13",
			desc:"mission_desc_13",
			end:"mission_end_13",
			startConditions:[[GOT_MISSION,1]],
			conditions:[ [GOT_SHOPITEM,ShopInfo.ENGINE] ],
			startItem:[ ],
			endItem:[ [MAP_SHOP,COLLECTED_INV] ]
		},
		{	// 14 *5 Rien n'arrête l'AR-57
			name:"mission_name_14",
			desc:"mission_desc_14",
			end:"mission_end_14",
			startConditions:[[GOT_MISSION,15]],
			conditions:[ [GOT_ITEM,MissionInfo.STONE_LYCANS,MissionInfo.STONE_SPIGNYSOS] ],
			startItem:[ [MissionInfo.STONE_LYCANS,VISIBLE],[MissionInfo.STONE_SPIGNYSOS,VISIBLE] ],
			endItem:[ [MISSILE_BLUE,COLLECTED_INV] ]
		},
		{	// 15 *4 Retrouver le générateur
			name:"mission_name_15",
			desc:"mission_desc_15",
			end:"mission_end_15",
			startConditions:[[GOT_MISSION,4]],
			conditions:[ [GOT_ITEM,GENERATOR] ],
			startItem:[ [GENERATOR,VISIBLE] ],
			endItem:[]
		},
		{	// 16 *7 - 7xETOILES TODO Poussières d'étoile
			name:"mission_name_16",
			desc:"mission_desc_16",
			end:"mission_end_16",
			startConditions:[[GOT_MISSION,11]],
			conditions:[ [GOT_ITEM,STAR_RED,STAR_ORANGE,STAR_YELLOW,STAR_GREEN,STAR_SKY,STAR_BLUE,STAR_PURPLE] ],
			startItem:[ [STAR_RED,VISIBLE], [STAR_ORANGE,VISIBLE], [STAR_YELLOW,VISIBLE], [STAR_GREEN,VISIBLE], [STAR_SKY,VISIBLE], [STAR_BLUE,VISIBLE], [STAR_PURPLE,VISIBLE]],
			endItem:[ [EDITOR,COLLECTED_INV] ]
		},
		{	// 17 Pre-Moltear
			name:"mission_name_17",
			desc:null,
			end:"mission_end_17",
			startConditions:[[GOT_MISSION,0]],
			conditions:[ [GOT_ITEM,MEDAL_0,MEDAL_1,MEDAL_2] ],
			startItem:[ [MEDAL_0,SURPRISE], [MEDAL_1,SURPRISE], [MEDAL_2,SURPRISE]],
			endItem:[ [MEDAL,COLLECTED] ]
		},
		{	// 18 DESTRUCTION DES ENVELOPPES
			name:"mission_name_18",
			desc:null,
			end:"mission_end_18",
			startConditions:[[GOT_MISSION,0]],
			conditions:[ [LEAVE_ZONE, 0, 0, 6] ],
			startItem:[],
			endItem:[ [LOSS_LIFE], [LOSS_LIFE], [LOSS_LIFE] ]
		},
		{	// 19 PROBLEMES DE RADAR
			name:"mission_name_19",
			desc:null,
			end:"mission_end_19",
			startConditions:[[GOT_ITEM,RADAR_OK]],
			conditions:[ [ENTER_ZONE, -10, -11, 3],[GOT_ITEM,RADAR_OK] ],
			startItem:[],
			endItem:[ [LOSS_RADAR],[RADAR_OK,INVISIBLE],[RESET_MISSION,19] ]
		},
		{	// 20 SALMEN ET L'AMBRO-X
			name:"mission_name_20",
			desc:null,
			end:"mission_end_20",
			startConditions:[[GOT_MISSION,8],[NOT_ITEM,MODE_DIF]],
			conditions:[ [ENTER_ZONE, -58, 36, 9] ],
			startItem:[],
			endItem:[[SUPER_RADAR,VISIBLE]]
		},
		{	// 21 BALLE SOLDAT AU SAIN DE MOLTEAR
			name:"mission_name_21",
			desc:"mission_desc_21",
			end:"mission_end_21",
			startConditions:[[GOT_MISSION,14]],
			conditions:[[GOT_ITEM,BALL_SOLDAT]],
			startItem:[[BALL_SOLDAT,VISIBLE]],
			endItem:[]
		},
		{	// 22 BALLE PUISSANCE PERDU DANS L'UNIVERS
			name:"mission_name_22",
			desc:"mission_desc_22",
			end:"mission_end_22",
			startConditions:[[GOT_MISSION,11]],
			conditions:[[GOT_ITEM,BALL_POWER]],
			startItem:[[BALL_POWER,VISIBLE] ],
			endItem:[]
		},
		{	// 23 FURI - BALLE SECRETE : ASPHALT
			name:"mission_name_23",
			desc:"mission_name_23",
			end:"mission_end_23",
			startConditions:[[GOT_ITEM,EVASION],[IS_LEVEL,100],[GOT_MISSION,22]],
			conditions:[[GOT_ITEM,BALL_BLACK]],
			startItem:[[BALL_BLACK,VISIBLE]],
			endItem:[]
		},
		{	// 24 PROBLEMES DE RADAR 2
			name:"mission_name_24",
			desc:null,
			end:"mission_end_24",
			startConditions:[[GOT_ITEM,RADAR_OK]],
			conditions:[ [ENTER_ZONE, 48, 13, 5],[GOT_ITEM,RADAR_OK] ],
			startItem:[],
			endItem:[[LOSS_RADAR],[RADAR_OK,INVISIBLE],[RESET_MISSION,24]]
		},
		{	// 25 PROBLEMES DE RADAR 3
			name:"mission_name_25",
			desc:null,
			end:"mission_end_25",
			startConditions:[[GOT_ITEM,RADAR_OK]],
			conditions:[ [ENTER_ZONE, -22, 43, 6],[GOT_ITEM,RADAR_OK] ],
			startItem:[],
			endItem:[ [LOSS_RADAR],[RADAR_OK,INVISIBLE],[RESET_MISSION,25]]
		},
		{	// 26 PROBLEMES DE RADAR 3
			name:"mission_name_26",
			desc:null,
			end:"mission_end_26",
			startConditions:[[GOT_ITEM,RADAR_OK]],
			conditions:[ [ENTER_ZONE, -67, -32, 7],[GOT_ITEM,RADAR_OK] ],
			startItem:[],
			endItem:[ [LOSS_RADAR],[RADAR_OK,INVISIBLE],[RESET_MISSION,26] ]
		},
		{	// 27 NOYAUX ANTIMATIERE
			name:"mission_name_27",
			desc:"mission_desc_27",
			end:"mission_end_27",
			startConditions:[[GOT_MISSION,21]],
			conditions:[ [GOT_ITEM,ANTIMAT_0,ANTIMAT_1,ANTIMAT_2,ANTIMAT_3] ],
			startItem:[ [ANTIMAT_0,SURPRISE], [ANTIMAT_1,SURPRISE], [ANTIMAT_2,SURPRISE], [ANTIMAT_3,SURPRISE] ],
			endItem:[ [MISSILE_BLACK,COLLECTED] ]
		},
		{	// 28 LIMITE DE ZONE - CEINTURE DE KARBONIS
			name:"mission_name_28",
			desc:"mission_desc_28",
			end:"mission_end_28",
			startConditions:[[NOT_ITEM,BELT_PASS],[NOT_ITEM,EVASION],[LEAVE_ZONE, 27, 6,  ZoneInfo.ASTEROBELT_RAY-20] ],
			conditions:[[LEAVE_ZONE, 27, 6, ZoneInfo.ASTEROBELT_RAY],[NOT_ITEM,BELT_PASS]],
			startItem:[],
			endItem:[[EVASION,COLLECTED],[DISABLE_LEVEL_MISSIONS],[RESET_MISSION,28]]
		},
		{	// 29 SALMEEN LE MECANO ETAPE 1
			name:"mission_name_29",
			desc:"mission_desc_29",
			end:"mission_end_29",
			startConditions:[ [ LEAVE_ZONE, 7, -10, 8 ], [GOT_ITEM,SALMEEN] ],
			conditions:[ [GOT_ITEM, WRECK_0, WRECK_1, WRECK_2, WRECK_3] ],
			startItem:[ [WRECK_0,VISIBLE], [WRECK_1,VISIBLE], [WRECK_2,VISIBLE], [WRECK_3,VISIBLE] ],
			endItem:[ [LANDER_REACTOR,COLLECTED] ]
		},
		{	// 30 SALMEEN LE MECANO ETAPE 2
			name:"mission_name_30",
			desc:"mission_desc_30",
			end:"mission_end_30",
			startConditions:[[GOT_MISSION,29],[GOT_MISSION,5]],
			conditions:[[GOT_SHOPITEM,ShopInfo.PODS]],
			startItem:[],
			endItem:[[LOSS_LIFE]]
		},
		{	// 31 ESCORP - COMBINAISON GRATUITE
			name:"mission_name_31",
			desc:"mission_desc_31",
			end:"mission_end_31",
			startConditions:[ [NOT_ITEM,COMBINAISON], [NOT_ITEM,EVASION], [GOT_MISSION,30], [LEAVE_ZONE,-12,-1,60] ],
			conditions:[[GOT_ITEM,COMBINAISON]],
			startItem:[[COMBINAISON,GROUND]],
			endItem:[[CHS,20]]
		},
		{	// 32 SALMEEN - COMBINAISON DE SECOURS
			name:"mission_name_32",
			desc:"mission_desc_32",
			end:"mission_end_32",
			startConditions:[ [NOT_ITEM,COMBINAISON], [GOT_ITEM,EVASION], [GOT_MISSION,30], [LEAVE_ZONE,-12,-1,70] ],
			conditions:[[GOT_ITEM,SALMEEN_COUSIN]],
			startItem:[[SALMEEN_COUSIN,GROUND]],
			endItem:[[COMBINAISON,COLLECTED]]
		},
		{	// 33 SIGNAL NALIKORS
			name:"mission_name_33",
			desc:"mission_desc_33",
			end:"mission_end_33",
			startConditions:[ [GOT_ITEM,EVASION], [LEAVE_ZONE, 27, 6, ZoneInfo.ASTEROBELT_RAY+20] ],
			conditions:[ [ENTER_ZONE, 67, 153, 7] ],
			startItem:[],
			endItem:[]
		},
		{	// 34 CAMPAGNE FURI
			name:"mission_name_34",
			desc:"mission_desc_34",
			end:"mission_end_34",
			startConditions:[ [GOT_ITEM,EVASION], [ENTER_ZONE, 67, 153, 5] ],
			conditions:[[GOT_ITEM,BADGE_FURI]],
			startItem:[[BADGE_FURI,GROUND]],
			endItem:[[ENABLE_REBEL_MISSIONS]]
		},
		{	// 35 ESCORP - RECHERCHE DES REBELLES
			name:"mission_name_35",
			desc:"mission_desc_35",
			end:"mission_end_35",
			startConditions:[ [NOT_ITEM,EVASION], [IS_LEVEL,63]],
			conditions:[[GOT_MISSION,120]],
			startItem:[[CHS,20]],
			endItem:[]
		},
		{	// 36 ESCORP - ESPIONNAGE
			name:"mission_name_36",
			desc:"mission_desc_36",
			end:"mission_end_36",
			startConditions:[ [NOT_ITEM,EVASION], [IS_LEVEL,52] ],
			conditions:[[GOT_PLANET,ZoneInfo.NALIKORS]],
			startItem:[[BELT_PASS,COLLECTED],[RESET_MISSION,28]],
			endItem:[[MINERAI,1500]]
		},
		{	// 37 ESCORP - EXTENSION ULTIME
			name:"mission_name_37",
			desc:"mission_desc_37",
			end:"mission_end_37",
			startConditions:[ [NOT_ITEM,EVASION], [IS_LEVEL,100] ],
			conditions:[[GOT_ITEM,EXTENSION_2]],
			startItem:[[EXTENSION_2,VISIBLE]],
			endItem:[]
		},
		{	// 38 ESCORP - CRYSTAL ROSE --> MISSILE SONIQUE
			name:"mission_name_38",
			desc:"mission_desc_38",
			end:"mission_end_38",
			startConditions:[ [NOT_ITEM,EVASION], [IS_LEVEL,87] ],
			conditions:[ [GOT_ITEM,CRYSTAL_0,CRYSTAL_1,CRYSTAL_2,CRYSTAL_3,CRYSTAL_4] ],
			startItem:[ [CRYSTAL_0,SURPRISE], [CRYSTAL_1,SURPRISE], [CRYSTAL_2,SURPRISE], [CRYSTAL_3,SURPRISE], [CRYSTAL_4,SURPRISE] ],
			endItem:[[MISSILE_RED,COLLECTED]]
		},
		{	// 39 FURI - SYNTROGEN
			name:"mission_name_39",
			desc:"mission_desc_39",
			end:"mission_end_39",
			startConditions:[ [GOT_ITEM,EVASION], [IS_LEVEL,20] ],
			conditions:[[GOT_ITEM,SCROLL_0,SCROLL_1,SCROLL_2,SCROLL_3,SCROLL_4,SCROLL_5,SCROLL_6,SCROLL_7]],
			startItem:[[SCROLL_0,VISIBLE], [SCROLL_1,VISIBLE], [SCROLL_2,VISIBLE], [SCROLL_3,VISIBLE], [SCROLL_4,VISIBLE], [SCROLL_5,VISIBLE], [SCROLL_6,VISIBLE], [SCROLL_7,VISIBLE] ],
			endItem:[[SYNTROGEN,VISIBLE]]
		},
		{	// 40 FURI - HOLOVAN TERRE DE PAIX
			name:"mission_name_40",
			desc:"mission_desc_40",
			end:"mission_end_40",
			startConditions:[ [GOT_ITEM,EVASION], [IS_LEVEL,5] ],
			conditions:[[GOT_PLANET,ZoneInfo.HOLOVAN]],
			startItem:[],
			endItem:[[BALL_DOUBLE,GROUND]]
		},
		{	// 41 SALMEEN - DEPART DE SALMEEN > VIE SUPPLEMENTAIRE
			name:"mission_name_41",
			desc:"mission_desc_41",
			end:"mission_end_41",
			startConditions:[[GOT_MISSION,30],[GOT_MISSION,20]],
			conditions:[[ ENTER_ZONE, 180, -191, 6 ]],
			startItem:[],
			endItem:[[NEW_LIFE],[CHS,50],[SALMEEN,INVISIBLE]]
		},
		{	// 42 ESCORP - TELEPORTEUR
			name:"mission_name_42",
			desc:"mission_desc_42",
			end:"mission_end_42",
			startConditions:[[NOT_ITEM,EVASION],[IS_LEVEL,73]],
			conditions:[[GOT_ITEM,RETROFUSER]],
			startItem:[[RETROFUSER,GROUND]],
			endItem:[]
		},
		{	// 43 ALL - TABLETTES
			name:"mission_name_43",
			desc:null,
			end:"mission_end_43",
			startConditions:[[GOT_MISSION,5]],
			conditions:[[GOT_ITEM, TBL_0, TBL_1, TBL_2, TBL_3, TBL_4, TBL_5, TBL_6, TBL_7, TBL_8, TBL_9, TBL_10, TBL_11 ]],
			startItem:[[TBL_0,GROUND],[TBL_1,GROUND],[TBL_2,GROUND],[TBL_3,GROUND],[TBL_4,GROUND],[TBL_5,GROUND],[TBL_6,GROUND],[TBL_7,GROUND],[TBL_8,GROUND],[TBL_9,GROUND],[TBL_10,GROUND],[TBL_11,GROUND]],
			endItem:[]
		},
		{	// 44 ALL - TABLETTES -< TROUVER L'Ingenieur Karbonite
			name:"mission_name_44",
			desc:"mission_desc_44",
			end:"mission_end_44",
			startConditions:[[GOT_MISSION,43]],
			conditions:[[GOT_ITEM,KARBONITE]],
			startItem:[[KARBONITE,GROUND]],
			endItem:[[NEW_RADAR]]
		},
		{	// 45 ESCORP - MINES FORA 7R-Z
			name:"mission_name_45",
			desc:"mission_desc_45",
			end:"mission_end_45",
			startConditions:[[NOT_ITEM,EVASION],[IS_LEVEL,58]],
			conditions:[[GOT_PLANET,ZoneInfo.CILORILE]],
			startItem:[],
			endItem:[[MINES,COLLECTED]]
		},
		{	// 46 ALL - PID PLANET
			name:"mission_name_46",
			desc:null,
			end:"mission_end_46",
			startConditions:[[GOT_MISSION,0]],
			conditions:[[GOT_MISSION,120]],
			startItem:[
				[EMAP_0,GROUND],
				[EMAP_0+1,GROUND],
				[EMAP_0+2,GROUND],
				[EMAP_0+3,GROUND],
				[EMAP_0+4,GROUND],
				[EMAP_0+5,GROUND],
				[EMAP_0+6,GROUND],
				[EMAP_0+7,GROUND],
				[EMAP_0+8,GROUND],
				[EMAP_0+9,GROUND],
				[EMAP_0+10,GROUND],
				[EMAP_0+11,GROUND],
				[EMAP_0+12,GROUND],
				[EMAP_0+13,GROUND],
				[EMAP_0+14,GROUND],
				[EMAP_0+15,GROUND],
				[EMAP_0+16,GROUND],
				[EMAP_0+17,GROUND],
				[EMAP_0+18,GROUND],
				[EMAP_0+19,GROUND],
				[EMAP_0+20,GROUND],
				[EMAP_0+21,GROUND],
				[EMAP_0+22,GROUND],
				[EMAP_0+23,GROUND],
				[EMAP_0+24,GROUND],
				[EMAP_0+25,GROUND],
				[EMAP_0+26,GROUND],
				[EMAP_0+27,GROUND],
				[EMAP_0+28,GROUND],
				[EMAP_0+29,GROUND],
				[EMAP_0+30,GROUND],
				[EMAP_0+31,GROUND],
				[EMAP_0+32,GROUND],
				[EMAP_0+33,GROUND],
				[EMAP_0+34,GROUND],
				[EMAP_0+35,GROUND],
				[EMAP_0+36,GROUND],
				[EMAP_0+37,GROUND],
				[EMAP_0+38,GROUND],
				[EMAP_0+39,GROUND],
				[EMAP_0+40,GROUND],
				[EMAP_0+41,GROUND],
			],
			endItem:[]
		},
		{	// 47 ALL - SALMEEN - DEPART DE SALMEEN > VIE SUPPLEMENTAIRE	XXX SPECIAL MODE DIF
			name:"mission_name_41",
			desc:"mission_desc_41",
			end:"mission_end_41",
			startConditions:[[GOT_MISSION,30],[GOT_ITEM,MODE_DIF]],
			conditions:[[ ENTER_ZONE, 180, -191, 6 ]],
			startItem:[],
			endItem:[[NEW_LIFE],[CHS,50],[SALMEEN,INVISIBLE]]
		},


	];

	// !!! A appelé avant d'utiliser LIST


	static function initFonction(){


		#if web

		//VERITABLE LISTE DES ITEMS NE PAS EFFACER !
		var a = [
			{ 	x:0, 	y:0,			fam:0 }, // First Level
			{ 	x:0, 	y:-1,			fam:0 }, // Accreditation Alpha
			{ 	x:-1, 	y:1,			fam:0 }, // Accreditation Beta
			{ 	x:2, 	y:1,			fam:0 }, // Accreditation Ceta
			{ 	x:0, 	y:1,			fam:0 }, // Balle de Forage
			{ 	x:4, 	y:-4,			fam:0 }, // Appel de detresse
			{ 	x:null,	y:null,			fam:0 }, // Douglas
			{ 	x:-1, 	y:8,			fam:0 }, // Debris centrale
			{ 	x:3, 	y:8,			fam:0 }, // Debris coupant
			{ 	x:-3, 	y:7,			fam:0 }, // Debris singulier
			{ 	x:1, 	y:9,			fam:0 }, // Debris fumant
			{ 	x:-4, 	y:9,			fam:0 }, // Debris curieux
			{ 	x:-2, 	y:11,			fam:0 }, // Debris minuscule
			{ 	x:0, 	y:6,			fam:0 }, // Debris anodin
			{ 	x:-1, 	y:0,			fam:0 }, // Extension envellope
			{ 	x:9, 	y:-10,			fam:0 }, // Symboles étranges
			{ 	x:7, 	y:-10,			fam:0 }, // Salmeen
			{ 	x:1, 	y:1,			fam:0 }, // ---
			{ 	x:-1, 	y:-2,			fam:1 }, // Missile

			{ 	x:null, y:null,			fam:0 }, // Carte des marchands
			{ 	x:null, y:null,			fam:0 }, // Missile bleu
			{ 	x:null, y:null,			fam:0 }, // Missile noir
			{ 	x:3, 	y:16,			fam:0 }, // Pierre de Lycans
			{ 	x:-39,  y:-9,			fam:0 }, // Pierre de Spignysos
			{ 	x:25,  y:-110,			fam:2 }, // Etoile rouge
			{ 	x:170,  y:-100,			fam:2 }, // Etoile orange
			{ 	x:115,  y:80,			fam:2 }, // Etoile jaune
			{ 	x:-37,  y:176,			fam:2 }, // Etoile verte
			{ 	x:-54,  y:49,			fam:2 }, // Etoile turquoise
			{ 	x:-170,  y:-36,			fam:2 }, // Etoile bleue
			{ 	x:-97,  y:-174,			fam:2 }, // Etoile violette
			{ 	x:null,  y:null,		fam:0 }, // Editeur minier
			{ 	x:-58, y:30,			fam:0 }, // Medaillon partie ronde
			{	x:-51, y:37,			fam:0 }, // Medaillon partie croissante
			{ 	x:-54, y:40,			fam:0 }, // Medaillon partie creuse
			{ 	x:null, y:null,			fam:0 }, // Medaillon Moltearien
			{ 	x:-54, y:32,			fam:0 }, // Balle OX-Soldat
			{ 	x:-532, y:123,			fam:0 }, // Balle OX-Delta
			{ 	x:450, y:826,			fam:0 }, // Balle Asphalt
			{ 	x:null, y:null,			fam:0 }, // Missile Rouge
			{ 	x:-60, y:36,			fam:0 }, // Ambro-X
			{ 	x:null, y:null,			fam:0 }, // Radar ok
			{ 	x:11, y:-1,			fam:0 }, // Generateur
		];
		a = a.concat([
			{ 	x:18, y:-40,			fam:4 }, // Noyaux anti-matiere
			{ 	x:-30, y:42,			fam:4 }, // Noyaux anti-matiere
			{ 	x:35, y:-28,			fam:4 }, // Noyaux anti-matiere
			{ 	x:30, y:61,			fam:4 }, // Noyaux anti-matiere

			{ 	x:null, y:null,			fam:0 }, // Proces verbal d'evasion
			{ 	x:44, y:-5,			fam:0 }, // Bouclier atmospherique
			{ 	x:46, y:-1,			fam:0 }, // Blindage externe
			{	x:50, y:-9,			fam:0 }, // Stabilisateurs hydroliques
			{ 	x:58, y:-12,			fam:0 }, // Epave de réacteur
			{ 	x:null, y:null,			fam:0 }, // Réacteur de surface
			{ 	x:76, y:-20,			fam:0 }, // Combinaison
			{ 	x:-7, y:2,			fam:0 }, // Cousin de Salmeen
			{ 	x:64, y:154,			fam:0 }, // Badge FURI
			{ 	x:null, y:null,			fam:0 }, // Karbonis-Belt Pass

			{ 	x:-2, 	y:0,			fam:0 }, // Extension d'envellope 2
			{ 	x:303, 	y:-60,			fam:5 }, // Crystal rose A
			{ 	x:340, 	y:-112,			fam:5 }, // Crystal rose B
			{ 	x:281, 	y:-76,			fam:5 }, // Crystal rose C
			{ 	x:284, 	y:-15,			fam:5 }, // Crystal rose D
			{ 	x:350, 	y:-44,			fam:5 }, // Crystal rose E
			{ 	x:21, 	y:118,			fam:6 }, // Parchemin A
			{ 	x:-41, 	y:93,			fam:6 }, // Parchemin B
			{ 	x:-83, 	y:19,			fam:6 }, // Parchemin C
			{ 	x:-80, 	y:-20,			fam:6 }, // Parchemin D
			{ 	x:-36, 	y:-84,			fam:6 }, // Parchemin E
			{ 	x:103, 	y:-73,			fam:6 }, // Parchemin F
			{ 	x:134, 	y:-21,			fam:6 }, // Parchemin G
			{ 	x:81, 	y:102,			fam:6 }, // Parchemin H
			{ 	x:67, 	y:152,			fam:0 }, // Acc. syntrogènique
			{ 	x:null, y:null,			fam:0 }, // Extension d'envellope 3
			{ 	x:-148, y:108,			fam:0 }, // Jumeleur de Saumir
			{ 	x:83, y:-123,			fam:0 }, // Rétrofuseur du Dr Sactus

			{ 	x:127, y:-24,			fam:7 }, // Tablette Karbonite
			{ 	x:142, y:6,			fam:7 }, // Tablette Karbonite
			{ 	x:119, y:65,			fam:7 }, // Tablette Karbonite
			{ 	x:58, y:106,			fam:7 }, // Tablette Karbonite
			{ 	x:-14, y:113,			fam:7 }, // Tablette Karbonite
			{ 	x:-67, y:66,			fam:7 }, // Tablette Karbonite
			{ 	x:-85, y:18,			fam:7 }, // Tablette Karbonite
			{ 	x:-64, y:-56,			fam:7 }, // Tablette Karbonite
			{ 	x:-29, y:-98,			fam:7 }, // Tablette Karbonite
			{ 	x:28, y:-111,			fam:7 }, // Tablette Karbonite
			{ 	x:65, y:-102,			fam:7 }, // Tablette Karbonite
			{ 	x:102, y:-64,			fam:7 }, // Tablette Karbonite

			{ 	x:70, y:151,			fam:0 }, // Ingenieur Karbonite
			{ 	x:null, y:null,			fam:0 }, // Mines

			{ 	x:-59, y:34,			fam:8 }, // EARTH MAP 0 - MOLTEAR
			{ 	x:-51, y:36,			fam:8 }, // EARTH MAP 1 - MOLTEAR
			{ 	x:-8, y:1,			fam:8 }, // EARTH MAP 2 - SOUPALINE
			{ 	x:2, y:20,			fam:8 }, // EARTH MAP 3 - LYCANS
			{ 	x:-1, y:16,			fam:8 }, // EARTH MAP 4 - LYCANS
			{ 	x:7, y:9,			fam:8 }, // EARTH MAP 5 - LYCANS
			{ 	x:417, y:93,			fam:8 }, // EARTH MAP 6 - SAMOSA
			{ 	x:407, y:92,			fam:8 }, // EARTH MAP 7 - SAMOSA
			{ 	x:415, y:85,			fam:8 }, // EARTH MAP 8 - SAMOSA
			{ 	x:408, y:100,			fam:8 }, // EARTH MAP 9 - SAMOSA
			{ 	x:420, y:99,			fam:8 }, // EARTH MAP 10 - SAMOSA
			{ 	x:10, y:-12,			fam:8 }, // EARTH MAP 11 - TIBOON
			{ 	x:-9, y:-43,			fam:8 }, // EARTH MAP 12 - BALIXT
			{ 	x:-14, y:-38,			fam:8 }, // EARTH MAP 13 - BALIXT
			{ 	x:-53, y:90,			fam:8 }, // EARTH MAP 14 - KARBONIS
			{ 	x:132, y:44,			fam:8 }, // EARTH MAP 15 - KARBONIS
			{ 	x:-41, y:-13,			fam:8 }, // EARTH MAP 16 - SPIGNYSOS
			{ 	x:-34, y:-10,			fam:8 }, // EARTH MAP 17 - SPIGNYSOS
			{ 	x:-20, y:83,			fam:8 }, // EARTH MAP 18 - POFIAK
			{ 	x:-16, y:83,			fam:8 }, // EARTH MAP 19 - POFIAK
			{ 	x:-81, y:-105,			fam:8 }, // EARTH MAP 20 - DOURIV
			{ 	x:-90, y:-106,			fam:8 }, // EARTH MAP 21 - DOURIV
			{ 	x:-85, y:-108,			fam:8 }, // EARTH MAP 22 - DOURIV
			{ 	x:77, y:-121,			fam:8 }, // EARTH MAP 23 - GRIMORN
			{ 	x:80, y:-123,			fam:8 }, // EARTH MAP 24 - GRIMORN
			{ 	x:247, y:-46,			fam:8 }, // EARTH MAP 25 - DTRITUS
			{ 	x:68, y:150,			fam:8 }, // EARTH MAP 26 - NALIKORS
			{ 	x:63, y:151,			fam:8 }, // EARTH MAP 27 - NALIKORS
			{ 	x:-150, y:111,			fam:8 }, // EARTH MAP 28 - HOLOVAN
			{ 	x:-149, y:116,			fam:8 }, // EARTH MAP 29 - HOLOVAN
			{ 	x:180, y:-193,			fam:8 }, // EARTH MAP 30 - KHORLAN
			{ 	x:184, y:-189,			fam:8 }, // EARTH MAP 31 - KHORLAN
			{ 	x:79, y:-28,			fam:8 }, // EARTH MAP 32 - CILORILE
			{ 	x:75, y:-24,			fam:8 }, // EARTH MAP 33 - CILORILE
			{ 	x:191, y:113,			fam:8 }, // EARTH MAP 34 - TARCITURNE
			{ 	x:189, y:116,			fam:8 }, // EARTH MAP 35 - TARCITURNE
			{ 	x:-323, y:-575,			fam:8 }, // EARTH MAP 36 - CHAGARINA
			{ 	x:-320, y:-577,			fam:8 }, // EARTH MAP 37 - CHAGARINA
			{ 	x:-306, y:-149,			fam:8 }, // EARTH MAP 38 - VOLCER
			{ 	x:-298, y:-151,			fam:8 }, // EARTH MAP 39 - VOLCER
			{ 	x:-295, y:-142,			fam:8 }, // EARTH MAP 40 - VOLCER
			{ 	x:-345, y:359,			fam:8 }, // EARTH MAP 41 - BALMANCH

			{ 	x:null, y:null,			fam:0 },
		]);

		ITEMS = a;
		#else
		/*

		var str = haxe.Serializer.run(a);
		var o = new mt.net.Codec("bonjour");
		str = StringTools.urlEncode(o.run(str));
		flash.System.setClipboard(str);
		/*/

		//trace(encryptedList);

		var str = StringTools.urlDecode(encryptedList);
		var o = new mt.net.Codec("bonjour");
		ITEMS = haxe.Unserializer.run(o.run(str));
		//*/

		#end

		// MISSILE
		var seed = new OldRandom(2657);
		var mi = LIST[12];
		var ray = 5;
		var max = MISSILE_MAX-1;
		var a = seed.random(6280)/1000;
		for( i in 0...max ){
			var c = i/max;
			var id = MISSILE+(i+1);
			var ray = 9+Math.pow(c,2)*500;
			a += 1+seed.random(3000)/1000;
			var x = Std.int(Math.cos(a)*ray);
			var y = Std.int(Math.sin(a)*ray);
			ITEMS.insert( id, {x:x,y:y,fam:1} );
			//Text.ITEM_NAMES.insert( id, "Missile "+(i+2) );
			mi.endItem.push( [id,SURPRISE] );
		}

		//
		return true;
	}

	static var init = initFonction();


	public static function get( id:Int ) : Mission {
		return LIST[id];
	}

//{
}












