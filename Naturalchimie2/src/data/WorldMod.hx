package data ;

import GameData._ArtefactId ;
import GameData._Artefact ;
import GameData.QuestPlayMod ;
import data.Quest ;



typedef WorldMod = {
	var id : String ;
	var name : String ;
	var hasDayRand : Bool ;
	var mods : Array<{align : String, zMid : String, mod : QuestPlayMod}> ;
}



class WorldModXML {
	public static function parse() {
		var h = new Hash() ;
		var file = "worldMod.xml" ;
		for( e in Data.xml(file).elements() ) {
			parseWM(new haxe.xml.Fast(e), h) ;
		}
		return h ;
	}

	
	static function parseWM(d : haxe.xml.Fast, h : Hash<WorldMod>) {
		var w : WorldMod = {
				id : d.att.id,
				name : d.att.name,
				hasDayRand : false,
				mods : new Array() 
			} ;
			
		for (e in d.nodes.playMod) {
			var m = {align : if (e.has.align) e.att.align else null,
						zMid : if (e.has.zone && e.att.zone != "") e.att.zone else null,
						mod : data.QuestXML.parsePlayMod(e)}
			if (m.zMid == "dayRand")
				w.hasDayRand = true ;
			w.mods.push(m) ;
		}
		h.set(w.id, w) ;
	}
}


