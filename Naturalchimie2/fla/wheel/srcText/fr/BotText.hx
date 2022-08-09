import ZoneData._DialogInfos ;

class BotText {
	
	static function getRewardName(r : String) {
		return switch(r) {
				case "pyram1" : "un pyram" ;
				case "pyram3" : "trois pyrams" ;
				case "pyram5" : " cinq pyrams" ;
				case "pslot" : "un pyram (vous avez déjà votre poche)" ;
				case "slot" : "un quart de poche, qui complète votre poche de ceinture" ;
				case "slot1", "slot2", "slot3" : "un quart de poche" ;
				case "pa" : "un lot de potions de vigueur" ;
				case "recipe" : "une recette alchimique" ;
				case "elt_earth" : "un élément rare de la terre" ; 
				case "elt_water" : "un élément rare de l'eau" ;
				case "elt_fire" : "un élément rare du feu" ; 
				case "elt_wind" : "un élément rare du vent" ; 
				default : return null ;
			}
	}
	
	
	static var TEXTS = ["Félicitation !  Vous gagnez {::REWARD:: !} ",
					"Terminer la discussion",
					"Et en bonus, je vous offre cette magnifique [casquette promo]. %func% | Evitez les coups de soleil pendant vos alchimies grâce à Chouettex !",
					"Je vois que vous portez fièrement votre [casquette promo]. Vous êtes vraiment magnifique, comme ça.",
					"Chouette casquette, en tout cas.",
					"J'adore votre couvre-chef, soit dit en passant.",
					] ;
	
	
	
	public static function getRewardDialog(result : Array<String>) : _DialogInfos {
		var res = {_id : "wreward",
				_gfx : null,
				_redir : {_url : "/gf/wheel", _auto : false},
				_texts : new Array(),
				_answers : new List(),
				_error : null
			} ;
		
			
			res._texts.push({_text : StringTools.replace(TEXTS[0], "::REWARD::", getRewardName(result[1])), _off : false, _frame : "happy", _fast : 1}) ;
			res._texts.push({_text : if (result[0] == "1") TEXTS[2] else TEXTS[3 + Std.random(3)] , _off : false, _frame : "normal", _fast : 1}) ;
			
			res._answers.push({_text : TEXTS[1], _id : "end", _target : res._redir._url, _off : true}) ;
			
		
			return res ;
		
	}


	
	
	
}