
@:native("_sb") enum Subject {
	S_Science ;
	S_History ;
	S_Math ;
}


@:native("_SLessonInfost") enum Stance {
	Normal ;
	Super ;
	Extra ;
	StaffRoom ;
	House ;
}



@:native("_TAction")
@:build(ods.Data.build("data.ods", "actions", "id")) enum TAction { }


typedef Mission = {
	idx : Int,
	schoolName : String,
	s : Subject,
	extra : Null<TAction>,
	difficulty : Float, // 0 -> 3
	stds : Int,
	lessons : Int,
	idealLessons : Int,
	lessonLimit : Int,
	firstObj : Objective,
	otherObjs : Array<Objective>,
	halfMark : Float,
	prepared : Int,
	homeReward : Null<Int>
}


typedef Objective = {
	active : Bool,
	user : Null<Int>,
	toDo : ObjectiveToDo,
	reward : ObjectiveReward,
	hiddenReward : Bool,
	done : Bool
}


@:native("_mr") enum ObjectiveReward {
	MR_XP(v : Int) ;
	MR_Gold(v : Int) ;
	MR_Object(o : TObject, n : Int) ;
}


@:native("_ob") enum ObjectiveToDo {
	Min_Note(n : Float) ;
	Mention_AB(n : Int) ;
	Mention_B(n : Int) ;
	Mention_TB(n : Int) ;
	Personal_Note(sid : Int, n : Float) ; //sid doit avoir la note n
	Repeater(sid : Int) ; // student sid  doit redoubler
	No_Repeater(n : Int) ; // n redoublants maximum
	Min_Avg(v : Float) ; // NOT USED ANYMORE
}



@:native("_xg") enum XmasGift {
	XG_XP(v : Int) ;
	XG_Gold(v : Int) ;
	XG_Object(o : TObject, n : Int) ;
	XG_Hat(id : Int) ;
	XG_CItem(c : CItem) ;
}


typedef Damages = {
	value : Int,
	crit : Int,
	resist : Int,
	type : DamageType
}


enum DamageType {
	Classic ;
	DoubleOnLife ;
	DoubleOnBoredom ;
	ThroughBoredom ;
}


typedef TActionData = {
	id : TAction,
	name : String,
	cd : Null<Int>,
	quick : Bool,
	cost : Null<Int>,
	stance : Stance,
	desc : String,
	frame : Null<Int>,
	prio : Int
}

/*
@:native("_SAttention")
@:build(ods.Data.build("data.ods", "attention", "id")) enum SAttention { }*/

/*
typedef SAttentionData = {
	id : SAttention,
	name : String,
	level : Int,
	desc : String
}
*/

@:native("_SState")
@:build(ods.Data.build("data.ods", "states", "id")) enum SState { }

typedef SStateData = {
	id : SState,
	name : String,
	cleanable : Int, //1 : positive state, 0 : cleanable, -1 : cant be cleaned
	desc : String
}

@:native("_SChar")
@:build(ods.Data.build("data.ods", "character", "id")) enum SChar { }

typedef SCharData = {
	id : SChar,
	name : Null<String>,
	level : Int, //level minimum pour rencontrer ce caractère
	unique : Int, // 0 : caractère tiré pour tout le monde. 1 : peut être seul ou accompagné. 2 : caractère unique sur l'élève (hors ceux à 0)
	rare : Int, //rareté du caractère, de 0 à 4.
	hostility : Int,
	modResist : Int,
	modKnow : Int,
	desc : Null<String>,
}



@:native("_TObject")
@:build(ods.Data.build("data.ods", "objects", "id")) enum TObject { }

typedef TObjectData = {
	id : TObject,
	name : String,
	pack : Array<Int>,
	cost : Array<Int>,
	minLevel : Null<Int>,
	desc : String,
	flavor : Null<String>,
	frame : Null<Int>,
	always : Bool

}

/*
@:native("_Equipment")
@:build(ods.Data.build("data.ods", "equipment", "id")) enum Equipment { }

typedef EquipmentData = {
	id : Equipment,
	name : String,
	pa : Int,
	cost : Int,
	subject : Null<Subject>,
	actionName : Null<String>,
	desc : String,
	flavor : Null<String>
}
*/

@:native("_CItem")
@:build(ods.Data.build("data.ods", "collection", "id")) enum CItem { }

typedef CItemData = {
	id : CItem,
	name : String,
	desc : String,
	rare : Int,
	goal : String,
	worldMod : Null<String>

}

