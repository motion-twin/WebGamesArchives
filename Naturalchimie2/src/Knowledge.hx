import db.SchoolTeam.SKnow ;
import db.STLogKind ;
import db.Play.PlayReward ;
import GameData._ArtefactId ;
import CauldronData.CauldronResult ;
import db.UserLogKind ;
import db.SchoolTeam.SNeed ;
import db.SchoolTeam.RewardTree ;
import handler.Action ;
import db.SchoolTeam.GiveResult ;


typedef KLeaf = {
	var k : Knowledge ;
	var usedPoints : Int ;
	var locked : Bool ;
	var next : Int ;
	var isPrereq : Bool ;
}


class Knowledge {
	
	public var id				: String ;
	public var place			: {x : Int, y : Int} ;
	public var name 			: String ;
	public var school			: Int ;
	public var desc				: String ;
	public var points 			: Int ;
	public var pre 				: Array<String> ;
	public var values 			: Array<Int> ;
	public var textComplements 	: Array<String> ;
	public var perMemberValue 	: Bool ;


	public function new() {}


	public function getValue(p : Int, ?sct : db.SchoolTeam) {
		if (values == null)
			return null ;
		if (p - 1 >= values.length) {
			//throw "invalid value for Knowledge" ;
			p = values.length ; //changé pour ne pas faire planter les historiques quand on rééquilibre les savoirs en réduisant les points
		}

		var m = if (sct != null && perMemberValue) sct.members else 1 ;

		return values[p - 1] * m ;
	}


	public function formatDesc(index : Int, ?sct : db.SchoolTeam) : String {
		if (values == null)
			return desc ;

		var v = getValue(index, sct) ;
		if (v == null)
			throw "invalid index for desc value" ;

		var c = null ;
		if (textComplements != null)
			c = textComplements[index - 1] ;

		return Text.format(desc, {X : v, COMP : c}) ;
	}


	static public function onIncrement(sk : SKnow, sct : db.SchoolTeam) {

		switch(sk.k.id) {
			case "spy" : // special knowledge : get random one of other school
				var avspy = db.SchoolTeam.getAvailableForSpy(sct.school) ;
				sk.special = avspy[Std.random(avspy.length)] ;

				sct.knowledges.push({
							k : Data.KNOWLEDGES.getName(sk.special.id),
							special : null,
							points : 1,
							value : 0,
							lastUse : null,
							kId : null,
							spId : null,
							spyed : true
						}) ;

			
			case "jk" : //extra joker
				sct.maxJoker++ ;

			case "wheel" : //extra wheel on knowledge win. Check autorecal
				if (sk.points <= 1)
					return ;
				var nlimit = sk.k.getValue(sk.points) ;
				if (nlimit > sk.value)
					return ;

				sk.value -= nlimit ;
				sct.wheels++ ;

				db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points}) ;
				
			case "tp" : //recal teleports number for today
				var old = if (sk.points > 1) sk.k.getValue(sk.points - 1) else 0 ;
				var v = sk.k.getValue(sk.points) ;

				sk.value = v - (old - sk.value) ;
				var obj = _Sct("tp") ;

				sct.removeChestObject(obj, null, true) ;
				sct.addChestObject(obj, sk.value) ;

				sk.lastUse = Date.now() ;

