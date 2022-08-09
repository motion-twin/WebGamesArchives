package logic;
import Common;


typedef TeachAction = {
	var data : TActionData ;
	var cooldown : Int ;
}


class Teacher {

	static public var DEFAULT_RESIST = 2 ; // /100
	static public var DEFAULT_CRIT = 1 ; // /100

	public var yearSeed : Int ;
	public var level : Int ;
	public var day : Int ;
	
	public var maxSelfControl : Int ;
	public var selfControl : Int ;
	public var maxPa : Int ;
	public var pa : Int ;

	public var prepared : Int ;
	public var isPrepared : Bool ;
	public var bonusRewards : Int ;
	public var curBonusReward : Int ;
	
	public var tests : Array<{avg : Float, score : Int }> ;

	public var comps : Array<TComp> ;
	public var items : Array<CoordsData> ;
	public var gold : Int ;
	public var hasPaid : Bool ;
	//public var timetable : Timetable ;

	public var pos : Coords ;

	public var lastAction : TAction ;
	public var extraTime : Int ;

	//public var leftLastTurns : Int ;
	public var superAttack : Array<Int> ;
	public var superAttackDone : Bool ;

	public var actions : Array<TeachAction> ;

	//### DEV TEST
	public var avActions : Array<{a : TAction, c : Int}> ;
	public var selectedActions : Array<TAction> ;
	//####

	/*public var stance : Int ;
	public var stanceBonus : Bool ;*/

	public var objects : IntHash<{stock : Int, used : Int}> ;
	public var collection : IntHash<Int> ;
	public var lootList : Array<TObject> ;

	public var avHelpers : Null<{cur : Array<Helper>, av : Array<Helper>}> ;

	// Solver only
	public var solver : Solver ;
	

	public function new( d : TeacherData, sv : Solver, g : Int, hp : Bool) {
		maxSelfControl = d._ms ;
		maxPa = d._mp ;

		yearSeed = d._ys ;

		extraTime = 0 ;
		superAttack = [0, 0] ;
		superAttackDone = false ;

		gold = g ;
		hasPaid = hp ;
		selfControl = d._s ;
		pa = d._p ;
		level = d._l ;
		//leftLastTurns = d._llt ;
		isPrepared = false ;

		solver = sv ;

		tests = new Array() ;
		lootList = new Array() ;

		if (d._avHelpers != null)
			avHelpers = {cur : d._avHelpers._cur, av : d._avHelpers._av } ;
		
		prepared = 0 ;
		if (d._pp != null) {
			prepared = d._pp ;
			
			if (solver.isLesson()) {
				isPrepared = d._pp > 0 ;
				prepared = 0 ;
			}
		}

		curBonusReward = 0 ;
		bonusRewards = 0 ;

		/*bonusRewards = 0 ;
		if (d._br != null) {
			bonusRewards = d._br ;
			
			if (solver.isLesson()) {
				curBonusReward = d._br ;
				bonusRewards = 0 ;
			}
		}*/


		avActions = [] ;
		selectedActions = [] ;

		collection = new IntHash() ;

		actions = new Array() ;
		for (aid in d._act) {
			var act = Common.getTActionData(aid) ;
			actions.push({data : act, cooldown : 0}) ;
		}



		objects = new IntHash() ;
		for (o in d._o)
			objects.set(Type.enumIndex(o._o), {stock : o._n, used : 0}) ;
		
		items = d._i.copy() ;
		comps = d._cps.copy() ;
		//timetable = d._t ;
	}


	public function getAllActions() {
		var acts = actions.copy() ;
		if (solver.stockAction != null)
			acts.push({data : Common.getTActionData(solver.stockAction), cooldown : 0}) ;
			return acts ;
	}


	public function getSlotNumbers() : Int {
		var res = 3 ; //2 si pas payeur

		for (c in [More_Slot_0, More_Slot_1]) {
			if (hasComp(c))
				res++ ;
		}

		return res ;
	}


