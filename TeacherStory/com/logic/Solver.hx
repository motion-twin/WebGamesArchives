package logic;
import Common;

using Lambda ;


class Solver {
	public static var VERSION = 21 ;

	public static inline var FRAMES = 100 ;

	public var type : TPeriod ;
	public var allLog : Array<List<LessonLog>> ;
	public var turnLog : List<LessonLog> ;
	public var touchTargets : List<AcTarget> ;
	public var subject : Subject ;
	public var seed : Int ;
	public var rseed : mt.Rand ;

	public var waitingAction : Null<{act : TAction, stud : Student}> ;
	public var lockedActions : Array<{a : TAction, p : Null<Int>}> ;
	public var stockAction : Null<TAction> ;
	public var allPetActions : Array<TAction> ;

	public var time : {last : Date, now : Date} ;

	public var initAction : Bool ;
	public var turn : Int ;
	public var finished : Null<LessonLog> ;
	public var successDone : Bool ;

	var events : Array<Event> ;
	public var students : Array<Student> ;
	public var teacher : logic.Teacher ;

	public var curPet : {s : Student, a : TAction} ;
	public var helper : Null<Helper> ;
	public var helperLine : Int ;
	public var supervisorSeats : Array<Coords> ;
	public var turnKills : Array<Int> ;
	public var ultima : Null<Int> ;
	public var launch : Array<Int> ;
	public var worldMod : Null<String> ;


	public var cornerHealer : {s : Null<Student>, canSave : Bool, hit : Int} ;

	public var seats : Array<Coords> ;
	public var lines : Array<Int> ;
	public var columns : Array<Int> ;
	public var onTheFloor : Array<{oid : Int, o : InvObject, from : Student, to : Student, t : Int}> ;
	public var curDepth : Int ;

	public static var me : Solver ;

	public var minNote : Float ;

	#if debug
	public var debugActions : Array<{act  :SAction, n :Int}> ;
	#end

	
	public function new() {
		me = this ;
		turnLog = new List() ;
		allLog = new Array() ;
		allLog.push(turnLog) ;
		turn = 0 ;
		finished = null ;
		turnKills = new Array() ;
		events = new Array() ;
		lockedActions = new Array() ;
		allPetActions = [ChoosePet] ;
		successDone = false ;

		seats = new Array() ;
		lines = new Array() ;
		columns = new Array() ;
		onTheFloor = new Array() ;
		cornerHealer = {s : null, canSave : false, hit : 0} ;
		curDepth = 0 ;


		#if debug
			//format : {act : SAction, n : Int}
			debugActions = [
				//{act : SAction.LaunchThing, n : 5},
				//{act : SAction.Atk_Ps_6, n : 10},
				//{act : Dot_Ph_0, n : 1},
				//{act : SAction.Add_Lol, n : 1},
			] ;
		#end
	}


	public function init(t : TPeriod,  o : SolverInit, g : Int, hp : Bool, tm : {_last : Date, _now : Date}) {

		type = t ;
		seed = o._seed ;
		rseed = new mt.Rand(0) ;
		initSeed() ;

		if (tm != null)
			time = {last : tm._last, now : tm._now} ;

		subject = o._subject ;

		teacher = new logic.Teacher(o._teacherData, this, g, hp) ;
		if (teacher.items != null) {
			for (it in teacher.items) {
				seats.push({x : it._x, y : it._y}) ;

				if (!Lambda.exists(lines, function(l) { return l == it._y ; } ))
					lines.push(it._y) ;

				if (!Lambda.exists(columns, function(c) { return c == it._x ; } ))
					columns.push(it._x) ;
			}
		}

		Solver.sort(lines, function(a : Int, b : Int) { return b - a ; }) ;
		Solver.sort(columns, function(a : Int, b : Int) { return b - a ; }) ;

		students = new Array() ;
		for (s in o._students)
			students.push(new logic.Student(s, this)) ;

		teacher.solver = this ;
		helper = o._teacherData._helper ;
		helperLine = 0 ;

		switch(type) {
			case Lesson(s) :

				/*if (teacher.isPrepared) {
					var n = teacher.getPreparedNumber() ;
					var stds = students.copy() ;
					for (i in 0...n) {
						if (stds.length == 0)
							break ;
						var s = stds[random(stds.length)] ;
						stds.remove(s) ;
						s.addState(Attentive) ;
					}
				}*/


				if (o._ultima != null)
					ultima = o._ultima ;

				launch = new Array() ;
				for (l in o._launch)
					launch.push(l) ;

				teacher.initTurnActions() ;

				supervisorSeats = new Array() ;
				if (helper != null) {
					switch(helper) {
						case Supervisor :
							var choice = seats[random(seats.length)] ;
							supervisorSeats = getTableCoords(choice) ;
							log(L_SupervisorChoice(Lambda.map(supervisorSeats, function(s) { return {_x : s.x, _y : s.y} ; })))  ;

						case Director, Inspector, Dog :
							var c = getEmptyPlaceOnLine(getHelperLine()) ;
							log(L_HelperMoveTo({_x : c.x, _y : c.y})) ;

						default :
					}
				}


			case Break, Rest, NeedMission :
				teacher.initCooldowns(t) ;
				teacher.sendAvActions() ;
				
				if (o._leftActions <= 0)
					log(L_Wait(time.last)) ;

			default : //nothing to do
		}

		return turnLog ;
	}


	static public function getDevData(?period : TPeriod) : ClientInit {
		var initRand = new mt.Rand(123) ;

		if (period == null)
			period = Lesson(S_Math) ;

		var sub = S_Math ;
		var tSubs = [S_Math, S_History] ;

		var duration = 12;
		var teacher : TeacherData = {
			_pr : 0,
			_am : Std.random(2) == 0,
			_s : 25,
			_ms : 25,
			_p : duration,
			_mp : duration,
			_l : 0,
			_pp : 0,
			_i : new Array(),
			_o : [	{_o : Heal_0, _n : 1},
					{_o : Sponge, _n : 3}],
			_ys : 1234,
			_llt : 0,
			_act : [],
			_cps : [],
			_ill : null,
			_grade : 0,
			_helper : null,
			_avHelpers : null
		} ;
		switch( period ) {
			case Lesson(_) :
				teacher._act = [GoToBoard, What, Answer, TAction.Teach, TAction.MoreAttention, TAction.HardTeach, TAction.UseObject, TAction.Swap, TAction.Clean, TAction.Cogitate, TAction.TestTeach, TAction.Grab];
			case Break :
				teacher._act = [StartLesson, Coffee, /*SRPrepareSubject_0*/] ;
			case Rest :
				teacher._act = [Rest, /*HPrepareSubject_0,*/ WakeUp] ;
			default : throw "unsupported";
		}

		var avSeats = new Array() ;
		for (y in [2,4,6])
			for (x in [2,4,5,7,8,10]) {
				avSeats.push({_x : x, _y : y}) ;
				teacher._i.push({
					_x: x,
					_y: y
				});
			}

		var sNames = [["Theo", "Nathan", "Rémi", "David", "Nicolas", "Joachim", "Marius", "Charles-Edouard", "Barnabé", "Henri"],
		["Suzette", "Barbara", "Anna", "Marie-Charlotte", "Louise", "Kimberley", "Emma", "Inès", "Maélys", "Georgette"]] ;

		var avCharacters = [[Std_V1], [Std_V2], [Std_V3, Pee], [Dumb, Smell], [Dreamer], [Hibernator], [Greedy], [Gossip], [Clever], [Physic_1], [Noisy_0]] ;
		
		var students = new Array() ;
		for (i in 0...10) {
			var p = avSeats[initRand.random(avSeats.length)] ;
			avSeats.remove(p) ;
			var sex = Std.random(2) ;
			var note = 7.0 + Std.random(8) ;
			students.push({
				_i: i + 1,
				_m: sex,
				_h : i == 0 || i == 10 || i == 5 || i == 2,
				_f: sNames[sex][i],
				_lf : 2 + Std.random(4),
				_sb : 1 + Std.random(2),
				_mb : 2 + Std.random(2),

				//_ck : 0,
				//_iq : -2 + Std.random(4),
				//_mk: 20 + Std.random(20),
				//_mk: 20 + Std.random(20),
				//_mk: 20,
				_ss : new List(),
				_r : Std.random(2),
				_ch : avCharacters[i][0],
				_p: p,
				_pet : null,
				_n : note,
				_fn : note - Std.random(4),
				_l : 0,
				_late : 0,
				_new : 0,
				_lastReward : -1.0,
				_u : null,
				_gift : null
				}) ;
		}

		return {
			_period : period,
			_extra : {
				_urlNext : "/next",
				_urlRanking : "/ranks",
				_urlLevelUp : "/game/isLevelUp",
				_urlMissionDone : "/game/isMissionDone",
				_userName : "USERNAME",
				_urlHome : "/game/updateHome",
				_urlHat : "/setHat",
				_urlGift : "/game/openGift",
			},
			_solverInit : {
				_seed : 123, //seed
				_leftActions : null,
				_subject : sub,
				_teacherData : teacher,
				_students : students,
				_ultima : null,
				_launch : [],
				_extraInv : [],
				_wm : null
			},
			_actions : new Array(),
			_actionUrl : "/lessonAction",
			_tutorialData : [],
			_delivery : false,
			_gold : 100,
			_hat : {_h : 0, _av : [0]},
			_time : {_last : Date.now(), _now : Date.now()},
			_home : null,
			_picture : false,
			_hp : false,
			_div : 1.0,
			_freePlay : false


		}
	}


	public function isLesson() : Bool {
		switch(type) {
			case Lesson(_) : return true ;
			default : return false ;
		}
	}


	function initSeed() {
		rseed.initSeed( seed + turn ) ;
	}


	public function random(r : Int) {
		return rseed.random(r) ;
	}


	public function log( l : LessonLog ) {
		if (turnLog != null)
			turnLog.add(l) ;
	}



	public function setPet(stud : logic.Student) {
		if (curPet != null)
			throw SE_Fatal("existing pet") ;

		stud.addState(Pet) ;
		stud.petAction.k = true ;
		curPet = {s : stud, a : stud.petAction.a} ;

		//### DEBUG
		//curPet.a = Pet_Muscled ;
		//###

		teacher.addAction(curPet.a) ;
		teacher.initTurnActions(true) ;


		/*#if flash
		var acts = [] ;
		for (a in teacher.actions)
			acts.push(a.data.id) ;
		trace("setPet : actions = " + Std.string(acts)) ;
		#end*/

	}


	public function unsetPet() {
		if (curPet == null)
			throw SE_Fatal("cant unset null pet") ;

		teacher.removeAction(curPet.a) ;
		curPet = null ;
		teacher.updateCoolDowns(ChoosePet, false) ;
		teacher.initTurnActions(true) ;
	}


	public function setStockAction(a : TAction) {
		if (stockAction != null)
			unsetStockAction() ;

		stockAction = a ;
		teacher.removeAction(a) ;
	}


	public function unsetStockAction() {
		if (stockAction == null)
			return ;
		teacher.addAction(stockAction) ;
		stockAction = null ;
	}


	public function isStockAction(a :TAction) {
		return stockAction != null && Type.enumEq(stockAction, a) ;
	}


	public function getStudent( id : Int ) {
		for (s in students) {
			if (s.id == id)
				return s ;
		}
		return null ;
	}


	public function getStudentByLine(line : Null<Int>, column : Null<Int>) : Array<Student> {
		var res = new Array() ;

		for (s in students)
			if (s.isSeat() && ( (line != null && s.seat.y == line) || (column != null && s.seat.x == column) ))
				res.push(s) ;

		Solver.sort(res, function(a : Student, b : Student) {
			if (line != null)
				return a.seat.x - b.seat.x ;
			else
				return b.seat.y - a.seat.y ;


		}) ;

		return res ;
	}