enum TCompType {
	Super ;
	Passive ;
	Trigger ;
	BaseAction ;

}

@:native("_TComp")
@:build(ods.Data.build("data.ods", "comps", "id")) enum TComp { }

typedef TCompData = {
	id : TComp,
	name : String,
	type : TCompType,
	pre : Null<TComp>,
	disable : Null<TComp>,
	action : Null<Array<TAction>>,
	minLevel : Null<Int>,
	onForcedLevel : Bool,
	subjects : Array<Subject>,
	desc : Null<String>

}


@:native("_Helper")
@:build(ods.Data.build("data.ods", "helper", "id")) enum Helper { }

typedef HelperData = {
	id : Helper,
	name : String,
	shortName : String,
	frame : Int,
	desc : String,
	icon : String
}


@:native("_Inv")
enum InvObject {
	IvItem(ci : CItem) ;
	IvObject(o : TObject) ;
}


typedef CharAction = {
	a : SAction,
	p : Int //proba, en fonction du caractère
}


enum Target {
	Teacher ;
	All_Students ;
	Choose_Student(n : Int, ?with : SState) ;
	Choose_Seat(n : Int) ;
	Choose_Line;
	Choose_Column ;
	Choose_Num ;
}

@:native("_act")
enum AcTarget {
	AT_Coord(c : CoordsData) ;
	AT_Num(n : Int) ; //for line, column and subjects, ...
	AT_Std(sid : Int) ;
}



typedef SendAction = {
	var _r : Int ; //round
	var _a : TAction ; //action
	var _t : List<AcTarget> ; //targets
	var _tu : Array<String> ; // tutorial
	var _v : Null<String> ; //flash version
}

typedef Answer = {
	var _r : Int ; //round
	var _ok : Bool ; //answer
	var _leftAct : Null<Int> ;
	var _url : Null<{_u : String, _why : String}> ;
}

/*
@:native("_urlt")
enum UrlType {
	LevelUp ;
	MissionDone ;
	NewSolver ;
	Refresh ;
}
*/


enum Event {
	Ev_Exercice(sid : Int, time : Int, bonus : Bool) ;
	Ev_Corner(sid : Int, time : Int) ;
	Ev_TeachDot(sid : Int, action : TAction, time : Int) ;
	Ev_State(sid : Int, state : SState, duration : Int) ;
	Ev_Replay(?sid : Int, ?excludeActions : Array<{a : TAction, p : Null<Int>}>) ;
	Ev_TeacherSleep ;
	Ev_StudentOut(sid : Int, bonus : Bool, time : Int) ;
	Ev_StudentNew(sid : Int, time : Int) ;
	Ev_HandUp(sid : Int, time : Int) ;
	Ev_Object(o : TObject, time : Int, ?value : Int) ;
}



enum HitType {
	Resist ;
	Critic ;
}


enum LessonLog {
	L_StudentAction(sid : Int, s : SAction, ?targets : Array<Int>) ;
	L_StudentHit(sid : Int, dLife : Int, dBoredom : Int, ?type : HitType, ?from : SAction, ?by : Int, ?done : Float) ; //by = sid if student damages
	L_TeacherHit(sid : Int, v : Int, from : SAction, ?type : HitType) ;
	L_SelfControl(d:Int, ?from : SAction) ;
	//L_PA(d:Int, ?from : SAction) ; //### DEPRECATED see L_Time
	L_PapersToMark(d:Int, s : Subject) ;
	L_WaitingExercise(d:Int) ;
	L_TeacherAction(a:TAction, ?targets : List<AcTarget>, ?realTargets : List<AcTarget>) ;
	L_Error(se : SolverError) ;
	L_ActionFailed ;

	L_StudentGoOut(sid : Int) ;
	L_StudentGoBack(sid : Int, isNew : Bool, gift : Common.TObject) ;
	
	L_StudentsProgress(r:IntHash<Int>) ;
	L_Dead ; //depression nerveuse, game over (self control = 0)
	L_Ring ; //la cloche sonne, fin du cours (PA = 0)
	L_Success ; //tous les élèves ont amélioré leur note : réussite du cours.

