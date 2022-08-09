import Protocole;


#if flash
typedef Text = { _id:Int, _name:String } ;
#end


typedef TextOds = { _cards:Array<{_name:String,_desc:String}>, _fruits:Array<{_name:String}> } ;

class DText implements haxe.Public {

	#if neko
	static function getCacheFile(file) {
		return Config.TPL + file;
	}
	#end

	#if fr
	static var TEXT = mt.data.Mods.parseODS( "text.ods", "fr", DataText );
	#elseif en
	static var TEXT = mt.data.Mods.parseODS( "text.ods", "en", DataText );
	#elseif de
	static var TEXT = mt.data.Mods.parseODS( "text.ods", "de", DataText );
	#elseif es
	static var TEXT = mt.data.Mods.parseODS( "text.ods", "es", DataText );
	#end
}


class Data implements haxe.Public
{//}
	static var CODEC_VERSION = "0" ;

	#if neko
	static function getCacheFile(file) {
		return Config.TPL + "../fr/" +  file;
	}
	#end

	
	static var CARDS = mt.data.Mods.parseODS( "data.ods", "cartes", DataCard );
	static var TEXT = DText.TEXT ;
	
	//static var CARD_MAX = 130 ;
	
	static var BUY_POSITIVE_ONLY_CAP = 10 ;
	static var CARD_COST = 50 ;
	static var BOOSTER_COST = 460 ;
	static var TICKET_COST = 10 ;
	static var CNX_RETRY_TIME = 30000 ; // old : 8000
	static var CNX_RETRY_MAX = 20 ; //old : 4
	
	static var MS_PER_FRAME = 25;

	
	// DRAFT
	static var DRAFT_COST = 500 ;
	static var DRAFT_PLAYER_MAX = 6 ;	// nombre de joueur minimum et maximum par tournoi
	static var DRAFT_TIME_OPEN = 18 ;	// heure d'ouverture du tournoi
	static var DRAFT_TIME_CLOSE = 20 ;	// heure de fermeture du tournoi
	static var DRAFT_TIME_PICK = 8000 ;	// temps de sélection en millisecondes ( pour chaque carte dans le pack )
	static var DRAFT_PRIZES = [200, 100, 50] ;


	public static function getDraftOpen() {
		#if neko
		if (App.user != null && App.user.id == 4)
			return 8 ;
		#end
		return DRAFT_TIME_OPEN ;
	}


	public static function getDraftClose() {
		#if neko
		if (App.user != null && App.user.id == 4)
			return DRAFT_TIME_CLOSE ;
		#end
		return DRAFT_TIME_CLOSE ;
	}
	
	public static function getTodayDraftTimes() : {open : Date, close : Date} {
		var today = Date.now() ;
		var d = today.getDate() ;
		var m = today.getMonth() ;
		var y = today.getFullYear() ;
		return {	open : new Date(y, m, d, getDraftOpen(), 0, 0),
				close : new Date(y, m, d, getDraftClose(), 0, 0)} ;
	}
	
	public static function getDraftPickTime(cards) {
		return DRAFT_TIME_PICK * cards;
	}
	static var MOJO_PLAY = 6 ;
	static var START_CARDS =  [TRAINING, MAGNET, CRYSTAL_BALL, WINDMILL_SMALL, POTION_BLUE, SCISSOR, HOURGLASS, SALT] ;
	 static var QUEST_CARDS =  [FEATHER, TONGUE, TRONCONNEUSE, LOUD_SPEAKER, RAINBOW, KAZOO] ;
	// static var CARD_COOLDOWN = 23 * 60 * 60 * 1000 ; //23h
	
	
	
	// BAZAR - MEPHISTOUF
	static var BAZAR_AVERAGE_PRICES = 	[5, 15, 30];
	static var BAZAR_RAISE_DELAY = 		/*[30, 15, 5]*/ [5, 3, 1] ;
	static var BAZAR_STARTING_MOODS = [0, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 6, 7] ;
	static var BAZAR_STARTING_DEALS = [1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 5] ;
	static var BAZAR_MIN_CARD = 20 ;
	
	
	static function getDeal(ct:_CardType,averagePrice:Int) {
		
		var freq = Data.CARDS[Type.enumIndex(ct)].freq;
		var inc = switch(freq) {
			case "C" : 1;
			case "U" : 3;
			case "R" : 5;
		}
		
		var price = averagePrice + Std.random(inc) * (Std.random(2) * 2 - 1);
		var bonus = 0;
		if( Std.random(2)==0 ) bonus = Std.random(inc*2);
		price -= bonus;
		
		var a:Array<Null<Int>> = [];
		while( bonus>0 && a.length < 10 ) {
			if( Std.random(2) == 0 ) {
				var inc = Std.random(bonus) + 1;
				bonus -= inc;
				a.push(inc);
			}
			a.push(null);
		}
		return  {price : price, deal : a} ;
	}
	
	static function getCardMax() {
		var a = Type.getEnumConstructs(_CardType);
		return a.length;
	}
	
	
//{
}