	public function getStudentByPos(c : Coords, ?standUpOk = true) : logic.Student {
		if (c == null)
			return null ;

		for(s in students) {
			if( s.seat != null && s.seat.x == c.x && s.seat.y == c.y ) {
				if (standUpOk || !s.isStanding())
					return s ;
			}
		}
		return null ;
	}


	public function getEmptySeats(?strictlyFree = true) : Array<Coords> {
		var res = seats.copy() ;
		for (s in students) {
			if (s.seat == null)
				continue ;
			if (!strictlyFree && !s.isSeat())
				continue ;
			for (r in res.copy()) {
				if (r.x == s.seat.x && r.y == s.seat.y) {
					res.remove(r) ;
					break ;
				}
			}
		}

		return res ;
	}


	public function dist(s1 : Student, s2 : Student) {
		return Math.abs(s1.seat.x-s2.seat.x) + Math.abs(s1.seat.y-s2.seat.y) ;
	}

	

	public function isNear( s1 : Student, s2 : Student, d = 1 ) {
		var c1Idx = s1.getCoordIndexes() ;
		var c2Idx = s2.getCoordIndexes() ;

		return Math.abs(c1Idx.l - c2Idx.l) <= d && Math.abs(c1Idx.c - c2Idx.c) <= d ;

	}

	function randStudent( ?state : SState ){
		var a = new Array();
		for( e in students ){
			if( state == null || e.hasState(state) )
				a.push(e);
		}
		return a[random(a.length)];
	}


	public function studentNear( stud : Student, d = 1, ?check : logic.Student -> Bool ) : Array<logic.Student> {
		var l = new Array();
		for( s in students ){
			if( s != stud && isNear(s, stud, d) && (check == null || check(s)) )
				l.push(s);
		}
		return l ;
	}


	public function studentNearest( stud : Student, ?act : SState) {
		var l = new List() ;

		var min = 1000.0 ;
		var res = null ;

		for( s in students ){
			if( s == stud ||  (act != null && !s.hasState(act)))
				continue ;
			var d = dist(stud, s) ;
			if (d >= min)
				continue ;
			min = d ;
			res = s ;
		}
		return res ;
	}


	/*function checkRage() : Null<Int> {
		for (s in students) {
			if (s.done())
				continue ;
			if (s.hasState(Rage) && s.isAvailable(true))
				return s.id ;
		}
		return null ;
	}*/


	//Si l'event Replay est présent, on le retire de la liste et on passe le tour des élèves.
	function checkReplay(?student = false) : Null<Int> {
		for (e in events.copy()) {
			switch(e) {
				case Ev_Replay(sid, ea) :
					if ((sid == null && !student) || (sid != null && student)) {
						events.remove(e) ;
						if (ea != null) {
							lockedActions = ea.copy() ;
							//log(L_LockObjects(true)) ;
						}
						return sid != null ? sid : 0 ;
					}
				default : continue ;
			}
		}
		return null ;
	}


	function checkTeacherSleep() : Bool {
		for (e in events.copy()) {
			switch(e) {
				case Ev_TeacherSleep :
					events.remove(e) ;
					return true ;

				default : continue ;
			}
		}
		return false ;
	}


	function checkEnd() {
		if (teacher.selfControl <= 0) {
			if (hasHelper(Einstein)) {
				log(L_TriggerHelper(Einstein)) ;
				teacher.selfControl = 0 ;
				teacher.dSelfControl(3) ;
				helper = null ;
				return false ;
			}

			log(L_Dead) ;
			finished = L_Dead ;
			return true ;
		}

		if (successDone)
			return false ;

		var success = true ;
		for (s in students) {
			if (s.done())
				continue ;
			success = false ;
			break ;
		}

		if (success) {
			finished = L_Success ;
			log(L_Success) ;
			successDone = true ;
			return true ;
		}

		if (teacher.pa <= 0) {
			log(L_Ring) ;
			finished = L_Ring ;
			return true ;
		}

		return success ;
	}


	public function getTargets(a : TAction, ?param : Dynamic ) : Target { //param is used for objects


		switch(a) {
			case 	Exam,
					Exercice,
					Projector 	: return All_Students ;

			case 	MoreAttention, MoreAttention_0, MoreAttention_1,
					Teach,
					Seriously,
					Sacrifice,
					ChoosePet,
					BigTeach,
					Smite,
					BestTestTeach,
					BestMoreAttention,
					Anecdote	: return Choose_Student(1) ; // choose table


			case 	Clean, Clean_0, Clean_1,
				 	Cogitate,
				 	TestTeach, TestTeach_0, TestTeach_1,
				 	GoToBoard,
				 	CounterAttack,
				 	SuperBook,
				 	MathBump,
				 	Hypnotism,
				 	CoolTeach,
				 	TeachingFlick,
				 	AcademicBomb,
				 	LifeTransfer,
				 	BonusKill
				 	/*Reprimand, Reprimand_0, Reprimand_1*/ : return Choose_Student(1) ;

			case 	BigClean,
					BigHardTeach 		: return Choose_Column ;

			case 	AllAttentive,
					OtherBigClean,
					ExtensiveTeach	 	: return Choose_Line ;

			case 	LangageAid 		: return Teacher ;
			case 	Buy 			: return Teacher ;
			case 	MoreSlots		: return Teacher ;
			case 	LockedSlot		: return Teacher ;
			case 	HRerollHelper,
					SRRerollHelper	: return Teacher ;
			case 	ChooseHelper	: return Teacher ;
			case 	SROpenGift, HOpenGift : return Teacher ;

			case 	Pet_IronWill,
					Pet_Dring,
					Pet_ComeOn,
					Pet_Alzheimer,
					Pet_Hot 		: return Teacher ;

			case 	Pet_ElbowHit,
					Pet_Meditate,
					Pet_Explication,
					Pet_Valium,
					Pet_Sleep,
					Pet_Club,
					Pet_Shock,
					Pet_Cheater,
					Pet_BonusXp,
					Pet_Tickle,
					Pet_BoringTransfer,
					Pet_NoLaugh,
					Pet_Chut,
					Pet_ToTheCorner,
					Pet_Stock,
					Pet_Exclude		: return Choose_Student(1) ;

			case 	Pet_Muscled		: return Choose_Seat(1)  ;
			

			case 	Swap			: return Choose_Seat(2) ;

			case 	What			: return Choose_Student(1) ;
				
			case	Answer, Grab	: return Choose_Num ;

			case 	HardTeach, HardTeach_0, HardTeach_1 : return Choose_Column ;

			case UseObject :
				if (param == null)
					throw SE_Fatal("missing object in target request") ;
				var obj : TObject = param ;

				switch(type) {
					case Break, Rest :
						var data = Common.getObjectData(obj, []) ;
						if (!data.always)
							return Teacher ; //no selection ingame for disabled object
					default : //nothing to do
				}

				switch(obj) {
					case 	Heal_0, Heal_1, Heal_2,
							//Replay,
							//CodLiverOil,
							SuperAttack_0, SuperAttack_1,
							/*ResetCooldown,
							SurvivorAmulet,
							Life_Well,*/
							LangageAid				: return Teacher ;

					case 	//RemoveKO,
							Sponge
							/*Sedative,
							AlarmClock,
							Warrant,
							LostExam*/				: return Choose_Student(1) ;
				}


			//STAFFROOM
			case Coffee, StartLesson, SRMoreXp, SRIll	: return Teacher ;

			case /*SRPrepareSubject_0, SRPrepareSubject_1, SRPrepareSubject_2,*/
				SRBonusReward : return Teacher ;

			//HOUSE
			case Rest, WakeUp, HMoreXp, HIll		: return Teacher ;

			case /*HPrepareSubject_0, HPrepareSubject_1, HPrepareSubject_2,*/
				HBonusReward : return Teacher ;

			//case StopIll, Resurrect, GoToIll : return Teacher ;

		}
	}
	

	public function doTurn(infos : SendAction, ?init = false) {
		var res = new List() ;
		initAction = init ;
		switch(type) {
			case Lesson(s) : res = doLessonTurn(infos) ;

			case Break : res = doBreakTurn(infos) ;

			case Rest, NeedMission : res = doRestTurn(infos) ;

			case Ill  : res = doRestTurn(infos) ;

			default : throw "invalid solver type" ;
		}
		initAction = false ;
		return res ;
	}


	function doBreakTurn(infos : SendAction) {
		try {

		turnLog = new List() ;
		allLog.push(turnLog) ;

		var a = infos._a ;
		var targets = Lambda.list(infos._t) ;

		var data = Common.getTActionData(a) ;

		if (Lambda.exists(lockedActions, function(x) { return Type.enumEq(x.a, a) ; }))
			throw SE_Invalid(_Err_ActionUnavailable(a)) ;

		if (!teacher.canDo(data.id, null))
			throw SE_Invalid(_Err_ActionUnavailable(a)) ;

		var logList = Lambda.list(infos._t) ;
		log(L_TeacherAction(a, logList)) ;

		/*#if flash
		trace("teacher action : " + L_TeacherAction(a, logList)) ;
		#end*/
			
		var getNextTarget = function() : Dynamic {
			if (targets == null || targets.length == 0)
				return null ;

			switch(targets.pop()) {
				case AT_Coord(c) : return {x : c._x, y : c._y} ;
				case AT_Num(n) : return n ;
				case AT_Std(sid) : return getStudent(sid) ;
			}
		}


		switch(a) {
				
			case Coffee :

				var value = teacher.getFreeRestValue() ;

				log(L_TeacherHeal(value)) ;
				teacher.dSelfControl(value) ;


			case SRMoreXp :
				var value = teacher.getFreeXpRestValue() ;
				log(L_XP(null, value)) ;
				log(L_ExtraAdd(0, value)) ;

			case StartLesson :
				//nothing to do


			case SRBonusReward :
				setBonusReward() ;

			case SRIll :
				if (!teacher.isMidLife())
					throw SE_Invalid(_Err_NoMidLife) ;
				log(L_GoToIll) ;

			case UseObject :
				var obj = Type.createEnumIndex(TObject, getNextTarget()) ;
				if (!teacher.hasObject(obj))
					throw SE_Invalid(_Err_ObjectUnavailable) ;

				var oData = Common.getObjectData(obj, []) ;
				if (!oData.always)
					throw SE_Invalid(_Err_CantUseObjectHere) ;

				teacher.useObject(obj, Break, getNextTarget()) ;

			case Buy :
				var obj = Type.createEnumIndex(TObject, getNextTarget()) ;

				var idx = getNextTarget() ;

				if (teacher.hasObject(obj))
					throw SE_Fatal("has object " + Std.string(obj) + ". Cant buy it now") ;

				var objData = Common.getObjectData(obj, teacher.comps) ;

				if (idx < 0 || idx >= objData.cost.length)
					throw SE_Fatal("Invalid selection. Cant buy it now") ;

				if (objData.cost[idx] > teacher.gold)
					throw SE_Invalid(_Err_NotEnoughMoney) ;

				teacher.buyObject(objData, idx) ;

			case SRRerollHelper :
				if (teacher.avHelpers == null)
					throw SE_Invalid(_Err_UselessAction) ;

				if (logic.Data.REROLL_HELPERS_COST > teacher.gold)
					throw SE_Invalid(_Err_NotEnoughMoney) ;

				teacher.rerollHelpers() ;


			case ChooseHelper :
				var h = Type.createEnumIndex(Helper, getNextTarget()) ;

				if (teacher.avHelpers == null)
					throw SE_Invalid(_Err_UselessAction) ;

				if (logic.Data.REROLL_HELPERS_COST > teacher.gold)
					throw SE_Invalid(_Err_NotEnoughMoney) ;

				teacher.chooseHelper(h) ;


			default : throw SE_Fatal("invalid action during Break") ;
		}


		teacher.spendCost(data) ;
		teacher.initCooldowns(Break) ;
		log(L_EndTeacherAction(a, 0, Lambda.list(infos._t))) ;

		if (teacher.pa == 0)
			log(L_Wait(time.last)) ;

		} catch(e : SolverError) {

			var l = new List() ;
			l.push(L_Error(e)) ;
			return l ;
		}
		catch(e : Dynamic) {
			#if neko
				App.current.logError("dynamic error : " + Std.string(e)) ;
			#end

			var l = new List() ;
			l.push(L_Error(SE_Fatal( Std.string(e) ))) ;
			return l ;
		}

		return turnLog ;
	}


