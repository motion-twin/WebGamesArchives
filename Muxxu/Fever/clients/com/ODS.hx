#if macro
import mt.data.Ods;
#end

class ODS {
	#if macro
	static function parseDatas( f : haxe.io.Input ) {

		
		/*
		var skip = { name : null, cols : [All(R(RSkip))] };
		var eof = { name : null, cols : [R(RValues(["EOF"]))] };
		
		// CARD
		var card = {
			name : "_cards",
			cols : [
				R(RSkip),
				A("_enum", RText),
				A("_mojo", RInt),
				A("_freq", RValues(["C", "U", "R"], true) ),
				Opt(A("_multi", RValues(["x", "o"], true) )),
				A("_type", RValues(["passif", "actif", "auto"], true) ),
				Opt(A("_time", RInt ) ),
				R(RBlank),
				All(R(RSkip)),
			 ]
		};
		var doc_cards = DList([
		   DLine(skip),
		   DLine(skip),
		   DMany(DLine(card)),
		   DLine(eof),
		   DMany(DLine(skip)),
		 ]);
		 */
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
		
		/*
		#if flash
		var data = new haxe.io.BytesInput( haxe.Resource.getBytes("data.ods") );
		#elseif neko
		var data = new haxe.io.BytesInput(neko.io.File.getBytes(neko.Web.getCwd() + "../clients/com/Data.ods")) ;
		#end
		*/
		
		/*
		var ods = new OdsChecker();
		ods.loadODS(data);
		GAMES = 		ods.check("games", docGame).o._games;
		MONSTERS = 		ods.check("monsters", docMonster).o._monsters;
		*/
		
		var ods = new OdsChecker();
		ods.loadODS(f);
		//return ods.check("cartes", docGame).o;
		
		return {
			_games : ods.check("games", docGame).o._games,
			_monsters : ods.check("monsters", docMonster).o._monsters,
		}
		
	}
	

	#end
	
	
	
	@:macro public static function getDatas() {
		return mt.data.CachedData.get("data.ods", parseDatas, true);
	}
	

}