	//NEW
	L_StudentResist(sid : Int) ;
	L_ExerciceEnd(sid : Int) ;
	L_CornerStart(sid : Int, extraHeal : Bool) ;
	L_CornerEnd(sid : Int) ;
	L_HandUpEnd(sid : Int) ;
	L_TeacherHeal(d : Int) ;
	L_DotStart(sid : Int, action : SAction) ;
	L_DotEnd(sid : Int, action : SAction) ;
	L_AddState(sid : Int, state : SState) ;
	L_RemoveState(sid : Int, state : SState) ;
	L_SetBoredom(sid : Int, b : Int, byUpdate : Bool) ;
	L_NoEffect(sid : Int) ; //action innaplicable sur l'eleve sid
	L_SwapTo(sid : Int, c : CoordsData) ;  //l'eleve sid change de place
	L_HandUpStart(sid : Int, what : HandUp_What) ;
	L_TeacherWakeUp ;
	L_TeachDotEnd(sid : Int, action : TAction) ;
	L_TriggerObject(o : TObject, ?value : Int, ?destroyed : Bool) ;

	L_StudentSay(sid : Int, what : HandUp_What) ;
	L_EndStudentAction(sid : Int, s : SAction, ?targets : Array<Int>) ;
	L_EndTeacherAction(a:TAction, c : Int, ?targets : List<AcTarget>, ?realTargets : List<AcTarget>) ;
	L_Loot(ci : CItem, o : TObject) ;

	L_LockObjects(l : Bool) ;
	L_LockSuper(l : Bool) ;

	L_LaunchItem(oid : Int, o : InvObject, from : Int, to : Int, success : Bool) ;
	L_GrabItem(sid : Int, oid : Int, o : InvObject) ;
	L_StudentTrigger(sid : Int, s : SAction) ;
	L_SetHostile(sid : Int, h : Bool, ?from : Int) ;
	L_Cooldown(act : Array<{a : TAction, c : Int}>) ;
	
	
	L_TeacherReplay ;
	L_Time(d:Int, ?from : SAction) ;
	L_Bought(cost : Int, a : TAction, ?o : TObject) ;
	L_XP(sid : Null<Int>, n : Int) ;
	L_ExtraAdd(gold : Int, xp : Int) ;
	L_SwapTable(from : CoordsData, to : CoordsData, s : Null<Int>) ;  //l'eleve sid
	L_SuperAttack(n : Int) ;
	L_ExtraReward(notes : Array<{sid : Int, r : Float}>) ;
	L_AvActions(act : Array<{a : TAction, c : Int}>, moreSlotsIndex : Int, ?shuffle : Bool) ;
	L_Wait(t : Date) ;
	L_Gift(o : TObject, u : Int) ;
	L_GoToIll ;

	//### NEW
	L_RerollHelpers(av : Array<Helper>) ; //done
	L_ChooseHelper(h : Helper) ; //done
	L_TriggerHelper(h : Helper, ?p : Array<Int>) ;
	L_SupervisorChoice(seats : List<CoordsData>) ;
	L_HelperMoveTo(c : CoordsData) ;
	//###

}


enum HandUp_What {
	HW_Out(time : Int) ;
	HW_Question(l : Array<{life : Int, give : QuestionReward}>) ;
	HW_Cheat(sid : Null<Int>) ;
	HW_Heal(n : Null<Int>) ;
	HW_Note ;
}


enum QuestionReward {
	QR_Hit(n : Int) ; //n dégâts
	QR_State(s : SState) ; //donne l'état s à l'élève
	QR_Clean ; //retire un état négatif
	QR_Heal(n : Int) ;
}


@:native("_SAction")
@:build(ods.Data.build("data.ods", "studentActions", "id")) enum SAction { }


typedef SActionData = {
	var id : SAction ;
	//var type : Null<SAttackType> ;
	var level : Null<Int> ;
	var ultima : Null<Int> ;
	var cooldown : Null<Int> ;
	var name : String ;
	var desc : Null<String> ;
	var announce : Null<String> ;
}




typedef Coords = {
	var x: Int;
	var y: Int;
}

typedef CoordsData = {
	var _x: Int;
	var _y: Int;
}


typedef HomeRequest = {
	_id : String,
	_f : Null<Int>,
	_col : Null<Int>
}


typedef HatRequest = {
	_hat : Int
}

@:native("_extObj")
enum ExtraObject {
	XmasGift ;
}