	function doRestTurn(infos : SendAction) {
		try {

		turnLog = new List();
		allLog.push(turnLog) ;

		var a = infos._a ;
		var targets = Lambda.list(infos._t) ;

		var data = Common.getTActionData(a) ;

		if (Lambda.exists(lockedActions, function(x) { return Type.enumEq(x.a, a) ; }))
			throw SE_Invalid(_Err_ActionUnavailable(a)) ;

		if (!teacher.canDo(data.id, null))
			throw SE_Invalid(_Err_ActionUnavailable(a)) ;

		var logList = Lambda.list(infos._t) ;

		log(L_TeacherAction(a, logList)) ;

		/*#if flash
		trace("teacher action : " + L_TeacherAction(a, logList)) ;
		#end*/
			
		var getNextTarget = function() : Dynamic {
			if (targets == null || targets.length == 0)
				return null ;

			switch(targets.pop()) {
				case AT_Coord(c) : return {x : c._x, y : c._y} ;
				case AT_Num(n) : return n ;
				case AT_Std(sid) : return getStudent(sid) ;
			}
		}

		switch(a) {
			case Rest :
			
				var value = teacher.getFreeRestValue() ;

				log(L_TeacherHeal(value)) ;
				teacher.dSelfControl(value) ;

			

			case HMoreXp :
				var value = teacher.getFreeXpRestValue() ;
				log(L_XP(null, value)) ;
				log(L_ExtraAdd(0, value)) ;

			case HBonusReward :
				setBonusReward() ;


			case HIll :
				if (!teacher.isMidLife())
					throw SE_Invalid(_Err_NoMidLife) ;
				log(L_GoToIll) ;

			
			case WakeUp :
				//nothing to do

			case UseObject :
				var obj = Type.createEnumIndex(TObject, getNextTarget()) ;
				if (!teacher.hasObject(obj))
					throw SE_Invalid(_Err_ObjectUnavailable) ;

				var oData = Common.getObjectData(obj, []) ;
				if (!oData.always)
					throw SE_Invalid(_Err_CantUseObjectHere) ;

				teacher.useObject(obj, Rest, getNextTarget()) ;


			case Buy :
				var obj = Type.createEnumIndex(TObject, getNextTarget()) ;

				
				var idx = getNextTarget() ;

				if (teacher.hasObject(obj))
					throw SE_Fatal("has object " + Std.string(obj) + ". Cant buy it now") ;

				var objData = Common.getObjectData(obj, teacher.comps) ;

				if (idx < 0 || idx >= objData.cost.length)
					throw SE_Fatal("Invalid selection. Cant buy it now") ;

				if (objData.cost[idx] > teacher.gold)
					throw SE_Invalid(_Err_NotEnoughMoney) ;

				teacher.buyObject(objData, idx) ;

			case HRerollHelper :
				if (teacher.avHelpers == null)
					throw SE_Invalid(_Err_UselessAction) ;

				if (logic.Data.REROLL_HELPERS_COST > teacher.gold)
					throw SE_Invalid(_Err_NotEnoughMoney) ;

				teacher.rerollHelpers() ;

			case ChooseHelper :
				var h = Type.createEnumIndex(Helper, getNextTarget()) ;

				if (teacher.avHelpers == null)
					throw SE_Invalid(_Err_UselessAction) ;

				if (logic.Data.REROLL_HELPERS_COST > teacher.gold)
					throw SE_Invalid(_Err_NotEnoughMoney) ;

				teacher.chooseHelper(h) ;

			default : throw SE_Fatal("invalid action during Break") ;
		}

		teacher.spendCost(data) ;
		teacher.initCooldowns(Rest) ;

		log(L_EndTeacherAction(a, 0, Lambda.list(infos._t))) ;

		if (teacher.pa == 0)
			log(L_Wait(time.last)) ;


		} catch(e : SolverError) {

			/*#if neko
				App.current.logError(Std.string(e)) ;
			#end*/

			var l = new List() ;
			l.push(L_Error(e)) ;
			return l ;
		}
		catch(e : Dynamic) {
			#if neko
				App.current.logError("dynamic error : " + Std.string(e)) ;
			#end

			var l = new List() ;
			l.push(L_Error(SE_Fatal( Std.string(e) ))) ;
			return l ;

		}

		return turnLog ;
	}


	function initTurn(a : TAction) {
		if (!Type.enumEq(a, Buy))
			turn++ ;
		initSeed() ;
		turnLog = new List() ;
		touchTargets = new List() ;
		turnKills = new Array() ;
		allLog.push(turnLog) ;
		minNote = getMinNote() ;
		curDepth = 0 ;
	}


	function doLessonTurn(infos : SendAction) {
		try {

			initTurn(infos._a) ;
			if (waitingAction != null) {
				var check = false ;
				switch(waitingAction.act) {
					case What : check = Type.enumEq(infos._a, Answer) ;
					default : check = false ;
				}

				if (!check)
					throw SE_Fatal("invalid waiting action at init : " + waitingAction + " answer : " + Std.string(infos)) ;			
			}

			/*if (waitingAction == null)
				initTurn(infos._a) ;
			else {
				var check = true ;
				switch(waitingAction.act) {
					case What : check = Type.enumEq(infos._a, Answer) ;
					default : check = false ;
				}

				if (!check)
					throw SE_Fatal("invalid waiting action") ;
			}*/

			if (checkTeacherSleep())
				log(L_TeacherWakeUp) ;
			else
				doAction(infos) ;

			if (waitingAction != null)
				return turnLog ;

			if (checkEnd())
				return turnLog ;

			checkStudentAvailability() ;

			for (s in students)
				s.untouch() ;

			if (checkReplay() != null)
				return turnLog ;

			unlockActions() ;

			cornerHealer.s = null ;

			processEvents() ;
			
			checkMultiKill() ;
			checkGrab() ;

			checkHelperMovement() ;

			checkStudentAvailability() ;

			if (checkEnd())
				return turnLog ;
		
			updateAttention() ;

			for (s in students)
				s.newTurn() ;

			
			/*while(true) {
				var rageId = checkRage() ;
				if (rageId == null)
					break ;
				doStudentAction(rageId, RageAtk) ;
			}*/

			var sid = null ;
			while(true) {
				doStudentAction(sid) ;
				sid = checkReplay(true) ;

				if (sid == null)
					break ;
			}

			checkStudentAvailability() ;

			if (checkEnd())
				return turnLog ;

			teacher.initTurnActions() ;

		} catch(e : SolverError) {

			var l = new List() ;
			l.push(L_Error(e)) ;
			return l ;
		}
		catch(e : Dynamic) {
			#if neko
				App.current.logError("dynamic error : " + Std.string(e)) ;
			#end

			var l = new List() ;
			l.push(L_Error(SE_Fatal( Std.string(e) ))) ;
			return l ;
		}


		/*var infos = "" ;
		for (s in students)
			infos += s.firstname  + " " + s.life + "/" + s.boredom + " => " + s.done() +  " # " + Std.string(s.seat) + " $$$  " ;

		#if neko
			App.current.logError(infos) ;
		#end
		#if flash
			trace(infos) ;
		#end*/

		return turnLog ;
	}


	function checkGrab() {
		if (onTheFloor.length == 0)
			return ;

		//trace(onTheFloor) ;

		for (o in onTheFloor.copy()) {
			o.t-- ;
			if (o.t <= 0 && o.to.isAvailable(true)) {
				log(L_GrabItem(o.to.id, o.oid, o.o)) ;
				onTheFloor.remove(o) ;
			}
		}
	}



	public function getNoteRewards(s : Student) : Float {
		var points = Data.NOTE_REWARD_PER_LINE.copy() ;
		while(lines.length > points.length)
			points.shift() ;

		for (i in 0...lines.length) {
			if (lines[i] == s.seat.y)
				return points[i] + teacher.curBonusReward * logic.Data.BY_BONUS_REWARD ;
		}

		return 0 ;
	}


	public function getHelperLine() {
		return lines[helperLine] ;
	}


	function checkHelperMovement() {
		if (helper == null)
			return ;

		switch(helper) {
			case Director, Inspector, Dog : //continue
			default : return ; //no move
		}

		helperLine++ ;
		if (helperLine >= lines.length)
			helperLine = 0 ;

		var c = getEmptyPlaceOnLine(getHelperLine()) ;
		log(L_HelperMoveTo({_x : c.x, _y : c.y})) ;


		if (Type.enumEq(helper, Director)) {
			var studs = getStudentByLine(getHelperLine(), null) ;
			if (studs.length == 0)
				return ;

			var cleanables = [] ;

			for (s in studs) {
				if (s.hasCleanableStates())
					cleanables.push(s) ;
			}

			if (cleanables.length == 0)
				return ;

			var s = cleanables[random(cleanables.length)] ;

			log(L_TriggerHelper(Director, [s.id] )) ;
			s.clean() ;
		}
	}


	function checkStudentAvailability() {
		var av = 0 ;
		var activables = new Array() ;

		for (s in students) {
			if (s.done())
				continue ;
			if (!s.isAvailable(true))
				activables.push(s) ;
			else
				av++ ;
		}

		if (av > 0) //nothing to do
			return ;

		if (activables.length == 0)
			return ; //nothing to do

		var std = activables[random(activables.length)] ;

		if (std.out) {
			std.comeIn() ;
			if (std.isAvailable(true))
				return ;
		}

		if (std.cornered) {
			std.cornerBack() ;
			if (std.isAvailable(true))
				return ;
		}

		var us = Data.UNAVAILABILITY_STATES.copy() ;
		//us.remove(Book) ;

		for (st in us) {
			if (std.hasState(st))
				std.removeState(st) ;

			if (std.isAvailable(true))
				return ;
		}
	}


	function unlockActions() {
		if (lockedActions.length > 0)
			log(L_LockObjects(false)) ;
		lockedActions = [] ;
	}


