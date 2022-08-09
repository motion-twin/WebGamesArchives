package logic;

import Common;
using Lambda;


@:native("_St") class Student {

	static public var COOLDOWN = 20 ;
	static public var BASE_SPEED = 4 ;
	static public var BASE_ENERGY = 10 ;
	static public var DEFAULT_RESIST = 0 ; // /100
	static public var DEFAULT_CRIT = 1 ; // /100

	public var id : Int ;

	public var knowledge : Int ;
	public var kMax : Int ;

	public var life : Int ;
	public var isNew : Bool ;

	public var boredom : Int ;
	public var maxBoredom : Int ;

	public var stackPoints : Int ; //dégâts à valider par une action : exercice/correction

	public var gender : Int ;
	public var firstname : String ;
	public var level : Int ;

	/*public var energy : Int ;
	public var stress : Int ;*/
	public var note : Float ;
	public var reward : Float ;
	public var success : Int ;

	public var fromUser : Null<Int> ;
	public var withGift : Null<TObject> ;

	public var fromNote : Float ;

	public var absorbs : Int ; //résistances par matière

	public var hostile : Bool ;
	public var petAction : {a : TAction, k : Bool, n : Int} ;

	public var speed : Int ; //default time between 2 actions
	public var coolDown : Int ;
	public var lastAction : SAction ;

	public var cornered : Bool ;
	public var out : Bool ;
	public var handUp : { what : HandUp_What, k : Int, hostile : Bool } ;
	public var inLoveWith : Null<Int> ;

	public var lastReward : Float ;

	public var seat : Null<Coords>;

	/*public var attention : SAttention ;
	public var attCooldown : Int ;*/
	public var states : Array<SState> ;
	
	public var touched : Bool ;

	public var ownCharacter : SChar ;
	public var characters : Array<SChar> ;
	public var avActions : Array<{act : CharAction, from : SState}> ;

	public var actionCooldown : Int ;

	public var ultimas : Array<{act : SAction, from : SState}> ;

	public var cloners : List<Int> ;
	public var speakers : List<Int> ;

	public var oneShot : Bool ;

	//public var data : Null<StudentData> ;
	
	public var solver : Null<Solver> ;

		
	public function new( d : Null<StudentData>, sv : Solver) {
		coolDown = COOLDOWN ;
		//speed = 3 ; // à changer en fonction des attributs de l'élève

		stackPoints = 0 ;
		success = 0 ;
		cornered = false ;
		out = false ;
		actionCooldown = 0 ;
		touched = false ;

		oneShot = true ;


		reward = 0 ;

		solver = sv ;

		states = new Array() ;

		cloners = new List() ;
		speakers = new List() ;

		if( d != null ) {
			//data = d ;
			id = d._i ;
			firstname = d._f ;

			life = d._lf ;

			boredom = d._sb ;
			maxBoredom = d._mb ;

			//### TO REMOVE
			knowledge = 0 ;
			kMax = life ;
			//###

			gender = d._m ;
			note = d._n ;

			hostile = d._h ;

			lastReward = d._lastReward ;
			fromUser = d._u ;

			level = d._l ;
			//stress = d._st ;
			//energy = d._e ;
			absorbs = d._r ;
			fromNote = d._fn ;
			//iq = d._iq ;

			petAction = {a : d._pet._a, k : d._pet._k, n : 0} ;
			solver.addToPetActions(petAction.a) ;

			ownCharacter = d._ch ;
			characters = [Std_0] ;
			characters.push(d._ch) ;

			/* for (ri in 0...Type.allEnums(Subject).length)
				absorbs[ri] = if (d._r == null || d._r[ri] == null) 0 else d._r[ri] ; */

			//comment = d._c;
			seat = d._p == null ? null : {
				x: d._p._x,
				y: d._p._y
			} ;


			for (s in d._ss) {
				switch(s._s) {
					case InLove :
						addState(InLove) ;
						inLoveWith = s._p ;
					case BrokenHeart :
						addState(BrokenHeart) ;
					/*case BonusPoint :
						if (s._p == Type.enumIndex(solver.subject))
							addState(BonusPoint) ;*/
					default : //nothing to do
				}
			}


			if (d._late > 0) {
				out = true ;
				solver.addStudentOut(id, d._late) ;
			}

			if (d._new > 0) {
				out = true ;
				isNew = true ;
				if (d._gift != null)
					withGift = d._gift ;
				solver.addStudentOut(id, 1, true) ;
			}

			initActions() ;
		}
	}


	public function initActions() {
		avActions = new Array() ;
		ultimas = new Array() ;

		for (c in characters) {
			var acts = Data.getCharacterActions(c) ;

			for (na in acts) {
				var found = false ;
				for (a in avActions) {
					if (!Type.enumEq(a.act.a, na.a))
						continue ;
					a.act.p = Std.int(Math.max(a.act.p, na.p)) ;
					found = true ;
					break ;
				}
				if (!found) {
					if (na.p == -1) { // ultima
						var uc = Common.getStudentActionData(na.a).ultima ;
						ultimas.push({act : na.a, from : null}) ;
					} else
						avActions.push({act : na, from : null}) ;
				}
			}
		}
	}


	public function addExtraAction(na : CharAction, from : SState) {
		for (a in avActions) {
			if (!Type.enumEq(a.act.a, na.a))
				continue ;
			return ;
		}

		if (na.p == -1) //ultima
			ultimas.push({act : na.a, from : from}) ;
		else
			avActions.push({act : na, from : from}) ;
	}


	public function removeExtraActionsFrom(st : SState) {
		for (u in ultimas.copy()) {
			if (u.from != null && Type.enumEq(u.from, st))
				ultimas.remove(u) ;
		}

		for (a in avActions.copy()) {
			if (a.from != null && Type.enumEq(a.from, st))
				avActions.remove(a) ;
		}
	}


	public function getStates() {
		return states.copy() ;
	}


	public inline function log( l : LessonLog ) {
		if( solver != null )
			solver.log(l);
	}


	public function done() : Bool {
		return success > 0 || success == -2 ;
	}


	public function active() {
		!done() && hostile ;
	}

	public function incPetAction() {
		petAction.n++ ;
	}


	public function getRandUltima() : SAction {
		if (ultimas.length == 0)
			return null ;
		return ultimas[solver.random(ultimas.length)].act ;
	}


	public function hasUltima(?s : SAction) {
		if (s == null)
			return ultimas.length > 0 ;

		for (u in ultimas) {
			if (Type.enumEq(u.act, s))
				return true ;
		}
		return false ;
	}


	public function setHandUp(act : SAction, ?forceHostile = false) {
		if (handUp != null)
			throw SE_Fatal("already hand up") ;

		//to do better with states and characters
		var know = 0 ;

		var what = switch(act) {
			case HandUpOut : HW_Out(2 + solver.random(3)) ;

			case HandUpQuestion :
				var choices = [	0, 0, 0, 0, 0, 0,	//only hits
								1, 1,				//1 bonus state
								2,					//2 bonus state
								3] ;				//free clean

				var n = 2 + solver.random(4) ;
				know = solver.teacher.getKnowledge(What, false, n).value ;

				var delta = (solver.teacher.hasComp(Speaker)) ? -1 : 0 ;

				var l = new Array() ;
				l.push({life : Std.int(Math.max(1, n + delta)), give : QR_Hit(know)}) ;

				var divLife  = Std.int(Math.max(1, Math.round( n / 2 + delta))) ;
				if (divLife != l[0].life)
					l.unshift({life : divLife, give : QR_Hit( Std.int(Math.round( know / 2 )) )}) ;

				var choice = choices[solver.random(choices.length)] ;

				switch(choice) {
					case 0 : //nothing to do

					case 1, 2 :
						var avStates : Array<{s : SState, weight : Int}> =
									[	{ s : Illumination, weight : 8},
										{s : Attentive, weight : 15},
										{s : Doughy, weight : 8},
										{s : VeryAttentive, weight : 1}] ;
						if (isHostile()) {
							avStates.push({s : Harmless, weight : 3}) ;
							avStates.push({s : Headache, weight : 3}) ;
						}

						var lc = l.copy() ;
						for (i in 0...choice) {

							if (avStates.length == 0 || lc.length == 0)
								break ;

							var stw = solver.randomWeight(cast avStates) ;
							avStates.remove(stw) ;
							var c = lc[solver.random(lc.length)] ;
							c.give = QR_State(stw.s) ;
							lc.remove(c) ;
						}

					case 3 :
						l[solver.random(l.length)].give = QR_Clean ;
				}

				if (solver.random(4) == 0)
					l.unshift({life : 0, give: QR_Heal(2 + solver.random(3))}) ;
					
				l.unshift({life : 0, give: QR_Hit(0)}) ;
				
				HW_Question(l) ;

			/*case BadQuestion :
				var min = Std.int(Math.min(solver.teacher.pa - 1, 2 + solver.random(3))) ;
				var max = min + solver.random(5) ;

				know = solver.teacher.getKnowledge(What, false, max).value ;
				HW_HellQuestion(min, max, 0, know) ;*/

			case HandUpCheat : HW_Cheat(null) ;

			case HandUpHeal : HW_Heal(null) ;

			case HandUpNote : HW_Note ;

			default : //invalid

		}

		handUp = {what : what,
				k : know,
				hostile : forceHostile} ;

		log(L_HandUpStart(id, what)) ;
	}


	public function getWhat() : HandUp_What {
		if (handUp == null)
			return null ;
		
		return handUp.what ;
	}


	public function removeHandUp(success : Bool) {
		if (handUp == null)
			throw SE_Fatal("cant remove missing hand up") ;

		solver.removeHandUpEvent(id) ;

		log(L_HandUpEnd(id)) ;

		if (!success) {
			if (handUp.hostile)
				setHostile(true) ;

			//switch(solver.random(4)) {
			switch(solver.random(1)) {
				case 0 : addState(Rage) ;
				case 1 : addState(Angry) ;
				case 2 : addState(Sulk) ;
				case 3 : addBoredom(2) ;
			}
		}
		handUp = null ;
	}


	public function getKnowledgeHit(act : SActionData, ?param : Int) : Int {
		//var tLevel = solver.teacher.level ;
		var res = 0 ;

		switch(act.id) {

			case HandUpCheat : //knowledge on other student
				res = -1 - solver.random(2) ;

			case Trigger_Sulk :
				res = -1 ;

			case Atk_Ph_5, HelpMePlease : //punaise
				return switch(act.level) {
							case 0 : -1 ;
							case 1 : -1 ;
							case 2 : -2 ;
							case 3 : -2 ;
							case 4 : -3 ;
						}

			case Atk_Ps_6 : return -1 ;

			case Trigger_Done :

				/*	### DEPRECATED
				var mult = 1.0 + param * 0.8 ;
				var base =  6 + solver.random(2) ;
				return Std.int(Math.round( base * mult )) ;*/

			default : return 0 ;
		}

		return res ;
		/*var tLevel = solver.teacher.level ;
		return Std.int(Math.round(res * (1.0 + tLevel * Data.S_DIFF_LEVEL))) ;*/
	}


	public function getDamages(act : SActionData, ?param : Int) : Damages {
		var res = {value : 10000, crit : logic.Teacher.DEFAULT_CRIT, resist : solver.teacher.getResist(), type : Classic} ;

		var tLevel = solver.teacher.level ;
		var useDiffLevel = true ;
		var useBonus = true ;

		try {

		switch(act.id) {
			case Add_BoringGenerator : res.value = 2 ; useDiffLevel = false ;
			case Event_Chewing : res.value = 1 ; useDiffLevel = false ;
			case Event_Lol : res.value = 1 ; useDiffLevel = false ;
			case Event_Tictic : res.value = 1 ; useDiffLevel = false ;
			case Event_Singing : res.value = 1 ; useDiffLevel = false ;
			case Event_Voodoo : res.value = 2 ; useDiffLevel = false ;

			case Trigger_Bomb : res.value = 1 ; useDiffLevel = false ; useBonus = false ;
			case Trigger_BombExplode : res.value = 2 ; useDiffLevel = false ; useBonus = false ;

			case Trigger_BadBehaviour :
				res.value = Std.int(Math.max(1, param)) ;
				useDiffLevel = false ;

			case Atk_N_0, Atk_N_1, Atk_N_2, Atk_N_3, Atk_N_4, Atk_N_5, Atk_N_6, Atk_N_7, Atk_N_8, Atk_N_9,
				Atk_Ph_0, Atk_Ph_1, Atk_Ph_2, Atk_Ph_3, Atk_Ph_4, Atk_Ph_5, Atk_Ph_6, Atk_Ph_7, Atk_Ph_8,
				Atk_Ps_0, Atk_Ps_1, Atk_Ps_2, Atk_Ps_3, Atk_Ps_4, Atk_Ps_6, Atk_Ps_7, Atk_Ph_9, Concert, NeighbourLaunch, Tornado, SlowOthers, SelfKO, Prout, LaughingGas, FallInLove, Dizzy, Calumny, BrokeHeart, Atk_Asleep, Dining, RageAtk :
				//attaques standards


				//var level = Std.int(Math.min(solver.teacher.level + 1, act.level)) ;
				var level = act.level ;

				res.value = switch(level) {
								case 0 : 1 ;
								case 1 : 2 ;
								case 2 : 3 ;
								case 3 : 4 ;
								case 4 : 5 ;
							}

			case Add_Invisibility, Add_Inverted, Add_Lol, Add_Asleep, Add_Chewing, Add_Slow, Add_Moon, Add_Angry, Add_Clone, Add_BadBehaviour, Give_Invisibility, Give_KO, Give_Chewing, Give_Asleep, Give_Lol, Give_Slow, Give_Moon, Add_Boredom, Add_BigBoredom, Give_Speak, LaunchThing :
				//small dot
					 res.value = switch(act.level) {
									case 0 : 0 ;
									case 1 : 1 ;
									default : 1 ;
								}

					


			case Trigger_Shy, Trigger_Sulk, Morpheus, AttackTwice, BadQuestion, HelpMePlease, CopyChar, HandUpOut, HandUpQuestion, HandUpCheat, HandUpHeal, HandUpNote, Atk_Ps_5, Trigger_Done, Add_Tictic, Add_Singing, Add_Voodoo :
					res.value = 0 ;

			case Trigger_Genius :
				res.value = 1 ;
		}


		} catch(e : Dynamic) {
			throw e + " # " + firstname + " # " + Std.string(act) ;
		}


		if (useDiffLevel)
			res.value = Std.int(Math.round(res.value * (1.0 + (tLevel - 1) * Data.S_DIFF_LEVEL))) ;
	
		if (useBonus) {
			//angry bonus
			if (hasState(Angry)) {
				res.value++ ;
				res.crit += 3 ;
			}

			if (hasState(Doughy))
				res.value = Std.int(Math.max(0, res.value - 1)) ;

			if (hasState(Harmless))
				res.value = 0 ;
		}

		return res ;
	}


	public function dropItem() : InvObject {
		var allColl = new Array() ;
		for (ci in Common.getAllCItems()) {
			if (ci.rare > 3)
				continue ;
			if (ci.worldMod != null && Solver.me.worldMod != ci.worldMod)
				continue ;

			allColl.push({i : IvItem(ci.id), weight : logic.Data.COLL_WEIGHT[ci.rare] * ((ci.worldMod != null && Solver.me.worldMod == ci.worldMod) ? 3 : 1) }) ;
		}

		return solver.randomWeight(cast allColl).i ;
	}


	public function copyChar(target : Student) {
			removeState(Copy) ;

		var avChars = target.characters.copy() ;
		for (c in characters)
			avChars.remove(c) ;

		if (avChars.length == 0)
			return false ;

		addState(Copy) ;
		var c = avChars[solver.random(avChars.length)] ;

		var actions = Data.getCharacterActions(c) ;
		if (actions != null) {
			for (a in actions)
				addExtraAction(a, Copy) ;
		}

		return true ;
	}


	public function touch() {
		if (touched == true)
			return ;
		touched = true ;
		solver.touchTargets.add(AT_Std(id)) ;
	}


	public function addSpeaker(s : Student) {
		speakers.push(s.id) ;
	}


	public function removeSpeaker(s) {
		speakers.remove(s.id) ;
		if (speakers.length > 0)
			return ;

		removeState(Speak) ;
	}


	public function addState(st : SState, ?check = false) {
		if (hasState(st)) {
			if (check)
				throw SE_Fatal("cant add " + Std.string(st)) ;
			else
				return ;
		}

		//pre push
		switch(st) {
			case Lol :
				if (hasCharacter(NoLaugh)) {
					log(L_StudentResist(id)) ;
					return ;
				}

			default : //nothing to do
		}

		states.push(st) ;
		log(L_AddState(id, st)) ;

		//post push
		switch(st) {

			case Asleep :
				var toRemove = [Lol, Speak, Chewing, TicTic, Singing, Voodoo, BoringGenerator] ;
					for (tr in toRemove) {
						if (hasState(tr))
							removeState(tr) ;
					}

				if (handUp != null)
					removeHandUp(true) ;

			case KO :
				var toRemove = [Lol, Speak, Chewing, TicTic, Singing, Voodoo, BoringGenerator] ;
					for (tr in toRemove) {
						if (hasState(tr))
							removeState(tr) ;
					}

				if (handUp != null)
					removeHandUp(true) ;

			case Book :
				var toRemove = [Lol, Speak, TicTic, Singing, Voodoo, BoringGenerator, Slowed] ;
					for (tr in toRemove) {
						if (hasState(tr))
							removeState(tr) ;
					}

				if (handUp != null)
					removeHandUp(true) ;


			default : //nothing to do
		}

		var extra = Data.getExtraActions(st) ;
		if (extra != null) {
			for (e in extra)
				addExtraAction(e, st) ;
		}

		switch(st) {
			case Tetanised,
				Lol,
				Chewing,
				Invisibility,
				Clone,
				Angry,
				Speak,
				Harmless,
				TicTic,
				Singing,
				Voodoo,
				KO,
				Headache,
				Book,
				BadBehaviour,
				BoringGenerator,
				Inverted,
				Bomb3,Bomb2,Bomb1,
				LifeTransfer,
				Rage,
				BrokenHeart : solver.addEventState(id, st) ;

			default : //nothing to do
		}
		
	}


	public function removeState(st : SState, ?check = false) {
		if (!hasState(st)) {
			if (check)
				throw SE_Fatal("cant remove " + Std.string(st)) ;
			else
				return ;
		}
		states.remove(st) ;
		log(L_RemoveState(id, st)) ;

		removeExtraActionsFrom(st) ;

		switch(st) {
			case Clone :
				for (s in solver.students)
					s.removeCloner(this) ;

			case InLove :
				inLoveWith = null ;

			case Speak :
				for (s in speakers)
					solver.getStudent(s).removeSpeaker(this) ;
				speakers = new List() ;

			default : //nothing to do
		}

		solver.removeEventState(id, st) ;
	}


	public function cleanState(n = 1, ?critical = false ) { //remove n negative states
		//var t = {st : [], probs : []} ;
		var done = false ;

		var minValue = [0] ;
		if (critical)
			minValue.unshift(-1) ;

		for (mv in minValue) {
			while (n > 0 && states.length > 0) {
				var st : SState = null ;
				for (i in 0...states.length) {
					st = states[states.length - 1 - i] ;
					var stData = Common.getStateData(st) ;

					if (stData.cleanable != mv) {
						st = null ;
						continue ;
					}

					break ; //found
				}

				if (st != null) {
					if (Type.enumEq(st, InLove)) {
						if (inLoveWith != null) {
							var other = solver.getStudent(inLoveWith) ;
							other.removeState(InLove) ;
							other.addState(BrokenHeart) ;
						}
					}

					removeState(st) ;
					done = true ;
					n-- ;
				} else
					break ;
			}
		}

		return done ;
	}



	public function hasState(st : SState) {
		for (s in getStates()) {
			if (Type.enumEq(s, st))
				return true ;
		}
		return false ;
	}


	public function studentHit(v : Int, action : SAction, by : Student) {
		

		for (st in states.copy()) {
			switch(st) {
				case Slowed :
					v = Std.int(Math.max(0, v - 1)) ;

				case Inverted :
					v *= -1 ;

				default : continue ; //nothing to do
			}
		}

		var hits = 0 ;
		if (v > 0) {
			hits = removeBoredom(v) ;
			if (hits > 0)
				life = Std.int(Math.max(0, life - hits)) ;
		} else {
			life -= v ;
			hits = v ;
		}

		var done : Null<Float> = checkNote() ;

		log(L_StudentHit(id, hits, 0, null, action, by.id, done)) ;
		if (done != null) {
			log(L_XP(id, 1)) ;
			if (hostile) {
				solver.setNewHostile(id) ;
				setHostile(false) ;
			}
		}


		/*if (done != null)
			applySuccess(done) ;*/
		
	}
	

	public function hit(d : Damages, ?noResist = false) {
		if (done())
			return 0 ;

		var infos = modTeach(d) ;
		var type : HitType = null ;

		var r = solver.random(100) ;
		if (infos.value > 0  && r >= 100 - infos.crit) {
			infos.value = Std.int(infos.value * 2.0) ;
			type = Critic ;
			if (solver.hasHelper(Dog) && solver.getHelperLine() == seat.y)
				log(L_TriggerHelper(Dog, [this.id])) ;

		} else if (r < infos.resist && !noResist) {
			infos.value = 0 ;
			type = Resist ;
		}


		var hits = 0;
		var realRemove = 0 ;
		if (infos.value > 0) {
			if (Type.enumEq(d.type, DoubleOnBoredom))
				infos.value *= 2 ;

			if (Type.enumEq(d.type, ThroughBoredom))
				hits = infos.value ;
			else
				hits = removeBoredom(infos.value) ;

			realRemove = infos.value - hits ;

			if (Type.enumEq(d.type, DoubleOnBoredom))
				hits = Std.int(Math.floor(hits / 2)) ;

			if (Type.enumEq(d.type, DoubleOnLife))
				hits *= 2 ;

			if (hits > 0) {
				realRemove += Std.int(Math.min(life, hits)) ;
				life = Std.int(Math.max(0, life - hits)) ;
			}
		} else {
			life -= infos.value ;
			hits = infos.value ;
		}

		if (hasState(Headache))
			removeState(Headache) ;


		var wasBadBehaviour = hasState(BadBehaviour) ;
		
		var done : Null<Float> = checkNote() ;

		log(L_StudentHit(id, hits, 0, type, null, null, done)) ;
		if (done != null) {
			log(L_XP(id, 1)) ;
			if (hostile) {
				solver.setNewHostile(id) ;
				setHostile(false) ;
			}
		}
		/*if (done != null)
			applySuccess(done) ;*/

		if (wasBadBehaviour && realRemove > 0) {
			log(L_StudentTrigger(id, Trigger_BadBehaviour)) ;
			var sData = Common.getStudentActionData(Trigger_BadBehaviour) ;
			var d = getDamages(sData, Std.int(Math.abs(realRemove))) ;
			solver.teacher.hit(sData, d, this) ;
		}

		return infos.value ;
	}


	public function isPet() : Bool {
		return solver.curPet != null && solver.curPet.s.id == this.id ;
	}


	public function clean(?n = 1, ?critical = false) {
		resetCooldown() ;

		var res = false ;

		if (n > 0)
			res = cleanState(n, critical) ;

		return res ;
	}


	function checkNote() : Null<Float> {
		if (life > 0) {
			oneShot = false ;
			return null ;
		}
		if (done()) //wtf ?
			return null ;

		solver.turnKills.push(id) ;

		success++ ;

		reward = solver.getNoteRewards(this) ;

		if (hasState(BonusPoint)) {
			removeState(BonusPoint) ;
			reward++ ;
		}
		if (hasState(HandUpBonusPoint)) {
			removeState(HandUpBonusPoint) ;
			reward++ ;
		}
		if (solver.isSupervisorSeat(seat)) {
			log(L_TriggerHelper(Supervisor, [this.id])) ;
			reward++ ;
		}

		if (solver.hasHelper(Inspector) && solver.getHelperLine() == seat.y) {
			log(L_TriggerHelper(Inspector, [this.id])) ;
			reward += 0.5 ;
		}

		if (solver.curPet != null && solver.curPet.s == this)
			solver.unsetPet() ;

		note = Math.min(note + reward, 20) ;

		//clean
		if (handUp != null)
			removeHandUp(true) ;
		clean(20, true) ;
		cleanPositive() ;

		if (hasState(Clone))
			removeState(Clone) ;

		return note ;
	}


	public function setHostile(h : Bool, ?from : Int) {
		if (hostile == h)
			return ;
		hostile = h ;
		log( L_SetHostile(id, hostile, from) ) ;
	}


	static public function getNextLifeBar(note : Float, fromNote : Float, iq : Int, level : Int, chars : Array<SChar>) : Int {
		var next = Std.int(Math.max(0, note - fromNote)) ;
		var from = fromNote ;

		var base = [2, 2, 3, 3, 4, 4, 5] ;
		var res = base[iq + 3] ;
		var more = Math.floor(next / 3) ;
		
		res += more ;

		var modKnow = 0 ;
		for (c in chars)
			modKnow += Common.getCharacterData(c).modKnow ;
		if (modKnow != 0)
			res = Std.int(Math.max(1, res + modKnow)) ;

		return Std.int(Math.max(1, res)) ;

	}


	public function getTableNeighbours(?avDone = false) : List<Student> {
		var res = new List() ;

		for (side in [-1, 1]) {
			var sx  = seat.x + side ;
			while (Lambda.exists(solver.seats, function(e) { return e.y == seat.y && e.x == sx ; } )) {

				var std = solver.getStudentByPos({x : sx, y : seat.y}) ;
				if (std != null && std.canBeTargeted() && (avDone || !std.done()))
					res.push(std) ;

				sx += side ;
			}

		}

		return res ;
	}


	public function getNeighbours(?avDone = false) : List<Student> {
		return Lambda.filter(solver.studentNear(this, 3), function(n) { return n.seat.y == this.seat.y && n.canBeTargeted() && (avDone || !n.done()) ;}) ;
	}


	public function unStack(deltaDay : Int) : Damages {
		var res = {value : 0,
					resist : 0,
					crit : solver.teacher.getCritic(),
					type : Classic
				} ;

		var d = Std.int(Math.round(Math.max(1, 5 - deltaDay))) ;
		res.value = Std.int(Math.round(2 * stackPoints * d / 5)) ;
		stackPoints = 0 ;

		return res ;
	}
	

	public function resetStack() {
		stackPoints = 0 ;
	}


	public function clonedBy(s : logic.Student) {
		cloners.add(s.id) ;
	}


	public function removeCloner(s : logic.Student) {
		cloners.remove(s.id) ;
	}


	public function getAction(?forceAction : SAction) : {a : SAction, targets : Array<Int>}  {
		var res =  {a : null, targets : null} ;

		if (forceAction == null) {
			if (res.a == null) {
				var avAct = avActions.copy() ;
				if (!isHostile()) {
					avAct = [] ;
					for (a in avActions) {
						switch(a.act.a) {
							case 	HandUpCheat,
									HandUpQuestion,
									HandUpOut,
									HandUpHeal,
									HandUpNote,
									Add_Boredom : avAct.push(a) ;
							default : //nothing to do
						}
					}
				}

				while(res.a == null && avAct.length > 0) {
					var probs = new Array() ;
					for (i in 0...avAct.length) {
						var act = avAct[i] ;
						var p = Type.enumEq(act.act.a, lastAction) ? Std.int(Math.round(act.act.p / 2)) : act.act.p ;

						var aData = Common.getStudentActionData(act.act.a) ;
						if (aData.cooldown == null || actionCooldown == 0)
							probs.push({idx : i, weight : p}) ;
					}

					if (probs.length == 0)
						return res ; //fail

					var idx = solver.randomWeight(cast probs).idx ;

					res.a = avAct[idx].act.a ;

					if (canLaunchAction(res.a))
						break ;
					else {
						avAct.remove(avAct[idx]) ;
						res.a = null ;
					}
	
				}
			}

		} else {
			if (canLaunchAction(forceAction))
				res.a = forceAction ;
		}
		

	#if debug
		if (solver.debugActions != null && solver.debugActions.length > 0) {
			res.a = solver.debugActions[0].act ;
			solver.debugActions[0].n-- ;

			if (solver.debugActions[0].n <= 0)
				solver.debugActions.shift() ;
		}
	#end

		if (res.a == null)
			return res ; //fail


		lastAction = res.a ;
		var data = Common.getStudentActionData(res.a) ;
		if (data.cooldown != null)
			actionCooldown = data.cooldown ;

		//choose targets
		var avTargets = null ;
		switch(res.a) {
			case Atk_N_6, Atk_Ph_5, Give_KO, Give_Asleep, Give_Slow, SelfKO : //random student available
				avTargets = solver.studentNear(this, 10, function(x : Student) { return x.isAvailable() ; } ) ;

			case Calumny : //random student available and not hostile
				avTargets = solver.studentNear(this, 10, function(x : Student) { return x.isAvailable() && !x.hostile ; } ) ;

			case Add_Invisibility, Add_Inverted, Add_Lol, Add_Asleep, Add_Chewing, Add_Slow, Add_Angry, Add_BadBehaviour, Add_Boredom, Add_BigBoredom, Add_Moon, Add_Tictic, Add_Voodoo, Add_Singing, Add_BoringGenerator :
				//self target
				avTargets = [this] ;

			case Give_Invisibility, LaughingGas : //random stud
				avTargets = solver.studentNear(this, 10) ;

			case CopyChar, Give_Chewing, Give_Lol, Give_Moon, Add_Clone : //1 voisin ou proche available
				for (i in 1...6) {
					avTargets = solver.studentNear(this, i, function(x : Student) { return x.isAvailable() ; } ) ;
					if (avTargets.length > 0)
						break ;
				}

			case FallInLove : //1 voisin ou proche available du sexe opposé
				for (i in 1...6) {
					avTargets = solver.studentNear(this, i, function(x : Student) { return x.isAvailable(true) && x.gender != this.gender ; } ) ;
					if (avTargets.length > 0)
						break ;
				}

			case LaunchThing : //1 voisin ou proche available la plupart du temps ( 2/3 ), ou 1 random available
				if (solver.random(3) == 0) { //random available
					avTargets = solver.studentNear(this, 10, function(x : Student) { return x.isAvailable(true) ; } ) ;
				} else {
					for (i in 1...6) {
						avTargets = solver.studentNear(this, i, function(x : Student) { return x.isAvailable(true) ; } ) ;
						if (avTargets.length > 0)
							break ;
					}
				}

			case Give_Speak, HelpMePlease : //voisin strict available ou fail
				avTargets = solver.studentNear(this, 1, function(x : Student) { return x.isAvailable() ; } ) ;

			case NeighbourLaunch : //voisin strict
				avTargets = solver.studentNear(this, 1) ;

			case BrokeHeart : //lover needed
				/*var lovedBy = Lambda.array(solver.students.filter(function(x) { return x.inLoveWith == this.id ; } )) ;

				avTargets = lovedBy.length > 0 ? [lovedBy[solver.random(lovedBy.length)]] : [] ;*/

				avTargets = (inLoveWith != null) ?[solver.getStudent(inLoveWith)] : [] ;

			default : //nothing to do for others actions
		}

		if (avTargets != null) {
			if (avTargets.length == 0)
				res.a = null ; //fail
			else {
				var t = null ;
				while(avTargets.length > 0) {
					t = avTargets[solver.random(avTargets.length)] ;
					avTargets.remove(t) ;

					if ( /*!t.hasState(Locked) &&*/ Data.actionCond(res.a)(t))
						break ; //found
					else
						t = null ;
				}

				if (t == null)
					res.a = null ; //fail
				else
					res.targets = [t.id] ;
			}
		}
		
		return res ;
	}


	public function isInverted() {
		return hasState(Inverted) ;
	}


	public function hasCharacter(ch : SChar) : Bool {
		for (c in characters) {
			if (Type.enumEq(c, ch))
				return true ;
		}
		return false ;
	}


	public function untouch() {
		touched = false ;
	}

	public function updateBoredom() {
		var stun = touched ;
		touched = false ;

		if (!isAvailable() || stun)
			return ;
				
		if (boredom >= maxBoredom)
			return ;

		var value = 0 ;
		if (hasState(Moon))
			value++ ;
		if (hasState(Sulk))
			value++ ;

		if (hasState(InLove) && !solver.isNear(this, solver.getStudent(inLoveWith)))
			value++ ;

		if (value > 0)
			addBoredom(value, true) ;

		/*if (boredom == maxBoredom)
			cleanPositive() ;*/
	}


	public function addBoredom(?n = 1, ?update = false) {
		var old = boredom ;
		boredom  = Std.int(Math.min(boredom + n, maxBoredom)) ;

		log(L_SetBoredom(id, boredom, update)) ;
		return boredom - old ;
	}



	public function cleanPositive() {
		for (s in states.copy()) {
			if (Common.getStateData(s).cleanable > 0)
				removeState(s) ;
		}
	}


	public function hasCleanableStates() : Bool {
		for (s in states.copy()) {
			if (Common.getStateData(s).cleanable == 0)
				return true ;
				
		}
		return false ;
	}


	public function removeBoredom(n : Int) : Int {

		var left = (n > boredom) ? n - boredom : 0 ;

		boredom -= n - left ;

		log(L_SetBoredom(id, boredom, false)) ;

		return left ;
	}

	public function hasMaxBoredom() : Bool {
		return boredom >= maxBoredom ;
	}


	public function modTeach(d : Damages) : {value : Int, crit : Int, resist : Int, absorb : Bool} {
		var res = {value : d.value, crit : d.crit, resist : d.resist, absorb : false } ;

		if (done())
			return {value : res.value, crit : 0, resist : 200, absorb : false} ;
			
		if (solver.hasHelper(Dog) && solver.getHelperLine() == seat.y)
			res.crit += 20 ;			

		for (st in states.copy()) {
			switch(st) {
				case BrokenHeart : //malus
					res.resist += 80 ;

				case InLove :
					if (solver.isNear(this, solver.getStudent(inLoveWith)))
						res.resist += 200 ;

				case Slowed :
					res.value = Std.int(Math.max(0, res.value - 1)) ;

				case Speak :
					res.resist += 30 ;

				case Illumination :
					res.crit = 200 ;
					res.resist = 0 ;
					removeState(Illumination) ;

				case Inverted :
					res.value *= -1 ;

				case Attentive :
					if (d.value > 0) {
						res.value++ ;
						removeState(Attentive) ;
					}

				case VeryAttentive :
					if (d.value > 0) {
						res.value += 2 ;
						removeState(VeryAttentive) ;
					}

				default : continue ; //nothing to do
			}
		}


		return res ;

	}



	public function newTurn(?forceCooldown = false) {
		if (done() /*|| !hostile*/ )
			return ;

		if (!isAvailable(true))
			return ;

		coolDown = Std.int(Math.max(0, coolDown - getSpeed())) ;
	}


	function getSpeed() {
		var sp = 1 + solver.random(2) ;

		if (isHostile() && !done())
			sp += BASE_SPEED ;

		if (hasState(SpeedUp))
			sp += BASE_SPEED ;

		if (hasState(Slowed))
			sp = Std.int(sp / 2) ;

		return sp ;

	}


	public function isHostile() : Bool {
		return hostile || hasState(Angry) ;
	}


	public function hasNegativeState() : Bool {
		for (s in states) {
			var sd = Common.getStateData(s) ;
			if (sd.cleanable <= 0)
				return true ;
		}
		return false ;
	}


	public function resetCooldown() {
		coolDown = COOLDOWN ;
	}


	public function canPlay() {
		if (out || cornered)
			return false ;

		if (handUp != null)
			return false ;

		for (s in states) {
			if (Lambda.exists([Tetanised, KO, Headache], function(x) { return Type.enumEq(x, s) ; }))
				return false ;
		}
		
		return true ;
	}


	public function endLesson( rseed : mt.Rand ){
		/*if( activity == SA_Out )
			focus = 0;
		var d = 0;
		if( solver.random(100) < focus ){
			d = 1;
			switch( solver.subject ){
				case S_Math: skMath += d;
				case S_NativeLang: skNlang += d;
				case S_ForeignLang: skFlang += d;
				case S_Science: skScience += d;
				case S_History: skHistory += d;
			}
		}
		return d;*/
	}


	function listNear( d = 1 ){
		return solver.studentNear(this, d) ;
	}


	function talkingNear(){
		/*for( s in listNear(4) )
			if( s.curAction == SA_Talking )
				return true;*/
		return false;
	}


	public function getCoordIndexes() : {l : Int, c : Int} {
		var res = {l : 0, c : 0} ;

		for (i in 0...solver.lines.length) {
			if (solver.lines[i] == seat.y) {
				res.l = i ;
				break ;
			}
		}

		for (i in 0...solver.columns.length) {
			if (solver.columns[i] == seat.x) {
				res.c = i ;
				break ;
			}
		}

		return res ;
	}


	function teacherNear(){
		var t = solver.teacher ;
		return solver.isNear(this,this,4) ;
	}


	public function isSeat() {
	
		return !out && !cornered ;
	}


	public function isOut() {
		return out ;
	}


	public function exclude() {
		if (hasState(Speak))
			removeState(Speak) ;
		success = -2 ;
		clean(20, true) ;
		out = true ;
		solver.addStudentOut(id, -1) ;
		solver.log(L_StudentGoOut(id)) ;
	}


	public function canBeTargeted(?invOk = false) : Bool {
		if (isStanding())
			return false ;
		if (invOk)
			return true ;
		return !Lambda.exists(states, function(x) { return Type.enumEq(Invisibility, x) ; } ) ;
	}


	public function isStanding() : Bool {
		return out || cornered ;
	}


	public function isAvailable(?handUpOk = false, ?doneOk = false) {
		if (!doneOk && done())
			return false ;

		if (out || cornered)
			return false ;

		if (handUp != null && !handUpOk)
			return false ;

		for (s in states) {
			if (Lambda.exists(Data.UNAVAILABILITY_STATES, function(x) { return Type.enumEq(x, s) ; }))
				return false ;
		}
		return true ;
	}


	public function canDoTest() : Bool {
		return isAvailable(true, true) ;
	}


	public function setLover(s : Student) {
		removeState(BrokenHeart) ;

		inLoveWith = s.id ;
		addState(InLove) ;
	}


	public function comeIn() {

		if (!out)
			return ;

		out = false ;
		if (isNew) {
			isNew = false ;
			log(L_StudentGoBack(id, true, withGift)) ;
			if (withGift != null && !solver.initAction)
				solver.teacher.receiveGift(withGift, fromUser) ;

		} else
			log(L_StudentGoBack(id, false, null)) ;

		for (e in solver.getEvents()) {
			switch(e) {
				case Ev_StudentOut(sid, bonus, time) :
					if (sid != id)
						continue ;
					if (bonus)
						addState(Attentive) ;
					solver.removeEvent(e) ;
					break ;
				case Ev_StudentNew(sid, time) :
					if (sid != id)
						continue ;
					solver.removeEvent(e) ;
					break ;

				default : //nothing to do
			}
		}
		
	}


	public function cornerBack() {
		if (!cornered)
			return ;

		cornered = false ;
		log(L_CornerEnd(id)) ;

		for (e in solver.getEvents()) {
			switch(e) {
				case Ev_Corner(sid, time) :
					if (sid != id)
						continue ;
					solver.removeEvent(e) ;
					break ;

				default : //nothing to do
			}
		}
	}


	public function setKO() {
		if (hasState(KO))
			return ;
		addState(KO) ;

		for (s in [Asleep, Lol, Tetanised, Speak])
			removeState(s) ;
	}


	public function canLaunchAction(a : SAction) {
		if (hasState(Headache))
			return false ;

		switch(a) {
			case Morpheus, Atk_Asleep, Give_Asleep : return hasState(Asleep) ;

			case FallInLove : return inLoveWith == null && isAvailable(true) && !solver.hasLovers() ;

			case SelfKO : return solver.curPet != null && solver.curPet.s != this && isAvailable(true) ;

			case HandUpNote : return isAvailable(true) && !hasState(HandUpBonusPoint) ;

			case Add_Invisibility, Add_Asleep, HandUpOut, Dizzy :
				return solver.countAvStudents() > 1 && isAvailable(true) ;

			default : return isAvailable(true) ;
		}
	}


	//
	public function toString(){
		return "Student#"+id+" ("+firstname+")";
	}

}

