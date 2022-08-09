import GameData._ArtefactId ;
import data.Category ;
import CauldronData._CResult ;
import data.Condition ;
import db.UserLogKind ;



typedef Disp = {
	var way : DispWay ;
	var weight : Int ;
	var price : {token : Int, tokenVar : Null<Int>, gold : Int, goldVar : Null<Int>} ;
	var cond : Condition ;
}


enum DispWay {
	Random ;
	School ;
	Black ;
	Quest ;
	RaceReward ;
	RaceSecret ;
}


class Recipe {
	
	public var id : String ;
	public var mid : Int ;
	public var name : String ;
	public var school : Int ;
	public var scOnly : Bool ;
	public var category : data.Category ;
	public var specialist : Bool ;
	public var flash : Bool ;
	public var questOnly : Bool ;
	public var forbidden : Bool ;
	public var desc : String ;
	public var icon : String ;
	public var flavor: String ;
	public var disps : Array<Disp> ;
	
	public var luckDiff : Int ;
	
	public var sNeeds : String ;
	public var needs : Array<{o : _ArtefactId, qty : Int}> ;
	public var joker : _ArtefactId ;
	
	//results
	public var sResult : String ;
	public var result : _CResult ;
			
	
	
	public function new() {
		//gotIt = false ;
		questOnly = false ;
		luckDiff = 0 ;
	}
	
	
	public function setDisp(x : haxe.xml.Fast) {
		if (x == null)
			return ;
		if (disps == null)
			disps = new Array() ;
		var d = {way : null, weight : 0, cond : null, price : null} ;
		
		switch (x.att.way) {
			case "random" : 
				d.way = Random ;
			case "school" : d.way = School ;
			case "black" : d.way = Black ;
			case "quest" : d.way = Quest ;
			case "race" : d.way = RaceReward ;
			case "secretrace" : d.way = RaceSecret ;
			default : 
				throw "unknown disp way :" + x.att.way + " for recipe " + id ;
		}
		
		if (x.att.way != "random")
			luckDiff = 1 ;
			
		
		d.weight = if (x.has.weight) Std.parseInt(x.att.weight) else 0 ;
		d.cond = if (x.has.cond) Script.parse(x.att.cond) else Condition.CTrue ;
		if (!x.has.price)
			d.price = {token : 1, tokenVar : null, gold : 0, goldVar : null} ;
		else {
			var p : Array<String> = x.att.price.split(":") ;
			if (p == null || p.length != 4)
				throw "invalid price for disp : " + Std.string(x) ;
			d.price = {token : Std.parseInt(p[0]), tokenVar : if (Std.parseInt(p[1]) == 0) null else Std.parseInt(p[1]), gold : Std.parseInt(p[2]), goldVar : if (Std.parseInt(p[3]) == 0) null else Std.parseInt(p[3])} ;
		}
		
		disps.push(d) ;
	}