	function doAction(infos : SendAction) {
		var a = infos._a ;
		var targets = Lambda.list(infos._t) ;

		var data = Common.getTActionData(a) ;

		var getNextTarget = function(?popIt = true) : Dynamic {
			if (targets == null || targets.length == 0)
				return null ;

			var t = (popIt) ? targets.pop() : targets.first() ;

			switch(t) {
				case AT_Coord(c) : return {x : c._x, y : c._y} ;
				case AT_Num(n) : return n ;
				case AT_Std(sid) :
					var std : Student = getStudent(sid) ;
					if (std != null)
						std.touch() ;
					return std ;
			}
		}


		/*var debug = "COOLDOWN : "  ;
		for (a in teacher.getAllActions())
			debug += a.data.id + ":"+ a.cooldown + ", " ;
		#if neko
			App.current.logError(debug) ;
		#end
		#if flash
			trace(debug) ;
		#end*/


		if (!teacher.canDo(data.id, (Type.enumEq(data.id, UseObject)) ? getNextTarget(false) : null ))
			throw SE_Invalid(_Err_ActionUnavailable(data.id)) ;

		var logList = Lambda.list(infos._t) ;
		if (Type.enumEq(a, Answer))
			logList.push(AT_Std(waitingAction.stud.id)) ;

		log(L_TeacherAction(a, logList, touchTargets)) ;

		if (isStockAction(a))
			unsetStockAction() ;

		switch(a) {
			case Teach, BigTeach :
				//var stds = getStudentByLine(getNextTarget(), null) ;

				var stud : Student = getNextTarget() ;
				var stds = stud.getTableNeighbours() ;
				stds.push(stud) ;

				var k = teacher.getKnowledge(a) ;

				if (stds.length > 0) {
					for (s in stds) {
						if (!s.isAvailable(true))
							continue ;
						s.touch() ;
						s.hit(k) ;
					}
				}


			case Smite :

				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else
					stud.hit(teacher.getKnowledge(a)) ;

				
			case Exercice :

				for (s in students) {
					if (!s.isAvailable(true))
						continue ;
					if (s.handUp != null)
						s.removeHandUp(true) ;
					s.touch() ;
					events.push(Ev_Exercice(s.id, 2, false)) ;
				}


			case Swap :

				var coords = new Array() ;
				coords.push(getNextTarget()) ;
				coords.push(getNextTarget()) ;


				
				var s0 : Student = getStudentByPos(coords[0], true) ;
				var s1 : Student = getStudentByPos(coords[1], true) ;


				if (s0 == null && s1 == null)
					throw SE_Invalid(_Err_CantSwapEmptySeats) ;

				if (s1 == null && s0 != null && !s0.canBeTargeted())
					throw SE_Invalid(_Err_CantSwapEmptySeats) ;

				if ((s0 != null && !s0.isAvailable(true) && s0.canBeTargeted()) || (s1 != null && !s1.isAvailable(true) && s1.canBeTargeted()))
					throw SE_Invalid(_Err_CantSwapUnavailableStudent) ;

				var s0Speaks = false ;
				var s1Speaks = false ;

				if (s0 != null) {
					s0.seat = coords[1] ;
					s0.touch() ;
					if (s0.hasState(Speak)) {
						s0Speaks = true ;
						s0.removeState(Speak) ;
					}

					if (s0.canBeTargeted(true))
						log(L_SwapTo(s0.id, {_x : s0.seat.x, _y : s0.seat.y})) ;
				}
				if (s1 != null) {
					s1.seat = coords[0] ;
					s1.touch() ;
					if (s1.hasState(Speak)) {
						s1Speaks = true ;
						s1.removeState(Speak) ;
					}
					if (s1.canBeTargeted(true))
						log(L_SwapTo(s1.id, {_x : s1.seat.x, _y : s1.seat.y})) ;
				}

				if (s0Speaks)
					doStudentAction(s0.id, Give_Speak) ;
				if (s1Speaks)
					doStudentAction(s1.id, Give_Speak) ;


				addTeacherReplay(Swap) ;

			
			case What :
				var stud : Student = getNextTarget() ;
				if (stud.handUp == null)
					throw SE_Fatal("cant say 'what' without HandUp #" + stud.id) ;

				switch(stud.getWhat()) {
					case HW_Cheat(sid) :
						var choice = null ;
						var d = 1 ;
						while (choice == null && d <= 10) {
							var near = studentNear(stud, d) ;
							if (near.length > 0) {
								choice = near[random(near.length)] ;
								if (!choice.isAvailable())
									choice = null ;
							}
							d += 1 ;
						}

						if (choice == null) { //FORCE HW_OUT
							stud.handUp.what = HW_Out(1 + random(2)) ;
							waitingAction = {act : What, stud : stud} ;
							log(L_StudentSay(stud.id, stud.handUp.what)) ;
						} else {
							stud.handUp.what = HW_Cheat(choice.id) ;

							log(L_StudentSay(stud.id, stud.handUp.what)) ;
							
							var sData = Common.getStudentActionData(HandUpCheat) ;
							choice.studentHit(stud.getKnowledgeHit(sData), sData.id, stud) ;

							stud.removeHandUp(true) ;
						}

						addTeacherReplay(What) ;

					case HW_Heal(n) :
						var h = [	3, 3, 3, 3,
									4, 4, 4, 4,
									5,
									6] ;

						var n = h[random(h.length)] ;
						log(L_StudentSay(stud.id, HW_Heal(n))) ;
						log(L_TeacherHeal(n)) ;
						teacher.dSelfControl(n) ;
						stud.removeHandUp(true) ;

						addTeacherReplay(What) ;

					case HW_Note :

						log(L_StudentSay(stud.id, HW_Note)) ;
						stud.addState(HandUpBonusPoint) ;
						stud.removeHandUp(true) ;
						addTeacherReplay(What) ;

					default :
						waitingAction = {act : What, stud : stud} ;
						log(L_StudentSay(stud.id, stud.handUp.what)) ;
				}
				

			case Answer:
					if (waitingAction == null)
						throw SE_Fatal("missing waiting action") ;
					if (!Type.enumEq(waitingAction.act, What))
						throw SE_Fatal("invalid waiting action : " + waitingAction) ;

					var stud = waitingAction.stud ;
					if (stud.handUp == null)
						throw SE_Fatal("cant say 'what' without HandUp") ;

					var agree = true ;
					switch(stud.getWhat()) {
						case HW_Out(time) :
							var answer = getNextTarget() ;
							if (answer == 0) {
								stud.out = true ;
								if (stud.hasState(Speak))
									stud.removeState(Speak) ;
								addStudentOut(stud.id, time, false, true) ;
								log(L_StudentGoOut(stud.id)) ;
							} else
								agree = false ;

							stud.removeHandUp(agree) ;

						case HW_Question(l) :
							var pa = getNextTarget() ;

							var effect = l[pa] ;
							/*for (e in l) {
								if (e.life != pa)
									continue ;
								effect = e ;
								break ;
							}*/


							if (effect == null)
								throw SE_Fatal("invalid answer : " + pa) ;

							teacher.dSelfControl( -1 * effect.life ) ;
							stud.removeHandUp(agree) ;

							switch(effect.give) {
								case QR_Hit(n) :
									stud.hit({value : n, crit : 0, resist : 0, type : null}, false) ;

								case QR_State(st) :
									if (stud.hasState(st))
										stud.removeState(st) ; //in case of refresh state timer (ex : Harmless)
									stud.addState(st) ;

								case QR_Clean :
									stud.clean() ;

								case QR_Heal(n) :
									teacher.dSelfControl(n) ;
							}

						default : //nothing to do

						/*case HW_Heal(n) :
							log(L_TeacherHeal(n)) ;
							teacher.dSelfControl(n) ;
							stud.removeHandUp(true) ;

						case HW_Cheat(sid) :
							var choice = getStudent(sid) ;
							
							if (choice == null)
								log(L_NoEffect(stud.id)) ;
							else {
								var sData = Common.getStudentActionData(HandUpCheat) ;
								choice.studentHit(stud.getKnowledgeHit(sData), sData.id, stud) ;
								
								if (stud.hasUltima(SelfKO))
									stud.dUltimaCoolDown(6 + random(10)) ;
							}

							stud.removeHandUp(agree) ;*/
					}

					waitingAction = null ;
					/*for (e in events.copy()) {
						switch(e) {
							case Ev_HandUp(sid, time) :
								if (sid != stud.id)
									continue ;
								events.remove(e) ;
								break ;
							default : continue ;
						}
					}*/

					addTeacherReplay(What) ;


			case Clean, Clean_0, Clean_1 :
				var stud : Student = getNextTarget() ;

				if (!stud.canBeTargeted())
					throw SE_Invalid(_Err_StudentUnavailable) ;

				var stds = new List() ;
				if (Type.enumEq(Clean_1, a))
					stds = stds.concat(stud.getTableNeighbours()) ;
				stds.push(stud) ;

				for (s in stds) {
					if (!s.canBeTargeted())
						continue ;

					
					var done = s.clean() ;
					var oldBoredom = s.boredom ;
					s.removeBoredom(1) ;
					if (oldBoredom > s.boredom)
						s.oneShot = false ;

					/*if (done && !s.hasState(Attentive))
						s.addState(Attentive) ;*/

					if (Type.enumEq(Clean_0, a))
						teacher.dSelfControl(3) ;
					
				}
			

			case HardTeach, HardTeach_0, HardTeach_1 :

				var count = 0 ;
				var stds = getStudentByLine(null, getNextTarget()) ;

				for (s in stds) {
					if (s.isAvailable(true)) {
						s.touch() ;

						var k = teacher.getKnowledge(a) ;
						if (count == 0 && Type.enumEq(HardTeach_1, a))
							k.value++ ;
						s.hit(k) ;
					}
					count++ ;
				}

			
			/*case Reprimand, Reprimand_0, Reprimand_1 :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else {
				


					var value = stud.addBoredom(2) ;
					value = switch(value) {
								case 2 : 5 + ((Type.enumEq(Reprimand_0, a)) ? 1 : 0) ;
								case 1 : 3 ;
								case 0 : 0 ;
							} ;


					var v = teacher.dSelfControl(value) ;
					log(L_TeacherHeal(v)) ;

				}*/

			case TestTeach, TestTeach_0, TestTeach_1 :
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else
					stud.hit(teacher.getKnowledge(a)) ;

				if (Type.enumEq(a, TestTeach_1) && stud.done()) {
					var neighbours = stud.getTableNeighbours() ;
					for (n in neighbours) {
						if (n.isAvailable(true))
							n.addState(Attentive) ;
					}
				}

			case MoreAttention, MoreAttention_0, MoreAttention_1 :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				var stds = stud.getTableNeighbours() ;
				stds.push(stud) ;


				var countBored = 0 ;
				for (s in stds) {
					if (!s.isAvailable(true))
						continue ;
					if (s.boredom > 0)
						countBored++ ;
				}


				for (s in stds) {
					if (!s.isAvailable(true))
						continue ;
					s.touch() ;
					var oldBoredom = s.boredom ;
					s.removeBoredom(5) ;
					if (oldBoredom > s.boredom)
						s.oneShot = false ;
					if (!s.hasState(Attentive) && (Type.enumEq(a, MoreAttention_1) || (countBored == 1 && oldBoredom > 0)))
						s.addState(Attentive) ;
				}

				/*if (neighbours.length == 0) {
					stud.removeBoredom(4) ;
					stud.touch() ;
					if (!stud.hasState(Attentive))
						stud.addState(Attentive) ;
				} else {
					neighbours.push(stud) ;
					for (n in neighbours) {
						n.touch() ;
						n.removeBoredom(3) ;
						if (Type.enumEq(a, MoreAttention_1) && !n.hasState(Attentive))
							n.addState(Attentive) ;
					}
				}*/

			case Grab :



				var objId = getNextTarget() ;
				var found = false ;

				for (f in onTheFloor.copy()) {
					if (f.oid != objId)
						continue ;

					teacher.loot(f.o) ;
					onTheFloor.remove(f) ;

					found = true ;
					break ;
				}

				if (!found)
					throw SE_Fatal("cant find object to grab") ;

			//SUPERS :


			case GoToBoard :
				
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else {
					stud.removeBoredom(stud.boredom) ;
					stud.hit(teacher.getKnowledge(a)) ;
				}

			
			case Cogitate :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else
					events.push(Ev_TeachDot(stud.id, Cogitate, 3)) ;


			case Exam :
				for (s in students) {
					if (!s.isAvailable(true))
						continue ;
					s.touch() ;
					s.clean() ;
					if (random(4) == 0)
						s.addBoredom(1) ;
					//events.push(Ev_TeachDot(s.id, Exam, 3)) ;
				}

			case Seriously :
				var stud : Student = getNextTarget() ;
				var stds = stud.getTableNeighbours() ;
				stds.push(stud) ;

				for (s in stds) {
					if (!s.isAvailable(true))
						continue ;
					s.touch() ;
					s.hit(teacher.getKnowledge(a, (s.hasNegativeState()) ? 1 : 0 )) ;
				}
			
			case CounterAttack :
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else
					stud.hit(teacher.getKnowledge(a, (stud == cornerHealer.s) ? cornerHealer.hit : 0 )) ;

			/*case FirstAid :
				var stud : Student = getNextTarget() ;
				for (st in [KO, Tetanised, BrokenHeart]) {
					if (stud.hasState(st))
						stud.removeState(st) ;
				}*/

			case Sacrifice :
				var stud : Student = getNextTarget() ;
				
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				var boring = stud.boredom ;
				stud.hit(teacher.getKnowledge(a, boring)) ;

				if (boring > 0)
					teacher.dSelfControl(-1 * boring) ;


			/*case Dissection :
				for (s in students) {
					if (!s.isAvailable(true))
						continue ;
					s.touch() ;
					s.hit(teacher.getKnowledge(a)) ;
					if (s.gender == 0)
						s.addState(Attentive) ;
				}*/


			case SuperBook :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else
					stud.addState(Book) ;


			case LangageAid :
				var life = 4 + random(3) ;
				events.push(Ev_Object(LangageAid, 999, life)) ;


			case Anecdote :
				var stud : Student = getNextTarget() ;
				var stds = stud.getTableNeighbours() ;
				stds.push(stud) ;


				for (s in stds) {
					if (!s.isAvailable(true))
						continue ;
					s.touch() ;
					s.hit(teacher.getKnowledge(a)) ;
				}

			case MathBump :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				stud.addState(KO) ;

				var avStuds = students.copy() ;
				avStuds.remove(stud) ;

				var n = stud.boredom ;
				while (n > 0 && avStuds.length > 0) {
					var s = avStuds[random(avStuds.length)] ;
					avStuds.remove(s) ;

					if (!s.isAvailable(true) || s.hasState(Attentive))
						continue ;

					s.addState(Attentive) ;
					n-- ;
				}


			case BigClean :
				var stds = getStudentByLine(null, getNextTarget()) ;

				for (s in stds) {
					s.touch() ;
					s.clean() ;
					var oldBoredom = s.boredom ;
					s.removeBoredom(1) ;
					if (oldBoredom > s.boredom)
						s.oneShot = false ;
				}

		

			case Projector :
				for (s in students) {
					if (!s.isAvailable(true))
						continue ;
					s.touch() ;
					var oldBoredom = s.boredom ;
					s.removeBoredom(2) ;
					if (oldBoredom > s.boredom)
						s.oneShot = false ;
					
				}

			

			case AllAttentive :
				var stds = getStudentByLine(getNextTarget(), null) ;
				if (stds.length > 0) {
					for (s in stds) {
						if (s.isAvailable(true) && !s.hasState(Attentive)) {
							s.touch() ;
							s.addState(Attentive) ;
						}
					}
				}


			case BonusKill :
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				teacher.curBonusReward+= 1 ;
				stud.hit(teacher.getKnowledge(a)) ;
				teacher.curBonusReward-= 1 ;



			case BigHardTeach :
				var stds = getStudentByLine(null, getNextTarget()) ;
				for (s in stds) {
					if (s.isAvailable(true)) {
						s.touch() ;
						var k = teacher.getKnowledge(a) ;
						s.hit(k) ;
					}
				}


			case BestTestTeach :
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else
					stud.hit(teacher.getKnowledge(a)) ;

				if (stud.done()) {
					var neighbours = stud.getTableNeighbours() ;
					for (n in neighbours) {
						if (n.isAvailable(true))
							n.addState(Attentive) ;
					}
				}

			case BestMoreAttention :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				var stds = stud.getTableNeighbours() ;
				stds.push(stud) ;

				for (s in stds) {
					s.touch() ;
					var oldBoredom = s.boredom ;
					s.removeBoredom(5) ;
					if (oldBoredom > s.boredom)
						s.oneShot = false ;
					if (!s.hasState(Attentive) && oldBoredom > 0)
						s.addState(Attentive) ;
				}

			case ExtensiveTeach :
				var stds = getStudentByLine(getNextTarget(), null) ;
				if (stds.length > 0) {
					for (s in stds) {
						if (s.isAvailable(true)) {
							s.touch() ;
							s.hit(teacher.getKnowledge(a)) ;
						}
					}
				}

			case Hypnotism :
				var s : Student = getNextTarget() ;
				if (!s.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				var oldBoredom = s.boredom ;
				s.removeBoredom(4) ;
				if (oldBoredom > s.boredom)
					s.oneShot = false ;
				s.addState(VeryAttentive) ;


			case CoolTeach :
				var s : Student = getNextTarget() ;
				if (!s.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				var all = s.life ;
				s.hit(teacher.getKnowledge(a)) ;

				var healValue = all - s.life ;
				if (healValue > 0) {
					log(L_TeacherHeal(healValue)) ;
					teacher.dSelfControl(healValue) ;
				}


			case OtherBigClean :
				var stds = getStudentByLine(getNextTarget(), null) ;

				for (s in stds) {
					s.touch() ;
					s.clean() ;
					var oldBoredom = s.boredom ;
					s.removeBoredom(1) ;
					if (oldBoredom > s.boredom)
						s.oneShot = false ;
				}


			case TeachingFlick :
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				teacher.curBonusReward+= 3 ;
				stud.hit(teacher.getKnowledge(a)) ;
				teacher.curBonusReward-= 3 ;


			case AcademicBomb :
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				stud.addState(Bomb3) ;

			case LifeTransfer :
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				stud.addState(LifeTransfer) ;

			//######################################################################################
			//###############################     PET ACTIONS     ##################################
			//######################################################################################

			case ChoosePet :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true) || stud.hasState(Pet))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				setPet(stud) ;
				addTeacherReplay() ;

			case Pet_IronWill :
				var value = 1 ;
				log(L_TeacherHeal(value)) ;
				teacher.dSelfControl(value) ;

				addTeacherReplay() ;

			case Pet_ElbowHit :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				var oldBoredom = stud.boredom ;
				stud.removeBoredom(1) ;
				if (oldBoredom > stud.boredom)
					stud.oneShot = false ;

				addTeacherReplay() ;

			case Pet_Meditate :
				var stud : Student = getNextTarget() ;

				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;


				stud.addBoredom(1) ;
				var value = 2 ;
				log(L_TeacherHeal(value)) ;
				teacher.dSelfControl(value) ;

				addTeacherReplay() ;


			case Pet_Explication :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				stud.hit(teacher.getKnowledge(a, false)) ;

				addTeacherReplay() ;

			case Pet_Valium :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				stud.addState(Harmless) ;
				addTeacherReplay() ;

			case Pet_Sleep :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				stud.addState(Doughy) ;

				addTeacherReplay() ;

			case Pet_Alzheimer :

				teacher.updateCoolDowns(null, true, 2) ;
				teacher.initTurnActions() ;
				addTeacherReplay() ;

			case Pet_Club :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				stud.addState(Headache) ;

				addTeacherReplay() ;

			case Pet_Dring :
				for (s in students) {
					if (!s.hasState(Asleep))
						continue ;
					s.touch() ;
					s.removeState(Asleep) ;
					s.addState(Attentive) ;
				}

				addTeacherReplay() ;

			case Pet_ToTheCorner :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				else if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;
				else {
					stud.cornered = true ;
					if (stud.hasState(Speak))
						stud.removeState(Speak) ;
					if (stud.hasState(Lol))
						stud.removeState(Lol) ;
					events.push(Ev_Corner(stud.id, 3)) ;

					log(L_CornerStart(stud.id, false)) ;

					addTeacherReplay() ;
				}


			case Pet_Stock :
				var stud : Student = getNextTarget() ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;
				stud.addState(VeryAttentive) ;

				addTeacherReplay() ;

			case Pet_Shock :
				var stud : Student = getNextTarget() ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				for (st in [KO, Tetanised, BrokenHeart, InLove, Clone]) {
					if (stud.hasState(st)) {
						stud.touch() ;
						stud.removeState(st) ;
					}
				}

				addTeacherReplay() ;

			case Pet_ComeOn :
				var avSeats = getEmptySeats(false) ;
				Solver.sort(avSeats, function(a : Coords, b : Coords) {
								return b.y - a.y ;
							}) ;

				var studs = [] ;
				for (y in 0...lines.length) {
					var toSort = getStudentByLine(lines[lines.length - 1 - y], null) ;

					Solver.sort(toSort, function(a : Student, b : Student) {
						return Std.int(a.note * 10) - Std.int(b.note * 10) ;
					}) ;
					studs = studs.concat(toSort) ;
				}




				if (studs[0].seat.y < avSeats[0].y) {
					var debug = 20 ;
					while(debug > 0 && studs.length > 0 && avSeats.length > 0) {
						debug-- ;
						var s = studs.shift() ;
						if (!s.isAvailable(true))
							continue ;
						
						if (s.seat.y >= avSeats[0].y)
							break ;

						var old = s.seat ;


						var ns = avSeats.shift() ;

						for (os in students) {
							if (os.seat != null && os.seat.x == ns.x  && os.seat.y == ns.y) {
								os.seat = old ;
								break ;
							}
						}

						s.seat = ns ;
						s.touch() ;
						log(L_SwapTo(s.id, {_x : s.seat.x, _y : s.seat.y})) ;
					}
				} else {
					throw SE_Invalid(_Err_UselessAction) ;
					
				}

				addTeacherReplay() ;

			case Pet_Cheater :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;
				if (stud.hasState(BonusPoint))
					throw SE_Invalid(_Err_StudentUnavailable) ;

				stud.addState(BonusPoint) ;

				addTeacherReplay() ;

			case Pet_BonusXp :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				stud.hit(teacher.getKnowledge(a)) ;
				if (stud.done()) {
					stud.success++ ;
					log(L_XP(stud.id, 1)) ;
				}

				addTeacherReplay() ;

			case Pet_Tickle :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				var oldBoredom = stud.boredom ;
				stud.removeBoredom(stud.boredom) ;
				if (oldBoredom > stud.boredom)
					stud.oneShot = false ;
				stud.addState(Angry) ;

				addTeacherReplay() ;

			case Pet_Muscled :
				var t : Coords = getNextTarget() ;
				var to = {x : t.x, y  :t.y + 2} ;
				var lineFound = false ;
				for (l in lines) {
					if (to.y == l) {
						lineFound = true ;
						break ;
					}
				}
				if (!lineFound)
					throw SE_Invalid(_Err_CantMoveTable) ;

				for (s in seats.copy()) {
					if (s.x == t.x && s.y == t.y)
						seats.remove(s) ;
					if (s.x == to.x && s.y == to.y) //destination seat already exists
						throw SE_Invalid(_Err_CantMoveTable) ;
				}

				
				var stud = getStudentByPos(t) ;
				if(stud != null) {
					if (stud.canBeTargeted() && !stud.isAvailable(true))
						throw SE_Invalid(_Err_StudentUnavailable) ;
					stud.seat = {x: to.x, y : to.y} ;
				}

				seats.push(to) ;

				if (supervisorSeats.length > 0) {
					for (s in supervisorSeats.copy()) {
						if (s.x == t.x && s.y == t.y) {
							supervisorSeats.remove(s) ;
							supervisorSeats.push(to) ;
							break ;
						}
					}

				}

				for (it in teacher.items.copy()) {
					if (it._x == t.x && it._y == t.y) {
						teacher.items.remove(it) ;
						break ;
					}
				}
				teacher.items.push({_x : to.x, _y : to.y}) ;


				log(L_SwapTable({_x : t.x, _y : t.y}, {_x : to.x, _y : to.y}, (stud != null) ? stud.id : null)) ;

				addTeacherReplay() ;

			case Pet_Hot :
				events.push(Ev_TeachDot(curPet.s.id, Pet_Hot, 3)) ;
				addTeacherReplay() ;


			case Pet_Exclude :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				stud.exclude() ;

				addTeacherReplay() ;

			case Pet_BoringTransfer :
				var stud : Student = getNextTarget() ;
				if (!stud.isAvailable(true))
					throw SE_Invalid(_Err_StudentUnavailable) ;
				if (stud.hasState(Pet))
					throw SE_Invalid(_Err_CantTargetPet) ;

				var b = Std.int(Math.round(stud.boredom / 2)) ;

				var oldBoredom = stud.boredom ;
				stud.removeBoredom(b) ;
				if (oldBoredom > stud.boredom)
					stud.oneShot = false ;

				if (b > 0) {
					var neighbours = stud.getTableNeighbours() ;
					if (neighbours.length > 0) {
						var nb = Std.int(Math.floor(b / neighbours.length)) ;
						if (nb > 0) {
							for (n in neighbours)
								n.addBoredom(nb) ;
						}
					} else
						stud.addBoredom(b) ;
				}

				addTeacherReplay() ;

			case Pet_NoLaugh :
				var stud : Student = getNextTarget() ;
				var stds = stud.getTableNeighbours() ;
				stds.push(stud) ;

				if (stds.length > 0) {
					for (s in stds) {
						if (!s.canBeTargeted())
							continue ;
						s.touch() ;
						if (s.hasState(Lol))
							s.removeState(Lol) ;
					}
				}

				addTeacherReplay() ;

			case Pet_Chut :
				var stud : Student = getNextTarget() ;
				var stds = stud.getTableNeighbours() ;
				stds.push(stud) ;

				if (stds.length > 0) {
					for (s in stds) {
						if (!s.canBeTargeted())
							continue ;
						s.touch() ;
						if (s.clean(2))
							s.addBoredom(1) ;
					}
				}

				addTeacherReplay() ;
			
			//######################################################################################
			//######################################################################################
			//######################################################################################


			case UseObject :
				var obj = Type.createEnumIndex(TObject, getNextTarget()) ;
				if (!teacher.hasObject(obj))
					throw SE_Invalid(_Err_ObjectUnavailable) ;

				teacher.useObject(obj, Lesson(subject), getNextTarget()) ;

				addTeacherReplay(obj) ;

			case Buy :
				var obj = Type.createEnumIndex(TObject, getNextTarget()) ;

				var idx = getNextTarget() ;

				if (teacher.hasObject(obj))
					throw SE_Fatal("has object " + Std.string(obj) + ". Cant buy it now") ;

				var objData = Common.getObjectData(obj, teacher.comps) ;

				if (idx < 0 || idx >= objData.cost.length)
					throw SE_Fatal("Invalid selection. Cant buy it now") ;

				if (objData.cost[idx] > teacher.gold)
					throw SE_Invalid(_Err_NotEnoughMoney) ;

				teacher.buyObject(objData, idx) ;
				addTeacherReplay(false) ;


			case MoreSlots :

				if (!initAction && logic.Data.MORESLOTS_COST > teacher.gold)
					throw SE_Invalid(_Err_NotEnoughMoney) ;

				teacher.spendGold(logic.Data.MORESLOTS_COST, MoreSlots) ;

				teacher.updateCoolDowns(null, true, 2, true) ;
				teacher.initTurnActions(false, null, true) ;

				addTeacherReplay(MoreSlots) ;

			default :
				throw SE_Fatal("invalid action : " + Std.string(a)) ;

		}

		var spent = teacher.spendCost(data) ;

		if (curPet != null && Type.enumEq(curPet.a, a))
			curPet.s.incPetAction() ;

		var nc = teacher.updateCoolDowns(a, spent) ;

		teacher.checkSuperAttack() ;
		checkMultiKill() ;

		log(L_EndTeacherAction(a, nc, Lambda.list(infos._t), touchTargets)) ;

		teacher.lastAction = a ;
	}


