import GameData._Artefact ;
import GameData._ArtefactId ;
import GameData.CheckData ;
import GameData.GameLog ;
import GameData._GameData ;
import MapData._MapData ;


enum GameMode {
	Default ;
	IceAttack ;
	Dig ;
	Wind ;
	Mission ;
	Tutorial ;
}


typedef GameInfo = {
	var mode : GameMode ;
	var chain : Array<Int> ;
	var chainKnown : Int ;
	var objects : Int ;
	var artefacts : Array<_Artefact> ;
	var bg : String ;
	var modWeight : Array<{o : _ArtefactId, factor : Float}> ;
}


class Game {
	
	public static var CHAIN_START = [0, 1, 2, 3, 4, 5, 6, 7] ;
	public static var SCORE_MODE = [{m : Default, z : null}, 
									{m : IceAttack, z : "apcol"}, 
									{ m : Dig, z : "jzcata"}, 
									{ m : Wind, z : "skobs"}, 
									{m : Mission, z : "gmclim"}] ;

	//game Mode
	public static function getGameMode(g : String) : GameMode {
		switch (g) {
			case null : return Default ;
			case "" : return Default ;
			case "dft" : return Default ;
			case "ice" : return IceAttack ;
			case "dig" : return Dig ;
			case "tuto" : return Tutorial ;
			case "wind" : return Wind ;
			case "mission" : return Mission ;
			default : 
				throw "unknown game mode : " + g ;
		}
	}
	
	
	public static function getModeList() { //tpl use
		var res = new List() ;
		/*for(m in Type.getEnumConstructs(GameMode)) {
			if (m == Std.string(Tutorial))
				continue ;
			
			res.add({index : Type.enumIndex(Type.createEnum(GameMode, m)), name : Text.getText("gamemode_" + m)}) ;
		}*/
		for(m in SCORE_MODE) {
			res.add({index : Type.enumIndex(m.m), name : Text.getText("gamemode_" + Std.string(m.m)), mid : if (m.z == null) null else Data.MAP.getName(m.z).mid } ) ;
		}
		return res ;
	}

	public static function getModeMids() {
		var res = new List() ;
		for(m in SCORE_MODE) {
			if (m.z == null)
				continue ;
			res.add(Data.MAP.getName(m.z).mid) ;
		}
		return res ;	

	}
	
	
	public static function getModeByIndex(i : Int) : GameMode { //tpl use
		for(m in Type.getEnumConstructs(GameMode)) {
			var e = Type.createEnum(GameMode, m) ;
			
			if (Type.enumEq(e, Tutorial) || e == null)
				continue ;
			
			if (Type.enumIndex(e) == i)
				return e ;
		}
		return null ;
	}
	
	
	public static function dispUserObjects(z : data.Map, curQuest : Bool, ?cur : Int) : Int {
		if (Data.isSchoolCup(z) && App.user.canPlayCup() && !curQuest)
			return 0 ;
		
		return if (cur != null) cur else z.gameMode.objects ;
	}
	
	
	public static function getDefaultGameInfo() {
		return {
			mode : Default,
			chain : [8,9,10,11],
			chainKnown : 12,
			spe : null,
			objects : -1,
			artefacts : getDefaultArtefacts(),
			bg : "0:0",
			modWeight : null
		} ;
	}
	