			default : //nothing to do
		}
	}


	static public function onWinSize(play : db.Play, c : Int) : Int {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace())
			return c ;

		var res = c ;
		for (sk in App.user.scTeam.knowledges) {
			switch(sk.k.id) {
				case "focus" : 
					var v = sk.k.getValue(sk.points) ;
					if (Std.random(100) >= v)
						continue ;
					res++ ;
					play.activeKnowledge(sk.k) ;

				default : continue ;
			}
		}

		return res ;
	}

	static public function onPlayRewards(play : db.Play, rewards : PlayReward) {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace())
			return rewards ;

		for (sk in App.user.scTeam.knowledges) {
			switch(sk.k.id) {
				case "score" :
				if (play.goldScore == null || play.score < play.goldScore) 
					continue ;
					
					var chain = Game.CHAIN_START.concat(Data.MAP.getId(play.zMid).gameMode.chain).slice(0, play.level) ;
					var disps = App.user.scTeam.getLeftNeeds(chain) ;
					var total = 0 ;
					for (d in disps)
						total += d.qty ;
					

					if (disps.length == 0)
						continue ;

					var nb = 1 ;
					if (total > 3) {
						nb =  tools.Utils.randomProbs(cast [{n : 1, weight : 55},
												{n : 2, weight : 35},
												{n : 3, weight : 10}]).n ;
					}

					if (rewards.specials == null)
						rewards.specials = new Array() ;

					var chosen = new IntHash() ;
					for (i in 0...nb) {
						var e = tools.Utils.randomProbs(cast disps) ;
						var c = chosen.get(e.eid) ;
						if (c == null)
							c = {qty : 0} ;
						c.qty++ ;
						chosen.set(e.eid, c) ;
						e.qty-- ;
						if (e.qty == 0)
							disps.remove(cast e) ;
					}

					var infos = "" ;
					for (c in chosen.keys()) {
						if (infos != "")
							infos += ":" ;
						infos += Std.string(Data.getArtefactCode(_Elt(c))) + "%" + Std.string(chosen.get(c).qty) ;

						rewards.specials.push({by : null, got : _Elt(c), nb : chosen.get(c).qty}) ;
					}

					play.activeKnowledge(sk.k, infos) ;
						

				default : continue ;
			}
		}

		return rewards ;		

	}

	static public function onRecipe(drops : Array<{o : _ArtefactId, qty : Int}>, recipe : Recipe, res : CauldronResult) {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace())
			return ;

		for (sk in App.user.scTeam.knowledges) {
			switch(sk.k.id) {
				case "lump" : 
					var v = sk.k.getValue(sk.points) ;
					if (Std.random(100) >= v) 
						continue ;
					
					var highers = getBestRankElements(drops) ;

					if (highers.disps.length == 0)
						continue ;

					var backFired = highers.disps[Std.random(highers.disps.length)] ;
					res._backFire = backFired ;

					App.user.inventory.add(backFired) ;
					App.user.update() ;
					db.UserLog.insert(App.user, KBackFire, Std.string(backFired) + " on recipe " + recipe.id) ;



				default : continue ;
			}
		}
	}

	static public function onQuestReward(quest : data.Quest, rewards) {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace())
			return ;

		for (sk in App.user.scTeam.knowledges) {
			switch(sk.k.id) {
				case "bonus" : 
					if (quest.race != App.user.scTeam.school)
						continue ;

					var disps = App.user.scTeam.getLeftNeeds(null, 11) ;
					if (disps.length == 0)
						continue ;

					
					var choice = tools.Utils.randomProbs(cast disps) ;
					var qty = 1 ;
					App.user.inventory.add(choice.o, qty) ;
					rewards.push({win : "object", v : Data.getArtefactCode(choice.o), s : qty, k : sk.k.id}) ;

					db.UserLog.insert(App.user, KExtraReward, Std.string(choice.o) + " x " + Std.string(qty)) ;	

				default : continue ;
			}
		}
	}

	static public function onNewNeedPoints(np : Int) : Int {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace())
			return np ;

		var res = np ;
		for (sk in App.user.scTeam.knowledges) {
			switch(sk.k.id) {
				case "thumb" : 
					res = Math.round(res * (1.0 - sk.k.getValue(sk.points) / 100.0)) ;

					db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points, infos: sk.k.getValue(sk.points)}) ;

				default : continue ;
			}
		}
		return res ;
	}


	static public function onNewNeedList(curNeeds : Array<SNeed>, fqty : Int -> Int) {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace())
			return ;

		for (sk in App.user.scTeam.knowledges) {
			switch(sk.k.id) {
				case "easy" : 
					var proc = 0 ;
					var avSubstitutes = new IntHash() ;
					for (n in curNeeds) {
						switch(n.o) {
							case _Elt(eid) : 
								if (eid >= 4 && eid <= 8 )
									avSubstitutes.set(eid, n) ;
							default : continue ;
						}
					}


					for (n in curNeeds.copy()) {
						switch(n.o) {
							case _Elt(eid) : 
								if (eid > 3) //not a basic potion
									continue ;
								var v = sk.k.getValue(sk.points) ;
								if (Std.random(100) >= v)
									continue ;

								proc++ ;
								curNeeds.remove(n) ;

								var newOne = Std.random(5) + 4 ;
								if (avSubstitutes.get(newOne) != null)
									avSubstitutes.get(newOne).qty += n.qty ;
								else {
									var nn = {o : _Elt(newOne), qty : n.qty, given : 0} ;
									avSubstitutes.set(newOne, nn) ;
									curNeeds.push(nn) ;
								}
								
							default : continue ;
						}
					}

					if (proc > 0)
						db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points, infos: proc}) ;


				case "crash" : 
					var v = sk.k.getValue(sk.points) ;
					if (Std.random(100) >= v)
						continue ;

					var highers = getBestRankElements(cast curNeeds) ;
					if (highers.disps.length == 0)
						continue ;

					var choice = highers.disps[Std.random(highers.disps.length)] ;

					var elt = Data.getArtefactInfo(choice) ;
					var tree = db.SchoolTeam.getAvailableNeeds(App.user.scTeam.school) ;

					
					var subPoint = null ;	
					var need = Data.getNeed(elt.need, App.user.scTeam.school) ;
					for (i in 0...tree.points.length) {
						if (tree.points[i] != need.points)
							continue ;
						subPoint = tree.points[i - 1] ;
						break ;
					}

					if (subPoint == null || tree.objects[subPoint] == null)
						continue ;
					var down = tree.objects[subPoint][Std.random(tree.objects[subPoint].length)] ;

					var found = false ;
					for (n in curNeeds) {
						if (!Type.enumEq(n.o, down.o))
							continue ;
						n.qty += fqty(subPoint) ;
						found = true ;
						break ;
					}
					if (!found)
						curNeeds.push({o : down.o, qty : fqty(subPoint), given : 0}) ;

					
					for (n in curNeeds.copy()) {
						if (!Type.enumEq(n.o, choice))
							continue ;
						curNeeds.remove(n) ;
						break ;
					}

					db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points, infos: {from : choice, to : down.o}}) ;

					

				default : continue ;
			}
		}
	}



	static public function onFullNeeds(sct : db.SchoolTeam) {
		var res = new Array() ;

		for (n in sct.curNeeds) {
			var e = {  	o : n.o,
						qty : n.qty,
						given : n.given, 
						extraActions : new Array()
					} ;

			if (e.qty > e.given) {
				for (sk in sct.knowledges) {
					switch(sk.k.id) {
						case "gugive", "scgive", "cancel" : 
							if (sk.k.id == "cancel" && !Data.getArtefactInfo(e.o).playable)
								continue ;
							
							if (sk.k.id == "gugive" && (e.qty < 2 || Std.int(e.qty / 2) <= e.given))
								continue ;

							var act = tools.Utils.copyAction(Data.ACTIONS.getName("k" + sk.k.id)) ;
							act.desc = sk.k.formatDesc(sk.points, sct) ;
							act.hidden = !sct.canUseSpecialAction(sk) ;
							act.tipTitle = sk.k.name ;
							act.type = "k" + sk.k.id ;

							act.link = if (!act.hidden) Text.format(act.link, {ING : Data.getArtefactCode(e.o)}) else "#" ;
							e.extraActions.push(act) ;
						
						default : continue ;
					}
				}
			}

			if (e.extraActions.length == 0)
				e.extraActions = null ;
			res.push(e) ;

		}

		return res ; 

	}


	static public function onSchoolTeamInterface(sct : db.SchoolTeam) {
		var res = new Array() ;
		if (App.user.stid == null || !sct.canPlayRace() || App.user.stid != sct.id)
			return res ;

		for (sk in sct.knowledges) {
			switch(sk.k.id) {
				case "exch",  "bours", "actpl", "actrec" : 
					var act = tools.Utils.copyAction(Data.ACTIONS.getName("k" + sk.k.id)) ;
					act.desc = sk.k.formatDesc(sk.points) ;
					act.hidden = !sct.canUseSpecialAction(sk) ;
					act.type = "k" + sk.k.id ;
					if (act.hidden)
						act.link = "#" ;

					res.push(act) ;

				case "tp" :
					var today = DateTools.format(Date.now(), "%Y-%m-%d") ;
					if (DateTools.format(sk.lastUse, "%Y-%m-%d") < today ) { // UPDATE TELEPORT NUMBER FOR TODAY
						var sct = db.SchoolTeam.manager.get(App.user.stid, true) ;
						var lsk = sct.getSchoolKnowledge(sk.k) ;
						lsk.value = sk.k.getValue(sk.points) ;
						lsk.lastUse = Date.now() ;
						sk = lsk ;
						sct.update() ;
					}

					var act = tools.Utils.copyAction(Data.ACTIONS.getName("k" + sk.k.id)) ;
					act.desc = sk.k.formatDesc(sk.points) ;
					act.hidden = sk.value == 0 ;
					act.text = act.text + " [" + sk.value + "]" ;
					if (act.hidden)
						act.link = "#" ;
					res.push(act) ;

				default : continue ;
			}
		}
		return res ;
	}


	static public function onKnowledgeAction(ak : Knowledge, sct : db.SchoolTeam, request : mtwin.web.Request) : Bool {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace() || App.user.stid != sct.id)
			return false ;

		var url = "/sct/" + sct.id ;

		var sk = sct.getSchoolKnowledge(ak) ;
		if (sk == null)
			return false ;

		switch(sk.k.id) {
			case "exch" : 
				if (!App.user.isTeamSpecialist(sct.id))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_no_grant) ;
				if (!sct.canUseSpecialAction(sk))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_kaction_already_done) ;

				var nb = sk.k.getValue(sk.points, sct) ;

				if (sct.wheels < nb)
					throw Action.Error(url, Text .get.sct_not_enough_wheel) ;
				sk.lastUse = Date.now() ;
				if (sct.addKPoint())
					sct.wheels -= nb ;
				sct.update() ;

				db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points}) ;
				return true ;

			case "gugive", "scgive" :
				if (!App.user.isTeamSpecialist(sct.id))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_no_grant) ;
				if (!sct.canUseSpecialAction(sk))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_kaction_already_done) ;

				var ing = Data.getArtefactByCode(request.get("ing")) ;
				var need = if (ing != null) sct.getNeedOf(ing) else null ;
				if (ing == null || need == null)
					throw Action.Error(url, Text.get.sct_object_not_found) ;
				
				if (need.given >= need.qty)
					throw Action.Error(url, Text.get.sct_err_object_done) ;

				if (sk.k.id == "gugive" && (need.qty < 2 || Std.int(need.qty / 2) <= need.given))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_err_gugive_error) ;

				var r = if (sk.k.id == "gugive") Data.GU else sct.school ;

				var cost = sk.k.getValue(sk.points, sct) ;
				if (sct.chest.reputs[r] < cost)
					throw Action.Error(url, Text.get.sct_not_enough_reput) ;

				sct.chest.reputs[r] -= cost ;

				
				if (sk.k.id == "gugive")
					need.qty = Math.floor(need.qty / 2) ;
				else
					sct.curNeeds.remove(need) ;
				sct.update() ;

				db.SchoolTeamLog.insert(App.user, KChestTake, {type : "reput", value : cost, school : r}) ;
				db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points}) ;

				return true ;

			case "cancel" :
				if (!App.user.isTeamSpecialist(sct.id))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_no_grant) ;
				if (!sct.canUseSpecialAction(sk))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_kaction_already_done) ;

				var ing = Data.getArtefactByCode(request.get("ing")) ;
				var need = if (ing != null) sct.getNeedOf(ing) else null ;
				if (ing == null || need == null)
					throw Action.Error(url, Text.get.sct_object_not_found) ;

				if (need.given >= need.qty)
					throw Action.Error(url, Text.get.sct_err_object_done) ;

				var info = Data.getArtefactInfo(ing) ;
				if (!info.playable)
					throw Action.Error(url, Text.get.sct_not_a_valid_object) ;

				var cost = sk.k.getValue(sk.points, sct) ;
				if (sct.wheels < cost)
					throw Action.Error(url, Text.get.sct_not_enough_wheel) ;

				sct.wheels -= cost ;
				sct.curNeeds.remove(need) ;
				sct.update() ;

				db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points, kill : Data.getArtefactCode(need.o)}) ;
				return true ;

			case "tp" : 
				var target = "kirvie" ;
				if (App.user.zone.id == target)
					throw Action.Error("/cauldron", Text.get.sct_teleport_useless) ;
				
				if (sk.value <= 0)
					throw Action.Error(url, Text.get.sct_no_teleport) ;

				sk.value-- ;
				sct.update() ;
				db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points}) ;

				mt.db.Twinoid.goals.increment(App.user, "rtp", 1) ; 
				//db.UserTitle.add(Data.TITLES.getName("rtp"), App.user, 1) ; 

				App.user.moveTo(Data.MAP.getName(target), 0) ;
				throw Action.Goto("/cauldron") ;
				return true ;

			case "bours" :
				if (!App.user.isTeamSpecialist(sct.id))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_no_grant) ;
				if (!sct.canUseSpecialAction(sk))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_kaction_already_done) ;

				var gold = sk.k.getValue(sk.points, sct) ;
				if (sct.chest.gold < gold)
					throw Action.Error("/sct/" + sct.id, Text.get.sct_not_enough_gold) ;

				sct.chest.gold -= gold ;
				sct.wheels++ ;
				sk.lastUse = Date.now() ;
				sct.update() ;

				db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id}) ;
				
				return true ;

			case "actpl" :
				if (!App.user.isTeamSpecialist(sct.id))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_no_grant) ;
				if (!sct.canUseSpecialAction(sk))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_kaction_already_done) ;

				if (sct.wheels < 1)
					throw Action.Error(url, Text.get.sct_not_enough_wheel) ;

				sct.wheels-- ;

				var obj = _Sct("actpl") ;
				var qty = sct.members ;
				sct.addChestObject(obj, qty) ;

				sk.lastUse = Date.now() ;
				sct.update() ;

				db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id}) ;
				db.SchoolTeamLog.insert(App.user, KChestAdd, {type : "object", o : _Sct("actpl"), qty : qty}) ;
				
				return true ;

			case "actrec" :
				if (!App.user.isTeamSpecialist(sct.id))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_no_grant) ;
				if (!sct.canUseSpecialAction(sk))
					throw Action.Error("/sct/" + sct.id, Text.get.sct_kaction_already_done) ;

				if (sct.wheels < 1)
					throw Action.Error(url, Text.get.sct_not_enough_wheel) ;

				sct.wheels-- ;
				
				var obj = _Sct("actrec") ;
				var qty = sct.members ;
				sct.addChestObject(obj, qty) ;

				sk.lastUse = Date.now() ;
				sct.update() ;

				db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id}) ;
				db.SchoolTeamLog.insert(App.user, KChestAdd, {type : "object", o : _Sct("actrec"), qty : qty}) ;

				return true ;

			default : return false ;
		}
	}

	static public function onNeedComplete(sct : db.SchoolTeam) {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace() || App.user.stid != sct.id)
			return ;
		var sct = App.user.scTeam ;

		for (sk in sct.knowledges) {
			switch(sk.k.id) {
				case "pa" : 
					var nb = sk.k.getValue(sk.points) ;
					for (u in sct.getMembers(true)) {
						u.inventory.add(_Pa, nb) ;
						u.update() ;
					}

					sk.lastUse = Date.now() ;
					sct.update() ;

					db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points}) ;
				
				case "pride" :
					var nb = sk.k.getValue(sk.points) ;
					for (u in sct.getMembers(true)) {
						u.addReput(sct.school, nb) ;
						u.update() ;
					}

					sk.lastUse = Date.now() ;
					sct.update() ;

					db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points}) ;
				
				default : continue ;
			}
		}
	}

	static public function onNewKPoint(sct : db.SchoolTeam) {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace() || App.user.stid != sct.id)
			return ;

		var sct = App.user.scTeam ;
		for (sk in sct.knowledges) {
			switch(sk.k.id) {
				case "wheel" : 
					var limit = sk.k.getValue(sk.points) ;
					sk.value++ ;
						
					if (sk.value >= limit) { //wheel proc
						sk.value -= limit ;
						sct.wheels++ ;

						db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points}) ;
					}
					
					sct.update() ;
					
				default : continue ;
			}
		}
	}
				

	static public function onDataRace(d : CauldronData) : Array<SKnow> {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace())
			return [] ;

		var res = new Array() ;
		var sct = App.user.scTeam ;
		for (sk in sct.knowledges) {
			switch(sk.k.id) {
				case "bakch" : 
					var gold = sk.k.getValue(sk.points) ;
					var q = Math.floor(App.user.gold / gold) ;
					if (q > 0)
						d._objects.push({_o : _QuestObj("kubor" + sk.points), _qty : q }) ;
					
					res.push(sk) ;

				case "shine", "press", "hungry", "random", "catz", "vigor", "hot" : 
					res.push(sk) ;
					
				default : continue ;
			}
		}
		return res ;
	}


	static public function onGiveNeeds(sct : db.SchoolTeam, ing : Array<{o : _ArtefactId, qty : Int}>, res : GiveResult) {
		if (App.user.stid == null || !App.user.scTeam.canPlayRace())
			return ;


		var sct = App.user.scTeam ;

		var tk = ["bakch", "vigor", "press", "catz", "shine", "hot", "hungry", "random"] ; //traitement ordonné pour optimiser les effets

		var eltByRank = {ranks : new Array(), elts : new Array(), total : 0} ;
		var others = new Array() ;
		for (n in sct.curNeeds) {
			if (n.given >= n.qty)
				continue ;

			switch(n.o) {
				case _Elt(eid) : 
					var info = Data.getArtefactInfo(n.o) ;
					if (eltByRank.elts[info.rank] == null) {
						eltByRank.elts[info.rank] = new Array() ;
						eltByRank.ranks.push(info.rank) ;
					}
					eltByRank.elts[info.rank].push(n) ;
					eltByRank.total += n.qty - n.given ;

				default : others.push(n) ;
			}
		}

		eltByRank.ranks.sort(function(a, b) {
			return if (a > b) -1 else 1 ;
		}) ;



		var fGetQuantity = function(o : _ArtefactId, nb : Int) : Int {
				for (i in ing.copy()) {
					if (!Type.enumEq(i.o, o))
						continue ;
					var n = Math.floor(i.qty / nb) ;
					i.qty -= n * nb ;
					if (i.qty <= 0)
						ing.remove(i) ;
					
					return n ;
				}
				return 0 ;
		} ;


		var fRemove = function(rank : Int, o : _ArtefactId, nb : Int, log : Array<{o : _ArtefactId, qty : Int}>) : Int {
				var choice = null ;
				if (o == null)
					choice = eltByRank.elts[rank][Std.random(eltByRank.elts[rank].length)] ;
				else {
					for (e in eltByRank.elts[rank])	{
						if (!Type.enumEq(e.o, o))
							continue ;
						choice = e ;
						break ;
					}
					if (choice == null)
					return 0 ;
				}


				var max = choice.qty - choice.given ;
				var n = if (nb > max) max else nb ;

				choice.given += n ;
				res.totalGiven += n ;

				var majFound = false ;
				var cid = Data.getArtefactCode(choice.o) ;
				for (tm in res.toMaj) {
					if (tm._id != cid)
						continue ;
					tm._qty = Std.int(Math.min(choice.given, choice.qty)) ;
					tm._given += n ;
					tm._ok = choice.given >= choice.qty ;

					majFound = true ;
					break ;
				}
				if (!majFound)
					res.toMaj.push({_id : cid, _o : choice.o, _qty : Std.int(Math.min(choice.given, choice.qty)), _given : n, _ok : choice.given >= choice.qty}) ;

				eltByRank.total-= n ;
				nb -= n ;
				log.push({o : choice.o, qty : n}) ;

				if (choice.given >= choice.qty) {
					eltByRank.elts[rank].remove(choice) ;
					if (eltByRank.elts[rank].length == 0) {
						eltByRank.elts[rank] = null ;
						eltByRank.ranks.remove(rank) ;
						if (nb <= 0)
							return -1 ; //rank list is now empty
						return nb ; // return left quantity
					}
				}
				return Std.int(Math.max(0, nb)) ;
		} ;

		for (kid in tk) {
			var sk = sct.getSchoolKnowledge(Data.KNOWLEDGES.getName(kid)) ;

			if (sk == null)
				continue ;	

			var log = new Array() ;

			switch(sk.k.id) {
				case "bakch" : // x kubors contre 1 élément de plus haut niveau disponible
					var gold = sk.k.getValue(sk.points) ;
					var g = fGetQuantity(_QuestObj("kubor" + sk.points), 1) ;
					
					if (App.user.gold < gold * g)
						throw Action.Error("/cauldron", Text.get.sct_not_enough_gold) ;

					App.user.addGold(-1 * gold * g) ;

					if (eltByRank.ranks.length == 0 || g == 0)
						continue ;

					var best = eltByRank.ranks[0] ;
					while (g > 0) {
						if (eltByRank.total <= 0 || best == null)
							break ;

						if (fRemove(best, null, 1, log) != 0)
							best = eltByRank.ranks[0] ;

						g-- ;
					}

					res.uk.push({sk : sk, data : {id : sk.k.id, value : sk.points, l : log}}) ;

				case "shine" : // 1 pépite pour un élément de même rang
					var r = 11 ;
					if (eltByRank.elts[r] == null)
						continue ;

					var n = fGetQuantity(_Elt(11), 1) ;
					
					if (n == 0)
						continue ;

					while (n > 0) {
						if (eltByRank.total <= 0 || fRemove(r, null, 1, log) != 0)
							break ;
						n-- ;
					}

					res.uk.push({sk : sk, data : {id : sk.k.id, value : sk.points, l : log}}) ;

				case "press" : // 1 bière Geminish Regular contre 1 élément de rang 9
					var r = 9 ;
					if (eltByRank.elts[r] == null)
						continue ;

					var n = fGetQuantity(_QuestObj("geminishregular"), 1) ;
					if (n == 0)
						continue ;

					while (n > 0) {
						if (eltByRank.total <= 0 || fRemove(r, null, 1, log) != 0)
							break ;
						n-- ;
					}

					res.uk.push({sk : sk, data : {id : sk.k.id, value : sk.points, l : log}}) ;

				case "hungry" : // 1 chocapic contre x éléments de rang 10 ou 11
					var ra = [10, 11] ;
					if (eltByRank.elts[ra[0]] == null && eltByRank.elts[ra[1]] == null)
						continue ;

					var n = fGetQuantity(_QuestObj("chocapic"), 1) ;

					if (n == 0)
						continue ;

					var slots = new Array() ;
					var value = sk.k.getValue(sk.points) ;
					for (i in 0...n)
						slots.push(value) ;

					while (slots.length > 0) {
						if (eltByRank.total <= 0)
							break ;

						var index = Std.random(ra.length) ;
						if (eltByRank.elts[ra[index]] == null) {
							if (ra.length > 1) 
								index = (index + 1) % 2 ;
							else
								break ;
							if (eltByRank.elts[ra[index]] == null)
								break ;
						}

						var left = fRemove(ra[index], null, slots[0], log) ;
						if (left > 0) {
							slots[0] = left ;
						} else
							slots.shift() ;

						if (eltByRank.elts[ra[index]] == null)
							ra.remove(ra[index]) ;
						if (ra.length == 0)
							break ;
					}

					res.uk.push({sk : sk, data : {id : sk.k.id, value : sk.points, l : log}}) ;

				case "random" : // 1 objet magique contre des éléments pris au hasard
					var n = new Array() ;
					for (i in ing.copy()) {
						switch(i.o) {
							case _Elt(eid) : continue ;
							case _QuestObj(id) : continue ;
							case _Empty : continue ;
							case _Stamp : continue ;
							default : 
								var info = Data.getArtefactInfo(i.o) ;
								if (info == null || !info.playable)
									continue ;

								var need = Data.getNeed(info.need, App.user.scTeam.school) ;
								if (need == null)
									need = {points : 8, school : null} ;
								for (j in 0...i.qty) {
									var rd = Std.random(100) ;
									n.push({o : i.o, 
											need : need.points,
											points : Math.round(0.75 * ( if (rd == 0)
																	Math.round(need.points * 2.2)
																else if (rd < 6)
																	Math.round(need.points * 1.8)
																else if (rd < 16)
																	Math.round(need.points * 1.10)
																else if (rd < 80)
																	need.points
																else
																	Math.round(need.points * 0.85) ) )
											}) ;
								}
								ing.remove(i) ;
						}
					}

					if (n.length == 0)
						continue ;
					
					for (obj in n) {
						if (eltByRank.total == 0)
								break ;

						var points = obj.points ;
						var count = 50 ;
						while (points > 0 && count > 0) {
							var rank = eltByRank.ranks[Std.random(eltByRank.ranks.length)] ;
							fRemove(rank, null, 1, log) ;

							var info = Data.getArtefactInfo(log[log.length - 1].o) ;
							if (info == null)
								throw "no Artefact Info for element " + Std.string(log[log.length - 1].o) ;
							
							var need = 	Data.getNeed(info.need, App.user.scTeam.school) ;

							points -= need.points ;
							count-- ;

							if (eltByRank.total == 0)
								break ;
						}
					}
					
					res.uk.push({sk : sk, data : {id : sk.k.id, value : sk.points, l : log}}) ;


				case "catz" : // 1 catz contre 1 élément de rang x (10, 11, 12)
					var r = sk.k.getValue(sk.points) - 1 ;
					if (eltByRank.elts[r] == null)
						continue ;

					var n = fGetQuantity(_Catz, 1) ;
					if (n == 0)
						continue ;

					while (n > 0) {
						if (eltByRank.total <= 0 || fRemove(r, null, 1, log) != 0)
							break ;
						n-- ;
					}

					res.uk.push({sk : sk, data : {id : sk.k.id, value : sk.points, l : log}}) ;

				case "vigor" : 
					var rMax = 8 ;
					/*if (eltByRank.elts[r] == null)
						continue ;*/

					var n = fGetQuantity(_Pa, 1) ;
					if (n == 0)
						continue ;

					n *= 2 ; 

					while (n > 0) {
						if (eltByRank.total <= 0)
							break ;
						var av = [] ; 
						for (i in 0...rMax) {
							if (eltByRank.elts[i] != null)
								av.push(i) ;
						}
						if (av.length == 0)
							break ;

 						fRemove(av[Std.random(av.length)], null, 1, log) ;
						n-- ;
					}

					res.uk.push({sk : sk, data : {id : sk.k.id, value : sk.points, l : log}}) ;

				case "hot" : 
					var limit = sk.k.getValue(sk.points) ;
					var all = [{r : 8, by : 16, to : 12},
								{r : 9, by : 17,to : 13},
								{r : 10, by : 18, to : 14},
								{r : 11, by : 19, to : 15}] ;
					var all = all.slice(0, limit - 8) ;
					var found = false ;
					for (a in all) {
						var r = a.r ;
						if (eltByRank.elts[r] == null)
							continue ;

						var n = fGetQuantity(_Elt(a.by), 1) ;
						if (n == 0)
							continue ;

						while (n > 0) {
							if (eltByRank.total <= 0 || fRemove(r, _Elt(a.to), 1, log) != 0)
								break ;
							n-- ;
							found = true ;
						}
					}

					if (found)
						res.uk.push({sk : sk, data : {id : sk.k.id, value : sk.points, l : log}}) ;
			}					
		}
	}


