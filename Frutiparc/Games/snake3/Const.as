class snake3.Const {

	public static var POS_X = 0;
	public static var POS_Y = 0;

	public static var WIDTH = 700;
	public static var HEIGHT = 480;

	public static var FRUIT_MAX = 300;
	public static var FRUIT_POURRIS_MAX = 22;
	public static var FRUIT_DEBLOK = 20;
	public static var FRUIT_NAME_LEARN = 10;

	// divers
	public static var FRUITS_FREQ = 375;
	public static var FRUIT_BASE = 60;
	public static var FBARRE_MAX = 150;
	public static var FBARRE_PERMANENT_LOOSE = 0.004;
	public static var FBARRE_EAT_FRUIT = 0.7;
	public static var FBARRE_FRUIT_TIMEOUT = -1;
	public static var BONUS_FREQ = 600;

	public static var PLAN_BACKGROUND = 0;
	public static var PLAN_FRUITSHADE = 1;
	public static var PLAN_BONUSES = 2; 
	public static var PLAN_FRUITS = 2;

	public static var PLAN_LANGUE = 3;
	public static var PLAN_SNAKE = 4;

	public static var PLAN_INTERFACE = 5;
	public static var PLAN_SLOTS = 5;
	public static var PLAN_DUMMIES = 6;


	public static var PROBABILITIES = [
		340,	// petit ciseau
		150,	// moyen ciseau
		40,		// grand ciseau
		50,		// langue
		100,	// coffre	
		4,		// potion rouge
		60,		// pillule
		10,		// bague
		15,		// potion bleu
		7,		// potion rose
		5,		// potion violette
		10,		// ressort
		50,		// rondelle psychique
		7,		// inverseur
		2,		// potion noire
		7,		// baguette magique
		200,	// molecule
		70,		// double molecule
		5,		// bombe
		6,		// potion verte
		4,		// plume
		2,		// cyclope
		20,		// fleche
		10,		// fleche rouge
		40,		// potion orange
		3,		// potion jaune
		400,	// dynamite
		3,		// poupee
		30,		// aureole
		10,		// croix
		12,		// sonnette
		3,		// cloche
		9,		// pentacle
		40,		// sabre
		15,		// coffre à options
		50,		// pieu
		5		// potion fuca
	];

	public static var COLOR_SNAKE_DEFAULT = 0x009900;
	public static var COLOR_SNAKE_BORDER_DEFAULT = 0x006C00;
	public static var COLOR_SNAKE_INVINCIBLE = 0x89A6B5;
	public static var COLOR_SNAKE_BORDER_INVINCIBLE = 0x61869A;
	public static var COLOR_GAMEOVER = 0xADE76B;
	public static var COLOR_FRUIT_OMBRE = 0x82D823;
	public static var COLOR_CISEAUX = 0xFF0000;

	public static var FLECHE_ROTATION_SPEED = 10;
	public static var FLECHE_ROUGE_GENSPEED = 45;
	public static var FLECHE_BLEUE_GENSPEED = 25;
	public static var CROIX_GENSPEED = 45;

	// temps en secondes
	public static var TIME_POTIONROUGE = 30;
	public static var TIME_STEROIDS = 12.5;
	public static var TIME_POTIONBLEUE = 25;
	public static var TIME_POTIONROSE = 30;
	public static var TIME_POTIONVIOLETTE = 37.5;
	public static var TIME_RONDELLE = 6.3;
	public static var TIME_POTIONVERTE = 80 + random(80);
	public static var TIME_POTIONORANGE = 30;
	public static var TIME_POTIONJAUNE = 30;
	public static var TIME_POTIONNOIRE = 30;
	public static var TIME_POTIONFUCA = 60;
	public static var TIME_PIEU = 30;
	public static var TIME_BOMBE = 5;

	static function fruit_points(id) {
		if( id <= 40 )
			return id * 5;
		else if( id <= 90 )
			return 200 + (id - 40) * 10;
		else if( id <= 150 )
			return 700 + (id - 90) * 20;
		else if( id <= 220 )
			return 1900 + (id - 150) * 30;
		else if( id <= 260 )
			return 4000 + (id - 220) * 50;
		else if( id <= 300 )
			return 6000 + (id - 260) * 100;
		else {
			// fruit pourri
			return - (id - 320) * 250;
		}
	}

	public static var DEFAULT_KEYS = [
		Key.LEFT, Key.RIGHT, Key.UP, // Player 1
		49, 50, 51, // Player 2 : 1,2,3
		75, 76, 77, // Player 3 : K,L,M
		103, 104, 105 // Player 4 : 7,8,9 NumPad
	];

	public static var SNAKE_DEFAULT_SPEED = 3.3;
	public static var SNAKE_DEFAULT_TURN = 0.125;
	public static var SNAKE_DEFAULT_LENGTH = 3;

	public static var CHALLENGE_SPEED_COEF = 3;
	public static var CHALLENGE_FRICTION = 0.97;

	// Battle
	public static var BATTLE_POWER_MAX = 60;
	public static var BATTLE_POWER_RECUP = 0.03;
	public static var BATTLE_FRICTION = 0.96;
	public static var BATTLE_ACCEL = 12;

	public static var BATTLE_COLORS = [ 0x009900, 0xDF2020, 0xE6D306, 0xFF9617 ];
	public static var BATTLE_BORDER_COLORS = [ 0x006C00, 0x841313, 0xA48006, 0xB45A01 ];

	// Textes
	public static var SCREEN_GAMEOVER = "gameOver";
	public static var SCREEN_CONNECTING = "connexion";
	public static var SCREEN_TEXT = "text";
	public static var SCREEN_RESULT = "resultat";
	public static var SCREEN_FRUIT = "fruit";


	public static var TXT_COLOR = ["vert ","rouge ","jaune ","orange "];
	public static var TXT_BATTLE_DRAW = "Egalité !";
	public static function TXT_BATTLE_WIN(winner) { return "Le serpent "+TXT_COLOR[winner]+"a gagné !"; }
	public static var TXT_ENCYCLO_ZEROFRUITS = "Aucun ";
	public static var TXT_ENCYCLO_VALUEUNK_SPECIAL = "Devine ";
	public static var TXT_ENCYCLO_VALUEUNK = "? ";
	public static var TXT_CONNECTING_MESSAGE = "Merci de patienter quelques instants.";
	public static var TXT_STARTING_GAME = "Démarrage du jeu...";
	public static var TXT_STARTING_GAME_MESSAGE = TXT_CONNECTING_MESSAGE;
	public static var TXT_ERROR = "ERREUR !";
	public static var TXT_SCORE_SAVING = "Sauvegarde en cours...";
	public static var TXT_SCORE_BATTLE = "Résultats du Match :";
	public static var TXT_SCORE_BATTU = "Bravo ! vous avez battu votre record !";
	public static function TXT_VOTRE_SCORE(s) { return "Votre score : "+s; }
	public static function TXT_VOTRE_RECORD(s) { return "Votre record personnel : "+s; }
	public static function TXT_VOTRE_PLACE(p) { return "Votre classement aujourd'hui : "+p; }
	public static function TXT_PLACE_GAGNEES(p) { return "Vous avez gagné "+((p == 1)?"une place":(p+" places"))+" dans le classement !" };
	public static function TXT_FRUIT_NAME(id) {
		if( id >= 320 )
			id -= 20;
		return FRUIT_NAMES[id-1]; 
	};
	public static function TXT_SCORE_WIN_FRUIT(id,n) {
		var txt = "Bravo ! Vous avez rammassé "+n+" fruits \""+TXT_FRUIT_NAME(id)+"\" !\n";
		txt += "Vous pouvez maintenant utiliser ce fruit sur le Forum !";
		return txt;
	};
	
	public static var TXT_FRUIT_NAME_UNKNOWN = " Inconnu ";
	public static var TXT_FRUIT_NAME_EN_COURS = "Analyse en cours...";

	// Sons
	public static var CHANNEL_MUSIC_1 = 1;
	public static var CHANNEL_MUSIC_2 = 2;
	public static var MUSIC_FADE_LENGTH = 1.5; // seconds
	public static var CHANNEL_SOUNDS = 0;
	public static var SOUND_MENU_LOOP = "sound_menu_loop";
	public static var SOUND_GAME_LOOP = "sound_game_loop";
	public static var SOUND_GAME_OVER = "sound_game_over";
	public static var SOUND_FRUIT_APPEAR = "sound_fapp";
	public static var SOUND_FRUIT_EAT_1 = "sound_glurps";
	public static var SOUND_FRUIT_EAT_2 = "sound_glurps_2";
	public static var SOUND_CISEAUX = "sound_ciseaux"
	public static var SOUND_COFFRE = "sound_coffre"
	public static var SOUND_EFFECT_END = "sound_effect_end"
	public static var SOUND_LANGUE = "sound_langue"
	public static var SOUND_OPTION_EAT = "sound_option"
	public static var SOUND_CLOCHE = "sound_cloche"
	public static var SOUND_DYNAMITE = "sound_dynamite"
	public static var SOUND_RESSORT = "sound_ressort"
	public static var SOUND_SABRE = "sound_sabre"
	public static var SOUND_POTION = "sound_potion"
	public static var SOUND_DISAPPEAR = "sound_fdisp"
	public static var SOUND_SONNETTE = "sound_sonnette"
	public static var SOUND_EXPLOSE = "sound_explose"

	public static var SOUND_PAGE = "sound_page";
	public static var SOUND_RETURN_MENU = "sound_retmenu";
	public static var SOUND_ROTATION_MENU = "sound_rotmenu";
	public static var SOUND_SELECT_MENU = "sound_selmenu";

	// NOMS DE FRUITS
	public static var FRUIT_NAMES = [
		" pokiros ",
		"pomme chauve",
		"quartier de pomme",
		" prunette ",
		" gland ",
		" goozblou ",
		"noix de Gondomar",
		" mornille ",
		" grorange ",
		"piwi rose",
		"carotte douce",
		" mousselin ",
		" harikou ",
		"amande fraîche",
		"baie d'Ouen",
		"pain-pêche",
		"prune marine",
		" saccarolme ",
		" citron ",
		" dates ",
		" fouillot ",
		"oignon du Sahel",
		"olivion confit",
		"baie d'Aran",
		"raisin glinglin",
		" peurangue ",
		"cerise burlat",
		"baie du Bourg",
		"fouillot mure",
		" girondine ",
		" anemordorée ",
		" nouaztek ",
		"paire de girondines",
		"abricot velu",
		"fève de Barcelos",
		"outres birmanes",
		" Frougère ",
		"kiwi bob's leg",
		" zilmeon ",
		" ivreprune ",
		" pastavia ",
		"figue de l'abbe Santos",
		"poire sableuse",
		" poustil ",
		" crocgnoles ",
		" sarderose ",
		" gramade ",
		" noix ",
		" grozine ",
		" mangarine ",
		"fraise feroce d'outre-sang",
		"bouton de pecanette",
		" dolmitos ",
		"pompine d'Almansa",
		"piastre aigre",
		"jacquelin bossu",
		"pêche papuleuse",
		" florkebella ",
		"coeur de Salamahari",
		"coque d'obeissance",
		"ficus iberia",
		"fruit d'Ostrac",
		"fruit de Lupox",
		"pelote ougandaise",
		"fouillot séché",
		"prune triomphante",
		" bogueraide ",
		" moltereaux ",
		"balauste latine",
		"baie d'Inah",
		" gornales ",
		"noisette de Chaperet",
		" mossetoise ",
		"merangue crispée",
		" cookie ",
		"pomme d'Arnequin",
		"perce-gazette",
		"navet lacté",
		" malegousse ",
		"grasse-langue de Salignac",
		" obustang ",
		"paire de bolchevine",
		"baie d'Estipule",
		" poiranque ",
		"tranche de goujaunaine",
		" ondines ",
		" palmeran ",
		" rongemirage ",
		"niches d'Armangaux",
		" ficelode ",
		"hisse-fièvre",
		"festin du mendigot",
		" pugne ",
		" pruneau ",
		"pastisson amère d'Oberwart",
		"cosse foraine",
		"corne d'abondance",
		"bourraine vermeille",
		"bile-du-diable",
		" cipoline ",
		" rosat ",
		"pivoc d'Aleöne ",
		" tourmerande ",
		"poire Packham",
		"succul de Korma",
		" Danoude ",
		"cerise guillaume",
		"noix du Sichuan",
		"courte-baies malsone",
		"noeud-de-brume",
		" rogneron ",
		" indigoyave ",
		" clocheboise ",
		" turmelin ",
		"saramise ecailleuse",
		"fraise-papillon",
		" mangueponce ",
		"mi-cannebille",
		" florion ",
		"tomates cireuses du Mexique",
		"pêche Nelly",
		" gorgamone ",
		" cantebrise ",
		" polyFrameole ",
		"lustre d'Hyperion",
		" chavenagre ",
		" elibaba ",
		"palet-sucre de Catamarca",
		"parmepugne frisée",
		"citron velu d'escampette",
		" marapourpre ",
		" cariano ",
		"gousse de camerile",
		" bolognos ",
		" guignefauve ",
		"musette du pèlerin",
		" lichelen ",
		" polkine ",
		"opalin des Malouines",
		" ganesouge ",
		"régal de mirmelin",
		"poivre-chaud de Bilbao",
		" toxecarne ",
		" pierrot ",
		" chicoutai ",
		" coulemelle ",
		" solivatre ",
		"parangon d'Ispahan",
		" pranterase ",
		"mangue de Tulem",
		" ecumides ",
		" flasme ",
		" poquecharde ",
		"chaussette-du-pape",
		"prune imperiale",
		" saperin ",
		"corne de boulingre",
		"noix de coco",
		" rostegibse ",
		" geminicama ",
		" saramiche ",
		"pigne-reine",
		"germe de cariano",
		" fraiseraunes ",
		" fauchelouge ",
		"coloquinte ocre de Barbezieux",
		" alnetrine ",
		"larme du coquebin",
		"grenat splendide de Manaus",
		"maille d'Oursan",
		" furnegrise ",
		"alberge bergaline",
		" mandrelouste ",
		"polne bourrelée",
		" aigrette ",
		"poire Bosc",
		"fruit-du-guède",
		" achegrèse ",
		" morphéanulme ",
		" veloutard ",
		"dazongre molle de San Fernando",
		" annelet ",
		"prunes totemiques d'Abigaël",
		" kibis ",
		"nacre de Carbet",
		" hypoponacre ",
		"prune hyaline de Borza",
		"aumonière hirsute de Kaesong",
		"rutabaga bicephale",
		" goulveraide ",
		"fane amere du Rousillon",
		"birmes tondues",
		"paneton aubé",
		" pouillemine ",
		"calebasse du wigam",
		"polisson scléreux de masse-pierre",
		"citron royal",
		" pisquedine ",
		"beuglante de Tachkent",
		"baies rousses titanesque ",
		"cyclatrice tourmentée",
		" pansedisette ",
		" fristelin ",
		"pauline d'aigue-sylvaine",
		"violine d'Istanbul",
		"pescorelle gauloise",
		"corympe géante de Hapevoie",
		"prune-givre",
		" jaboticaba ",
		"agulme d'Holmavik",
		" bilimbi ",
		"brochette de mochi",
		" niguelion ",
		"piffre d'Aude",
		"charme-janthe",
		"yubi constellé",
		"bulbe rosé de Gundagai",
		" sorghine ",
		" coquemyre ",
		"orbière méditerranéenne",
		" pangrelot ",
		"mangue piquée de saoul-rosse",
		"camelot de Louhans",
		"triticale princière",
		" pistelins ",
		" moguerouge ",
		"purnerine d'Apollon",
		"arbouse géante de Gobi",
		" hyspenasse ",
		"igname roux",
		"courge funky",
		"ecrin d'Estoroth",
		"gelée de cythere",
		" pléthorane ",
		"coiffe-matassin",
		" dangarne ",
		" pibom ",
		" ambroisine ",
		" argeraine ",
		" noubab ",
		" saccharide ",
		"fuse d'Op",
		" nocemorte ",
		"poursenaille fleurie de Bangkok",
		" perlerrante ",
		"cosserelle naine d'Amandou",
		" ravefane ",
		" pulsenoire ",
		" machepime ",
		"courge poncte de Chicoutimi",
		"salamaude houppée",
		"suiffe-grappe",
		"pognegrove de Selfoss",
		"gorzine cassenadaise",
		" folmerone ",
		"noix-bigre",
		"alouate safrinée",
		"gros tas de mirabelles",
		"brochette de moquenard",
		"perle blanche",
		"bocassin d'espenil",
		"sangre-ploie estoupé",
		"aigledrupe géant",
		"coscard mièvre des graves",
		"pouc-marine",
		"pêche-neige",
		"tolmine supre d'Astirmin",
		"plume-grasse colossale",
		" smarterine ",
		"gossenaille cyclopéenne d'Oblivion",
		" monstropoire ",
		" acolichte ",
		"cornacre lancelin ",
		" pachycourge ",
		"esthioche singulière de Mont-Perron",
		" oignefarge ",
		"carambolisse d'Ouperang",
		"dangarne monumentale",
		"kumquat ocre du Berhampur",
		"anne-jumeleine",
		"lorneline chanoine",
		"perle dorée",
		"colche-ventrue d'Eluos",
		"trovinelles des marais",
		"polfregueuse de Casse-NaN",
		" valseglante ",
		"bideplune de Deorbalde",
		"maltre-chat de bubenys",
		"herculime dyaphane de Boguebrud",
		"balzane galbée",
		"pomme granite de Pitronde",
		"caltesime de piong-ni",
		"potironne joustre de biche-râle",
		"noix de Goliath",
		"hotte-de-Brande",
		"pilme-en-pot",
		"golfane d'Iscanie",
		"bille-changre des rebouteux",
		"pocsin de mascarade",
		"cornette mauve de Malaisie",

		// POURRIS
		"pichte-aigre",
		" prunesangue ",
		"olcre délétère",
		"mouchtre fétide",
		"noeud-de-bile",
		"flestrane de Gaubert",
		"plaie de loutre",
		"histre-taille",
		" morsebrive ",
		" flambergine ",
		" limanide ",
		"supplice du ka",
		"navechulne des mâne-folles",
		"mirges toxiques de Cuzco",
		"ulsceme de Sapporo",
		"grigue lépreuse ",
		"poire-eventail",
		" calveret ",
		"acre-gose de Galacao",
		"crese nauseabonde de Sult",
		"lacherone d'obbrefus",
		"l'infâme pamplefrousse"
	];

	

}