	//artefacts 
	public static function getArtefacts(s : String) {
		switch (s) {
			case null : return getDefaultArtefacts() ;
			case "" : return getDefaultArtefacts() ;
			case "no" : return [] ;
			case "default" : return getDefaultArtefacts() ;
			case "moreneutral" : return getMoreNeutrals() ;
			default : 
				var tt = s.split(";") ;
				var res = new Array() ;
				if (tt[0] == "default") {
					res = getDefaultArtefacts() ;
					tt.shift() ;
				} else if (tt[0] == "moreneutral") {
					res = getMoreNeutrals() ;
					tt.shift() ;
				}
				
				for (t in tt) {
					var e = t.split(":") ;
					if (e.length != 2)
						throw "invalid artefacts on " + t + " # in " + s ;
					
					var aid = Data.parseArtefact(e[0]) ;
					
					res.push({_id : aid, _freq : Std.parseInt(e[1])}) ;
				}
				return res ;
		}
	}
	
	
	public static function parseModWeights(s : String) {
		var tt = s.split(";") ;
		var res = new Array() ;
		
		for (t in tt) {
			var e = t.split(":") ;
			if (e.length != 2)
				throw "invalid artefacts on " + t + " # in " + s ;
			
			var aid = Data.parseArtefact(e[0]) ;
			
			res.push({o : aid, factor : Std.parseFloat(e[1])}) ;
		}
		return res ;
	}
	
	
	public static function getDefaultArtefacts() : Array<_Artefact> {
		return  	[{_id : _Elts(2, null), _freq : 4500},
				{_id : _Elts(2, _Neutral), _freq : 500},
				/*{_id : _Dynamit(0), _freq : 30},
				{_id : _Dynamit(1), _freq : 15},
				{_id : _Alchimoth, _freq : 10}*/] ;
	}
	
	
	public static function getMoreNeutrals() : Array<_Artefact> {
		return  	[{_id : _Elts(2, null), _freq : 3700},
				{_id : _Elts(2, _Neutral), _freq : 1300},
				/*{_id : _Dynamit(0), _freq : 30},
				{_id : _Dynamit(1), _freq : 15},
				{_id : _Alchimoth, _freq : 10}*/] ;
	}
	
	
	public static function getUserObjects() : Array<_ArtefactId> {
		if (App.user.inventory.belt == null)
			return null ;
		var res = new Array() ;
		for (a in App.user.inventory.belt) {
			if (a == null)
				continue ;
			res.push(a) ;
		}
		
		return res ;
	}
	
	
	static public function isValidStart(data : CheckData, g : _GameData, play : db.Play) : Bool {
		if (play.startTime != null) {
			if (Data.DATABIN_LAST_MOD != null && Data.DATABIN_LAST_MOD.getTime() >= play.startTime.getTime()) {
				//### BYPASS VALIDATION : DATAS UPDATED BY MT DURING GAME
				return true ;
			}
		} else 
			throw "try to save without start date" ;
		
		try {
			if (data._object != g._object)
				return false ;
			if (data._qmin != g._qmin)
				return false ;
			if (!tools.Utils.compareArray(data._chain, g._chain, function(a : _ArtefactId, b: _ArtefactId) { return  Type.enumEq(a, b) ;})) {
				return false ;
			}
				
			if (!tools.Utils.compareArray(data._artefacts, g._artefacts, function(a : _Artefact, b: _Artefact) { return  Type.enumEq(a._id, b._id) && a._freq == b._freq ;}))
				return false ;
		
			return true ;
		} catch(e : Dynamic) {
			return false ;
		}
	}
	
	
	static public function getGrid(s : String) : Array<{_id : _ArtefactId, _x : Int, _y : Int}> {
		var tt = s.split(";") ;
		var res = new Array() ;
		for (t in tt) {
			var e = t.split(":") ;
			if (e.length != 3)
				throw "invalid startGrid on " + t + " # in " + s ;
			
			/*var a = e[0].split("(") ;
			var params = null ;
			if (a.length == 2) {
				params = new Array() ;
				for (s in a[1].split(")")[0].split(",")) {
					params.push(Std.parseInt(s)) ;
				}
			}
				
			var aid = Type.createEnum(ArtefactId, a[0], params) ;*/
			
			var aid = Data.parseArtefact(e[0]) ;
			
			res.push({_id : aid, _x : Std.parseInt(e[1]), _y : Std.parseInt(e[2])}) ;
		}
		return res ;
	}

	
	static public function isValidSave(d : _GameData, g : _GameData, play : db.Play) : Bool {
		if (play.startTime != null) {
			if (Data.DATABIN_LAST_MOD != null && Data.DATABIN_LAST_MOD.getTime() >= play.startTime.getTime()) {
				//### BYPASS VALIDATION : DATAS UPDATED BY MT DURING GAME
				return true ;
			}
			
			if (d._worldMod != g._worldMod) //### BYPASS VALIDATION : WORLD CHANGE DURING GAME (ANIMATION AUTO LOCATION ON DAILY CRON)
				return true ;
		} else 
			throw "try to save without start date" ;
		
		//try {
			if (d._mode != g._mode)
				return false ;
			if (d._object != g._object)
				return false ;
			if (d._qmin != g._qmin)
				return false ;
			if (g._object< 0 && d._userobjects != null && d._userobjects.length > 0)
				return false ;
				
			if (d._chainknown != g._chainknown) //### TO CHECK
				return false ;
			
			if (!tools.Utils.compareArray(d._chWeight, g._chWeight, function(a : Int, b: Int) { return  a == b ;}))
				return false ;
			
			if (!tools.Utils.compareArray(d._chain, g._chain, function(a : _ArtefactId, b: _ArtefactId) { return  Type.enumEq(a, b) ;}))
				return false ;
			
			if (!tools.Utils.compareArray(d._artefacts, g._artefacts, function(a : _Artefact, b: _Artefact) { return Type.enumEq(a._id, b._id) && a._freq == b._freq ;}))
				return false ;
				
			if (g._object == 0 && !tools.Utils.compareArray(d._userobjects, g._userobjects, function(a : _ArtefactId, b: _ArtefactId) { return Type.enumEq(a, b) ;}, true))
				return false ;
				
			return true ;
		
		/*} catch(e : Dynamic) {
			return false ;
		}*/
	}


	static public function checkCheater(data : GameLog, play : db.Play) : Int { // 0 = ok, 1 = valid score but log it, 2 = invalid score
		// check level / grid
		var eltChecked = new Array() ;
		for (g in data._grid) {
			for (e in g) {
				if (e == null)
					continue ;
				switch(e) {
					case _Elt(eid) : 
						if (Lambda.exists(eltChecked, function(x : Int) { return x == eid ; }))
							continue ; //already checked

						var found = false ;
						for (i in 0...data._infos._chain.length) {
							switch(data._infos._chain[i]) {
								case _Elt(ceid) : 
									if (ceid != eid)
										continue ;
									found = true ;
									if (data._level < i + 1)
										return 2 ;
									break ;

								default : throw "invalid chain on check save" ;
							}
						}
						if (!found)
							return 2 ;
						eltChecked.push(eid) ;

					default : continue ;
				}
			}
		}

		// check special rewards
		if (data._srewards == null || data._srewards.length == 0)
			return 0 ;

		for (r in data._srewards) {

			switch(r._got) {
				case _Elt(eid) :
					if (data._infos._mode != "Dig") {
						var found = false ;
						for (i in 0...data._infos._chain.length) {
							switch(data._infos._chain[i]) {
								case _Elt(ceid) : 
									if (ceid != eid)
										continue ;
									found = true ;
									break ;
								default : continue ;
							}
						}
						if (!found)
							return 1 ;
					}

					if (r._nb > 10)
						return 1 ; 

				case _GodFather, _Gift : //impossible
					return 1 ;

				case _CountBlock(l), _Block(l) : 
					continue;

				case _QuestObj(id) : 
					continue ; 
				
				case _Pumpkin(id) : 
					continue ; 

				case _NowelBall, _Choco : 
					continue ;

				default : 
					if (r._nb > 10)
						return 1 ; 
			}
		}
		
		return 0 ;
	}
	
	
	
	
}