	function checkMultiKill() {
		if (turnKills.length > 1 && helper != null) {
			switch(helper) {
				case Peggy :
					log(L_TriggerHelper(Peggy, turnKills.copy())) ;
					for (sid in turnKills) {
						getStudent(sid).success++ ;
						log(L_XP(sid, 1)) ;
					}

				case Skeleton :
					log(L_TriggerHelper(Skeleton)) ;
					if (teacher.superAttack[1] <= 0)
						teacher.addSuperAttack(1) ;

				default : //nothing to do
			}
		}
		turnKills = new Array() ;
	}


	function getPlayingStudent() : Student {
		var avStudents = new Array() ;

		for (s in students) {
			if (!s.canPlay())
				continue ;

			if (avStudents[s.coolDown] == null)
				avStudents[s.coolDown] = new Array() ;
			avStudents[s.coolDown].push({std : s, weight : (s.isHostile()) ? 5 : 1 }) ;
		}

		var stud = null ;
		for (i in 0...avStudents.length) {
			if (avStudents[i] == null)
				continue ;
			return randomWeight(cast avStudents[i]).std ;
		}

		return null ;
	}


	public function setBonusReward() {
		teacher.bonusRewards++ ;



		var notes = [] ;
		for (s in students) {
			if (s.lastReward >= 0)
				notes.push({sid : s.id, r : logic.Data.BY_BONUS_REWARD}) ;
		}
		log(L_ExtraReward(notes)) ;
	}