	public function initTurnActions(?refresh = false, ?onlyIndexes : Array<Int>, moreSlots = false) {
		var acts = getAllActions() ;

		var typeActions = {base : 0, supers : 0, wBase : 4, wSuper : 4} ;
		for (a in acts) {
			if (a.data.quick || a.data.prio <= 0)
				continue ;
			if (a.data.prio == 1)
				typeActions.supers++ ;
			else
				typeActions.base++ ;
		}

		if (typeActions.supers >= 2)
			typeActions.wSuper-- ;
		if (typeActions.supers >= 4)
			typeActions.wSuper-- ;
		if (typeActions.supers >= 5)
			typeActions.wBase++ ;
		if (typeActions.supers >= 7)
			typeActions.wBase++ ;
		if (typeActions.supers >= 9)
			typeActions.wBase++ ;



		var olds = selectedActions.copy() ;
		var max = getSlotNumbers() ;
		var fromIndex = -1;
		if (moreSlots) {
			fromIndex = max ;
			max+= 2 ; //2 more slots
		}
		avActions = [] ;
		
		var av = [] ;
		var cooldowned = [] ;

		if (!refresh) {
			if (onlyIndexes != null) {
				for (oi in onlyIndexes)
					selectedActions[oi] = null ;
			} else {
				if (!moreSlots)	{
					selectedActions = [] ;
					for (i in 0...max)
						selectedActions[i] = null ;
				} else {
					for (i in 0...2)
						selectedActions.push(null) ;
				}
			}
		}

		for (a in actions) {
			if (Type.enumEq(a.data.id, Swap)) {
					avActions.push({a : a.data.id, c : a.cooldown}) ;
				continue ;
			}

			if (Type.enumEq(a.data.id, MoreSlots)) {
					avActions.push({a : a.data.id, c : a.cooldown}) ;
				continue ;
			}

			if (Type.enumEq(a.data.id, ChoosePet)) {
				if (solver.curPet == null)
					avActions.push({a : a.data.id, c : a.cooldown}) ;
				continue ;
			}

			if (solver.curPet != null && Type.enumEq(solver.curPet.a, a.data.id)) {
				avActions.push({a : a.data.id, c : a.cooldown}) ;
				continue ;
			}

			if (a.data.prio == 0) {
				avActions.push({a : a.data.id, c : a.cooldown}) ;
				continue ;
			}

			var e = {a : a.data, c : a.cooldown, weight : (a.data.prio != 1) ? typeActions.wBase : typeActions.wSuper} ;

			if (Lambda.exists(olds, function(x) { return Type.enumEq(x, e.a.id) ; })) {
					e.weight = Std.int(Math.max(1, e.weight - 1)) ;
					if (moreSlots)
						continue ;
			}

			if (a.cooldown > 0) {
				cooldowned.push(e) ;
				//cooldowned.unshift(e) ;
			} else
				av.push(e) ;
		}

		if (!refresh) {

			/*var shortIt = function(tc : Array<Dynamic>) {
				var res = new Array() ;
				for (t in tc)
					res.push({a : t.a.id, c : t.c}) ;
				return res ;

			}

			var s = "#####PRE SORT : " + Std.string(shortIt(cooldowned)) ;
			#if neko
				App.current.logError(s) ;
			#end
			#if flash
				trace(s) ;
			#end*/
			
			//cooldowned.sort(function(a, b) {
				/*var infos = "a : " + Std.string(a.a.id) + "/" + Std.string(a.c) + ", b : " + Std.string(b.a.id) + "/" + Std.string(b.c) + " #### " + Std.string(shortIt(cooldowned)) ;
				#if neko
					App.current.logError(infos) ;
				#end
				#if flash
					trace(infos) ;
				#end*/
			//	return a.c - b.c ;
			//}) ;

			Solver.sort(cooldowned, function(a : {a : TActionData, c : Int, weight : Int}, b : {a : TActionData, c : Int, weight : Int}) { return a.c - b.c ; }) ;

			/*var s = "#####POST SORT : " + Std.string(shortIt(cooldowned)) ;
			#if neko
				App.current.logError(s) ;
			#end
			#if flash
				trace(s) ;
			#end*/


			for(i in 0...max) {
				if (selectedActions[i] != null) {
					if (i == 0 && !hasPaid)
						avActions.push({a : LockedSlot, c : 0}) ;
					else {
						for (a in actions) {
							if (Type.enumEq(a.data.id, selectedActions[i])) {
								avActions.push({a : a.data.id, c : a.cooldown}) ;
								break ;
							}
						}
					}
					continue ;
				}


				var c = null ;
				if (av.length > 0) {
					c = solver.randomWeight(cast av) ;
					av.remove(c) ;
				} else if (cooldowned.length > 0) {
					c = cooldowned.shift() ;
					c.c = 0 ;
					resetCooldown(c.a.id) ;
				}

				if (i == 0 && !hasPaid) {
					avActions.push({a : LockedSlot, c : 0}) ;
					selectedActions[i] = c.a.id ;
				} else {
					avActions.push({a : c.a.id, c : c.c}) ;
					selectedActions[i] = c.a.id ;
				}
			}
		} else {
			for (i in 0...selectedActions.length) {
				if (selectedActions[i] == null)
					continue ;

				if (i == 0 && !hasPaid)
					avActions.push({a : LockedSlot, c : 0}) ;
				else {
					for (a in actions) {
						if (Type.enumEq(a.data.id, selectedActions[i])) {
							avActions.push({a : a.data.id, c : a.cooldown}) ;
							break ;
						}
					}
				}
			}
		}

		if (!hasPaid && fromIndex < 0)
			fromIndex = 1 ;

		solver.log(L_AvActions(avActions.copy(), fromIndex, !refresh)) ;
	}