typedef TeacherData = {
	var _pr : Int ; //curPeriod
	var _am : Bool ;
	var _s: Int; 	//selfcontrol
	var _ms : Int ; //max Selfcontrol
	var _l : Int ; //level
	var _p : Int ; //pa
	var _mp : Int ; // max pa
	var _pp : Null<Int> ; //sujets préparés
	var _act : Array<TAction> ;//availables actions
	var _i : Array<CoordsData> ;
	var _o : Array<{_o : TObject, _n : Int}> ;
	//var _t: Timetable ;
	var _ys : Int ;
	var _llt : Int ; //leftLastTurns
	var _cps : Array<TComp> ;
	var _ill : Null<{_next : Null<Float>, _step : Float, _max : Int, _auto : Bool}> ;
	var _grade : Int ;
	var _helper : Null<Helper> ;
	var _avHelpers : Null<{_cur : Array<Helper>, _av : Array<Helper>}> ;
}

typedef StudentData = {
	var _i: Int; //id
	/*var _ck : Int; //current Knowledge
	var _mk : Int ; //max knowledge*/
	var _lf : Int ;
	var _sb : Int ; //starting boredom
	var _mb : Int ; //max boredom
	var _n : Float ; //current note
	var _f: String; //firstname
	var _r : Int ; //resistance
	var _ch : SChar ; //characters
	var _ss : List<{_s : SState, _p : Int}> ; //persistant states
	var _m : Int ; //gender
	var _h : Bool ;  //hostile
	var _pet : {_a : TAction, _k : Bool} ;
	var _p: Null<CoordsData>; //position
	//var _e : Int ; //energy => 0 = KO
	//var _st : Int ; //stress => 0 = Tetanised for Shy student
	var _fn : Float ; // from Note
	var _l : Int ; //level
	var _late : Int ;
	var _new : Int ;
	var _lastReward : Float;
	var _u : Null<Int> ; //user
	var _gift : Null<TObject> ; //user gift
} ;


typedef ClientInit = {
	var _period : TPeriod ; //Lesson(s), Break, Rest
	var _extra : Null<{_urlRanking : String,
					_urlLevelUp : String,
					_urlMissionDone : String,
					_urlNext : String,
					_urlHome : String,
					_urlHat : String,
					_urlGift : String,
					_userName : String,
				}> ; //extraInfos
	var _solverInit : Null<SolverInit> ;
	var _actions : Array<SendAction> ;
	var _actionUrl : String ; // URL sendaction
	var _tutorialData : Array<String>;
	var _delivery : Bool ; // true if new bought object  --------- TODO deprecated
	var _gold : Int ;
	var _hat : {_h : Int, _av : Array<Int>} ;
	var _time : Null<{_last : Date, _now : Date}> ;
	var _home : Null<{_l : Int, _t : Array<{_k:String, _f:Int, _c:Null<Int>}>}> ;
	var _picture : Bool ;
	var _hp : Bool ;
	var _div : Float;
	var _freePlay : Bool;

} ;

typedef SolverInit = {
	var _seed : Int; // seed
	var _leftActions : Null<Int> ; //leftActions ;
	var _subject : Null<Subject> ;
	var _teacherData : TeacherData ;
	var _students: Array<StudentData> ;
	var _ultima : Null<Int> ;
	var _launch : Array<Int> ;
	var _extraInv : Array<{_o : ExtraObject, _n : Int}> ;
	var _wm : Null<String> ; //worldMod (xmas, ...)
}


typedef SLessonInfo = { //progression pour chaque étudiant après un cours
	var id : Int ;
	var newSuccess : Bool ; //première progression de l'élève
	var done : Bool ;
	var xp : Int ;
	var reward : Float ; //avancées pendant le cours
	var curNote : Float ;
}


typedef MissionEvolution = {
		halfMark : Float,
		mentions : Array<Int>,
		repeaters : Int,
		minNote : Float
}


typedef TLessonResult = {
	var students : Array<SLessonInfo> ;
	var xp : Int ;
	var extraXp : Int ;
	var gold : Int ;
	var items : Array<{ci : CItem, n : Int}> ;
	var firstObjDone : {done : Null<Bool>, delta : Float, value : Float} ;
	var otherObjDone : Array<{done : Null<Bool>, delta : Float, value : Float}> ;
}


/*

typedef StaffroomInit = {
	var _s : Int ;
	var _a : Array<> ;
}
*/

@:native("_it") enum ItemType {
	ITable;
	IDesktop;
}

typedef ItemData = {
	var _t: ItemType;
	var _x: Int;
	var _y: Int;
}

