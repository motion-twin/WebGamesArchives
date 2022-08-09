

class Cs {//}

	public static var FIRST_TRADER = false;

	public static var mcw = 300;
	public static var mch = 300;
	public static var bh = 30;


	public static var XMAX = 40;
	public static var YMAX = 40;
	public static var RM = 3;
	public static var RX = 3;
	public static var RY = 3;
	public static var WALL = 1;

	public static var CS = 24;

	public static var SPEED = 0.2;
	//public static var HUNT_MAX = 10;

	public static var SCORE_MONSTER = 	KKApi.const(250);
	public static var SCORE_WALK = 		KKApi.const(1);
	public static var SCORE_GOLD = 		KKApi.const(20);
	public static var SCORE_FOOD = 		KKApi.const(5);

	public static var SCORE_GEM = 		KKApi.aconst([1000,3000,8000]);

	public static var DIR = [[1,0],[0,1],[-1,0],[0,-1]];
	public static var COLOR_GEM = [0x55FF00,0x6666FF,0xFF0088];
	public static var COL_BG = 0x273247;




	//public static var  PROBA_ITEMS_SUM = 0;
	public static var  PROBA_ITEMS = [
		0,	//0
		100,	//1 GOLD 1
		400,	//2 GOLD 2
		200,	//3 GOLD 3
		25,	//4 GOLD 4
		10,	//5 LEATHER ARMOR
		0,	//6 IRON ARMOR
		30,	//7 KNIFE
		1,	//8 KATANA
		200,	//9 APPLE
		250,	//10 FOOD
		170,	//11 SHURIKEN
		30,	//12 GROS SHURIKEN
		0,	//13 BACK PACK
		100,	//14 POTION NORMAL
		30,	//15 SUPER POTION
		20,	//16 GRAPIN
		30,	//17 TALISMAN UNDEAD
		5,	//18 RED AMULET
		5,	//19 GREEN AMULET
		5,	//20 BLUE AMULET

		250,	//21 BLUE CRYSTAL
		100,	//22 GREEN CRYSTAL
		10,	//23 RED CRYSTAL

		5,	//24 PATTE PORTE BONHEUR
		30,	//25 SCROLL FIRE
		30,	//26 SCROLL ICE
		3,	//27 BOMB
		70,	//28 OREILLER;
		30,	//29 SCROLL TELEPORT;
		30,	//30 SCROLL CHAOS;
		10,	//31 CAPUCHE OURS;
		40,	//32 OS;
		2,	//33 BRACELET QUI PIQUE
		5,	//34 BRIQUET


	];

	public static function probaLevelUp(){
		PROBA_ITEMS[23] += 2; 	// RED CRYSTAL
		PROBA_ITEMS[8] += 1; 	// KATANA
		PROBA_ITEMS[1] -= 10; 	// GOLD1
		PROBA_ITEMS[4] += 5; 	// GOLD4


		//if(PROBA_ITEMS[1]<0 )PROBA_ITEMS[1] = 0;

	}

	public static function init(){
		XMAX = WALL*2 + RX*(1+RM*2) ;
		YMAX = WALL*2 + RY*(1+RM*2) ;




	}

	public static function getRandomItem(){

		var sum = 0;
		for( n in PROBA_ITEMS)sum+=n;

		var rnd = Std.random(sum);
		var sum = 0;
		var id = 0;
		for( n in PROBA_ITEMS ){
			sum += n;

			if( sum > rnd )return id;
			id++;

		}
		trace("ERROR randomItem");
		return null;
	}

	public static function isUnique(id){
		return id == 28 || id==13 || id==33 || id==34;
	}

//{
}







