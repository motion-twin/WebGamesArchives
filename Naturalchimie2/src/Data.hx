import data.Container ;
import data.Condition ;
import data.RecipeContainer ;
import data.Map ;
import data.Effect ;
import data.Region ;
import data.Category ;
import data.Action ;
import data.Collection ;
import data.Object ;
import data.Dialog ;
import data.Keeper ;
import data.QuestPnj ;
import data.Quest ;
import data.Merchant ;
import data.Title ;
import data.WorldMod ; 
import data.KnowledgeXML ;
import data.SCTReward ;
import data.RecipeXML ;
import data.GESlotXML ;
import data.ForumGroup ;
import GameData._Artefact ;
import GameData._ArtefactId ;
import db.NewsPaper.GESlot ;
import db.UserLogKind ;


class Data {
	
	public static var DATABIN_LAST_MOD : Date ;
	
	//fidelity
	public static var FIDELITY_LIFETIME = 3 ; //3 mois
	public static var FIDELITY_WARNING = 4 ; //4 jours
	public static var FIDELITY_POINTS_PER_PYRAM = 5 ; //hors pyrams bonus
	public static var FIDELITY_RANK = [150, 400, 1250] ;
	public static var FIDELITY_HISTORY_SIZE = 30 ;
	public static var FIRSTBUY_PA = 10 ;
	
	//starting data
	public static var START_PA = 3 ;
	public static var CAULDRON_MIN_SIZE = 3 ;
	public static var DEFAULT_SCORE = 40000 ;
	
	public static var NOOB_RECALL = 4 ;
	
	//school
	public static var GU	= 0 ;
	public static var GM 	= 1 ;
	public static var AP	= 2 ;
	public static var SK	= 3 ;
	public static var JZ	= 4 ;
	
	public static var CHAIN_WEIGHT = [18, 18, 18, 18, 12, 8, 7, 5, 4, 1, 1, 0] ;
	
	public static var PLAY_BASE_MAX = 2.5 ;
	public static var MID_XP_PER_GAME = 4.2 ;
	public static var MID_GOLD_PER_GAME = 85 ;
	public static var MIN_QUEST_PLAYS = 1000000 ;
	
	public static var REF_RANKS = [0, 20, 100] ;
	public static var REF_WINS = ["pyram1", 
							"pyram1", 
							"pyram3", 
							"pyram5", 
							"slot", 
							"pa",
							"pa",
							"recipe", 
							"elt_earth",
							"elt_water",
							"elt_fire",
							"elt_wind"] ;
	
	public static var XP_BONUS_MODES = 1.50 ;
	
	public static var TUTORIAL_REWARDS = [{e : _Elt(0), qty : 2}, {e : _Elt(1), qty : 2}, {e : _Elt(3), qty : 2}] ;
		
	
	public static var GRADE_CAP = [0,
							80,
							80, 160, 250, 
							320, 400, 520, 670, 
							760, 890, 1060, 1250, //<== ### LOCKED ON GRADE 12. UNCOMMENT ONE BY ONE TO ADD GRADE ACCESS ### 
							1875, 2900, 4650  ] ;

			/*
			grade 0 > 12 : 6360 xp
			grade 12 > 15 : 9000+ xp
			*/
	
	
	public static var TELEPORT_COOLDOWN = 1000 * 60 * 60 * 4 ; // 4 heures
	
	//### SCHOOL TEAM
	static public var SCT_CREATION_COST = 1500 ;
	static public var SCT_APPLY_COST = 400 ;
	static public var SCT_CREATION_LEVEL = 3 ;
	static public var SCT_APPLY_LEVEL = 2 ;
	static public var SCT_MEMBER_MIN = 5 ;
	static public var SCT_MEMBER_MAX = 20 ;
	static public var SCT_SCORE_PER_MEMBER = 5 ;
	static public var SCT_JOKER_COST_MEMBER = 2500 ;

	static public var SCT_EXTRA_WHEELS = [5, 5, 3, 2, 2, 1, 1, 1, 1, 1] ; // TO CORRECT
	
	static public var KNOWLEDGE_FLOOR_LIMIT = 4 ;

	
	static public var RACE_DURATION = 21 ; //days
	static public var RACE_PAUSE_DURATION = 7 ; //days
	
		
	//### SCHOOL CUP BONUSES
	static public var BEST_CUP_BONUS_REPUT = 30 ;
	static public var AVG_CUP_BONUS_PA = 1 ;
	static public var ALL_CUP_BONUS_PRICE = 15 ;
	static public var OLD_CUP_WEEKS = 8 ;
	static public var CUP_REPUT_WIN = [30, 20, 10, 5, 3, 3, 2, 2, 2, 2, 2, 2, 2] ;
	
	static public var POUM_SALE = 15 ;
	public static var COLOR_FULL = 1500 ;