	public function getDispCond(way : DispWay) {
		if (disps == null)
			return null ;

		for (d in disps) {
			if (!Type.enumEq(d.way, way))
				continue ;
				
			return if (Type.enumEq(d.cond, Condition.CTrue)) null else d.cond ;
		}
		return null ;
	}
	
	
	public function isForbidden() {
		return forbidden || (scOnly && App.user != null &&school != App.user.school) ;
	}
	
	
	public function setNeeds(s : String) {
		if (s == null || s == "")
			throw "empty needs for recipe " + id ;
		
		sNeeds = s ;
		var sn = s.split(";") ;
		needs = new Array() ;
		for (n in sn) {
			var infos = n.split(":") ;
			if (infos.length != 2)
				throw "invalid need " + s + " for recipe " + id ;
			
			var o = Data.parseArtefact(infos[0]) ;
			if (o == null)
				throw "unknown object " + infos[0] + " for recipe " + id ; 
			switch(o) {
				case _Elt(i) : //nothing to do
					
				case _Joker : 
					joker = o ;
				default : 
					//advanced = true ;
			}
			
			
			var q = if (Std.parseInt(infos[1]) > 0)
						Std.parseInt(infos[1]) ;
					else 
						throw "invalid needs " + s + " for recipe " + id ;
			
			needs.push({o : o, qty : q}) ;
		}
	}
	
	
	public function setResult(s : String) {
		if (s == null || s == "")
			throw  "empty result for recipe " + id ;
		
		var fp = s.indexOf("(") ;
		if (fp < 0)
			throw "invalid result " + s + " for recipe " + id ;
		
		var sr = [s.substr(0, fp), s.substr(fp + 1)] ;
		
		if (sr.length != 2 || sr[1].charAt(sr[1].length - 1) != ")")
			throw "invalid result " + s + " for recipe " + id  ;
		sr[1] = sr[1].substr(0, sr[1].length - 1) ;
		sResult = s ;
		
		result = getCResult(sr[0], sr[1]) ;
	}
	
	
	function getCResult(c : String, args : String) : _CResult {
		switch(c) {
			case "add" : 
				var infos = args.split(":") ;
				if (infos.length == 0 || infos.length > 2)
					throw "invalid add result " + args + " for recipe " + id ;
				
				var o = Data.parseArtefact(infos[0]) ;
				if (o == null)
					throw "unknown object " + infos[0] + " for recipe " + id ; 
				
				var q = 	if (infos.length == 1)
							1
						else if (Std.parseInt(infos[1]) > 0)
							Std.parseInt(infos[1]) ;
						else 
							throw "invalid add quantity " + infos[1] + " for recipe " + id ;
						
				switch(o) {
					case _Elt(e) : //nothing to do
					default :
						var info = Data.getArtefactInfo(o) ;
						if (info != null) {
							var nr = getNeedRatio() / q ;
							if (info.ratio == null || info.ratio > nr)
								info.ratio = nr ;
						}
				}
				
				return _Add(o, q, 0) ;
			
			case "win" : 
				var att = args.split(",") ;
				if (att.length != 2)
					throw "invalid win result " + args + " for recipe " + id ;
				return _Win(Std.parseInt(att[0]), Std.parseInt(att[1])) ;
				
			case "avatar" : 
				var att = args.split(",") ;
				if (att.length != 2)
					throw "invalid avatar result " + args + " for recipe " + id ;
				return _Avatar(Std.parseInt(att[0]), Std.parseInt(att[1]), this.icon) ;
				
			case "avatarrand" :
				var att = args.split(",") ;
				if (att.length != 3)
					throw "invalid avatarrand result " + args + " for recipe " + id ;
				return _AvatarRand(Std.parseInt(att[0]), Std.parseInt(att[1]), Std.parseInt(att[2])) ;
				
			case "avatarinc" :
				var att = args.split(",") ;
				if (att.length != 2)
					throw "invalid avatarinc result " + args + " for recipe " + id ;
				return _AvatarInc(Std.parseInt(att[0]), Std.parseInt(att[1])) ;
				
			case "avatarlist" : 
				var l = args.split(":") ;
				if (l.length == 0)
					throw "invalid avatarlist result " + args + " for recipe " + id ;
				var rl = new Array() ;
				for(sl in l) {
					var fp = sl.indexOf("(") ;
					if (fp < 0)
						throw "invalid avatarlist arg " + sl + " for recipe " + id ;
					
					var sr = [sl.substr(0, fp), sl.substr(fp + 1)] ;
					if (sr.length != 2 || sr[1].charAt(sr[1].length - 1) != ")")
						throw "invalid avatarlist arg " + sl + " for recipe " + id  + " ## " + l ;
					sr[1] = sr[1].substr(0, sr[1].length - 1) ;
					
					rl.push(getCResult(sr[0], sr[1])) ;
				}
				return _AvatarList(rl, this.icon) ;
				
			case "avatartemp" : 
				var l = args.split(":") ;
				if (l.length == 0)
					throw "invalid avatartemp result " + args + " for recipe " + id ;
				var rl = new Array() ;
				//var l = [args.substr(0, idx), args.substr(idx + 1)] ;
				
				var fx = l.shift() ;
				if (Data.EFFECTS.getName(fx) == null)
					throw "invalid effect for avatartemp " + fx + " for recipe " + id  ;
				
				for(sl in l) {
					var fp = sl.indexOf("(") ;
					if (fp < 0)
						throw "invalid avatartemp arg " + sl + " for recipe " + id  ;
					
					var sr = [sl.substr(0, fp), sl.substr(fp + 1)] ;
					if (sr.length != 2 || sr[1].charAt(sr[1].length - 1) != ")")
						throw "invalid avatartemp arg " + sl + " for recipe " + id  ;
					sr[1] = sr[1].substr(0, sr[1].length - 1) ;
					
					rl.push(getCResult(sr[0], sr[1])) ;
				}
				
				
				return _AvatarTemp(fx, rl, this.icon) ;
				
			case "temp" : 
				var att = args.split(",") ;
				if (att.length != 2)
					throw "invalid temp result " + args + " for recipe " + id ;
				return _Temp(att[0], Std.parseInt(att[1])) ;
				
			case "kaboom" : 
				var att = args.split(",") ;
				if (att.length != 1)
					throw "invalid temp result " + args + " for recipe " + id ;
				return _Kaboom(att[0]) ;
				
			case "keepergoout" : 
				var att = args.split(",") ;
				if (att.length != 1)
					throw "invalid temp keepergoout " + args + " for recipe " + id ;
				return _KeeperGoOut(att[0], true) ;
				
			case "texture" : 
				var att = args.split(",") ;
				if (att.length != 1)
					throw "invalid texture result " + args + " for recipe " + id ;
				return _Texture(att[0]) ;
				
			case "smiley" : 
				var att = args.split(",") ;
				if (att.length != 2)
					throw "invalid smiley result " + args + " for recipe " + id ;
				return _Smiley(att[0], Std.parseInt(att[1])) ;
				
			case "color" : 
				var att = args.split(",") ;
				if (att.length != 2)
					throw "invalid color result " + args + " for recipe " + id ;
				
				return _Color(Std.parseInt(att[0]), Std.parseInt(att[1])) ;
				
			default : 
				throw "invalid result type " + c + " for recipe " + id ;
				return null ;
		}
	}
	
	
	public function getPrice(w : DispWay) : {token : Int, gold : Int} {
		if (disps == null || disps.length == 0)
			throw "recipe " + mid + " unavailable" ;

		for (d in disps) {
			if (d.way != w)
				continue ;

			return {	token : d.price.token + tools.Utils.getVar(d.price.tokenVar),
					gold : d.price.gold + tools.Utils.getVar(d.price.goldVar)
					} ;
		}
		
		throw "unknown  dispway " + Std.string(w) + " for recipe " + mid ;
	}
	
	
	