	public function sendAvActions() {
		var res = [] ;
		for (a in actions)
			res.push({a : a.data.id, c : a.cooldown}) ;

		solver.log(L_AvActions(res, -1, false)) ;
	}

	//####


	public function getCritic() {
		var c = logic.Student.DEFAULT_CRIT ;

		var perComp = 2 ;

		for (cp in [Critic_0, Critic_1, Critic_2]) {
			if (hasComp(cp))
				c += perComp ;
		}

		return c ;
	}


	public function getResist() {
		var c = DEFAULT_RESIST ;

		var perComp = 2 ;

		for (cp in [Resist_0, Resist_1, Resist_2, Resist_3, Resist_4, Resist_5]) {
			if (hasComp(cp))
				c += perComp ;
		}

		return c ;
	}


	public function addSuperAttack(?idx = 0) {
		if (idx == 0)
			superAttack[0] += 2 ;
		else
			superAttack[idx] += 1 ;
		log(L_SuperAttack(getSuperAttack())) ;
	}


	public function resetSuperAttack() {
		#if flash
			trace("resetSuperAttack") ;
		#end

		if (hasComp(BestSuperAttack))
			superAttack[0]-- ;
		else
			superAttack[0] = 0 ;
		superAttack[1] = 0 ;
		log(L_SuperAttack(0)) ;
	}


	public function hasComp(cp : TComp) {
		if (comps == null)
			return false ;

		return Lambda.exists(comps, function(x) { return Type.enumEq(x, cp) ; } ) ;
	}



	public function getFreeRestValue() {
		var value = logic.Data.COFFEE_EFFECT ;
		var byComp = 2 ;
		for (cp in [BestRest_0, BestRest_1, BestRest_2]) {

			if (hasComp(cp))
				value += byComp ;
	
		}
		return value ;
	}