enum SolverErrorKind {
	_Err_ActionUnavailable(a:TAction);
	_Err_UselessAction;
	_Err_UselessHeal;
	_Err_StudentUnavailable;
	_Err_ObjectUnavailable;
	_Err_CantTargetPet;
	_Err_CantUseObjectHere;
	_Err_CantSwapEmptySeats;
	_Err_CantSwapUnavailableStudent;
	_Err_CantMoveTable;
	_Err_NotEnoughMoney;
	_Err_NoMidLife;
}

@:native("_SE") enum SolverError {
	SE_Invalid(e:SolverErrorKind) ;
	SE_Fatal(s : String) ;
}

typedef LessonResult = IntHash<Int> ;
typedef Timetable = Array<TimePeriod> ;


@:native("_tp") enum TPeriod {
	Lesson(s : Subject) ;
	Break ;
	Rest ;
	Ill ;
	NeedMission ;
}


@:native("_tls") enum TLessonState {
	TLS_Wait ;
	TLS_Win ;
	TLS_Ring ;
	TLS_Dead ;
}


@:native("_ttp") enum TimePeriod {
	T_Lesson(s :Null<Subject>, type : TLessonState) ;
	T_StaffRoom ;
	T_House ;
	T_Ill ;
	T_Start(la : Int) ;
	T_AutoIll ;
	T_Canceled ;
}




class Common {
	static var rlist = new Hash<mt.deepnight.RandList<Dynamic>>();
	
	public static function randEnum<T>( e : Enum<T>, f : Int -> Int ) : T {
		var n = Type.getEnumName(e);
		var r = rlist.get(n);
		if ( r == null ) {
			r = mt.deepnight.RandList.fromEnum(e);
			r.setFastDraw();
			rlist.set(n, r);
		}
		return r.draw( f );
	}

	#if neko
	static var _ = Config ;
	static function getCacheFile(file) {
		return Config.TPL + file ;
	}
	#end
	

	#if neko
		static var L_TACTIONS_FR = ods.Data.parse( "../../fr/tpl/data.ods", "actions", TActionData) ;
		static var L_TACTIONS_EN = ods.Data.parse( "../../en/tpl/data.ods", "actions", TActionData) ;
		static var L_TACTIONS_ES = ods.Data.parse( "../../es/tpl/data.ods", "actions", TActionData) ;
		static var L_TACTIONS_DE = ods.Data.parse( "../../de/tpl/data.ods", "actions", TActionData) ;

		static var L_SSTATES_FR = ods.Data.parse( "../../fr/tpl/data.ods", "states", SStateData) ;
		static var L_SSTATES_EN = ods.Data.parse( "../../en/tpl/data.ods", "states", SStateData) ;
		static var L_SSTATES_ES = ods.Data.parse( "../../es/tpl/data.ods", "states", SStateData) ;
		static var L_SSTATES_DE = ods.Data.parse( "../../de/tpl/data.ods", "states", SStateData) ;

		static var L_SACTIONS_FR = ods.Data.parse( "../../fr/tpl/data.ods", "studentActions", SActionData) ;
		static var L_SACTIONS_EN = ods.Data.parse( "../../en/tpl/data.ods", "studentActions", SActionData) ;
		static var L_SACTIONS_ES = ods.Data.parse( "../../es/tpl/data.ods", "studentActions", SActionData) ;
		static var L_SACTIONS_DE = ods.Data.parse( "../../de/tpl/data.ods", "studentActions", SActionData) ;

		static var L_SCHARACTERS_FR = ods.Data.parse( "../../fr/tpl/data.ods", "character", SCharData) ;
		static var L_SCHARACTERS_EN = ods.Data.parse( "../../en/tpl/data.ods", "character", SCharData) ;
		static var L_SCHARACTERS_ES = ods.Data.parse( "../../es/tpl/data.ods", "character", SCharData) ;
		static var L_SCHARACTERS_DE = ods.Data.parse( "../../de/tpl/data.ods", "character", SCharData) ;

		static var L_TOBJECTS_FR = ods.Data.parse( "../../fr/tpl/data.ods", "objects", TObjectData) ;
		static var L_TOBJECTS_EN = ods.Data.parse( "../../en/tpl/data.ods", "objects", TObjectData) ;
		static var L_TOBJECTS_ES = ods.Data.parse( "../../es/tpl/data.ods", "objects", TObjectData) ;
		static var L_TOBJECTS_DE = ods.Data.parse( "../../de/tpl/data.ods", "objects", TObjectData) ;