/*
	static public function onRewardTree(r : RewardTree) {
		if (App.user.stid == null)
			return r ;

		var sct = App.user.scTeam ;
		for (sk in sct.knowledges) {
			switch(sk.k.id) {
				case "secret" : 
					var v = sk.k.getValue(sk.points) ;
					for (i in 0...r.limits.length)
						r.limits[i] += v ;

				default : continue ;
			}
		}

		return r ;
	}
*/

	static public function onRaceEnd(sct : db.SchoolTeam) {
		if (App.user.stid == null || App.user.stid != sct.id)
			return ;

		for (sk in sct.knowledges) {
			switch(sk.k.id) {
				case "corrup" : 
					var nb = sk.k.getValue(sk.points) ;
					nb = sct.avJoker * nb ;

					if (nb > 0)
						sct.avJoker = 0 ;

					sct.wheels += nb ;
					sct.update() ;

					db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points, nb : nb}) ;

				case "secret" : 
					var v = sk.k.getValue(sk.points) ;
					var nb = Math.round(sct.wheels / v) ;

					if (nb > 0)
						sct.wheels += nb ;
					sct.update() ;

					db.SchoolTeamLog.insert(App.user, KKnowledgeProc, {id : sk.k.id, value : sk.points, nb : nb}) ;

					
				default : continue ;
			}
		}
	}


	static public function getBestRankElements(drops : Array<{o : _ArtefactId, qty : Int}>) : {rank : Int, disps : Array<_ArtefactId>} {
		var highers = {rank : -1, disps : new Array()} ;					
		for (d in drops) {
			if (d.qty <= 0)
				continue ;
			switch(d.o) {
				case _Elt(eid) : 
					var r = Data.ELEMENTS.getId(eid).rank ;

					if (r == highers.rank)
						highers.disps.push(d.o) ;
					else if (r > highers.rank) {
						highers.rank = r ;
						highers.disps = [d.o] ;
					} else 
						continue ;

				default : continue ;
			}
		}
		return highers ;
	}


}