	public static var WIN_SIZE = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25, 28] ;
		
	public static function getCupWeek(d : Date) : Int {
		var res = Std.parseInt(DateTools.format(d, "%U")) ;
		if (res == 52 || res == 0)
			return 53 ;
		else
			return res ;
	}
	
	public static function prevCupWeek(w : Int) : Int {
		if (w == 53)
			return  51 ;
		else if (w == 1)
			return 53 ;
		else
			return  w - 1 ;
	}
	
	/*
	plus de grades ! 
	0 : PROFANE  												4
	1 : ASPIRANT (couleur veste auto) 							5
	2 : une recette d'école										6
	3 : 														7
	4 : APPRENTI (recette de veste)								9 (+)
	5 : 														10
	6 : une recette d'école										11
	7 : 														12
	8 : ALCHIMISTE CERTIFIE (recette de veste)					14 (+)
	9 : 														15
	10 : 														16
	11 : recette d'école	+ recette de veste					17
	12 : 														18
	13 : PROFESSEUR DES ECOLES (recette de veste)				20 (+)
	14 : 														21
	15 : une recette d'école									22
	16 : 														23
	17 : une recette d'école									24
	18 : 														25
	19 : ALCHIMAGE (une recette d'école + recette de veste)		28 (++)
	*/
		
	
	public static var GRADE_AVATAR = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 5, 5, 5] ;
	public static var GRADE_AVATAR_INDEX = 3 ;
		
	//reputation
	public static var reputs = [GU, AP, JZ, GM, SK] ;
	
	//public static var REPUT_CAP = [-150, -40, 0, 60, 450, 1340, 4200, 12600] ;
	public static var REPUT_CAP = [-150, -40, 0, 60, 530, 1870, 6070, 18670] ;
	public static var REPUT_AUTO_MOD =   [[0, 0, 0, 60, 20, 10, 0, 0, 0],
									[0, -10, -40, -40, -40, -90, -350, -2400, -5000]] ;

	public static var REPUT_FIRST_SCHOOL =  [60, 30, -40] ;
	
	public static var REPUT_MY_SCHOOL = /*4.0*/ 4. ;
	public static var REPUT_NEUTRAL_SCHOOL = /*1.8*/ 3. ;
	public static var REPUT_OPP_SCHOOL = /*0.7*/ 2.0 ;
	public static var REPUT_OPP_MY_SCHOOL = -3 ;
		
	//quest 
	public static var REPUT_BASE_QUEST = 6 ;
	public static var XP_BASE_QUEST = 12 ;
	public static var GOLD_BASE_QUEST = 80 ;
	
	public static var QUEST_MAX = [2, 4] ;
	
	public static var QUIT_COST = 990 ;
	public static var QUIT_SCHOOL_COST = [900, 2500, 6000] ;

		
	//recipe rank
	public static var RANK_CAP = [0, 8, 23, 63, 153, 299] ;
	public static var RANK_UP_PROB = [100, 100, 100, 70, 70, 70, 45, 45, 45, 45, 0] ;
	
	//guildian redaction
	public static var GE_HISTORY_MAX = 10 ;
	public static var GE_SUBMIT_MAX = 3 ;
	public static var GE_ARTICLE_SIZE = 2000 ; //chars
	public static var GE_TITLE_SIZE = 40 ; //chars
	public static var GE_ADVERT_COST = [{day : 1, gold : 700},
										{day : 2, gold : 1400},
										{day : 3, gold : 1800},
										{day : 6, gold : 2700}] ;
	public static var GE_ADVERT_SIZE = 140 ; //chars
	public static var GE_IMAGES=  [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42] ;
		
	//xmas event
	static public var XMAS_DAILY_PYRAM = 10 ;
	static public var XMAS_DAILY_SNOWBALLS = 12 ;
	
	
	//GENERATOR QUEST STATIC DATAS AND FUNCS
	static public var TRANSMUT_DIFFICULTIES = [[_Elt(4), _Elt(5), _Elt(6), _Elt(7), _Elt(8), _Elt(9), _Elt(10), _Elt(18), _Elt(21), _Destroyer(0), _Destroyer(3), _Dynamit(0), _Wombat], //level 0 : easy
										[_Elt(0), _Elt(1), _Elt(2), _Elt(3), _Elt(11), _Elt(12), _Elt(16), _Elt(20), _Elt(24), _Jeseleet(0), _PolarBomb, _Destroyer(null), _Alchimoth, _Detartrage, _Dynamit(1)], //level 1 : normal
										[_Elt(13), _Elt(25), _Elt(14), _Elt(22), _Elt(26), _Elt(15), _Elt(19), _Elt(27), _PearGrain(0), _Grenade(0), _Delorean(0), _Protoplop(1), _Pistonide], //level 2 : hard
										[_MentorHand, _Tejerkatum, _Dollyxir(0), _Teleport, _Jeseleet(1), _Dalton, _RazKroll]] ; //level 3 : nigthmare
	
	public static function getMaxQuest() {
		return QUEST_MAX[QUEST_MAX.length - 1] ;
	}
	
	public static function getRandomMap(?diff = 1, ?withElements : Array<{o : _ArtefactId, qty : Int}>, ?forAll = false) : data.Map {
		var av = Lambda.array(Data.MAP.l.filter(function(x) {
			var event = x.randEvent > 0 && x.randEvent <= diff ;
			if (diff < 3 && !forAll) //no hard mode => accessible zone only
				event = event && Script.eval(App.user, x.pre) ;
			if (withElements == null || withElements.length == 0)
				return event ;
			for (e in withElements) {
				var found = false ;
				for(c in x.gameMode.chain) {
					switch(e.o) {
						case _Elt(eid) :
							if (eid < 8 || eid == c) {
								found = true ;
								break ;
							}
						default : throw "invalid artefactId in getRandomMap : " + Std.string(e.o) ;
					}
				}
				if (!found)
					return false ;
			}
			return event ;
		})) ;
		
		return av[Std.random(av.length)] ;
	}
	
	
	
	public static function getSchoolCupMap() : data.Map {
		var av = new Array() ;
		for (m in Data.MAP.l) {
			var event = m.randEvent > 0 && m.randEvent < 3 && m.id != "gucaul" ;
			if (!event)
				continue ;
			
			var w = 0 ;
			switch(m.randEvent) {
				case 1 : w = 12 ;
				case 2 : w = 5 ;
				//case 3 : 	w = 1 ;
			}
			
			av.push({m : m, weight : w}) ;
		}
		
		var chosen = tools.Utils.randomProbs(cast av) ;
		return chosen.m ;
	}
	
	public static function isActiveCup() : Bool {
		return db.Version.manager.version("schoolCup") != null ;
	}

	public static function isActiveRace() : Bool {
		return db.Version.manager.version("race") != null ;
	}
	
	public static function isSchoolCup(zone : Map) {
		return zone.mid == db.Version.manager.version("schoolCup") ;
	}
	
	
	public static function getDataCupMap() : String {
		if (!Data.isActiveCup())
			return null ;
		
		var sCup = db.Version.manager.version("schoolCup") ;
		var z = if (sCup != null) Data.MAP.getId(sCup) else null ;
		
		if (z == null)
			return null ;
		
		return Std.string(z.id) + ";" + z.inf + ";" + Std.string(DefaultContext.version("mapData.swf")) ;
	}
	
	public static function isCurrentAvgCup(school : Int) : Bool {
		return school > 0 && school == db.Version.manager.getCupAvg() ;
	}
	
	public static function isCurrentBestCup(school : Int) : Bool {
		return school > 0 && school == db.Version.manager.getCupBest() ;
	}
	
	public static function isCurrentAllCup(school : Int) : Bool {
		return school > 0 && school == db.Version.manager.getCupAll() ;
	}
	
	
	public static function getReputMods(sc : Int, align : String, ?pb = 1.0) : Array<Int> {
		var res = new Array() ;
		var opp = getOppReput(sc) ;
		var ai = schoolIndex(align) ;
		
		if (ai == null)
			throw "invalid alignement" ;
		
		var cupMod = if (App.user.canPlayCup() && App.user.hasRewardCup("best")) (BEST_CUP_BONUS_REPUT / 100 + 1.0) else 1.0 ;
		
		for (r in reputs) {
			var v = 0.0 ;
			var min = 1.0 ;
			if (r == ai) {
				if (r == sc && sc > 0) {
					v = REPUT_MY_SCHOOL ;
					min = 2 ;
				}else if (r == opp) {
					v = REPUT_OPP_SCHOOL ;
				} else {
					v = REPUT_NEUTRAL_SCHOOL ;
					min = 2 ;
				}
				
			} else if (r == sc && ai == opp)
				v = REPUT_OPP_MY_SCHOOL ;
			
			if (v == 0)
				res[r] = 0 ;
			else
				res[r] = Std.int(if (v < 0) v else Math.max(min, (v * cupMod) * pb)) ;
		}
		return res ;
	}
	
	
	static public var OPEN_ARTEFACTS_WIN : Array<Array<{o:_ArtefactId, q : Int}>> = [[{o:_Pa,q:1}, {o:_Stamp,q:5},{o:_Pa,q:3},{o:_Stamp,q:10}, {o:_Protoplop(0),q:1}, {o:_Jeseleet(0),q:1}, {o:_Delorean(0),q:1}, {o:_Detartrage,q:1}, {o:_Grenade(0),q:1}, {o:_PolarBomb,q:2}, {o:_Destroyer(null),q:1}, {o:_Empty,q:2}],
									[{o:_Pa,q:5},{o:_Protoplop(1),q:1},{o:_Alchimoth,q:1},{o:_Dynamit(0),q:1},{o:_PearGrain(0),q:1},{o:_Jeseleet(1),q:1},{o:_PearGrain(1),q:1},{o:_Dollyxir(0),q:1},{o:_RazKroll,q:1},{o:_Grenade(1),q:1},{o:_Wombat,q:1},{o:_Catz,q:1}],
									[{o:_Catz,q:2},{o:_Pa,q:5},{o:_Patchinko,q:1},{o:_MentorHand,q:1},{o:_Dalton,q:1},{o:_Pistonide,q:1},{o:_Tejerkatum,q:1},{o:_Dynamit(1),q:1},{o:_Dynamit(2),q:1}],
									[{o:_Pa,q:12},{o:_Teleport,q:1},{o:_Pa,q:6},{o:_Dollyxir(1),q:1},{o:_Dynamit(1),q:2},{o:_Dynamit(0),q:3},{o:_Alchimoth,q:2},{o:_PearGrain(0),q:2},{o:_MentorHand,q:1},{o:_Patchinko,q:2}]] ;
	static var OPEN_WEIGHTS = [[ {id : "pyram", weight : 1},
							{id : "gold", weight : 210},
							{id : "recipe", weight : 130},
							{id : "artefact", weight : 199},
							{id : "element", weight : 410}],
							[ {id : "pyram", weight : 8},
							{id : "gold", weight : 190},
							{id : "recipe", weight : 150},
							{id : "artefact", weight : 330},
							{id : "element", weight : 250}]] ;
	
	
	static public function openSurprise(u : db.User, level : Int) {
		var r = Std.random(100) ;
		var ratio = if (level == 0) {
					if (r  == 0) 2 else if ( r < 11 ) 1 else 0 ;
				} else {
					if (r  == 0) 3 else if (r < 16 ) 2 else if (r < 70) 1 else 0 ;
				}
		
		var mult = if (level == 1 && ratio == 0)  {
					if (Std.random(100) < 20)
						2.0 ;
					else 
						1.0 ;
				} else 
					1.0 ;
		var w = OPEN_WEIGHTS[level].copy() ;
		if ((level == 0 && ratio < 2)) //no luck : remove pyram winning
			w.shift() ; 
						
		var type = tools.Utils.randomProbs(cast w) ;
		var log = "" ;
				
		switch(type.id) {
			case "pyram" : 
				var p = 1 ;
				switch(ratio) {
					case 0 : p = 1 ;
					case 1 : p = 1 ;
					case 2 : p = 1 + Std.random(2) ;
					case 3 : p = 2 + Std.random(2) ;
				}
				u.token += p ;
				log = p + " tokens" ;
				
				db.UserLog.insert(u, KTokenCreate, "by Surprise : " + log) ;
				
				App.session.setMessage(null, null, "token", p) ;
			case "gold" : 
				var g = 1 ;
				switch(ratio) {
					case 0 : g = 3 +Std.random(12) ;
					case 1 : g = 50 + Std.random(70) ;
					case 2 : g = 120 + Std.random(120) ;
					case 3 : g = 200 + Std.random(105) ;
				}
				g = Std.int(g * 10 * mult) ;
				u.addGold(g) ;
				log = g + " gold" ;
				App.session.setMessage(null, null, "gold", g) ;
			case "recipe" : 
				var r = null ;
				switch(ratio) {
					case 0 : r = Recipe.getRandomRecipe(u, 300, 240) ;
					case 1 : r = Recipe.getRandomRecipe(u, 260, 140) ;
					case 2 : r = Recipe.getRandomRecipe(u, 200, 80) ;
					case 3 : r = Recipe.getRandomRecipe(u, 160, 1) ;
				}
				if (r == null) { 
					r = Recipe.getRandomRecipe(u) ;
					
					if (r == null) {//no more recipes disps for this user = give gold instead
						var g= 400 + Std.random(800) ;
						u.addGold(g) ;
						log = g + "gold instead" ;
						App.session.setMessage(null, null, "gold", g) ;
					} else {
						db.UserRecipe.addRecipe(u.id, r.id) ;
						log = r.name ;
						App.session.setMessage(null, null, "recipe", r) ;
					}
				} else {
					db.UserRecipe.addRecipe(u.id, r.id) ;
					log = r.name ;
					App.session.setMessage(null, null, "recipe", r) ;
				}
			case "artefact" : 
				var o = null ;
				o = OPEN_ARTEFACTS_WIN[ratio][Std.random(OPEN_ARTEFACTS_WIN[ratio].length)] ;
				if (Type.enumEq(o.o, _Destroyer(null)))
					o = { o : _Destroyer(Std.random(8)), q : o.q} ;
				try {
					u.inventory.add(o.o, Std.int(o.q * mult)) ;
				} catch(e : Dynamic ) {
					throw Std.string(o) + ", ratio : " + ratio + ", " + Std.string(e) ;
				}					
				log = Std.string(o.o) + ", qty : " + Std.string(o.q * mult) ;
				App.session.setMessage(null, null, "art", [{o : o.o, qty : o.q}]) ;
			case "element" : 
				var id = 0 ;
				var q = 1 ;
				switch(ratio) {
					case 0 : 
						id = if (level == 0) Std.random(8) else (Std.random(4) + 7) ;
						q = 5 + Std.random(16 - id * 2 + Std.random(2)) ;
					case 1 : 
						var t = if (level == 0)
								[8, 9, 12, 13, 16, 17, 20, 21, 24 ,25] ;
							else 
								[12, 13, 14, 16, 17, 18, 20, 21, 22, 24 ,25, 26] ;
						var index = Std.random(t.length) ;
						id = t[index] ;
						q = 1 + (if (Std.random(100) < 20) 1 else 0) + (if (level == 1) Std.random(3) else 0) ;
					case 2 : 
						var t = if (level == 0)
								[10, 12, 13, 14, 16, 17, 18, 20, 21, 22, 24, 25, 26] ;
							else 
								[11,  13, 14, 15, 17, 18, 19, 21, 22, 24, 25, 26, 27] ;
						var index = Std.random(t.length) ;
						id = t[index] ;
						q = 1 + (if (Std.random(100) < 20) Std.random(3) else 0) ;
					case 3 : 
						var t = [11, 14, 18, 23, 26, 15, 19, 22, 27] ;
						var index = Std.random(t.length) ;
						q = if (index < 5) {2 + Std.random(4) ; } else {1 + (if (Std.random(100) < 30) 1 else 0) ; } ;
						id = t[index] ;
				}
				q = Std.int(Math.max(q, 1) * mult) ;
				u.inventory.add(_Elt(id), q) ;
				log = Std.string(_Elt(id)) + ", qty : " + q ;
				App.session.setMessage(null, null, "art", [{o : _Elt(id), qty : q}]) ;
		}
		
		db.UserLog.insert(u, KSurprise, "level :" + level + " # ratio : " + ratio + " # type : " + type.id + " # " + log) ;
	}
	
	
	static var OPEN_GIFT = [ {id : "pyram_1", weight : 75},
						{id : "pyram_2", weight : 23},
						{id : "pyram_3", weight : 8},
						{id : "pyram_5", weight : 3},
						{id : "recipe_hat", weight : 18},
						{id : "recipe_bg", weight : 18},
						//{id : "recipe_pyram", weight : 1},
						{id : "elem", weight : 100}] ;
	
	
	public static function openGift(u : db.User) {
		var type = tools.Utils.randomProbs(cast OPEN_GIFT) ;
		var log = "" ;
		
		switch(type.id) {
			case "pyram_1", "pyram_2", "pyram_3", "pyram_5" : 
				var p = switch(type.id) {
						case "pyram_1" : 1 ;
						case "pyram_2" : 2 ;
						case "pyram_3" : 3 ;
						case "pyram_5" : 5 ;
				} ;
				u.token += p ;
				log = p + " tokens" ;
				db.UserLog.insert(u, KTokenCreate, "by Gift : " + log) ;
				App.session.setMessage(null, null, "token", p) ;
			case "recipe_hat", "recipe_bg", "recipe_pyram" : 
				var rid = switch(type.id) {
							case "recipe_hat" : 		"xmhat" ;
							case "recipe_bg" : 		"xmbg" ;
							case "recipe_pyram" : 	"atoken" ;
					} ;
				if (db.UserRecipe.hasRecipe(u.id, rid)) {
					var p = if (rid == "atoken") 2 else 1 ;
					u.token += p ;
					log = p + " tokens" ;
					db.UserLog.insert(u, KTokenCreate, "by Gift (no recipe) : " + log) ;
					App.session.setMessage(null, null, "token", p) ;
				} else {
					var r = Data.RECIPES.getName(rid) ;
					db.UserRecipe.addRecipe(u.id, rid) ;
					log = r.name ;
					App.session.setMessage(null, null, "recipe", r) ;
				}
			case "elem" : 
				var disps = [14, 18, 22, 26, 15, 19, 23, 27] ;
				var nbs = [1, 1, 1, 1, 1, 2, 2, 2, 2, 3] ;
			
				var index = Std.random(disps.length) ;
				var q = nbs[Std.random(nbs.length)] ;
				if (index < 4 && q == 1)
					q++ ;
				
				u.inventory.add(_Elt(disps[index]), q) ;
				log = Std.string(_Elt(disps[index])) + ", qty : " + q ;
				App.session.setMessage(null, null, "art", [{o : _Elt(disps[index]), qty : q}]) ;
		}
		
		db.UserLog.insert(u, KGift, log) ;
	}
	
	
	static var OPEN_XMAS_BALL = [ {id : "xmcool", weight : 50},
							{id : "xmhu", weight : 50},
							{id : "xmyeah", weight : 50},
							{id : "snowball", weight : 80},
							{id : "choco", weight : 80},
							{id : "xmhat", weight : 1},
							{id : "xmbg", weight : 1}] ;
							
	public static function openXMasBall(u : db.User) {
		var type = tools.Utils.randomProbs(cast OPEN_XMAS_BALL) ;
		var log = "" ;
		
		switch(type.id) {
			case "xmcool", "xmhu", "xmyeah" : 
				var nbs = [3, 3, 3, 5, 5, 5, 8, 12] ;
				var nb = nbs[Std.random(nbs.length)] ;
			
				u.addSmiley(type.id, nb) ;
				log = nb + " x " + type.id ;
				App.session.setMessage(null, null, "smiley", {s : Config.DATADOMAIN + "/img/forum/smiley/" + Data.TEXTDESC.getIconFile(type.id) + ".gif", qty : nb}) ; 
				
			case "snowball", "choco" : 
				var nbs = [2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5] ;
				var nb = nbs[Std.random(nbs.length)] ;
			
				var o = if (type.id == "snowball") _SnowBall else _Choco ;
			
				u.inventory.add(o, nb) ;
				log = Std.string(o) + ", qty : " + nb ;
				App.session.setMessage(null, null, "art", [{o : o, qty : nb}]) ;
			
			case "xmhat", "xmbg" : 
				var rid = type.id ;
				if (db.UserRecipe.hasRecipe(u.id, rid)) {
					var o = _SnowBall ;
					var nb = 4 ;
					u.inventory.add(o, nb) ;
					log = Std.string(o) + ", qty : " + nb ;
					App.session.setMessage(null, null, "art", [{o : o, qty : nb}]) ;
				} else {
					var r = Data.RECIPES.getName(rid) ;
					db.UserRecipe.addRecipe(u.id, rid) ;
					log = r.name ;
					App.session.setMessage(null, null, "recipe", r) ;
				}
		}
		
		db.UserLog.insert(u, KXmasBall, log) ;
	}
	
	
	public static var DEFAULT_FACE = [6, //family
				4, //size
				0, //school
				0,  //rank
				4, //pattern
				0, //bg 
				0, //shoes
				3, //hair
				3, //eyes
				4, //nose
				4, //mouth
				2, //ears
				2, //shirt
				2, //trousers
				0, //misc1
				0, //misc2 ????
				8, //skin color
				6, //hair color
				5, //eyes color
				4, 4, 4, //uniform
				27, //shirt color
				27, //trousers color
				27, //shoes color
				0, 
				27] ; //bg color
	
	
	public static function checkSubFace(f : String) {
		if (f == null)
			return false ;
		
		var tf = f.split(";") ;
		if (tf.length != DEFAULT_FACE.length)
			return false ;
		
		for (i in 0...tf.length) {
			var s = tf[i] ;
			var ns = Std.parseInt(s) ;
			if (Std.string(ns) != s)
				return false ;
			
			if (DEFAULT_FACE[i] == 0) {
				if (ns != 0)
					return false ;
				continue ;
			} 
				
			if (ns >= DEFAULT_FACE[i])
				return false ;
		}
		
		return true ;
	}
	
		
	public static function getDefaultSubFace() {
		var res = new Array() ;
		for(t in DEFAULT_FACE) 
			res.push(Std.string(Std.random(t))) ;
		return res ;
	}
	
	
	public static function getSchoolNames() : Array<String> {
		var res =[] ;
		for (i in 0...4)
			res.push(Text.getText("school_" + Std.string(i + 1))) ;
		return res ;
	}
	
	
	public static function getReputRank(r : Int) : Int {
		var res = -3 ;
		var pre = -10000000 ;
		
		for(rank in REPUT_CAP) {
			if (r >= pre && r < rank)
				return res ;
			
			pre = rank ;
			res++ ;
		}
		
		return 5 ;
	}
	
	
	public static function getOppReput(sc : Int) : Int {
		switch(sc) {
			case GU : return null ;
			case AP : return GM ;
			case JZ : return SK ;
			case GM : return AP ;
			case SK : return JZ ;
			default : 
				throw "unknown reput" ;
		}
	}	


	public static function getNeed(ns : Array<{points : Int, school : Int}>, ?sch : Int) : {points : Int, school : Int} {
		if (ns == null)
			return null ;
			
		var need = null ;
		var needSch = null ;
		for (n in ns) {
			if (sch != null && n.school == sch)
				needSch = n ;
			else if (n.school == null)
				need = n ;
		}

		if (needSch != null)
			need = needSch ;
		
		return need ;
	}


	public static var KEEPER_TURNOVER = [[5, 0], [11, 0], [17, 0], [23, 0]] ;
	
	public static function checkKeeperTurnover(d0 : Date, d1 : Date) : Bool {
		var cDates = new Array() ;
		var dd1 = Date.fromString(DateTools.format(d1, "%Y-%m-%d") + " 00:00:00") ;
		for (t in KEEPER_TURNOVER) {
			cDates.push(dd1.getTime() + (t[0] * 60 * 60 + t[1] * 60) * 1000) ;
		}
		
		var indexs = new Array() ;
		for(d in [d0, d1]) {
			var ct = d.getTime() ;
			var found = false ;
			for(i in 0...cDates.length) {
				if (ct < cDates[i]) {
					indexs.push(i) ;
					found =  true ;
					break ;
				}
			}
			if (!found)
				indexs.push(cDates.length) ;
			
		}
		
		return indexs[0] != indexs[1] ;
	}
	
	
	
	public static function schoolIndex(s :String) {
		switch (s) {
			case "gu" : 	return GU ;
			case "ap" : 	return AP ;
			case "jz" : 	return JZ ;
			case "gm" : 	return GM ;
			case "sk" : 	return SK ;
			default : 	throw "unknown school code" ;
		}
	}
	
	public static function schoolCode(school : Int) {
		return switch(school) {
				case Data.GU : "gu" ;
				case Data.AP : "ap" ;
				case Data.GM : "gm" ;
				case Data.JZ : "jz" ;
				case Data.SK : "sk" ;
			}
	}
	
	
	public static function getArtefactName(a : _ArtefactId) : String {
		var o = getArtefactInfo(a) ;
		if (o == null)
			return null ;
		return o.name ;
	}
	
	
	public static function getArtefactSData(a : _ArtefactId) : String {
		return haxe.Serializer.run({_o : a}) ;
	}
		
	
	public static function getArtefactByCode(c : String) : _ArtefactId {
		var a = null ;
		if (~/^elt[0-9]{1,2}$/.match(c)) {
			a = Data.ELEMENTS.getName(c.substr(3)) ;
			if (a != null)
				return a.o ;
		} else {
			a = Data.OBJECTS.get(c) ;
			if (a != null)
				return a.o ;
		}
		throw "unknown artefact code : " + c ;
	}
	
	
	public static function getArtefactInfo(a : _ArtefactId) : Object {
		if (a == null)
			return null ;
		switch(a) {
			case _Elts(nb, p) : 
				return null ;
			case _Elt(e) :
				var e = Data.ELEMENTS.getId(e) ;
				return e ;
			/*case Destroyer(t) :
				var o = null ;
				if (t == null) {
					o = Data.OBJECTS.get("destroyernull") ;
				} else {
					var c = "destroyer" + Std.string(t) ;
					o  = Data.OBJECTS.get(c) ;
					var e = Data.ELEMENTS.getId(t) ;
					o.name += e.name ;
					o.desc = Text.format(o.desc, {element : e.name}) ;
				}
				
				return o ;*/
			case _DigReward(o) : //only for admin/play
				return getArtefactInfo(o) ;
			
			default : 
				var c = getArtefactCode(a) ;
				var o = Data.OBJECTS.get(c) ;
				if (o == null)
					throw "unknown object " + Std.string(a)  + " # " + getArtefactCode(a).toLowerCase() ;
				return o ;
		}
		
	}
	
	
	static public function getArtefactCode(a : _ArtefactId) : String { //_Elt(3) ==> elt3 / _Block(2, 1) ==> block2
		if (a == null)
			return null ;
		var n = Type.enumConstructor(a).toLowerCase().substr(1) ;
		var p = Type.enumParameters(a) ;
		var v = "" ;
		if (p != null && p.length > 0)
			v = Std.string(p[0]) ; 
		
		return n + v ;
	}
	
	public static var TELEPORTS : Hash<String> ;
	public static var TEXTDESC : tools.Editor ;
	
	public static var ELEMENTS : Container<Object, ElementXML> ;
	public static var OBJECTS : Hash<Object> ;
	public static var ACTIONS : Container<Action, ActionXML> ;
	public static var REGIONS : Container<Region, RegionXML> ;
	public static var CATEGORIES : Container<Category, CategoryXML> ;
	public static var MAP : Container<Map, MapXML> ;
	public static var EFFECTS : Container<Effect, EffectXML> ;
	public static var COLLECTION : Container<Collection, CollectionXML> ;
	public static var RECIPES : RecipeContainer ;
	public static var KEEPERS : Container<Keeper, KeeperXML> ;
	public static var QUESTPNJS : Hash<QuestPnj> ;
	public static var QUESTDIALOGS : Hash<Dialog> ;
	public static var CAULDRONDIALOGS : Hash<Dialog> ;
	public static var QUESTS : Container<Quest, Dynamic> ;
	public static var DIALOGS : Hash<Dialog> ;
	public static var MERCHANTS : Container<Merchant, MerchantXML> ;
	public static var TITLES : Container<Title, TitleXML> ;
	public static var KNOWLEDGES : Container<Knowledge, KnowledgeXML> ;
	public static var SCTREWARDS : Container<SCTReward, SCTRewardXML> ;
	public static var WORLDMODS : Hash<WorldMod> ;
	public static var FORUMGROUP : Container<ForumGroup, ForumGroupXML> ;
		
	public static var GUILDIAN_SMALL : Hash<GESlot> ;
	public static var GUILDIAN_PUB : Hash<GESlot> ;
	
	
	public static function initialize() {
		var file = Config.TPL + "datas.bin";
		


		if (!Init.noExecution() && (!Config.DEBUG || (Config.DEBUG && Config.DEBUG_BIN))) {
			try {
				var d = neko.Lib.localUnserialize(neko.Lib.bytesReference(neko.io.File.getContent(file))) ;
				untyped Data = d ;
				
				var stat = neko.FileSystem.stat(file) ;
				if (stat != null)
					Data.DATABIN_LAST_MOD = stat.ctime ;
				return ;
			} catch(e : Dynamic) {
				if (!(Config.DEBUG && Config.DEBUG_BIN))
					neko.Lib.rethrow(e) ;

			}
			
		}
		
		//hash teleport id / target id
		TELEPORTS = new Hash() ;
		TELEPORTS.set("tpgu", "gucaul") ;
		TELEPORTS.set("tpap", "aphall") ;
		TELEPORTS.set("tpjz", "jzhome") ;
		TELEPORTS.set("tpgm", "gmsch") ;
		TELEPORTS.set("tpsk", "skshar") ;
		
		
		TEXTDESC = new tools.Editor("") ;
		TEXTDESC.loadConfig("../tpl/"+Config.LANG+"/desctext.xml" );
		
		ELEMENTS = ElementXML.parse() ;
		OBJECTS = ObjectXML.parse() ;
		CATEGORIES = CategoryXML.parse() ;
		EFFECTS = EffectXML.parse();
		COLLECTION = CollectionXML.parse();
		ACTIONS = ActionXML.parse() ;
		REGIONS = RegionXML.parse() ;
		MAP = MapXML.parse() ;
		RECIPES = RecipeXML.parse() ;
		QUESTPNJS = QuestPnjXML.parse() ;
		QUESTS = QuestXML.parse() ;
		CAULDRONDIALOGS = DialogXML.parse("data/dialogs/cauldron");
		QUESTDIALOGS = DialogXML.parse("data/dialogs/quest");
		//DIALOGS = DialogXML.parse("data/dialogs");
		MERCHANTS = MerchantXML.parse();
		KEEPERS = KeeperXML.parse() ;
		FORUMGROUP = ForumGroupXML.parse();
		TITLES = TitleXML.parse() ;
		KNOWLEDGES = KnowledgeXML.parse() ;
		SCTREWARDS = SCTRewardXML.parse() ;
		WORLDMODS = WorldModXML.parse() ;
		
		var g = GESlotXML.parse() ;
		GUILDIAN_SMALL = g[0] ;
		GUILDIAN_PUB = g[1] ;
		
		MapXML.check();
		QuestXML.check() ;
		
		DIALOGS = DialogXML.parse("data/dialogs");
		
		if (Init.isCron())
			return ;
		
		var f = neko.io.File.write(file,true);
		f.writeString(neko.Lib.stringReference(neko.Lib.serialize(Data))) ;
		f.close();
	}
	
	
	static var _ = initialize() ;
	
	
	public static function xml(file) {
		return Xml.parse(neko.io.File.getContent(Config.TPL+"data/"+file)).firstElement() ;
	}
	
	
	public static function getDataPnj(id : String, frame : String) : String {
		return haxe.Serializer.run({_pnj : id, _frame : if (frame != null) frame else "1"}) ;
	}
	
	
	public static function checkQuestAccess(tfrom : Array<String>) : {c : Condition, ct : Condition} {
		var res = {c : null, ct : null} ;
		
		var hasRepeat = false ;
		
		var specialFirsts = ["apa", "ska", "gma", "borna"] ;
		
		for (i in 0...tfrom.length) {	
			var qfrom = tfrom[i] ;
			var quests = handler.Quests.getFrom(qfrom) ;
			if (quests == null || quests.length == 0)
				throw "error checking quest acces, for : " + qfrom ;
			
			if (i == 0) {
				var fq = quests.first() ;
				
				if (Lambda.exists(specialFirsts, function(x : String) { return x == fq.id ;}))
					res.c = CGrade("", 1) ;
				else
					res.c = fq.cond ;
			}
			
			if (!hasRepeat) {
				for (q in quests) {
					if (q.repeat || q.rand) {
						hasRepeat = true ;
						break ;
					}
				}
			}
			
			if (i == tfrom.length -1) { 
				if (!hasRepeat)
					res.ct = CQuest(quests.last(), CQDone) ;
				else 
					res.ct = CFalse ;
			}
		}
		
		
		return res ;
	}
	
	
	public static function parseArtefact(s : String, ?p : {p : Int}) {
		try {
			var pos = if (p == null) { p : 0 } else p ;
			var res = parseArt(s,pos) ;
			if(p == null &&  pos.p < s.length )
				throw "Expression too long";
			return res ;
		} catch( e : String ) {
			throw e+" in '"+s+"'";
		}
	}
	
	
	public static function parseArt(s : String, pos : { p : Int }) : _ArtefactId {
		var params : Array<Dynamic> = new Array() ;
		var c = s.charCodeAt(pos.p++) ;

		 if ((c >= 97 && c <= 122) || (c >= 65 && c <= 90)) { // a...z - A...Z
			pos.p -= 1 ;
			var cmd = Script.parseIdent(s,pos, true) ;
			 
			if (s.charCodeAt(pos.p++) != 40) // (
				return Type.createEnum(_ArtefactId, "_" + cmd, params) ;
			
			while (true) {
				c = s.charCodeAt(pos.p) ; 
				if (c >= 48 && c <= 57) {
					params.push(Script.parseInt(s, pos)) ;
				} else if ((c >= 97 && c <= 122) || (c >= 65 && c <= 90)) {
					var stpos = pos.p ;
					var n = Script.parseIdent(s, pos, true) ;
					
					var c2 = s.charCodeAt(pos.p) ;
					if ( c2 == 44 || c2 == 41) {
						//var d = Script.parseIdent(s, pos, true) ;
						var d = 	if (n == "null")
									null ;
								else {
									if (cmd == "QuestObj" || cmd == "Sct") {
										cast n ;
									} else {
										cast Type.createEnum(_ArtefactId, "_" + n, []) ;
									}
								}
						params.push(d) ;
					} else if (c2 == 40) { //sub artefactId (Elts(_, x))
						var next = s.indexOf(")", pos.p) + 1 ;
						if (next < 0)
							throw "invalid sub artefact : no )" ;
						params.push(parseArt(s.substr(stpos, next - stpos), {p : 0})) ;
						pos.p = next ;
					} else
						throw "invalid char in sub artefact " + c2 + " " +  s.charAt(pos.p +1) ;
				} else 
					throw "invalid char in artefact " + c  ;
				
				pos.p++ ;
				
				if (pos.p >= s.length || s.charCodeAt(pos.p -1) == 41)
					break ;
				
			}
			if( s.charCodeAt(pos.p-1) != 41 ) // )
				throw "Unclosed parenthesis " + pos.p + ", " + s.length + "#";
			
			return Type.createEnum(_ArtefactId, "_" + cmd, params) ;
		} else 
			throw "Syntax error in parsing artefact : " + s ;
		return null ;
	}
	
}