	//#############################################################
	//
	// static function for find recipe made 
	//
	//#############################################################
	
	static public function alchimyProcess(ingredients : Array<{o : _ArtefactId, qty : Int}>, ?noLuck : Bool = false) : Recipe {
		var res = {r : null, s : ""} ;
		if (ingredients == null || ingredients.length == 0)
			return null ;
		
		var ur = db.UserRecipe.manager.of(App.user) ;
		var recipes = Data.RECIPES.l.filter(function(x) {
			if (Lambda.exists(ur, function(xx : db.UserRecipe) {return xx.mid == x.mid && xx.active && (xx.fromQuest == null || xx.fromQuest == App.user.qid) ;}))
				return true ;
			return !x.flash && !x.questOnly ;
		}) ;
				
		for (r in recipes) {
			if (!r.isNeeds(ingredients))
				continue ;
			
			if (Lambda.exists(ur, function(x : db.UserRecipe) {return x.mid == r.mid && x.active ;}) || (!noLuck && byLuck(r)))
				return r ;
			else
				return null ;
			
		}
		
		return null ;
	}
	
	
	public function getResultElement() : {o : _ArtefactId, qty : Int} {
		switch(result) {
			case _Add(o, qty, _) : 
				return {o : o, qty : qty} ;
			default : 
				throw "invalid getResultElement for recipe " + id ;
		}
		return null ;
	}
	
	
	public function isNeeds(ing : Array<{o : _ArtefactId, qty : Int}>, ?jokerCheck : Bool = false) : Bool {
		var ingredients = ing.copy() ;
		var notFound = false ;
		
		if (joker == null && ingredients.length != needs.length)
			return false ;
		
		for (n in needs) {
			if (Type.enumEq(n.o, _Joker))
				continue ;
			
			notFound = true ;
			for (i in ing) {
				if (!Type.enumEq(n.o, i.o))
					continue ;
				
				if (n.qty == i.qty) {
					notFound = false ;
					ingredients.remove(i) ;
				} else {
					if (joker != null && n.qty == i.qty - 1) {
						notFound = false ;
						ingredients.remove(i) ;
						ingredients.push({o : i.o, qty  : 1}) ;
					}else
						return false ;
				}
			}
			
			if (notFound)
				return false ;
		}
		
		if (joker != null) {
			if (ingredients.length == 1 && ingredients[0].qty == 1) {
				switch(ingredients[0].o) {
					case _Elt(i) : 
						if (!jokerCheck)
							joker = ingredients[0].o ;
						return true ;
					case _Joker : //admin check process only
						return jokerCheck ;
					default : 
						if (!jokerCheck)
							joker = ingredients[0].o ;
						return true ;
				}
			} else 
				return false ;
		} else
			return ingredients.length == 0 ;
	}
	
	
	static function byLuck(r : Recipe) : Bool {
		var STANDARD_LUCK = 2 ;
		var DIFFICULT_LUCK = 5 ;
		var NOODLE_BORDERED_ASS = 2000 ;
		
		if (r.flash || r.questOnly || r.id == "beta")
			return false ;
		
		if (r.forbidden)
			return Std.random(NOODLE_BORDERED_ASS) == 0 ;
		
		if (r.luckDiff == 0) //random access recipes
			return Std.random(STANDARD_LUCK) == 0 ;
		
		return Std.random(DIFFICULT_LUCK) == 0 ;
			
		
		
		/*if (r.school == Data.GU || r.school == App.user.school)
			return Std.random(STANDARD_LUCK) == 0 ;
		
		return Std.random(OTHER_SCHOOL_LUCK) == 0 ;*/
	}
	
	
	//#############################################################
	//
	// recipe done : making result
	// return true in case of specialist procs
	//
	//#############################################################
	