		static var L_CITEMS_FR = ods.Data.parse( "../../fr/tpl/data.ods", "collection", CItemData) ;
		static var L_CITEMS_EN = ods.Data.parse( "../../en/tpl/data.ods", "collection", CItemData) ;
		static var L_CITEMS_ES = ods.Data.parse( "../../es/tpl/data.ods", "collection", CItemData) ;
		static var L_CITEMS_DE = ods.Data.parse( "../../de/tpl/data.ods", "collection", CItemData) ;

		static var L_TCOMPS_FR = ods.Data.parse( "../../fr/tpl/data.ods", "comps", TCompData) ;
		static var L_TCOMPS_EN = ods.Data.parse( "../../en/tpl/data.ods", "comps", TCompData) ;
		static var L_TCOMPS_ES = ods.Data.parse( "../../es/tpl/data.ods", "comps", TCompData) ;
		static var L_TCOMPS_DE = ods.Data.parse( "../../de/tpl/data.ods", "comps", TCompData) ;


		static var L_HELPERS_FR = ods.Data.parse( "../../fr/tpl/data.ods", "helper", HelperData) ;
		static var L_HELPERS_EN = ods.Data.parse( "../../en/tpl/data.ods", "helper", HelperData) ;
		static var L_HELPERS_ES = ods.Data.parse( "../../es/tpl/data.ods", "helper", HelperData) ;
		static var L_HELPERS_DE = ods.Data.parse( "../../de/tpl/data.ods", "helper", HelperData) ;

	#else
		static var TACTIONS = ods.Data.parse( "data.ods", "actions", TActionData) ;
		static var SSTATES = ods.Data.parse( "data.ods", "states", SStateData) ;
		static var SACTIONS = ods.Data.parse( "data.ods", "studentActions", SActionData) ;
		static var SCHARACTERS = ods.Data.parse( "data.ods", "character", SCharData) ;
		static var TOBJECTS = ods.Data.parse( "data.ods", "objects", TObjectData) ;
		static var CITEMS = ods.Data.parse( "data.ods", "collection", CItemData) ;
		static var TCOMPS = ods.Data.parse( "data.ods", "comps", TCompData) ;
		static var HELPERS = ods.Data.parse( "data.ods", "helper", HelperData) ;
	#end


	static public function getAllTActions() : Array<Common.TActionData>	{
		#if neko
			return switch(Config.LANG) {
						case "fr" : L_TACTIONS_FR ;
						case "en" : L_TACTIONS_EN ;
						case "es" : L_TACTIONS_ES ;
						case "de" : L_TACTIONS_DE ;
					}
		#else
			return TACTIONS ;
		#end
	}

	static public function getAllSStates() {
		#if neko
			return switch(Config.LANG) {
						case "fr" : L_SSTATES_FR ;
						case "en" : L_SSTATES_EN ;
						case "es" : L_SSTATES_ES ;
						case "de" : L_SSTATES_DE ;
					}
		#else
			return SSTATES ;
		#end
	}

	static public function getAllSActions() {
		#if neko
			return switch(Config.LANG) {
						case "fr" : L_SACTIONS_FR ;
						case "en" : L_SACTIONS_EN ;
						case "es" : L_SACTIONS_ES ;
						case "de" : L_SACTIONS_DE ;
					}
		#else
			return SACTIONS ;
		#end
	}


	static public function getAllSCharacters() {
		#if neko
			return switch(Config.LANG) {
						case "fr" : L_SCHARACTERS_FR ;
						case "en" : L_SCHARACTERS_EN ;
						case "es" : L_SCHARACTERS_ES ;
						case "de" : L_SCHARACTERS_DE ;
					}
		#else
			return SCHARACTERS ;
		#end
	}


	static public function getAllTObjects() {
		#if neko
			return switch(Config.LANG) {
						case "fr" : L_TOBJECTS_FR ;
						case "en" : L_TOBJECTS_EN ;
						case "es" : L_TOBJECTS_ES ;
						case "de" : L_TOBJECTS_DE ;
					}
		#else
			return TOBJECTS ;
		#end
	}

	static public function getAllCItems(?rareOnly = false) {
		#if neko
			var ci = switch(Config.LANG) {
						case "fr" : L_CITEMS_FR ;
						case "en" : L_CITEMS_EN ;
						case "es" : L_CITEMS_ES ;
						case "de" : L_CITEMS_DE ;
					}

			if (!rareOnly)
				return ci ;
			var res = [] ;
			for (c in ci) {
				if (c.rare >= 3)
					res.push(c) ;
			}
			return res ;
		#else
			return CITEMS ;
		#end
	}