	public function getFreeXpRestValue() {
		var value = logic.Data.FREE_XP_EFFECT ;
		var byComp = 2 ;
		for (cp in [BestRest_0, BestRest_1, BestRest_2]) {

			if (hasComp(cp))
				value += byComp ;
	
		}
		return value ;
	}


	public function getHealValue(h : TObject) {
		return logic.Data.getHealValue(h, comps) ;
	}

	
	public function addAction(a : TAction) {
		actions.push({data : Common.getTActionData(a), cooldown : 0}) ;
	}


	public function removeAction(a : TAction) {
		for (ta in actions.copy()) {
			if (Type.enumEq(ta.data.id, a)) {
				actions.remove(ta) ;
				return ;
			}
		}

	}


	public function loot(item : InvObject) {
		switch(item) {
			case IvItem(ci) :
				addCItem(ci) ;
				log(L_Loot(ci, null)) ;

			case IvObject(obj) :
				addObject(obj) ;
				lootList.push(obj) ;
				log(L_Loot(null, obj)) ;
		}

	}


	public function canDo(a : TAction, ?p : Int) : Bool {

		var unavailables = solver.lockedActions ;
		var ta = Common.getTActionData(a) ;

		if (Type.enumEq(ta.stance, Extra)) {
			if (Type.enumEq(a, ChooseHelper)) {
				return solver.helper == null;
			} else
				return true ;
		}

		if (unavailables != null) {
			if (Lambda.exists(unavailables, function(x) {
								return Type.enumEq(x.a, a) && (p == null || (x.p != null && x.p == p)) ; }))
				return false ;
		}

		switch(solver.type) {
			case Lesson(s) :
				if (!Type.enumEq(ta.stance, Normal) && !Type.enumEq(ta.stance, Super))
					return false ;

				/*if (Type.enumEq(ta.stance, Super) && leftSuper <= 0)
					return false ;*/

			case Break :
				var byPass = [UseObject] ;

				if (!Lambda.exists(byPass, function(x) { return Type.enumEq(a, x) ; }) && !Type.enumEq(ta.stance, StaffRoom))
					return false ;

			case Rest :

				var byPass = [UseObject] ;

				if (!Lambda.exists(byPass, function(x) { return Type.enumEq(a, x) ; })  && !Type.enumEq(ta.stance, House))
					return false ;

			case Ill, NeedMission :

				var byPass = [UseObject] ;
				if (!Lambda.exists(byPass, function(x) { return Type.enumEq(a, x) ; })  && !Type.enumEq(ta.stance, House))
					return false ;


			default : throw "cant do it : " + a ;
		}

		for (sa in getAllActions()) {
			if (!Type.enumEq(sa.data.id, ta.id))
				continue ;

			if (sa.cooldown > 0) {
				return false ;
			}

			switch(ta.id) {

				case ChoosePet :
					if (solver.curPet != null)
						return false ;
				
				case Pet_ToTheCorner :
					if (solver.countCorner() >= 2)
						return false ;

				case HBonusReward, SRBonusReward :
					if (solver.subject == null) //end of the year : next lesson is missing
						return false ;

				case HIll, SRIll :
					if (!isMidLife())
						return false ;

				case SRRerollHelper, HRerollHelper :
					return solver.helper == null ;

				default :
					if (solver.curPet != null && Type.enumEq(ta.id, solver.curPet.a)) {
						if (!solver.curPet.s.isAvailable(true))
							return false ;
					}
			}

			return true ;
		}
		return false ;
	}