	public  function makeResult(isForb : Bool)  : {spe : Bool, res : _CResult} {
		return applyResult(result, isForb) ;
	}
	
	
	function applyResult(res : _CResult, isForb : Bool, ?isTemp = false) : {spe : Bool, res : _CResult} {
		switch(res) {
			case _Fail : //nothing to do on server side
				return {spe : false, res : _Fail} ;
			case _Kaboom(fx) : //nothing to do on server side
				
				switch(fx) {
					case "nocthul" : 
						App.user.removeEffect(Data.EFFECTS.getName("cthulo")) ;
						App.user.update() ;
					
				}
			
				return {spe : false, res : _Kaboom(fx)} ;
				
			case _KeeperGoOut(fx, done) :
				var doIt = false ;
				if (!App.user.keeperGone) {
					doIt = true ;
					App.user.keeperGone = true ;
					App.user.update() ;
				}
				return {spe : false, res : _KeeperGoOut(fx, doIt)} ;
				
			case _Add(o, qty, _) : 
				if (joker != null) {
					switch(joker) {
						case _Elt(e) : 
							switch(o) {
								case _Destroyer(d) : 
									o = _Destroyer(e) ;
								default : 
									//nothing to do
							}
						
						default : 
							o = _Destroyer(Std.random(27)) ;
							//throw "invalid joker in " + name + ". " + Std.string(joker) + " is not an element" ;
					}
					
				}
				
				if (!isForb) {
					App.user.inventory.add(o, qty) ;
					App.user.update() ;
				}
			
				return {spe : false, res : _Add(o, qty, 0)} ;
				
			case _Win(token, gold) : 
				if (!isForb) {
					if (token != null && token > 0) {
						App.user.token += token ;
						db.UserLog.insert(App.user, KTokenCreate, "by Recipe : " + token + " tokens") ;
					}
					if (gold != null && gold > 0)
						App.user.gold += gold ;
					App.user.update() ;
				}
				
				return {spe : false, res : _Win(token, gold)} ;
				
			case _Avatar(a, b, ic) :
				
				if (isForb)
					return {spe : false, res : _Avatar(a, App.user.getFaceValue(a), ic)} ;
			
				var i = 0 ;
				if (joker != null) {
					switch(joker) {
						case _Elt(e) : 
							i = e ;
						default : 
							i = Type.enumIndex(joker) ;
							//throw "invalid joker in " + name + ". " + Std.string(joker) + " is not an element" ;
					}

					if (id == "scthat" && a != 25) //hack Pyrasol
						i = 0 ;
				}				
				var c = b + i ;
				
				if (a  == -1) { //sex change -- hack
					a = 0 ;
					c = switch(App.user.getFaceValue(0, true)) {
						case 0 : 1 ;
						case 1 : 0 ;
						case 2 : 3 ;
						case 3 : 2 ;
						case 4 : 5 ;
						case 5 : 4 ;
						default : App.user.getFaceValue(0, true) ;
					}
				}
				if (a  == -2) { //type change -- hack
					a = 0 ;
					var poss = switch(App.user.getFaceValue(0, true)) {
						case 0 : [2, 4] ;
						case 1 : [3, 5] ;
						case 2 : [0, 4] ;
						case 3 : [1, 5] ;
						case 4 : [0, 2] ;
						case 5 : [1, 3] ;
						default : [App.user.getFaceValue(0, true)] ;
					}
					
					c = poss[Std.random(poss.length)] ;
				}
				
				App.user.updateFace(a, c, isTemp) ;
				
				return {spe : false, res : _Avatar(a, c, ic)} ;
				
			case _AvatarInc(a, s) : 
				var cv = App.user.getFaceValue(a) ;
				if (a == null)
					throw "invalid index " + a + " for avatar inc" ;
				
				if (isForb)
					return {spe : false, res : _Avatar(a, cv, this.icon)} ;
			
				var nv =  cv + (if (s > 0) 1 else -1) ;
				if (nv < 0)
					nv = 99 ;
				App.user.updateFace(a, nv, isTemp) ;
				
				return {spe : false, res : _Avatar(a, nv, this.icon)} ;
			
			case _AvatarRand(a, rMax, p) : 
				var maxTries = 15 ;
				var old = App.user.getFaceValue(a) ;
			
				if (isForb)
					return {spe : false, res : _Avatar(a, old, this.icon)} ;
			
				var b = Std.random(rMax) + p ;
				while (maxTries > 0 && b == old) {
					b = Std.random(rMax) + p ;
					maxTries-- ;
				}
				App.user.updateFace(a, b, isTemp) ;
			
				return {spe : false, res : _Avatar(a, b, this.icon)} ;
				
			case _AvatarList(l, ic) :
				var lres = new Array() ;
				for (a in l) {
					var ra = applyResult(a, isForb) ;
					lres.push(ra.res) ;
				}
				return {spe : false, res : _AvatarList(lres, ic)} ;
				
			case _AvatarTemp(fx, avatar, ic) :
				var effect = Data.EFFECTS.getName(fx) ;
				if (effect == null)
					throw "unknown effect for recipe : " + fx ;
				
				App.user.addEffect(effect) ;
				var ue = App.user.getEffect(effect.eid, true) ;
				
				var lres = new Array() ;
				for (a in avatar) {
					var ra = applyResult(a, isForb, true) ;
					lres.push(ra.res) ;
				}
				
				ue.data.avatar = App.user.face ;
				ue.update() ;
				App.user.tempFaceFxId = ue.eid ;
			
				return {spe : false, res : _AvatarList(lres, ic)} ;
				
			case _Temp(fx, time) :
				//### ### #### ### ### TODO
				return {spe : false, res : _Temp(fx, time)} ;
				
			case _Smiley(img, nb) :
				if (!isForb)
					App.user.addSmiley(img, nb) ;
				return {spe : false, res : _Smiley(Config.DATADOMAIN + "/img/forum/smiley/" + Data.TEXTDESC.getIconFile(img) + ".gif", nb)} ;
			
			case _Color(c, days) :
				if (!isForb)
					App.user.addForumColor(c, days) ;
				return {spe : false, res : _Color(c, days)} ;
				
			case _Texture(t) :
				if (!isForb) {
					App.user.texture = t ;
					App.user.update() ;
				}
				return {spe : false, res : _Texture(t)} ;
		}	
	}