	function doStudentAction(?sid : Int, ?cloneAction : SAction) {
		var tries = 30 ;
		var act = null ;
		var s : Student = null ;

		
		//checkUltima
		if (ultima != null) {
			var avUltimaStuds = [] ;
			for (s in students) {
				if (s.isAvailable(true) && s.hasUltima())
					avUltimaStuds.push(s) ;
			}

			if (avUltimaStuds.length > 0) {
				ultima-- ;
				if (ultima <= 0) { //launch ultima action
					var ultimaAct = null ;
					while(s == null && avUltimaStuds.length > 0) {
						s = avUltimaStuds[random(avUltimaStuds.length)] ;
						ultimaAct = s.getRandUltima() ;

						avUltimaStuds.remove(s) ;
						if (!s.canLaunchAction(ultimaAct)) {
							s = null ;
							ultimaAct = null ;
						}
					}

					if (s != null) {
						act = s.getAction(ultimaAct) ;
						ultima = null ;
						if (act.a == null) //fail
							act = null ;
					}
				}
			}
		}

		if (launch.length > 0) {
			if (launch[0] > 0) {
				for (i in 0...launch.length)
					launch[i]-- ;
			}

			if (act == null && launch[0] <= 0) {
				var avStudents = new Array() ;
				for (s in students) {
					if (s.isAvailable(true))
						avStudents.push(s) ;
				}

				var launcher = avStudents[random(avStudents.length)] ;
				avStudents.remove(launcher) ;
				if (avStudents.length > 0) {
					launch.shift() ;
					s = launcher ;
					act = s.getAction(LaunchThing) ;
					if (act.a == null) //fail
						act = null ;
				}
			}
		}


		while (act == null && tries >= 0) {
			s = if (sid != null) getStudent(sid) else getPlayingStudent() ;
			if (s == null)
				return ;

			act = s.getAction(cloneAction) ;

			if (act.a == null) {
				act = null ;
				for (st in students) {
					if (st.id != s.id)
						st.newTurn(true) ;
				}
			} else
				break ; //found
			tries-- ;
		}

		if (act == null || act.a == null) //cant find student with available action. Fizzle
			return ;

		s.resetCooldown() ;
		log(L_StudentAction(s.id, act.a, act.targets)) ;

		cornerHealer.canSave = true ;

		/*#if flash
		trace("student action : " + s.firstname + " => " + L_StudentAction(s.id, act.a, act.targets)) ;
		#end*/

		var actData = Common.getStudentActionData(act.a) ;
		var target = if (act.targets != null) getStudent(act.targets[0]) else null ;
		var damages = s.getDamages(actData) ;
		


		switch(act.a) {
			case Atk_N_0, Atk_N_1, Atk_N_2, Atk_N_3, Atk_N_4, Atk_N_5, Atk_N_7, Atk_N_8, Atk_N_9, Atk_Asleep  :
				//attaques standards noisy
				teacher.hit(actData, damages, s) ;

			case Atk_Ph_0, Atk_Ph_1, Atk_Ph_2, Atk_Ph_3, Atk_Ph_4, Atk_Ph_6, Atk_Ph_7, Atk_Ph_8, Atk_Ph_9 :
				//attaques standards physic
				teacher.hit(actData, damages, s) ;

			case Atk_Ps_0, Atk_Ps_1, Atk_Ps_2, Atk_Ps_3, Atk_Ps_4, Atk_Ps_7 :
				//attaques standards psy
				teacher.hit(actData, damages, s) ;


			case Atk_N_6 : //coussin péteur
				target.addState(Tetanised) ;
				teacher.hit(actData, damages, s) ;

			case Atk_Ph_5 : //punaises
				target.studentHit(s.getKnowledgeHit(actData), act.a, s) ;
				teacher.hit(actData, damages, s) ;

			case Atk_Ps_5 : //redoublants tourmenteurs
				var value = Std.int(Math.floor(teacher.selfControl / 2)) ;
				log(L_TeacherHit(s.id, value, act.a, null)) ;
				teacher.dSelfControl(value * -1) ;

			case Atk_Ps_6 : //odeur déplaisante
				var knowledge = s.getKnowledgeHit(actData) ;
				for (st in studentNear(s)) {
					if (st.isAvailable(true) && random(2) == 0)
						st.studentHit(knowledge, act.a, s) ;
				}

				teacher.hit(actData, damages, s) ;

			case RageAtk :
				teacher.hit(actData, damages, s) ;
				s.removeState(Rage) ;

			case Add_Asleep, Give_Asleep :
				target.addState(Asleep) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Slow, Give_Slow :
				target.addState(Slowed) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Inverted : //attention
				target.addState(Inverted) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Moon, Give_Moon : //attention
				target.addState(Moon) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Boredom : //bordeom +1
				target.addBoredom(1) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_BigBoredom : //boredom +2
				target.addBoredom(2) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Lol, Give_Lol : //event
				target.addState(Lol) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Angry : //event
				target.addState(Angry) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Chewing, Give_Chewing : //event
				target.addState(Chewing) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Tictic :
				target.addState(TicTic) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Voodoo :
				target.addState(Voodoo) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Singing :
				target.addState(Singing) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_BoringGenerator :
				target.addState(BoringGenerator) ;
				target.addBoredom(2) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;


			case Add_BadBehaviour : //event
				target.addState(BadBehaviour) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Invisibility, Give_Invisibility : //event
				target.addState(Invisibility) ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Give_KO :
				target.setKO() ;
				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Give_Speak :
				if (!s.hasState(Speak))
					s.addState(Speak) ;
				s.addSpeaker(target) ;

				target.addState(Speak) ;
				target.addSpeaker(s) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Add_Clone :
				s.addState(Clone) ;
				target.clonedBy(s) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case HandUpOut :
				s.setHandUp(HandUpOut, random(2) == 0) ;
				events.push(Ev_HandUp(s.id, 1 + random(3))) ;

			case HandUpQuestion :
				s.setHandUp(HandUpQuestion, random(3) > 0) ;
				events.push(Ev_HandUp(s.id, 1 + random(3))) ;

			case HandUpCheat :
				s.setHandUp(HandUpCheat, random(3) > 0) ;
				events.push(Ev_HandUp(s.id, 1 + random(3))) ;

			case HandUpHeal :
				s.setHandUp(HandUpHeal, random(3) == 0) ;
				events.push(Ev_HandUp(s.id, 1 + random(2))) ;

			case HandUpNote :
				s.setHandUp(HandUpNote, random(3) == 0) ;
				events.push(Ev_HandUp(s.id, 1 + random(2))) ;

			
			case CopyChar :
				if (!s.copyChar(target))
					log(L_ActionFailed) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case LaunchThing :
				var item = s.dropItem() ;

				//var oid = Std.parseInt(Std.string(turn + "" + s.id)) ; //bug neko 2
				var oid = Std.parseInt(Std.string(turn + "" + onTheFloor.length)) ;
				
				onTheFloor.push({oid : oid, o : item, from : s, to : target, t : 1}) ;
				log(L_LaunchItem(oid, item, s.id, target.id, false) ) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case FallInLove :
				s.setLover(target) ;
				if (target.hasState(InLove))
					target.removeState(InLove) ;
				target.setLover(s) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case BrokeHeart :
				if (s.inLoveWith != null && s.inLoveWith == target.id)
					s.removeState(InLove) ;

				target.removeState(InLove) ;
				target.addState(BrokenHeart) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Prout :
				for (st in studentNear(s)) {
					if (st.isAvailable(true))
						st.setKO() ;
				}

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Concert :
				
				for (st in students) {
					if (random(2) == 0 && !st.hasState(BadBehaviour) && st.isAvailable(true))
						st.addState(BadBehaviour) ;
				}

				teacher.hit(actData, damages, s) ;

			case SlowOthers :

				var nb = 2 + random(2) ;

				var neighbours = studentNear(s, 2, function(x) { return !x.done() ; } ) ;
				while (neighbours.length > nb)
					neighbours.remove(neighbours[random(neighbours.length)]) ;

				for (st in neighbours) {
					if (st.isAvailable(true) && !st.hasState(Slowed))
						st.addState(Slowed) ;
				}

				/*for (st in studentNear(s, 2 + random(2))) {
					if (!st.hasState(Slowed))
						st.addState(Slowed) ;
				}*/

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case SelfKO :
				if (curPet == null)
					throw SE_Fatal("missing pet") ; // TODO utiliser SE_Invalid plutôt ? (seb)

				var stud = curPet.s ;
				stud.setKO() ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Tornado :
				var avSeats = getEmptySeats(true) ;
				for (st in students) {
					if (!st.isAvailable(true))
						continue ;

					if (avSeats.length == 0)
						break ;
					var oldSeat = st.seat ;
					var newSeat = avSeats[random(avSeats.length)] ;
					avSeats.remove(newSeat) ;

					st.seat = newSeat ;

					avSeats.push(oldSeat) ;
					log(L_SwapTo(st.id, {_x : newSeat.x, _y : newSeat.y})) ;
				}

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case HelpMePlease :
				var knowledge = s.getKnowledgeHit(actData) ;
				target.studentHit(knowledge, HelpMePlease, s) ;

				s.studentHit(Std.int( knowledge / 3 * -1 ), HelpMePlease, target) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case BadQuestion :
				s.setHandUp(BadQuestion, true) ;
				events.push(Ev_HandUp(s.id, 2 + random(3))) ;

			/*case DoctorLove :
				for (st in students) {
					if (st.gender == s.gender)
						continue ;

					for (state in [Sulk, Asleep])
						st.removeState(state) ;

					st.setLover(s) ;
				}

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;*/

			case Dizzy :
				s.setKO() ;

				var nb = 2 + random(2) ;
				var reacts = [] ;
				var stds = [] ;
				for (std in students) {
					if (std != s && std.isAvailable(true))
						stds.push(std) ;
				}


				while (stds.length > 0 && reacts.length < nb) {
					var c = stds[random(stds.length)] ;
					if (c == s || c.done())
						continue ;
					var ns = random(2) == 0 ? BadBehaviour : Lol ;
					if (!c.hasState(ns))
						c.addState(ns) ;
					reacts.push(c) ;
				}

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case LaughingGas :
				var nb = 3 + random(2) ;

				var neighbours = studentNear(target, 2, function(x) { return x.isAvailable(true) ; } ) ;
				while (neighbours.length > nb)
					neighbours.remove(neighbours[random(neighbours.length)]) ;


				for (st in neighbours) {
					for (state in [Sulk, Asleep, Lol, Tetanised]) { // => refresh Lol timer
						if (st.hasState(state))
							st.removeState(state) ;
					}
					st.addState(Lol) ;
				}

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case AttackTwice :
				for (i in 0...2)
					events.push(Ev_Replay(s.id)) ;

			case Dining :
				for (st in students) {
					if (st.isAvailable(true))
						st.addBoredom(1) ;
				}

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Calumny :
				var stds = target.getTableNeighbours() ;
				stds.push(target) ;

				for (s in stds) {
					s.setHostile(true) ;
					if (!s.hasState(Angry))
						s.addState(Angry) ;
				}

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case Morpheus :
				//events.push(Ev_TeacherSleep) ;

				teacher.dPA(-1 * Std.int(Math.min(2, teacher.pa))) ;

				if (damages.value > 0)
					teacher.hit(actData, damages, s) ;

			case NeighbourLaunch :
				teacher.hit(actData, damages, s) ;
				target.setKO() ;

			case Trigger_Shy, Trigger_Genius, Event_Lol, Event_Chewing, Trigger_BadBehaviour, Trigger_Sulk, Trigger_Done, Event_Tictic, Event_Singing, Event_Voodoo, Trigger_Bomb, Trigger_BombExplode :
				//nothing to do
		}

		cornerHealer.canSave = true ;

		log(L_EndStudentAction(s.id, act.a, act.targets)) ;

		/*var infos = "action by " + s.firstname + " => " + act.a + " on " + Std.string(act.targets ) ;
		#if neko
			App.current.logError(infos) ;
		#end
		#if flash
			trace(infos) ;
		#end*/


		if (s.cloners.length > 0) {
			for (st in s.cloners) {
				var stud = getStudent(st) ;
				if (stud.isAvailable(true))
					doStudentAction(st, act.a) ;
			}
		}

	}