	static public function getAllTComps() {
		#if neko
			return switch(Config.LANG) {
						case "fr" : L_TCOMPS_FR ;
						case "en" : L_TCOMPS_EN ;
						case "es" : L_TCOMPS_ES ;
						case "de" : L_TCOMPS_DE ;
					}
		#else
			return TCOMPS ;
		#end
	}


	static public function getAllHelpers() {
		#if neko
			return switch(Config.LANG) {
						case "fr" : L_HELPERS_FR ;
						case "en" : L_HELPERS_EN ;
						case "es" : L_HELPERS_ES ;
						case "de" : L_HELPERS_DE ;
					}
		#else
			return HELPERS ;
		#end
	}



	#if neko

	public static function initFormatTexts() {
		var toSwitch = [{ from : "{life}"		, to : "<img src=\"http://" + Config.DATA_HOST + "/img/icons/life.png\" />" },
						{ from : "{life2}"		, to : "<img src=\"http://" + Config.DATA_HOST + "/img/icons/life2.png\" />" },
						{ from : "{boredom}"	, to : "<img src=\"http://" + Config.DATA_HOST + "/img/icons/boredom.png\" />" },
						] ;


		for (l in [L_TACTIONS_FR, L_TACTIONS_EN, L_TACTIONS_ES, L_TACTIONS_DE]) {
			for (t in l) {
				for (tw in toSwitch) {
					if (t.desc != null)
						t.desc = StringTools.replace(t.desc, tw.from, tw.to) ;
				}
			}
		}

		for (l in [L_SSTATES_FR, L_SSTATES_EN, L_SSTATES_ES, L_SSTATES_DE]) {
			for (t in l) {
				for (tw in toSwitch) {
					if (t.desc != null)
						t.desc = StringTools.replace(t.desc, tw.from, tw.to) ;
				}
			}
		}

		for (l in [L_TOBJECTS_FR, L_TOBJECTS_EN, L_TOBJECTS_ES, L_TOBJECTS_DE]) {
			for (t in l) {
				for (tw in toSwitch) {
					if (t.desc != null)
						t.desc = StringTools.replace(t.desc, tw.from, tw.to) ;
				}
			}
		}

		for (l in [L_TCOMPS_FR, L_TCOMPS_EN, L_TCOMPS_ES, L_TCOMPS_DE]) {
			for (t in l) {
				for (tw in toSwitch) {
					if (t.desc != null)
						t.desc = StringTools.replace(t.desc, tw.from, tw.to) ;
				}
			}
		}

	}


	static var __ = initFormatTexts() ;

	#end


	static var CACHE_TAction = new Hash(); // EXPERIMENTAL
	static public function getTActionData(a : TAction) : TActionData {
		var res = null ;

		#if neko
			var aid =  Std.string(a) + "_" + Config.LANG ;
		#else
			var aid =  Std.string(a)  ;
		#end
		if( CACHE_TAction.exists(aid))
			res = CACHE_TAction.get(aid);
		else
			for (d in getAllTActions())
				if (Type.enumEq(d.id, a)) {
					res = {
						id : d.id,
						name : d.name,
						prio : d.prio,
						frame : d.frame,
						cd : d.cd,
						quick : d.quick,
						cost : d.cost,
						stance : d.stance,
						desc : d.desc
					} ;
					CACHE_TAction.set(aid, res);
					break ;
				}

		#if flash //LIVE VALUE IN DESC ODS
			try {
				if( logic.Solver.me != null && res.desc.indexOf("::")>=0 )
					for (vId in ["XPBONUS", "FREEHEAL"]) {
						var value = switch(vId) {
							case "XPBONUS" 	: logic.Solver.me.teacher.getFreeXpRestValue() ;
							case "FREEHEAL"		: logic.Solver.me.teacher.getFreeRestValue() ;
						}
						res.desc = StringTools.replace(res.desc, "::"+vId+"::", Std.string(value)) ;
					}
				}
			catch(e : Dynamic) {}
		#end

		return res ;
	}