	public function initCooldowns(t : TPeriod) {
		switch(t) {
			case Break :
				var res = [] ;
				for (a in actions) {
					if (Lambda.exists([UseObject, Buy, SRRerollHelper, ChooseHelper, SROpenGift], function (x) { return Type.enumEq(x, a.data.id) ; } ))
						a.cooldown = 0 ;
					else {
						if (pa > 0)
							a.cooldown = (!Type.enumEq(a.data.id, StartLesson)) ? 0 : 999 ;
						else
							a.cooldown = (Type.enumEq(a.data.id, StartLesson)) ? 0 : 1 ;
					}

					res.push({a : a.data.id, c : a.cooldown}) ;
				}
				log(L_Cooldown(res)) ;


			case Rest, NeedMission :
				var res = [] ;
				for (a in actions) {
					if (Lambda.exists([UseObject, Buy, HRerollHelper, ChooseHelper, HOpenGift], function (x) { return Type.enumEq(x, a.data.id) ; } ))
						a.cooldown = 0 ;
					else {
						if (pa > 0)
							a.cooldown = (!Type.enumEq(a.data.id, WakeUp)) ? 0 : 1 ;
						else
							a.cooldown = (Type.enumEq(a.data.id, WakeUp)) ? 0 : 999 ;
					}
					res.push({a : a.data.id, c : a.cooldown}) ;

				}
				log(L_Cooldown(res)) ;


			default : //nothing to do
		}

	}


	public function updateCoolDowns(played : TAction, ?spent = true, ?minor = 1, ?noQuick = false) {
		var res = [] ;
		var nc = 0 ;

		//var defaultUniqueSuperCD = 6 ;

		//var isSuper = Type.enumEq(Common.getTActionData(played).stance, Super) ;

		for (a in actions) {
			if (a.data.quick && noQuick)
				continue ;

			if (played != null && Type.enumEq(a.data.id, played)) {
				a.cooldown = a.data.cd ;
				nc = a.cooldown ;
			} else {
				/*if (isSuper && Type.enumEq(a.data.stance, Super)) {
					a.cooldown = (a.data.cd == 999) ? defaultUniqueSuperCD : a.data.cd ;*/
				//} else {
					if (a.cooldown > 0  && a.cooldown != 999 && spent)
						a.cooldown= Std.int(Math.max(0, a.cooldown - minor)) ;
				//}
			}
			res.push({a : a.data.id, c : a.cooldown}) ;
		}


		log(L_Cooldown(res)) ;

		/*#if flash
		trace("cooldowns : " + Std.string(res)) ;
		for (a in actions) {
			if (Type.enumEq(a.data.stance, Super))
				trace(a.data.id + " => " + canDo(a.data.id)) ;

		}
		trace("####################") ;
		#end*/
		return nc ;
	}


	public function resetCooldown(?act : TAction) {
		for (a in actions) {
			if (Type.enumEq(a.data.id, act)) {
				a.cooldown = 0 ;
				return ;
			}
		}

		/*var res = [] ;
		for (a in actions) {
			if (a.cooldown <= 0)
				continue ;
			if (!withSuper && Type.enumEq(a.data.stance, Super))
				continue ;
			a.cooldown = 0 ;
			res.push({a : a.data.id, c : a.cooldown}) ;
		}

		log(L_Cooldown(res)) ;*/
	}


	public function isFullLife() {
		return selfControl >= maxSelfControl ;
	}

	public function isMidLife() {
		return selfControl <= maxSelfControl / 2 ;
	}
	