	public function setNewHostile(from : Int) {
		var avStudents = Lambda.array(Lambda.filter(students, function(s) { return !s.done() && !s.hostile ; } )) ;

		if (avStudents.length == 0)
			return ;

		var choice = avStudents[random(avStudents.length)] ;
		choice.setHostile(true, from) ;
	}


	public function countAvStudents() : Int {
		var res = 0 ;
		for (s in students) {
			if (s.isAvailable(true))
				res++ ;
		}
		return res ;
	}


	public function setCornerHealer(std : Student, hit : Int) {
		if (!cornerHealer.canSave || cornerHealer.s != null)
			return ;
		cornerHealer.s = std ;
		cornerHealer.hit = hit ;
	}


	public function hasCurrentExercice() : Bool  {
		for (e in events) {
			switch(e) {
				case Ev_Exercice(_, t, _) : return true ;
				default : continue ;
			}
		}
		return false ;
	}


	public function countCorner() : Int  {
		var count = 0 ;
		for (e in events) {
			switch(e) {
				case Ev_Corner(s, t) : count++ ;
				default : continue ;
			}
		}
		return count ;
	}


	public function getMinNote() : Float {
		var min = 1000.0 ;
		for (s in students) {
			if (s.note < min)
				min = s.note ;
		}
		return min ;
	}



	function processEvents() {

		for (e in events.copy()) {
			switch(e) {
				case Ev_Exercice(sid, time, bonus) :
					var damages = teacher.getKnowledge(Exercice, false) ;
					var stud = getStudent(sid) ;

					if (stud.isAvailable()) {
						//stud.touch() ;
						stud.hit(damages, true) ;
					}

					time-- ;

					/*if (bonus)
						teacher.dPA(2) ;*/

					if (time == 0) {
						log(L_ExerciceEnd(sid)) ;
						removeEvent(e) ;
					} else
						updateEvent(e, Ev_Exercice(sid, time, bonus)) ;


				case Ev_Corner(sid, time) :
					time-- ;
					if (time == 0) {
						var s = getStudent(sid) ;
						var oldBoredom = s.boredom ;
						s.removeBoredom(s.boredom) ;
						if (oldBoredom > 0)
							s.oneShot = false ;
						s.addState(Harmless) ;
						s.cornerBack() ;
					} else
						updateEvent(e, Ev_Corner(sid, time)) ;


				case Ev_HandUp(sid, time) :
					time-- ;
					if (time == 0) {
						getStudent(sid).removeHandUp(false) ;
					} else
						updateEvent(e, Ev_HandUp(sid, time)) ;

				case Ev_Object(object, time, value) :
					time-- ;
					switch(object) {
						/*case Life_Well :
							teacher.dSelfControl(2) ;*/

						default : //invalid
					}

					if (time == 0)
						removeEvent(e) ;
					else
						updateEvent(e, Ev_Object(object, time, value)) ;


				case Ev_TeachDot(sid, action, time) :
					time-- ;
					var stud = getStudent(sid) ;
					switch(action) {
						case Cogitate :
							if (stud.isAvailable(true)) {
								var oldBoredom = stud.boredom ;
								stud.removeBoredom(1) ;
								if (oldBoredom > stud.boredom)
									stud.oneShot = false ;
							}

							if (time == 0) {
								if (!stud.hasState(VeryAttentive))
									stud.addState(VeryAttentive) ;
							}

						case Pet_Hot :
							var v = 1 ;
							log(L_TeacherHeal(v)) ;
							teacher.dSelfControl(v) ;

						/*case Exam :
							if (stud.isAvailable(true) && stud.boredom > 0)
								stud.removeBoredom(1) ;*/

						default : //invalid
					}

					if (time == 0)
						removeEvent(e) ;
					else
						updateEvent(e, Ev_TeachDot(sid, action, time)) ;


				case Ev_State(sid, state, duration) :
					var stud = getStudent(sid) ;
	
					switch(state) {
						case Speak :
							if (random(5) > 0)
								continue ;

							if (!stud.hasState(Speak)) //speak state already removed by other student
								continue ;

							var probs = [80, 6, 20, 12, 8, 6] ; // nothing, stop, mdr, sulk, badbehaviour, inverted, love affair

							var other = getStudent( stud.speakers.first() ) ;
							
							switch(randomProbs(probs)) {
								case 0 : //nothing to do

								case 1 :  //stop
									stud.removeState(Speak) ;
								case 2 : //mdr

									for (s in [stud, other]) {
										if (s.hasState(Speak))
											s.removeState(Speak) ;
										if (!s.hasState(Lol))
											s.addState(Lol) ;
									}

								case 3 : //boude
									
									for (s in [stud, other]) {
										if (s.hasState(Speak))
											s.removeState(Speak) ;
										if (!s.hasState(Sulk))
											s.addState(Sulk) ;
									}

								case 4 : //dissipé

									for (s in [stud, other]) {
										if (s.hasState(Speak))
											s.removeState(Speak) ;
										if (!s.hasState(BadBehaviour))
											s.addState(BadBehaviour) ;
									}

								case 5 : //largué
									for (s in [stud, other]) {
										if (s.hasState(Speak))
											s.removeState(Speak) ;
										if (!s.hasState(Inverted))
											s.addState(Inverted) ;
									}
							}

							
						case Lol :
							if (stud.isAvailable(true)) {

								var probs = [5, duration] ; // damage, stop

								if (teacher.hasComp(Fear))
									probs[0] = 2 ;

								switch(randomProbs(probs)) {
									case 0 :
										var aData = Common.getStudentActionData(Event_Lol) ;
										var damages = stud.getDamages(aData) ;
										teacher.hit(aData, damages, stud) ;

									case 1 : stud.removeState(Lol) ;
											duration = -1 ;
								}
							}


						case TicTic :
							if (stud.isAvailable(true)) {
								var aData = Common.getStudentActionData(Event_Tictic) ;
								var damages = stud.getDamages(aData) ;
								teacher.hit(aData, damages, stud) ;
							}

						case Singing :
							if (stud.isAvailable(true)) {
								var aData = Common.getStudentActionData(Event_Singing) ;
								var damages = stud.getDamages(aData) ;
								teacher.hit(aData, damages, stud) ;
							}

							if (duration >= 3) //stop it
								duration = -1 ;

						case Voodoo :
							if (stud.isAvailable(true)) {
								var aData = Common.getStudentActionData(Event_Voodoo) ;
								var damages = stud.getDamages(aData) ;
								teacher.hit(aData, damages, stud) ;
							}

						case BoringGenerator :
							var avStudents = [] ;
							for (s in students) {
								if (!s.isAvailable(true) || s.id == stud.id)
									continue ;
								if (s.hasMaxBoredom())
									continue ;
								avStudents.push(s) ;
							}

							if (avStudents.length > 0) {
								var choice = avStudents[random(avStudents.length)] ;
								choice.addBoredom(1) ;
							} else
								duration = -1 ;


						case Inverted :
							var probs = [8, duration] ; // nothing, stop

							if (teacher.hasComp(Fear))
								probs[0] = 4 ;

							switch(randomProbs(probs)) {
								case 0 : //nothing to do

								case 1 : stud.removeState(Inverted) ;
										duration = -1 ;
							}


						case BadBehaviour :
							var probs = [8, duration] ; // nothing, stop

							if (teacher.hasComp(Fear))
								probs[0] = 4 ;

							switch(randomProbs(probs)) {
								case 0 : //nothing to do

								case 1 : stud.removeState(BadBehaviour) ;
										duration = -1 ;
							}


						case Chewing :

							var probs = [2, duration] ; // damage, stop
							switch(randomProbs(probs)) {
								case 0 :
									if (stud.isAvailable(true)) {
										var aData = Common.getStudentActionData(Event_Chewing) ;
										var damages = stud.getDamages(aData) ;
										teacher.hit(aData, damages, stud) ;
									}
								case 1 :
									stud.removeState(Chewing) ;
							}

						case Tetanised :
							var probs = [100, duration] ; // nothing, stop
							switch(randomProbs(probs)) {
								case 0 : //nothing to do : still tetanised
								case 1 :
									stud.removeState(Tetanised) ;
							}


						case Book :
							stud.hit(teacher.getKnowledge(SuperBook, false)) ;

						case KO :
							var probs = [5, duration] ; // nothing, stop
							switch(randomProbs(probs)) {
								case 0 : //nothing to do : still KO
								case 1 : stud.removeState(KO) ;
							}

						/*case Genius :
							if (duration == 3)
								stud.removeState(Genius) ;*/


						case Angry :
							var probs = [7, duration] ; // nothing, stop
							switch(randomProbs(probs)) {
								case 0 : //nothing to do : still angry
								case 1 :
									stud.removeState(Angry) ;
							}


						case Harmless :
							if (duration == 3)
								stud.removeState(Harmless) ;


						case Rage :
							if (duration >= 1) {
								if (stud.isAvailable(true)) {
									stud.removeState(Rage) ;
									doStudentAction(stud.id, RageAtk) ;
								}
							}
						
						case Headache :
							if (duration == 4)
								stud.removeState(Headache) ;


						case LifeTransfer :

							var stds = stud.getTableNeighbours() ;
							stds.push(stud) ;
							var n = 0 ;
							for (s in stds) {
								if (s.isAvailable(true))
									n++ ;
							}

							log(L_TeacherHeal(n)) ;
							teacher.dSelfControl(n) ;

							if (duration == 3)
								stud.removeState(LifeTransfer) ;


						case BrokenHeart :
							if (!stud.hasState(Tetanised)) {
								var probs = [8, duration] ; // nothing, tetanised
								switch(randomProbs(probs)) {
									case 0 : //nothing to do ;
									case 1 :
										stud.addState(Tetanised) ;
										duration = 0 ;
								}
							}


						case Clone :
							var probs = [10, duration] ; // nothing, stop
							switch(randomProbs(probs)) {
								case 0 : //nothing to do : continue clonage
								case 1 :
									stud.removeState(Clone) ;
							}


						case Bomb3, Bomb2, Bomb1 :
							
							var sData = Common.getStudentActionData(Trigger_Bomb) ;
							stud.hit({value : stud.getDamages(sData).value, crit : 0, resist : 0, type : Classic}, false) ;

							if (stud.done()) {
								var exData = Common.getStudentActionData(Trigger_BombExplode) ;
								for (st in studentNear(stud)) {
									if (st.isAvailable(true))
										st.hit({value : stud.getDamages(exData).value, crit : 0, resist : 0, type : Classic}, false) ;
								}
							} else {
								switch(state) {
									case Bomb3 :
										stud.removeState(Bomb3) ;
										stud.addState(Bomb2) ;
									case Bomb2 :
										stud.removeState(Bomb2) ;
										stud.addState(Bomb1) ;
									case Bomb1 :
										stud.removeState(Bomb1) ;
									default : //impossible
								}
							}


						

						case Invisibility :
							var probs = [5, 3, duration * 2] ; //nothing, swap place, stop

							switch(randomProbs(probs)) {
								case 0 : //nothing to do
								case 1 :
									var avSeats = getEmptySeats() ;
									if (avSeats.length > 0) {
										var ns = avSeats[random(avSeats.length)] ;
										avSeats.remove(ns) ;
										avSeats.push(stud.seat) ;
										stud.seat = null ;

										var tempCheck = ns ;
										while (avSeats.length > 0) {
											var ts = getStudentByPos(tempCheck) ;
											if (ts == null)
												break ;
											var ns2 = avSeats[random(avSeats.length)] ;
											ts.seat = ns2 ;
											log(L_SwapTo(ts.id, {_x : ns2.x, _y : ns2.y})) ;
											tempCheck = ns2 ;
										}

										stud.seat = ns ;
										log(L_SwapTo(stud.id, {_x : ns.x, _y : ns.y})) ;
									}

								case 2 : stud.removeState(Invisibility) ;
							}

						default : //invalid
					}

					if (duration != -1) {
						duration++ ;
						updateEvent(e, Ev_State(sid, state, duration)) ;
					}


				case Ev_StudentOut(sid, bonus, time) :
					time-- ;
					if (time == 0) {
						var s = getStudent(sid) ;
						s.comeIn() ;
					} else
						updateEvent(e, Ev_StudentOut(sid, bonus, time)) ;

				case Ev_StudentNew(sid, time) :
					time-- ;
					if (time == 0) {
						getStudent(sid).comeIn() ;
					} else
						updateEvent(e, Ev_StudentNew(sid, time)) ;

				case Ev_Replay(sid, ea) : //nothing to do

				case Ev_TeacherSleep : //nothing to do
			}
		}

	}