	static public function getStudentActionData(a : SAction) : SActionData {
		for (d in getAllSActions()) {
			if (Type.enumEq(d.id, a))
				return d ;
		}
		return null ;
	}


	
	static public function getStateData(a : SState) : SStateData {
		for (d in getAllSStates()) {
			if (Type.enumEq(d.id, a))
				return d ;
		}
		return null ;
	}

/*
	static public function getAttentionData(a : SAttention) : SAttentionData {
		for (d in SATTENTIONS) {
			if (Type.enumEq(d.id, a))
				return d ;
		}
		return null ;
	}
*/
/*
	static public function getAttentionDataByLevel(l : Int) : SAttentionData {
		for (d in SATTENTIONS) {
			if (Type.enumEq(d.level, l))
				return d ;
		}
		return null ;
	}
*/

	static public function getCharacterData(a : SChar) : SCharData {
		for (d in getAllSCharacters()) {
			if (Type.enumEq(d.id, a))
				return d ;
		}
		return null ;
	}


	static public function getObjectData(o : TObject, comps : Array<TComp>) : TObjectData {

		if (comps == null)
			comps = [] ;

		for (t in getAllTObjects()) {
			if (Type.enumEq(t.id, o)) {
				return getLiveObjectData(t, comps) ;
			}
		}
		
		return null ;
	}


	static public function getAllLiveObjectData(comps : Array<TComp>) : Array<Common.TObjectData> {
		var n = 0 ;
		for (cp in [Buyer_0, Buyer_1]) {
			if (Lambda.exists(comps, function(x) { return Type.enumEq(x, cp) ; } ))
				n++ ;
		}

		var healComp = 0 ;
		var saComp = 0 ;
		for (cp in [BestHeal_0, BestHeal_1]) {
			if (Lambda.exists(comps, function(x) { return Type.enumEq(x, cp) ; } )) {
				healComp++ ;
			}
		}

		if (Lambda.exists(comps, function(x) { return Type.enumEq(x, BestSuperAttack) ; } ))
			saComp++ ;

		var res = new Array() ;
		for (od in getAllTObjects()) {
			var o = getLiveObjectData(od, comps, n) ;
			if (Type.enumEq(o.id, LangageAid))
				continue ;

			var add = true ;
			switch(o.id) {
				case Heal_0 :
					add = healComp == 0 ;

				case Heal_1 :
					add = healComp == 1 ;

				case Heal_2 :
					add = healComp == 2 ;

				case SuperAttack_0 :
					add = saComp == 0 ;

				case SuperAttack_1 :
					add = saComp == 1 ;

				default : add = true ;
			}

			if (add)
				res.push(o) ;

		}

		return res ;
	}


	static function getLiveObjectData(od : TObjectData, comps : Array<TComp>, ?byPassReduc : Int) : TObjectData {
		var dCost = 1.0 ;
		var reducByComp = 0.05 ;
		if (byPassReduc != null)
			dCost -= reducByComp * byPassReduc ;
		else {
			for (cp in [Buyer_0, Buyer_1]) {
				if (Lambda.exists(comps, function(x) { return Type.enumEq(x, cp) ; } ))
					dCost -= reducByComp ;
			}
		}

		var res = {	id : od.id,
					name : od.name,
					pack : od.pack,
					cost : [],
					minLevel : od.minLevel,
					desc : od.desc,
					frame : od.frame,
					always : od.always,
					flavor : od.flavor } ;

		for (c in od.cost)
			res.cost.push(Std.int(Math.floor( c * dCost ))) ;


		/*#if flash
			try {
				if (logic.Solver.me != null)*/
			for (vId in ["OBJHEAL"]) {
				var value = switch(vId) {
					case "OBJHEAL"		: logic.Data.getHealValue(res.id, comps) ;
				}

				res.desc = StringTools.replace(res.desc, "::"+vId+"::", Std.string(value)) ;
			}
		/*		}
			catch(e : Dynamic) {}
		#end*/



		return res ;
	}


	static public function getCItemData(ci : CItem) : CItemData {
		for (t in getAllCItems()) {
			if (Type.enumEq(t.id, ci))
				return t ;
		}
		return null ;
	}


	static public function getTCompData(tc : TComp) : TCompData {
		for (t in getAllTComps()) {
			if (Type.enumEq(t.id, tc)) {
				if (t.desc == null && t.action != null && t.action.length == 1)
					t.desc = Std.string(Common.getTActionData(t.action[0]).desc) ;

				return t ;
			}
		}
		return null ;
	}



	static public function getHelperData(h : Helper) : HelperData {
		for (t in getAllHelpers()) {
			if (Type.enumEq(t.id, h))
				return t ;
		}
		return null ;
	}




}
