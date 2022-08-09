import Grid;
/*
	FIX

	Le jeu met du temps à finir

	je peu plus jouer il y a 2 case en armageddon et plus de libre et je peu pas jouer.
*/


typedef Point = {
	x : Int,
	y : Int
}


enum Msg {
	Init( grid : T_Grid, moves:Array<Int>, omoves:Array<Int>, options:Array<Int>, oppOptions:Array<Int>, mode : Bool, zombieTurn : Int, zMoves : Array<{x:Int,y:Int,n:Int}> );
	ChooseCell( x : Int, y : Int, points : Int, z : Bool, option : Int );
	BedEvent( option : Int );
	MachineGunEvent( x : Int, y : Int, option : Int, z : Bool, onTarget : Int, offTarget : Int, touchedCells : Array<{x:Int,y:Int}> );
	ArmageddonEvent( x : Int, y : Int, option : Int, z : Bool );
	CatEvent( x : Int, y : Int, option : Int, z : Bool, killed : Int );
	GunEvent( x : Int, y : Int, option : Int, z : Bool );
	SportElecEvent( x : Int, y : Int, option : Int, z : Bool );
	ShieldEvent( x : Int, y : Int, option : Int, z : Bool );
	MegaShieldEvent( x : Int, y : Int, option : Int, z : Bool );
	WaterEvent();
	TrapEvent( x : Int, y : Int, option : Int, z : Bool );
	ZombieAttack( o : Int, info : String, playedCell : {x:Int,y:Int});
	NewTurn;
}

enum GameOption {
	Shield;			// protège la case choisie lors du prochain tour  (sauf Armageddon) // --> OK
	Gun;			// détruit une unité de l'adversaire sur une case				// --> OK
	MachineGun;		// Vide une case												// --> OK
	Armageddon;		// Supprime une case											// --> OK
	SportElec;		// Ajoute une unité sur une case								// --> OK
	Water;			// Permet de rejouer											// --> OK
	Bed;			// Permet de passer son tour									// --> OK
	Cat;			// Supprime 1 à trois citoyens									// --> OK
	MegaShield;		// Protège la case choisie ( opp + zombies ) jusqu'à la fin du jeu (sauf Armageddon) // --> OK
	Trap;
}

enum GameMode {
	Neutral;		// en cas de domination on se contente de récupérer les cases adjacentes plus faibles // --> OK

	Strengthen;		// en cas de domination on ajoute une unité à chaque unité alliée adjacente
	Hexile;			// en cas de domination on ajoute une unité à chaque unité alliée adjacente plus faible ET on en retranche une à chaque fois sur la case de base
	Weaken;			// en cas de domination on retranche une unité à chaque case alliée adjacente
	Restricted;		// seules les cases adjacentes à celles jouées peuvent être jouées
	Risk;			// un deuxième objectif est donné et permet d'amener à la victoire s'il est atteint
	Survivor;		// La partie est également finie si un joueur n'a plus d'unités présentes dans la partie
	NoHorde;		// Pas d'attaque de la Horde dans cette version
	FixedUnits;		// le nombre d'unités est fixé à l'avance.
	FixedTurns;		// Le nombre de tours est fixé à l'avance.
	Raw;			// Jeu sans options
	Gore;			// les citoyens meurent et ne sont pas regénérés
}

enum GFXMode {
	Low;			// On vire 30% des cases
	Medium;			// On vire 10% des cases
	High;			// Toutes les cases sont utilisées
}

enum VictoryMode {
	Units;			// Condition de victoire : Le plus d'unités possibles
	Land;			// Condition de victoire : Le plus de territoires possibles
}

class Const {


	public static var DEBUG = false;

	public static var UNIQ = 0;

	public static var BOARD_SIZE = 5;
	public static var MARGIN = 20;

	public static var MAX_BLOCKS = BOARD_SIZE * BOARD_SIZE - 1;

	// Modes de jeu
	public static var MODE_GAME		: GameMode		= Neutral;
	public static var MODE_GFX		: GFXMode		= Medium;
	public static var MODE_VICTORY	: VictoryMode	= Units;

	public static var GFX_HIGH = 5;
	public static var GFX_MEDIUM = 15;
	public static var GFX_LOW = 25;

	public static var MAX_OPTIONS = 4;
	public static var WIDTH = 300;
	public static var MAX_SIZE = 12;
	public static var MIN_SIZE = 6;
	public static var CELL_SIZE = 40;
	private static var auto_inc = 0;
	public static var DP_BG =		auto_inc++;
	public static var DP_H =		auto_inc++;
	public static var DP_HEX =		auto_inc++;
	public static var DP_FENCE =	auto_inc++;
	public static var DP_INTERF =	auto_inc++;
	public static var DP_SELECT = 	auto_inc++;
	public static var DP_INVISIBLE =auto_inc++;
	public static var DP_OPTIONS =  auto_inc++;
	public static var DP_TOP =  auto_inc++;
	public static var WITHPOINTS = true;
	public static var MAX_CAT_ATTACK = 3;
	public static var MORE_TURNS = 6;
	public static var MODE_DUEL = false;			// on peut jouer les options à la fin
	public static var HORDE_ATTACK = 5;				// Nombre de tour minimum avant l'attaque de la horde
	public static var HORDE_ATTACK_VARIATION = 3;	// nombre de tour = HORDE_ATTACK + Random(VARIATION)