	static public function getOtherSchoolRecipes(sc : Int) : Array<Recipe> {
		var res = new Array() ;
		for (r in Data.RECIPES.iterator()) {
			if (r.school == Data.GU || r.school == sc)
				continue ;
			if (r.disps == null)
				continue ;
			for (d in r.disps) {
				switch (d.way) {
					case RaceReward : 
						res.push(r) ;
						break ;
					default : //nothing to do
				}
			}
			
		}
		return res ;
	}


	static public function getSecretRecipes(type : String, sc : Int) : Array<Recipe> {
		var res = new Array() ;
		for (r in Data.RECIPES.iterator()) {
			if (r.school != Data.GU && r.school != sc)
				continue ;
			if (r.disps == null)
				continue ;
			for (d in r.disps) {
				switch (d.way) {
					case RaceSecret : 
						switch(type) {
							case "obj" : 
								if (r.category.code != "object")
									continue ;

							case "avatar" :
								if (r.category.code != "cloth" && r.category.code != "morph")
									continue ;

							default: throw "invalid secret recipe type" ;
						}
						
						res.push(r) ;
						break ;
					default : //nothing to do
				}
			}
			
			
		}
		return res ;
	}
	
	
	static public function getRandomRecipe(u : db.User, ?wMin : Int, ?wMax : Int, ?cat : Int) : Recipe {
		var ur = db.UserRecipe.manager.of(u) ;
		var recipes = new Array() ;
		
		for (r in Data.RECIPES.iterator()) {
			if (Lambda.exists(ur, function(x : db.UserRecipe) {return x.mid == r.mid && x.active ;}) || r.disps == null)
			//if ((db.UserRecipe.manager.gotIt(u.id, r.mid) && r.uInfos.active) || r.disps == null)
				continue ;
			
			if (cat != null && cat != r.category.id)
				continue ;
			
			for (d in r.disps) {
				if (d.way == Random) {
					if ((wMin != null && d.weight > wMin) || (wMax != null && d.weight < wMax))
						break ;
						
					recipes.push({r : r, weight : d.weight}) ;
					break ;
				}
			}
		}
		
		if (recipes.length == 0)
			return null ;
		
		var res = tools.Utils.randomProbs(cast recipes) ;
		
		return if (res != null) res.r.copy() else null ;
	}
	
	
	