	public function useObject(obj : TObject, period : TPeriod, target : Dynamic) {

		switch(obj) {
			
			case Heal_0 :
					if (isFullLife())
						throw SE_Invalid(_Err_UselessHeal) ;

					var value = getHealValue(Heal_0) ;
					solver.log(L_TeacherHeal(value)) ;
					dSelfControl(value) ;
			case Heal_1 :
					if (isFullLife())
						throw SE_Invalid(_Err_UselessHeal) ;

					var value = getHealValue(Heal_1) ;
					solver.log(L_TeacherHeal(value)) ;
					dSelfControl(value) ;
			case Heal_2 :
					if (isFullLife())
						throw SE_Invalid(_Err_UselessHeal) ;

					var value = getHealValue(Heal_2) ;
					solver.log(L_TeacherHeal(value)) ;
					dSelfControl(value) ;

			case LangageAid : //nothing to do

			case Sponge :
					var stud : Student = target ;
					var done = stud.clean(10, true) ;
					stud.removeBoredom(2) ;

			/*case CodLiverOil :
				updateCoolDowns(null, true, 2) ;
				initTurnActions(null, null, true) ;*/
		
			case SuperAttack_0, SuperAttack_1 :
				if (superAttack[0] > 0)
					throw SE_Invalid(_Err_ObjectUnavailable) ;

				addSuperAttack() ;

				/*var stud : Student = target ;
				if (!stud.hasState(Attentive))
					stud.addState(Attentive) ;*/

			/*case Replay :
				dPA(1) ;*/

			/*	case Life_Well : 	solver.addEventObject(obj, 4) ;

			case RemoveKO :
				var stud : Student = target ;
				if (stud.hasState(KO))
					stud.removeState(KO) ;
				else
					solver.log(L_ActionFailed) ;*/

			/*case AlarmClock :
				var stud : Student = target ;
				if (stud.hasState(Asleep))
					stud.removeState(Asleep) ;

			case Sedative :
				var stud : Student = target ;
				if (!stud.hasState(Harmless))
					stud.addState(Harmless) ;

			case ResetCooldown :
				resetCooldown() ;*/

			/*case LostExam :
				var stud : Student = target ;
				if (!stud.hasState(BonusPoint))
					stud.addState(BonusPoint) ;
				else
					solver.log(L_ActionFailed) ;
				
			case SurvivorAmulet : solver.addEventObject(obj, -1) ;

			case Warrant :
				var stud : Student = target ;
				var found = stud.inventory.length > 0 ;

				if (found) {
					var item = stud.dropItem() ;
					loot(item) ;
					stud.removeBoredom(2) ;
				} else
					solver.log(L_ActionFailed) ;*/
		}

		removeObject(obj) ;

	}


	public function buyObject(o : TObjectData, idx : Int) {
		spendGold(o.cost[idx], UseObject, o.id) ;
		addObject(o.id, o.pack[idx]) ;
	}


	public function receiveGift(o : TObject, from : Int) {
		addObject(o, 1) ;
		if (!solver.initAction)
			solver.log(L_Gift(o, from)) ;
	}


	public function spendGold(c : Int, a : TAction, ?obj  : TObject) {
		if (!solver.initAction)
			gold -= c ;
		if (gold < 0)
			throw SE_Invalid(_Err_NotEnoughMoney);
		
		if (!solver.initAction)
			solver.log(L_Bought(c, a, obj)) ;
	}


	public function rerollHelpers() {
		if (avHelpers == null)
			return ;

		var s = solver.seed + gold ;
		for (h in avHelpers.cur)
			s += Type.enumIndex(h) ;

		var rd = new mt.Rand(0) ;
		rd.initSeed(s) ;


		var olds = avHelpers.cur ;
		avHelpers.cur = [] ;

		var av = avHelpers.av.copy() ;
		av.remove(olds[rd.random(olds.length)]) ;
		
		for (i in 0...2) {
			if (av.length == 0)
				break ; // wtf ?
			var h = av[rd.random(av.length)] ;
			avHelpers.cur.push(h) ;
			av.remove(h) ;
		}

		log(L_RerollHelpers(avHelpers.cur)) ;
		spendGold(logic.Data.REROLL_HELPERS_COST, HRerollHelper) ;
	}


	public function chooseHelper(c : Helper) {
		if (avHelpers == null)
			throw "cant choose helper" ;

		if (!Lambda.exists(avHelpers.cur, function(x) { return Type.enumEq(x, c) ; }))
			throw "chosen helper is missing" ;

		solver.helper = c ;
		avHelpers = null ;

		log(L_ChooseHelper(c)) ;
		spendGold(logic.Data.CHOOSE_HELPER_COST, ChooseHelper) ;



	}