	public function removeEvent(e : Event) {
		events.remove(e) ;

		switch(e) {
			case Ev_TeachDot(sid, action, t) :
				log(L_TeachDotEnd(sid, action)) ;

			default : //nothing to do
		}

	}


	public function updateEvent(old : Event, newOne : Event) {
		for (i in 0...events.length) {
			if (events[i] == old) {
				events[i] = newOne ;
				return ;
			}
		}
	}


	public function removeEventState(sid : Int, state : SState) {
		for (e in events.copy()) {
			switch(e) {
				case Ev_State(s, st, duration) :
					if (s == sid && Type.enumEq(st, state)) {
						events.remove(e) ;
						return ;
					}

				default : continue ;
			}
		}
	}


	public function removeAllEventsFrom(sid : Int) {
		for (e in events.copy()) {
			switch(e) {
				case Ev_State(s, st, duration) :
					if (s == sid)
						events.remove(e) ;

				case Ev_TeachDot(s, act, t) :
					if (s == sid)
						events.remove(e) ;

				case Ev_HandUp(s, d) :
					if (s == sid)
						events.remove(e) ;

				default : continue ;
			}
		}

	}


	public function removeHandUpEvent(sid : Int) {
		for (e in events.copy()) {
			switch(e) {
				case Ev_HandUp(s, d) :
					if (s == sid) {
						events.remove(e) ;
						return ;
					}

				default : continue ;
			}
		}
	}


	public function getEventObjects() : Array<Event> {
		var res = new Array() ;
		for (e in events) {
			switch(e) {
				case Ev_Object(o, t, v) :
					res.push(e) ;
				default : //nothing to do
			}
		}
		return res ;
	}



	public function addEventState(sid : Int, st : SState) {
		events.push(Ev_State(sid, st, 0)) ;
	}

	public function addEventObject(o : TObject, n : Int) {
		events.push(Ev_Object(o, n)) ;
	}


	public function addStudentOut(sid : Int, time : Int, isNew = false, bonus = false) {
		if (isNew)
			events.push(Ev_StudentNew(sid, time)) ;
		else
			events.push(Ev_StudentOut(sid, bonus, time)) ;
	}


	public function addTeacherReplay(?excludeAllPetActions = false, excludeAllQuickActions = false, ?excludeAction : TAction, ?excludeObject : TObject) {
		var actions = lockedActions.copy() ;
		if (excludeObject != null && !initAction) {
			if (teacher.hasObject(excludeObject))
				actions.push({a : UseObject, p : Type.enumIndex(excludeObject)}) ;
		}

		if (excludeAction != null)
			actions.push({a : excludeAction, p : null}) ;

		if (excludeAllQuickActions) {
			for (a in Common.getAllTActions()) {
				if (a.quick)
					actions.push({a : a.id, p : null}) ;
			}
		}

		if (excludeAllPetActions) {
			for (a in allPetActions)
				actions.push({a : a, p : null}) ;
		}

		events.push(Ev_Replay(null, actions)) ;
		log(L_TeacherReplay) ;
	}


	public function hasLovers() {
		for (s in students) {
			if (s.hasState(InLove))
				return true ;
		}
		return false ;

	}

	function updateAttention() {
		for (s in students)
			s.updateBoredom() ;

		//#### DEPRECATED
		/*if (teacher.hasComp(Charisma)) {
			var stds = getStudentByLine(lines[0], null) ;
			while(stds.length > 0) {
				var s = stds[random(stds.length)] ;
				stds.remove(s) ;

				if (!s.isAvailable(true) || s.boredom == 0)
					continue ;

				s.removeBoredom(1) ;
				break ;
			}
		}*/
	}
	

	public function randomProbs(t : Array<Int>) : Int {
		var n = 0 ;
		for(e in t)
		    n += e ;
		n = random(n) ;
		var i = 0 ;
	
		while( n >= t[i]) {
			n -= t[i] ;
			i++ ;
		}
	
		return i ;
	}



	public function getTableCoords(seat : Coords) : Array<Coords> {
		var res = [{x : seat.x, y : seat.y}] ;

		for (side in [-1, 1]) {
			var sx  = seat.x + side ;
			while (Lambda.exists(seats, function(e) { return e.y == seat.y && e.x == sx ; } )) {
				res.push({x : sx, y : seat.y}) ;
				sx += side ;
			}
		}
		return res ;
	}


	public function getEmptyPlaceOnLine(y : Int) : Coords {
		var all = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] ;
		var min = 100 ;
		var max = 0 ;
		for (s in seats) {
			if (s.y != y)
				continue ;
			if (s.x > max)
				max = s.x ;
			if (s.x < min)
				min = s.x ;
			all.remove(s.x) ;
		}

		for (a in all.copy()) {
			if (a < min - 1 || a > max + 1)
				all.remove(a) ;
		}

		if (all.length == 0)
			return {x : 1, y : y + 1} ;
		return {x : all[0], y : y + 1} ;
	}


	public function isSupervisorSeat(seat : Coords) : Bool {
		return Lambda.exists(supervisorSeats, function(s) { return s.x == seat.x && s.y == seat.y ; } ) ;
	}


	public function getEvents() {
		return events ;
	}


	public function hasHelper(h : Helper) : Bool {
		if (helper == null)
			return false ;
		return Type.enumEq(helper, h) ;
	}


	public function addToPetActions(a : TAction) {
		if (Lambda.exists(allPetActions, function(x) { return Type.enumEq(x, a) ; }))
			return ;
		allPetActions.push(a) ;
	}


	public function randomWeight(t : Array<{weight : Int}>, ?diff = 0) : Dynamic {
		var n = 0 ;
		for(e in t)
		    n += e.weight ;
		n = Std.int(Math.min(random(n) + diff, n - 1)) ;
		var i = 0 ;
	

		while( n >= t[i].weight) {
			n -= t[i].weight ;
			i++ ;
		}

		return t[i] ;
		
	}


	static public function sort(t : Array<Dynamic>, f:Dynamic->Dynamic->Dynamic) : Void {
		var a = t ;
		var i = 0;
		var l = t.length;
		while( i < l ) {
			var swap = false;
			var j = 0;
			var max = l - i - 1;

			while( j < max ) {

				if( f(a[j],a[j+1]) > 0 ) {
					var tmp = a[j+1];
					a[j+1] = a[j];
					a[j] = tmp;
					swap = true;
				}


				j += 1;
			}
			if( !swap )
				break;
			i += 1;
		}

	}

/*
	static public function debugLog(s : String) {
		#if neko
		trace(s) ;
		#end
		#if flash
		trace(s) ;
		#end

	}*/
	
	
	

}