	//### ADMIN - RECIPE VALUE CALCULATOR
	
	function getElementRatio(e : _ArtefactId) : Float {
		var tProbs = [5670, 5650, 5620] ; //total game chain probs [default, advanced, with chronium]
		var goldRatio = Data.ELEMENTS.getId(11).weight / tProbs[0] ;
		
		switch(e) {
			case _Elt(i) :
				var t = tProbs[0] ; //default chain
				if (i > 11 && i < 28) { //advanced elements
					t = tProbs[1] ;
				} else if (i == 28) //ultra rare chronium
					t = tProbs[2] ;
				
				return goldRatio / (Data.ELEMENTS.getId(i).weight / t) ;
				
			case _Joker, _Choco, _SnowBall : 
				return null ;
			
			case _QuestObj(id) : 
				return null ;
			
			case _Pumpkin(id) : 
				return null ;
				
			default : 
				var info = Data.getArtefactInfo(e) ;
				if (info == null || info.ratio == null)
					throw "unknown ratio for artefact in recipe " + id ;
				return info.ratio ;
		}
	}
	
	
	function getRecipeRatio() : {value : Float, type : Int} { //type => 0 : cost / 1 : ratio
		var c = getNeedRatio() ;
		
		switch (result) {
			case _Add(o, qty,_) :
				switch(o) {
					case _Elt(e) : 
						var rr = getElementRatio(o) ;
						return {value : rr * qty / c, type : 1} ;
					default :  
						return {value : c, type : 0} ;
						
				}

			default : 
				return {value : c, type : 0} ;
		}
	}
	
	
	function getNeedRatio() : Float {
		var c = 0.0 ;
		for (n in needs) {
			var r = getElementRatio(n.o) ;
			if (r == null) 
				continue ;
			
			c += r * n.qty ;
		}
		return c ;
	}
	
	
	static public function checkUnicity(r : Recipe, rr : Recipe) : Bool {
		if (r.joker == null && r.joker == null)
			return rr.isNeeds(r.needs, true) ;
		else if (r.joker != null && rr.joker == null)
			return r.isNeeds(rr.needs, true) ;
		else if (r.joker == null && rr.joker != null)
			return rr.isNeeds(r.needs, true) ;
		else { //both with joker
			var ing = rr.needs.copy() ;
			var ingredients = ing.copy() ;
			for (n in r.needs) {
				if (Type.enumEq(n.o, _Joker))
					continue ;
				
				var notFound = true ;
				for (i in ing) {
					if (!Type.enumEq(n.o, i.o))
						continue ;
					
					if (n.qty == i.qty) {
						notFound = false ;
						ingredients.remove(i) ;
					} else {
						if (n.qty == i.qty - 1 || n.qty == i.qty + 1) {
							notFound = false ;
							ingredients.remove(i) ;
							ingredients.push({o : i.o, qty  : 1}) ;
						}else
							return false ;
					}
				}
				if (notFound)
					return false ;
			}
			return ingredients.length == 3 ; //ing joker + 2 elements left
		}
	}
	
	
	
	public function copy() : Recipe {
		var res = new Recipe() ;
		res.id = this.id ;
		res.mid = this.mid ;
		res.name = this.name ;
		res.school = this.school ;
		res.scOnly = this.scOnly ;
		res.category = this.category ;
		res.specialist = this.specialist ;
		res.flash = this.flash ;
		res.questOnly = this.questOnly ;
		res.forbidden = this.forbidden ;
		res.desc = parseColor(this.desc) ;
		res.icon = this.icon ;
		res.flavor = this.flavor ;
		res.disps = this.disps ;

		res.sNeeds = this.sNeeds ;
		res.needs = this.needs ;
		res.joker = this.joker ;

		res.sResult = this.sResult ;
		res.result = this.result ;
		
		return res ;
	}
	
	function parseColor(d : String) {
		if (App.user == null) 
			return d ;
		
		var res = d ;
		for (i in 0...4) {
			res = StringTools.replace(res, "::c_" + i + "::", Text.getText("col_" + App.user.school + "_" + i)) ;
			
		}
		return res ;
	}
	
	
	
} 