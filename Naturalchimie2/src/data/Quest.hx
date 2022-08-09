package data ;

import GameData._ArtefactId ;
import GameData._Artefact ;
import GameData.QuestPlayMod ;
import data.Dialog.ActionEffect ;



enum QGoal {
	GTalk(dialog : String) ; //parler à un pnj
	GMsg(text : String, action : String, auto : Bool, zone : Map) ; //action avec un message résultat 
	GAction(text : String, action : String, url : String, zone : Map) ; //action avec un message résultat 
	GFx(effect : data.Effect, has : Bool) ; //avoir tel effet sur son compte pour continuer
	GAt(zone : Map, hidden : Bool) ; //se rendre dans la zone donnée (hidden : la zone n'est pas indiquée au joueur)
	GCollect(objects : List<{o : _ArtefactId, qty : Int}>, zone : Map, mod : QuestPlayMod, modFactor : Float) ; //jouer dans telle zone jusqu'à récupérer les objets demandés
	GCreate(objects : List<{o : _ArtefactId, qty : Int}>, zone : Map, mod : QuestPlayMod, allInOne : Bool) ; //avoir tels objets dans le tableau à la fin de la partie pour les récupérer
	GTransform(objects : List<{o : _ArtefactId, qty : Int}>) ; //obtenir tels objets grâce au chaudron (mis de côté comme avec GCollect)
	GCauldron(r : Recipe, qty : Int, collect : Bool, drop : Bool, add : Int) ; //executer telle recette x fois
	GUse(objects : List<{o : _ArtefactId, qty : Int}>, qobjects : List<{o : _ArtefactId, qty : Int}>, gold : Int, token : Int, recipe : Recipe, text : String, action : String, zone : Map, result : Array<ActionEffect>, noList : Bool) ; //action avec un message résultat 
	GScore(score : Int, ratio : Float, zone : Map, mod : QuestPlayMod) ;
	GChain(index : Int, zone : Map, mod : QuestPlayMod) ;
	GComplete(from : String) ; //quête accomplie. Tag de fin
}


typedef QuestGoal = {
	var goal : QGoal ;
	var title : String ; //titre dans les étapes de questInfo, peut-être null
	var step : Bool ; //true pour masquer les étapes suivantes tant que celle-ci n'est pas remplie (default : false)
	var hideZone : Bool ; //true pour masquer le chemin vers la zone où se rendre sur la carte (le joueur doit trouver de lui-même) 
	var cond : Condition ;
	var index : Int ;
}


enum QuestWin {
	WXp(pts : Int) ;
	WGold(v : Int) ;
	WReput(school : Int, r : Int) ; 
	WRecipe(rid : String) ;
	WRandomRecipe(wMin : Int, wMax : Int) ;
	WItem(objects : List<{o : _ArtefactId, qty : Int}>) ;
	WEffect(id : Effect) ;
	WSlot ;
}


typedef Quest = {
	var id : String ;
	var mid : Int ;
	var rand : Bool ;
	var forcedRand : String ;
	var name : String ;
	var pre : Array<ActionEffect> ;
	var post : Array<ActionEffect> ;
	var begin : String ;
	var from : String ;
	var pnj : QuestPnj ;
	var end : String ;
	var endMid : Int ;
	var autoEnd : Bool ;
	var repeat : Bool ;
	var protect : Bool ;
	var goals : List<QuestGoal> ;
	var wins : List<QuestWin> ;
	var cond : Condition ;
	var hideCond : Condition ;
	var race : Int ;
}


class QuestXML {
	
	public static function parse() {
		var h = new Container<Quest,Dynamic>(true) ;
		for( file in questFiles()) {
			h.parse("quests/" + file, parseQuest) ;
		}
		return h ;
	}