	public function getKnowledge(a : TAction, ?directDamages = true, ?param : Int) : Damages {
		var res = {value : 0, crit : 0, resist : logic.Student.DEFAULT_RESIST, type : Classic} ;

		switch(a) {

			case Teach :
				res.value = 2 ;

			case Smite :
				res.value = 2 ;
				res.type = ThroughBoredom ;

			case BigTeach, BigHardTeach :
				res.value = 3 ;

			case ExtensiveTeach :
				res.value = 2 ;

			case GoToBoard :
				res.value = 2 ;

			case CoolTeach :
				res.value = 3 ;

			case HardTeach, HardTeach_0, HardTeach_1 :
				res.value = 2 ; // 12 + 8 + 4 => 24 (24 / 27)
			
			case TestTeach, BestTestTeach :
				/*res.value = 2 ;
				res.type = DoubleOnLife ;*/
				res.value = 4 ;

			case Exercice : // Dot damages
				res.value = 1 ;

			case Cogitate : //no random. Dot damages
				res.value = 1 ;

			case Seriously :
				res.value = 3 ;
				if (param == 1)
					res.type = ThroughBoredom ;

			case CounterAttack :
				res.value = (param == null) ? 0 : (param * 2) ;

			case Sacrifice :
				res.value = 3 ;
				if (param > 0)
					res.type = ThroughBoredom ;

			case SuperBook :
				res.value = 1 ;

			case Anecdote :
				res.value = 2 ;
				res.type = ThroughBoredom ;

			case BonusKill :
				res.value = 3 ;

			case TeachingFlick :
				res.value = 1 ;


			case What :
				res.value = switch(param) {
								case 0 : 0 ;
								case 1 : 1 ;
								case 2 : 2 + solver.random(2) ;
								case 3 : 2 + solver.random(3) ;
								case 4 : 3 + solver.random(3) ;
								default : 3 + solver.random(4) ; //5+
								}

			case Pet_Explication : res.value = 1 ;

			case Pet_BonusXp : res.value = 2 ;

			default : //nothing to do
		}


		res.crit = getCritic() ;

		var sa = getSuperAttack() ;
		if (directDamages && sa > 0) {
			res.value += sa ;
			superAttackDone = true ;
		}

		return res ;
	}


	public function checkSuperAttack() {
		if (!superAttackDone)
			return ;
		superAttackDone = false ;
		resetSuperAttack() ;
	}


	public function getSuperAttack() : Int {
		var res = 0 ;
		for (v in superAttack)
			res += v ;

		return res ;
	}


	public function hitPA(data : SAction, v : Int) {
		dPA(v * -1, data) ;
	}


	public function hit(data : SActionData, d : Damages, from : Student) {

		var infos = modHit(data, d) ;
		var type : HitType = null ;

		var r = solver.random(100) ;
		if (infos.value > 0  && r >= 100 - infos.crit) {
			infos.value = Std.int(Math.round(infos.value * 1.5)) ;
			type = Critic ;
		} else if (r < infos.resist || infos.value == 0) {
			infos.value = 0 ;
			type = Resist ;

			if (solver.hasHelper(Eddy))
				log(L_TriggerHelper(Eddy)) ;

		}

		for (e in solver.getEventObjects()) {
			switch(e) {
				case Ev_Object(o, t, v) :
					switch(o) {
						/*case SurvivorAmulet :
							if (selfControl - infos.value <= 0) {
								infos.value = selfControl - 1 ;
								log(L_TriggerObject(SurvivorAmulet)) ;
								solver.removeEvent(e) ;
							}*/

						default : //nothing to do
					}

				default : //nothing to do
			}
		}


		log(L_TeacherHit(from.id, infos.value, data.id, type)) ;
		if (infos.value != 0)
			dSelfControl(infos.value * -1) ;

		if (infos.value > 0 && from != null)
			solver.setCornerHealer(from, infos.value) ;
	}