	public static var HEXA_BORDER = 23.0;
	public static var HEXA_ANGLE_HEIGHT = 0.0; // Math.sin( 30 ) * HEXA_BORDER
	public static var HEXA_ANGLE_WIDTH	= 0.0; // Math.cos( 30 ) * HEXA_BORDER;
	public static var CENTER_Y = 0.0;
	public static var CENTER_X = 0.0;
	public static var DOCK_Y = 20;
	public static var MACHINE_GUN = 9;	// Nombre de balles
	public static var TRAP_DAMAGE = 2;

	public static var COLOR1 = 0x3171CE;
	public static var COLOR2 = 0xAEF40B;

	// Répartition des troupes aléatoire
	public static var CHANCES = [1,1,2,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,7,7];

	public static var DIRECTIONS_1 : Array<Point> = [{x:-1,y:0}, // gauche
													{x:1,y:0}, // droite

													{x:0,y:-1}, // haut gauche
													{x:1,y:-1}, // haut droite

													{x:0,y:1}, // bas gauche
													{x:1,y:1}]; // bas droite

	public static var DIRECTIONS_2 : Array<Point> = [{x:-1,y:0}, // gauche
													{x:1,y:0}, // droite

													{x:-1,y:-1}, // haut gauche
													{x:0,y:-1}, // haut droite

													{x:-1,y:1}, // bas gauche
													{x:0,y:1}]; // bas droite

	// Répartition des options aléatoire
	public static var OPTIONS = [Gun, Gun, Gun, MachineGun, MachineGun, Armageddon, SportElec, SportElec, SportElec, Water, Bed, Bed, Cat, Cat, Trap, Trap ];

	// Options non cumulables
	public static var SINGLE = [Armageddon, MegaShield ];
}

class Lang implements haxe.Public {

	static var TURN = " Tour ";
	static var YOUR_TURN = " A vous de jouer ! ";

	static var CUSTOM = [
		"Citoyens, prudence...",
		"Tour des Bannis",
		"Tour des citoyens",
		"Tour de votre adversaire...",
		"Les hordes arrivent !",
	];

	static var INFO_NAME = [
		"Portes",
		"Mode Territoires",
		"Mode Pouvoir",
		"Groupe en cours",
		"Zone Vierge",
		"Zone Ennemie",
		"Zone Terrifiante",
		"Portes"
	];

	static var INFO_DESC = [
		"Les portes doivent être fermées avant le nombre de tours indiqués, sinon...",
		"Vous devez conquérir le plus de zones possibles.",
		"Vous devez avoir le plus grand nombre d'unités en ville.",
		"Le premier chiffre indique la taille du groupe à poser à ce tour. Le second est votre coup suivant.",
		"Déposez votre groupe dans cette zone pour la conquérir.",
		"Cette zone appartient à votre ennemi.... Pour l'instant...",
		"Cette zone est détenue par des zombies.... Pour l'instant...",
		"Les portes sont fermées, les zombies ne peuvent plus entrer en ville."
	];

	static var ACTION_NAME = [
		"Barricades",
		"Pistolet rouillé",
		"Mitrailleuse",
		"Armageddon !",
		"Appel à l'aide",
		"Ration d'eau",
		"Petite pendaison",
		"Gros chat mignon",
		"Bouclier Rouge",
		"Piège vicieux"
	];

	static var ACTION_DESC = [
		"Empêche toute invasion de la zone jusqu'à votre prochain tour.",
		"Élimine 1 unité du groupe de citoyens ciblé.",
		"Crible de 9 balles le groupe ciblé. Attention aux balles perdues...",
		"Pulvérise la zone ciblée et endommage toutes les zones alentours.",
		"Rajoute une unité au groupe de citoyens ciblé.",
		"Permet de jouer 2 fois dans ce tour.",
		"Fait pendre votre groupe à poser actuel et en récupère un autre.",
		"Vraiment pas gentil, il peut massacrer entre 2 et 4 unités du groupe ciblé.",
		"Protège la zone contre l'adversaire et les zombies jusqu'à la fin de la partie.",
		"Piège la zone : si l'adversaire essaie de prendre la zone il perd tout son groupe."
	];


	static var TURN_INFO = [
		"Minuit et      minute",
		"Minuit et      minutes",
		"     23h et      minutes",
		"   Minuit !!"
	];

}
