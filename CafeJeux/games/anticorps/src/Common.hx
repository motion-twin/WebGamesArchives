import mt.bumdum.Lib;

enum Msg {
	Init(type:Int,seed:Int);
	Place(type:Int,x:Int,y:Int);
	PlayNext(?flAgain:Bool);
	PlayStack(a:Array<Int>);
	PlayJump(da:Float,power:Float);
	PlayShot(type:Int,mid:Int,?a:Float,?power:Float);
	ExplodeMine(a:Array<Int>);
	ShowWeapon(type:Int,?flSecret:Bool);
	HideWeapon();
	TakeCover();
}

enum CosmoState {
	Fly;
	Ground;
	Freeze;
	Levit;
}

enum CosmoType {
	CosmoDev;
	CosmoSoldat;
	CosmoScout;
	CosmoTank;
	CosmoMedic;
	CosmoNinja;
	CosmoMage;
}

enum Mod {
	Menu;
	PlaceCosmo;
	PlayStart;
	Watch;
	ExplodeMine;
	Move;
	Pass;
	Bazooka;
	Obus;
	Grenade;
	Mine;
	Gun;
	AirStrike;
	Sword;
	MedicMissile;
	Gaz;
	Medecine;
	Ram;
	Shotgun;
	Cover;
}



typedef Point = {
	x:Int,
	y:Int,
	gid:Int
}




class Cs {//}

	//6;
	public static var COSMO_MAX = 1;
	public static var COSMO_TEAM_MAX = 3; //3
	public static var MINE_RAY = 20;
	public static var MINE_EXPLODE_RAY = 50;
	public static var MINIMAP_SCALES = [0.15,0.024];

	public static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];
	public static var UNIT = 1;

	static public var mcw = 300;
	static public var mch = 300;

	public static var DEFAUT_MAP_ID = 0;
	static public var MAP_INFOS = [
		{ width:800,     height:685, type:0, startPos:[[300,280],[495,185]] },
		{ width:1000,    height:600, type:0, startPos:[[200,266],[800,260]] },
		{ width:800,     height:600, type:1, startPos:[[178,308],[632,256]] },
		{ width:800,     height:600, type:0, startPos:[[238,314],[546,320]] },
		{ width:600,     height:600, type:1, startPos:[[130,330],[458,334]] },
		{ width:920,     height:886, type:0, startPos:[[230,537],[700,515]] },
		{ width:600,     height:600, type:1, startPos:[[68,144],[464,434]] }
	];
	public static var ACTIONS = [

		[	// SOLDAT
			Move,
			Shotgun,
			Bazooka,
			Grenade,
			Pass
		],

		[	// SCOUT
			Move,
			Gun,
			Mine,
			Pass
		],
		[	// TANK
			Move,
			Bazooka,
			Ram,
			Obus,
			Sword,

			Pass
		],
		[	// MEDIC
			Move,
			Gun,
			MedicMissile,
			Gaz,
			Medecine,
			Pass
		],
		[	// NINJA
			Move,
			Pass
		],
		[	// MAGE
			Move,
			Pass
		]
	];

	static public function getDir(di){
		if(di==null){
			trace("getDir error!");
			return null;
		}
		return Std.int(Num.sMod(di,4));
	}
	static public function getDi(x,y){
		for(i in 0...4 ){
			var d = DIR[i];
			if( x==d[0] && y==d[1] )return i;
		}
		return null;
	}

	static public function getModId(m){
		switch(m){
			case Move:		return 0;
			case Pass: 		return 1;
			case Bazooka :		return 2;
			case Mine :		return 3;
			case Gun :		return 4;
			case Grenade :		return 5;
			case Obus :		return 6;
			case AirStrike :	return 7;
			case Sword :		return 8;
			case MedicMissile:	return 9;
			case Gaz:		return 10;
			case Medecine:		return 11;
			case Ram:		return 12;
			case Shotgun:		return 13;
			case Cover :		return 14;
			default:		return null;
		}


	}

	static public function getAmmo(m){
		switch(m){
			// case Bazooka :	return 5;
			case Mine :		return 2;
			case Grenade :		return 2;
			case Obus :		return 1;
			case AirStrike :	return 1;
			case MedicMissile:	return 2;
			case Gaz:		return 1;
			case Ram:		return 1;
			case Shotgun:		return 2;
			default:		return null;
		}
	}

	static public function getCosmoTypeId(ct){
		switch(ct){
			case CosmoSoldat:	return 0;
			case CosmoScout:	return 1;
			case CosmoTank:		return 2;
			case CosmoMedic:	return 3;
			case CosmoNinja:	return 4;
			case CosmoMage:		return 5;
			case CosmoDev:		return 6;
			default:		return null;
		}
	}
	static public function getCosmoType(id){
		switch(id){
			case 0: return CosmoSoldat;
			case 1: return CosmoScout;
			case 2: return CosmoTank;
			case 3: return CosmoMedic;
			case 4: return CosmoNinja;
			case 5: return CosmoMage;
			case 6: return CosmoDev;
			default: return null;
		}
	}


	// SELECTIONNER TOUS LES PERSONNAGES SUR DU ROLLOVER DE CARTES ROUGES


//{
}


class Lang implements haxe.Public {//}

	static var ACTION_NAME = [
		"Mouvement",
		"Passer son tour",
		"Capsule antibiotique",
		"Mine",
		"Pistolet",
		"Grenade epidermique",
		"Canon explosif",
		"Frappe aerienne",
		"Epée",
		"Missile medical",
		"Bombe-à-gaz",
		"Piqure",
		"Belier",
		"Fusil a impulsion cutanée",
		"Couverture"
	];

	static var ACTION_DESC = [
		"Pour déplacer ou faire sauter votre cosmo.",
		"Passe au cosmo suivant, si vous ne voulez plus agir pour ce tour",
		"Tir un obus soumis au condition du vent. Dégats moyen.",
		"Pose une mine invisible pour votre adversaire.",
		"Dégats faibles, mais il est possible de se repositionner apres chaque tir.",
		"Dégats élevés dans une large zone, mais elle n'est pas précise",
		"Un seul obus pour cette arme terrifiante. Ne le gachez pas !!",
		"Touche un cosmo a decouvert au début de votre prochain tour.",
		"Inflige de gros dégats aux cosmos face a vous.",
		"A son impact, tous les cosmos voisins sont soignés.",
		"Elle libère un gaz nocif qui empoisonne les cosmos dans un grand rayon d'action.",
		"La piqure soigne un cosmo face à vous.",
		"Le cosmo se jette an avant, détruisant tout sur son passage.",
		"Rapide et precis, ses degats sont faibles.",
		"Votre cosmo tirera sur tout ce qui est a sa portée."
	];
//{
}