	function modHit(data, d : Damages) : {value : Int, crit : Int, resist : Int, absorb : Bool} {
		var absorb = 0.0 ;
		var resist = d.resist ;
		var crit = d.crit ;

		var nv = d.value ;

		for (e in solver.getEventObjects()) {
			switch(e) {
				case Ev_Object(o, t, v) :
					switch(o) {
						case LangageAid :
							v -= nv ;
							var logValue = nv ;
							nv = 0 ;

							var destroy = false ;
							if (v <= 0) {
								destroy = true ;
								solver.removeEvent(e) ;
							} else
								solver.updateEvent(e, Ev_Object(o, t, v)) ;

							log(L_TriggerObject(o, logValue, destroy)) ;

						default : //nothing to do
					}

				default : //nothing to do
			}
		}

		if (solver.hasHelper(Eddy))
			resist += 15 ;

		return {value : nv, crit : crit, resist : resist, absorb : absorb > 0 } ;

	}




	public function getAllObjects() : Array<{o : TObject, n : Int}> {
		var res = new Array() ;

		for (k in objects.keys()) {
			var io = objects.get(k) ;
			if (io != null && io.stock > 0)
				res.push({o : Type.createEnumIndex(TObject, k), n : io.stock}) ;
		}

		return res ;
	}


	public function addCItem(ci : CItem, ?n = 1) {
		var idx = Type.enumIndex(ci) ;
		var h = collection.get(idx) ;
		if (h == null)
			collection.set(idx, n) ;
		else
			collection.set(idx, h + n) ;
	}


	public function addObject(o : TObject, ?qty = 1) {
		var idx = Type.enumIndex(o) ;
		var h = objects.get(idx) ;
		if (h == null)
			objects.set(idx, {stock : qty, used : 0}) ;
		else
			objects.set(idx, {stock : h.stock + qty, used : h.used}) ;
	}


	public function removeObject(o : TObject, ?qty = 1) {
		var idx = Type.enumIndex(o) ;
		var h = objects.get(idx) ;
		if (h == null || h.stock < qty)
			throw SE_Fatal("cant remove object " + Std.string(o)) ;
		
		objects.set(idx, {stock : h.stock - qty, used : h.used + qty}) ;
	}


	public function hasObject(o : TObject) {
		var h = objects.get(Type.enumIndex(o)) ;
		
		return h != null && h.stock > 0 ;
	}
	

	public inline function log( l : LessonLog ) {
		if( solver != null )
			solver.log(l);
	}


	public function spendCost(d : TActionData) {
		if (d.cost > 0) {
			if (extraTime > 0)
				extraTime-- ;
			else
				dPA(d.cost * -1 ) ;
		}

		return d.cost > 0 ;
	}


	public function dSelfControl( d : Int ) {

		if (d < 0)
			d = Std.int(Math.max(d, -1 * selfControl)) ;
		else
			d = Std.int(Math.min(d, maxSelfControl - selfControl)) ;
		selfControl += d ;
		log(L_SelfControl(d)) ;

		return d ;
	}
	

	public function dPA( d : Int, ?from : SAction) {
		pa = Std.int(Math.min( pa + d, maxPa )) ;
		if( pa < 0 )
			pa = 0 ;

		log(L_Time(d, from));
	}


	public function refillPa() {
		var delta = Std.int(Math.round(maxPa * 0.30)) ;
		dPA(delta) ;
	}



	public function getPreparedNumber() : Int {
		return 0 ; //DEPRECATED
		/*return 	if (hasComp(PrepareSubject_2))
					5
				else if (hasComp(PrepareSubject_1))
					4
				else if (hasComp(PrepareSubject_0))
					3
				else
					0 ;*/
	}


	public function dPreparation( d : Int) {
		prepared = Std.int(Math.max(0, prepared + d)) ;
	}

	
}
