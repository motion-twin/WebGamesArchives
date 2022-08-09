import Protocole;
import mt.data.Ods;
#if flash
import mt.bumdum9.Lib;
#end

typedef DataOds = { _games:Array<GameData>, _monsters:Array<MonsterData> };

class Data implements haxe.Public {//}
	
	static var CODEC_VERSION = "1" ;
	
	
	static var DATA : DataOds = haxe.Unserializer.run(mt.data.CachedData.decode( ODS.getDatas() ));
	//static var GAMES:Array<GameData>;
	//static var MONSTERS:Array<MonsterData>;
	
	
	
	static  var DAILY_TOKEN = 3 ;
	static  var DAILY_RAINBOW = 2 ;
	static var START_TOKENS = 9 ;
	static  var AVAILABLE_WORLD = 2 ;
	
	static var BANK_COST = [50, 300] ;
	static var BANK_ICECUBE = [12, 90] ;
	
	static var BANK_PROMO = [0, 10] ;

	
	// ECONOMY
	static var VALUE_ICECUBE = 5;
	static var VALUE_ICECUBE_BIG = 20;
	
	// GAMEPLAY
	//static var WORLD_SIZE = 100;
	static var START_HEARTS = 2;
	static var EXTRA_HEARTS = 10;
	static var ITEMS_POS = [
			0.381,			// Cocktail;
			0.33,			// Book;
			0.002,			// Shoes;
			0.6,			// Mirror;
			0.51,			// Clover;
			0.57,			// Voodoo_Doll;
			0.433,			// Voodoo_Mask;

			0.515,			// Wand;
			0.31,			// Google;
			0.01,			// Radar;
			0.008,			// Prisme;
			0.08,			// FeverX;
			0.016,			// Umbrella;
			0.25,			// Dice;
			
			0.83,			// Windmill;
			0.004,			// IceCream;
			0.39,			// Hourglass;
			0.17,			// ChromaX;
			0.75,			// MagicRing;
			0.131,			// Fork;
			0.287,			// RainbowString;
			
	];
	
	static var CARTRIDGE_MAX = 100;
	static var STATUE_MAX = 16;
	static var RUNE_MAX = 7;
	

	
	public static function init() {
		
		/*
		
		//trace("initData");
		// R = rule
		// A = action ( -> XML )
		// N = node ( pour une sortie XML )
		// Opt = action optionelle
		// All = toutes les colonnes suivantes
		
		var skip = { name : null, cols : [All(R(RSkip))] };
		var eof = { name : null, cols : [R(RSkip),R(RValues(["EOF"]))] };
		var game = {
			name : "_games",
			cols : [
				R(RSkip),
				A("_id", RInt),
				A("_name", RText),
				A("_acc", RInt),
				A("_weight", RInt),
				A("_type",RValues(["","RE","SUR","OBS"],true)),
				A("_desc", RText),
				//A("_freq", RValues(["C", "U", "R"], true) ),
				//Opt(A("_multi", RValues(["x", "o"], true) )),
				//A("_type", RValues(["passif", "actif", "auto"], true) ),
				//Opt(A("_time", RInt ) ),
				//R(RBlank),
				//A("_name", RText),
				//N("_desc", RText),
				//R(RBlank),
				//R(RSkip),
				All(R(RSkip)),
			 ]
		};
		var monster = {
			name : "_monsters",
			cols : [
				R(RSkip),
				A("_id", RInt),
				A("_name", RText),
				R(RSkip),
				A("_life", RInt),
				A("_atk", RInt),
				A("_tempStart", RInt),
				A("_tempInc", RInt),
				A("_tempMax", RInt),
				R(RSkip),
				A("_rangeFrom", RInt),
				A("_rangeTo", RInt),
				A("_weight", RInt),
				R(RSkip),
				A("_anim", RText),
				A("_oy", RInt ),
				A("_gameFam", RText),
				A("_gameSpecial", RText),
				All(R(RSkip)),
			 ]
		}
		
		
		var docGame = DList([
		   DLine(skip),
		   DLine(skip),
		   DMany(DLine(game)),
		   DLine(eof),
		   DMany(DLine(skip)),
		 ]);
		
		var docMonster = DList([
		   DLine(skip),
		   DLine(skip),
		   DMany(DLine(monster)),
		   DLine(eof),
		   DMany(DLine(skip)),
		 ]);
		
		#if flash
		var data = new haxe.io.BytesInput( haxe.Resource.getBytes("data.ods") );
		#elseif neko
		var data = new haxe.io.BytesInput(neko.io.File.getBytes(neko.Web.getCwd() + "../clients/com/Data.ods")) ;
		#end
		
		var ods = new OdsChecker();
		ods.loadODS(data);
		GAMES = 		ods.check("games", docGame).o._games;
		MONSTERS = 		ods.check("monsters", docMonster).o._monsters;
		
		*/
		
	}
			
	public static function stats() {
		var cat  = [0, 0, 0, 0];
		for( g in DATA._games ) {
			cat[g._acc]++;
		}
		trace(cat);
	}
	

	
	
//{
}