	static function parseQuest(id: String, iid : Int, m : haxe.xml.Fast ) : Quest {
		var goals = new List() ;
		var wins = new List() ;
		var i = 0 ;
		
		for (g in m.elements) {
			switch(g.name) {
				//### GOALS
				case "begin", "end" :
				case "fx" :
					goals.add({goal : GFx(Data.EFFECTS.getName(g.att.fid), true),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
				case "nofx" :
					goals.add({goal : GFx(Data.EFFECTS.getName(g.att.fid), false),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
								hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
				case "talk" : 
					goals.add({goal : GTalk(g.att.did),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "collect" :
					goals.add({goal : GCollect(Lambda.map(Game.getArtefacts(g.att.o), function(x) { return {o : x._id, qty : x._freq} ; }),
								if (g.has.zone) Data.MAP.getName(g.att.zone) else null,
								if (g.hasNode.playMod) parsePlayMod(g.node.playMod) else null,
								if (g.has.factor) Std.parseFloat(g.att.factor) else 1.0),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "create" :
					goals.add({goal : GCreate(Lambda.map(Game.getArtefacts(g.att.o), function(x) { return {o : x._id, qty : x._freq} ; }),
								if (g.has.zone) Data.MAP.getName(g.att.zone) else null,
								if (g.hasNode.playMod) parsePlayMod(g.node.playMod) else null,
								if (g.has.allInOne) Std.parseInt(g.att.allInOne) == 1 else false),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "chain" :
					var target = Std.parseInt(g.att.index) ;
					if (target == null || target < 0 || target > 11)
						throw "invalid target index for GChain : " + target ;
				
					goals.add({goal : GChain(target,
										if (g.has.zone) Data.MAP.getName(g.att.zone) else null,
										if (g.hasNode.playMod) parsePlayMod(g.node.playMod) else null),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "score" :
					var gs = GScore(if (g.has.score) Std.parseInt(g.att.score) else null,
								if (g.has.ratio) Std.parseFloat(g.att.ratio) else null,
								if (g.has.zone) Data.MAP.getName(g.att.zone) else null,
								if (g.hasNode.playMod) parsePlayMod(g.node.playMod) else null) ;
					switch(gs) {
						case GScore(sc, r, z, m) :
							if (sc == null && r == null)
								throw "invalid GSCore" ;
						default : 
					}
				
					goals.add({goal : gs,
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "transform" :
					goals.add({goal : GTransform(Lambda.map(Game.getArtefacts(g.att.o), function(x) { return {o : x._id, qty : x._freq} ; })),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "use" :
					var result = null ;
					if (g.has.give || g.has.qgive || g.has.effect) {
						result = new Array() ;
						if (g.has.give) {
							for (t in g.att.give.split(";")) {
								var p = t.split(":") ;
								result.push(EGive(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
							}
						
						}		
						if (g.has.qgive) {
							for (t in g.att.qgive.split(";")) {
								var p = t.split(":") ;
								result.push(EQuestGive(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
							}
						}
						if (g.has.effect) {
							for(e in g.att.effect.split(":"))
								result.push(EEffect(Data.EFFECTS.getName(e))) ;
						}
					} 
				
					var 	u = {goal : GUse(if (g.has.o) Lambda.map(Game.getArtefacts(g.att.o), function(x) { return {o : x._id, qty : x._freq} ; }) else null,
										if (g.has.qo) Lambda.map(Game.getArtefacts(g.att.qo), function(x) { return {o : x._id, qty : x._freq} ; }) else null,
										if (g.has.gold) Std.parseInt(g.att.gold) else null,
										if (g.has.token) Std.parseInt(g.att.token) else null,
										if (g.has.recipe) Data.RECIPES.getName(g.att.recipe) else null,
										g.att.text, 
										if (g.has.action) g.att.action else null, 
										if (g.has.zone) Data.MAP.getName(g.att.zone) else null,
										result,
										g.has.nolist && Std.parseInt(g.att.nolist) == 1),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i} ;

					goals.add(u) ;
					i++ ;
				case "cauldron" : 
					goals.add({goal : GCauldron(Data.RECIPES.getName(g.att.r),
										if (g.has.qty) Std.parseInt(g.att.qty) else 1,
										g.has.collect && Std.parseInt(g.att.collect) == 1,
										g.has.drop && Std.parseInt(g.att.drop) == 1,
										if (g.has.add && (Std.parseInt(g.att.add) == 1 || Std.parseInt(g.att.add) == 2)) Std.parseInt(g.att.add) else 0), //1 for add, 2 for add with forceflash
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "goto" : 
					goals.add({goal : GAt(Data.MAP.getName(g.att.zone), (g.has.hidden && Std.parseInt(g.att.hidden) == 1)),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "msg" :
					goals.add({goal : GMsg(g.att.text, if (g.has.action) g.att.action else null, (g.has.auto && Std.parseInt(g.att.auto) == 1), if (g.has.zone) Data.MAP.getName(g.att.zone) else null),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
				case "action" :
					goals.add({goal : GAction(g.att.text, g.att.action, g.att.urlact, if (g.has.zone) Data.MAP.getName(g.att.zone) else null),
							title : if (g.has.title) g.att.title else null,
							step : if (g.has.step) Std.parseInt(g.att.step) == 1 else false,
							hideZone : if (g.has.hidezone) Std.parseInt(g.att.hidezone) == 1 else false,
							cond : if (g.has.cond) Script.parse(g.att.cond) else Condition.CTrue,
							index : i}) ;
					i++ ;
							
				//### WINS
				case "xp" :
					wins.add(WXp(Std.parseInt(g.att.v))) ;
				case "gold" : 
					wins.add(WGold(Std.parseInt(g.att.v))) ;
				case "reput" :
					wins.add(WReput(Data.schoolIndex(g.att.s), Std.parseInt(g.att.v))) ;
				case "item" : 
					wins.add(WItem(Lambda.map(Game.getArtefacts(g.att.v), function(x) { return {o : x._id, qty : x._freq} ; }))) ;
				case "recipe" : 
					wins.add(WRecipe(g.att.v)) ;
				case "randomrecipe" : 
					var weights = g.att.v.split(":") ;
					wins.add(WRandomRecipe(Std.parseInt(weights[0]), Std.parseInt(weights[1]))) ;
				case "effect" :
					wins.add(WEffect(Data.EFFECTS.getName(g.att.v))) ;
				case "slot" : 
					wins.add(WSlot) ;
				default :
					throw "Invalid case "+g.name + " in quest "+id ;
			}
		}
		
		var rand = m.has.rand && Std.parseInt(m.att.rand) == 1;
		
		var pre = new Array() ;
		var post = new Array() ;
		var t = pre ;
		if (!rand) {
			for (elem in [{t : pre, a : m.node.begin}, {t : post, a : m.node.end}]) {
				for(name in  elem.a.x.attributes()) {
					var v = elem.a.x.get(name) ;
					switch( name ) {				
						case "give":
							for (t in v.split(";")) {
								var p = t.split(":");
								elem.t.push(EGive(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
							}
						case "take":
							for (t in v.split(";")) {
								var p = t.split(":");
								elem.t.push(ETake(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
							}
							
						case "qgive":
							for (t in v.split(";")) {
								var p = t.split(":");
								elem.t.push(EQuestGive(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
							}
						case "qtake":
							for (t in v.split(";")) {
								var p = t.split(":");
								elem.t.push(EQuestTake(Data.parseArtefact(p[0]), if( p[1] == null ) 1 else Std.parseInt(p[1]) )) ;
							}
						case "effect":
							for(e in v.split(":"))
								elem.t.push(EEffect(Data.EFFECTS.getName(e))) ;
						case "noeffect":
							for( e in v.split(":") )
								elem.t.push(ENoEffect(Data.EFFECTS.getName(e))) ;
						case "collection":
							elem.t.push(ECollection(Data.COLLECTION.getName(v))) ;
						case "nocollection":
							elem.t.push(ENoCollection(Data.COLLECTION.getName(v))) ;
						case "recipe":
							var infos = v.split(":") ;
							var r = null ;
							var forceFlash = false ;
							if (infos.length == 1)
								r = v ;
							else {
								r = infos[0] ;
								forceFlash = Std.parseInt(infos[1]) == 1 ;
							}
							elem.t.push(ERecipe(Data.RECIPES.getName(r), forceFlash)) ;
						case "norecipe":
							elem.t.push(ENoRecipe(Data.RECIPES.getName(v))) ;
						case "gold":
							elem.t.push(EGold(Std.parseInt(v))) ;
						case "refill":
							elem.t.push(ERefill(if (v == "") null else Std.parseInt(v))) ;
								
						case "auto", "zone" : //nothing to do
						default:
							throw "Begin effect "+ name + " not supported in quest   "+ m.att.name;
					}
				}
			}
		}
		
		
		if (!rand && (wins.isEmpty() || goals.isEmpty()))
			throw "Quest "+id+" is incomplete" ;
		
		if (!rand && (m.att.name == null || m.att.name == ""))
			throw "no name for quest " + m.att.id ;
		
		return {
			id : id,
			mid : iid,
			name : m.att.name,
			from : m.att.from,
			pnj : Data.QUESTPNJS.get(m.att.from),
			rand : rand,
			forcedRand : if (m.has.forcedRand) m.att.forcedRand else null,
			race : if (m.has.race) Data.schoolIndex(m.att.race) else null,
			pre : pre,
			post : post,
			repeat : if (m.has.repeat) Std.parseInt(m.att.repeat) == 1 else false,
			protect : if (m.has.protect) Std.parseInt(m.att.protect) == 1 else false,
			begin : if (m.hasNode.end) Data.TEXTDESC.format(m.node.begin.innerData) else null,
			end : if (m.hasNode.end) Data.TEXTDESC.format(m.node.end.innerData) else null,
			endMid : if (!rand) {if (m.node.end.has.zone) Data.MAP.getName(m.node.end.att.zone).mid ; else null ; } else null,
			autoEnd : if (!rand) {if (m.node.end.has.auto) Std.parseInt(m.node.end.att.auto) == 1 ; else false ; } else null,
			goals : goals,
			wins : wins,
			cond : Condition.CTrue,
			hideCond : Condition.CTrue
		};
	}
	
	
	static public function parsePlayMod(p : haxe.xml.Fast) : QuestPlayMod {
		var res = {
			_mode : if (!p.has.mode || p.att.mode == "") null else p.att.mode,
			_objects : if (p.has.obj )  if (Std.parseInt(p.att.obj) == 1) 0 else -1  else null,
			_forceuo : null,
			_artefacts  : if (!p.has.artft || p.att.artft == "") null else Game.getArtefacts(p.att.artft), 
			_replace : p.has.replace && Std.parseInt(p.att.replace) == 1,
			_replaceDefault : p.has.replaceDefault && Std.parseInt(p.att.replaceDefault) == 1,
			_chain : if (!p.has.chain || p.att.chain == "") null else Lambda.array(Lambda.map(Game.getArtefacts(p.att.chain), function(x) { if (x._freq > 11) throw "bad index in chain mod : " + x._freq ; return {_id : x._id, _index : x._freq} ; })),
			_grid : if (!p.hasNode.startGrid || !p.node.startGrid.has.g) null else Game.getGrid(p.node.startGrid.att.g),
			_hideIndex : if (!p.has.hideIndex || p.att.hideIndex == "") null else Std.parseInt(p.att.hideIndex)
		} ;
		
		if (res._replaceDefault)
			res._replace = false ;
		
		if (p.has.fuo && p.att.fuo != "") {
			res._forceuo = new Array() ;
			var uo = p.att.fuo.split(";") ;
			for (u in uo) {
				res._forceuo.push(Data.parseArtefact(u)) ;
			}
			
			if (res._forceuo.length > 4)
				throw "too many fuo in " + p.att.fuo ;
		}
		
		if (res._objects > 4 || res._objects < -1)
			throw "unvalid object value in playMod : " + res._objects ;
		
		return res ;
	}
	
	
	static function questFiles() {
		var m = neko.FileSystem.readDirectory(Config.TPL+"data/quests") ;
		m.remove(".svn") ;
		return m ;
	}
	
	
	static public function check() {
		for( file in questFiles() ) {
			var x = new haxe.xml.Fast(Data.xml("quests/"+file));
			for( e in x.elements ) {
				var q = Data.QUESTS.getName(e.att.id) ;
				if (e.has.cond)
					q.cond = Script.parse(e.att.cond) ;
				if (e.has.hideCond)
					q.hideCond = Script.parse(e.att.hideCond) ;
				
				for (g in q.goals) {
					switch(g.goal) {
						case GTalk(dialog) : 
							if (Data.QUESTDIALOGS.get(dialog) == null)
								throw "quest dialog " + dialog + " not found" ;
						default : //nothing to do
					}
				}
				
			}
		}
	}
	
	

}

