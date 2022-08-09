package logic ;

import Common ;


class Data {

	//static public var T_DIFF_LEVEL = 0.10 ; //teacher evolution of difficulty
	static public var S_DIFF_LEVEL = 0.03 ; //student evolution of difficulty

	//static public var YEAR_MAX_LEVEL = [12, 15, 18, 21, 24, 27, 30, 33, 33] ;


	//[12, 15, 18, 21, 24, 27, 30, 33, 33]
	static public var YEAR_MAX_LEVEL = [12, 15, 18, 21, 24, 28, 34, 40, 40] ;

	static public var ILL_TIME = 15 * 60 * 60 * 1000.0 ;
	static public var WAITING_TIME = 5 * 60 * 60 * 1000.0 ;
	static public var BY_LEFT_TURN_SALE = 5 ;
	static public var BY_HOUR_SALE = 5 ;
	static public var MIN_CONTINUE_COST = 10 ;


	public static var CONTINUE_COST = 50 ;
	public static var RESURRECT_COST = 60 ;
	public static var MORESLOTS_COST = 10 ;

	public static var CHOOSE_HELPER_COST = 10 ;
	public static var REROLL_HELPERS_COST = 5 ;


	static public var NOTE_REWARD_PER_LINE = [2, 1, 0] ;
	static public var BY_BONUS_REWARD = 0.5 ;

	static public var NB_PREPARE_SUBJECT = 3 ; //number of students with bonus for 'prepare subject'


	public static var START_PA = 10 ;
	public static var START_SELFCONTROL = 20 ;

	public static var START_HELPERS = [Eddy, Peggy, Einstein] ;	
	public static var START_LEFT_HELPERS = [Dog, Director, Supervisor, Inspector, Skeleton] ;	

	public static var COFFEE_EFFECT = 4 ; 
	public static var FREE_XP_EFFECT = 4 ; 

	public static var HATS = [1, 2, 3, 4, 5, 6, 7, 8,
							9, 10, 11 //xmas hats
							] ; 


	public static var XMAS_GIFTS = [{gift : XG_XP(10), 														weight : 12},
									{gift : XG_Gold(10), 					weight : 12},
									{gift : XG_CItem(SnowBall), 			weight : 30},
									{gift : XG_Object(Heal_0, 1), 			weight : 8},
									{gift : XG_Object(Sponge, 1), 			weight : 10},
									{gift : XG_Object(SuperAttack_0, 1), 	weight : 10},
									{gift : XG_Hat(9), 						weight : 6},
									{gift : XG_Hat(10), 					weight : 6},
									{gift : XG_Hat(11), 					weight : 6}] ;


	public static var BASE_NOTE = [{note : [2, 3], weight : 5},
							{note : [4, 5], weight : 12},
							{note : [6], weight : 20},
							{note : [7,8], weight : 30},
							{note : [9], weight : 20},
							{note : [10], weight : 8},
							{note : [11], weight : 2},
							{note : [12], weight : 2},
							{note : [13], weight : 1}] ;


	public static var COLL_WEIGHT = [50, 40, 30, 20, 10, 4] ;
	public static var COLL_POINTS = [1, 2, 3, 4, 10, 25] ;



	public static var FIRST_MISSION_CHARS = [Hibernator, Noisy_0, Shy, Std_V9, Std_V1] ;

	//public static var FIRST_MISSION_CHARS = [SerialLover, SerialLover, SerialLover, SerialLover, SerialLover] ;


	public static var UNAVAILABILITY_STATES = [Asleep, Tetanised, KO, Invisibility, Book] ;



	public static function getContinueCost(leftTurn : Int, from : Float, now : Float) : Int {
		var res = CONTINUE_COST ;
		res = Std.int(Math.max(MIN_CONTINUE_COST, CONTINUE_COST - BY_LEFT_TURN_SALE * leftTurn)) ;

		if (res == MIN_CONTINUE_COST)
			return res ;

		var hours = Std.int(Math.min(4, Math.floor( (now - from) / (60 * 60 * 1000) ))) ;

		return Std.int(Math.max(MIN_CONTINUE_COST, res - BY_HOUR_SALE * hours)) ;
	}


	public static function getAvgByLesson(obj: ObjectiveToDo, n : Int) {
		switch(obj) {
			case Min_Avg(_) : 
				var tier = n / 3 ;
				var res = 0.0 ;
				for (nr in NOTE_REWARD_PER_LINE)
					res += tier * nr ;

				return res / n ;

			case Repeater(sid) : return 0.5 ;

			case Min_Note(_) : return 1.5 ;

			default : return 1.8 ;
		}
	}



	static public function getHealValue(h : TObject, comps : Array<TComp>) {

		var res = switch(h) {
					case Heal_0 : 15 ;
					case Heal_1 : 20 ;
					case Heal_2 : 30 ;
					default : 0 ;
			} ;

		var mult = 1.0 ;
		var byComp = 0.1 ;
		for (cp in [PotionUser_0, PotionUser_1]) {
			if (Lambda.exists(comps, function(x) { return Type.enumEq(x, cp) ; } ))
				mult += byComp ;
		}

		return Std.int(Math.round( res * mult )) ;
	}


	static public function actionCond(a : SAction) : logic.Student -> Bool {

		switch(a) {
			case Add_Invisibility,Give_Invisibility : 
				return function(x : logic.Student) { return !x.hasState(Invisibility) ; } ;

			case Add_Inverted :
				return function(x : logic.Student) { return !x.hasState(Inverted) ; } ;

			case Add_Moon, Give_Moon :
				return function(x : logic.Student) { return !x.hasState(Moon) ; } ;

			case Add_Lol, Give_Lol :
				return function(x : logic.Student) { return !x.hasState(Lol) ; } ;

			case Add_Asleep, Give_Asleep :
				return function(x : logic.Student) { return !x.hasState(Asleep) ; } ;

			case Add_Chewing :
				return function(x : logic.Student) { return !x.hasState(Chewing) ; } ;

			case Add_Slow, Give_Slow :
				return function(x : logic.Student) { return !x.hasState(Slowed) ; } ;

			case Add_Tictic : 
				return function(x : logic.Student) { return !x.hasState(TicTic) ; } ;			

			case Add_Singing : 
				return function(x : logic.Student) { return !x.hasState(Singing) ; } ;			

			case Add_Voodoo : 
				return function(x : logic.Student) { return !x.hasState(Voodoo) ; } ;			

			case Add_BoringGenerator : 
				return function(x : logic.Student) { return !x.hasState(BoringGenerator) ; } ;			
			case Add_Angry :
				return function(x : logic.Student) { return !x.hasState(Angry) ; } ;

			case Add_Clone :
				return function(x : logic.Student) { return !x.hasState(Clone) ; } ;

			case Add_BadBehaviour :
				return function(x : logic.Student) { return !x.hasState(BadBehaviour) ; } ;

			case Give_KO :
				return function(x : logic.Student) { return !x.hasState(KO) ; } ;

			case Give_Speak :
				return function(x : logic.Student) { return !x.hasState(Speak) ; } ;



			default : return function(x : logic.Student) { return true ; } ;
		}
	}

/*
	static public function getAttentionProbs(c : SChar) : Array<Int> {
		//[2, 1, 0, -1, -2, -3] ;
		var std = [2, 18, 40, 30, 10] ;

		return switch(c) {
			case Dreamer : [0, 0, 0, 70, 40] ;

			case Clever : [4, 70, 0, 70, 0] ; 

			case Inquiring : [0, 28, 0, 0, 0] ;

			case Dumb : [0, 0, 0, 40, 20] ;
			
			case NoLaugh : [0, 25, 0, 0, 0] ;

			default : std ;
		}
	}	*/


	static public function setBoredomChanges(c : SChar, v) : Int {

		var res = v ;

		 switch(c) {
			case Dreamer : res++ ;

			case Clever : res-- ;

			case Inquiring : res-- ;

			case Dumb : res += 2 ;
			
			case NoLaugh : res = -100 ;

			default : //nothing to do ;
		}

		return res ;
	}	



	static public function getExtraActions(st : SState, ?student : logic.Student) : Array<CharAction> {
		return switch(st) {
			case Asleep : [{a : Atk_Asleep, p : 16}] ;

			case Speak : [{a : Give_Speak, p : 14}] ;

			default : null ;
		}
	}


	static public function getCharacterLateProbs(c : SChar) : Int {
		return switch(c) {
			case Dreamer : 10 ;
			case Hibernator : 10 ;
			case Pee : 8 ;
			case NoSleep : 8 ;

			default : 30 ;
		}	

	}


	static public function getCharacterPetActions(c : SChar) : Array<{a : TAction, weight : Int}> {
		var ta = switch(c) {

			//commun à tous les élèves
			case Std_0 : 		[] ;

			//variations pour les élèves de base
			case Std_V1 : 		[Pet_Chut] ;

			case Std_V2 :		[Pet_ElbowHit,Pet_Shock,Pet_Muscled] ;

			case Std_V3 : 		[Pet_Explication,Pet_IronWill,Pet_Hot] ;

			case Std_V4	: 		[Pet_Meditate,Pet_Valium,Pet_BonusXp] ;

			case Std_V5	: 		[Pet_ComeOn,Pet_NoLaugh,Pet_IronWill] ;

			case Std_V6	: 		[Pet_Sleep,Pet_Club,Pet_Alzheimer] ;

			case Std_V7	: 		[Pet_Chut,Pet_Club,Pet_Stock] ;

			case Std_V8 : 		[Pet_Tickle,Pet_Exclude,Pet_Cheater] ;

			case Std_V9 : 		[Pet_Dring, Pet_Valium, Pet_Cheater] ;

			case Std_V10 : 		[Pet_Meditate, Pet_Sleep, Pet_BoringTransfer] ;
			//
			case Noisy_0 : 		[Pet_ComeOn] ;

			case Noisy_1 : 		[Pet_Dring, Pet_Explication] ; 

			case Noisy_2 :  	[Pet_Exclude, Pet_Alzheimer] ;

			case Psi_0 : 		[Pet_Exclude] ;

			case Psi_1 : 		[Pet_Cheater] ;

			case Psi_2 : 		[Pet_BoringTransfer, Pet_Stock] ;

			case Physic_0 : 	[Pet_Club] ;

			case Physic_1 : 	[Pet_Muscled] ;

			case Physic_2 : 	[Pet_Muscled, Pet_ElbowHit] ;

			case Funny : 		[Pet_Shock, Pet_BonusXp] ;

			case Joker :		[Pet_Tickle] ;

			case Fan :			[Pet_Chut, Pet_Dring] ;

			case Dreamer : 		[Pet_Valium] ;

			case Hibernator : 	[Pet_IronWill] ;

			case Cruel : 		[Pet_Valium, Pet_Tickle] ;

			case Greedy : 		[Pet_Hot, Pet_Stock] ;

			case Speedy : 		[Pet_Alzheimer] ;

			case Shy : 			[Pet_Meditate] ;

			case Inquiring : 	[Pet_Stock] ;

			case Dumb : 		[Pet_BoringTransfer] ;

			case Careless : 	[Pet_Dring] ;

			case Wimpy : 		[Pet_Meditate, Pet_Valium] ;

			case Clever : 		[Pet_Explication] ;

			case Gossip : 		[Pet_ElbowHit] ;

			case Pee : 			[Pet_IronWill, Pet_Exclude] ;

			case Fragile : 		[Pet_Chut, Pet_Meditate] ;

			case NoSleep :		[Pet_Sleep] ;

			case NoLaugh : 		[Pet_NoLaugh] ;

			case CopyCat : 		[Pet_Shock] ;

			case SerialLover : 	[Pet_Hot, Pet_Cheater] ;

			case Wizard : 		[Pet_BonusXp] ;

			case Collector :	[Pet_ComeOn, Pet_ElbowHit] ;

			case Smell : 		[Pet_Muscled, Pet_Tickle] ;
		}


		var res = [] ;
		for (i in 0...ta.length) {
			res.push({a : ta[i], weight : (i < ta.length - 1) ? ta.length : 1}) ;
		}
		return res ;
	}


	static public function getCharacterActions(c : SChar) : Array<CharAction> {
		return switch(c) {
					case Std_0 : [{a : BrokeHeart, p : 1},
								{a : HandUpQuestion, p : 3},
								{a : HandUpNote, p : 1},
								{a : Add_Boredom, p : 8}] ;

			//variations pour les élèves de base
			case Std_V1 : 		[{a : HandUpQuestion, p : 4},
								{a : HandUpHeal, p : 1},
								{a : Atk_Ps_0, p : 10},] ;

			case Std_V2 :		[{a : Atk_Ph_0, p : 6},
								{a : Add_Lol, p : 6},
								{a : Add_BadBehaviour, p : 4}] ;

			case Std_V3 : 		[{a : Give_Speak, p : 6},
								{a : HandUpQuestion, p : 3},
								{a : HandUpHeal, p : 1},
								{a : Atk_N_0, p : 7}] ;

			case Std_V4	: 		[{a : HandUpOut, p : 2},
								{a : HandUpQuestion, p : 3},
								{a : Atk_Ph_8, p : 8}] ;

			case Std_V5	: 		[{a : Give_Speak, p : 3},
								{a : Add_Lol, p : 8},
								{a : HandUpQuestion, p : 3},
								{a : HandUpHeal, p : 2},
								{a : Atk_Ph_8, p : 12}] ;

			case Std_V6	: 		[{a : Atk_Ph_0, p : 16},
								{a : Atk_Ph_4, p : 2},
								{a : HandUpOut, p : 3}] ;

			case Std_V7	: 		[{a : Add_BadBehaviour, p : 14},
								{a : Atk_Ps_2, p : 14},
								{a : HandUpOut, p : 5}] ;

			case Std_V8 : 		[{a : HandUpQuestion, p : 5},
								{a : HandUpHeal, p : 2},
								{a : Atk_Ph_3, p : 1},
								{a : Atk_Ps_1, p : 12},
								{a : Add_BigBoredom, p : 8}] ;

			case Std_V9 : 		[{a : HandUpOut, p : 3},
								{a : Add_BoringGenerator, p : 1},
								{a : Give_Speak, p : 5},
								{a : Atk_N_2, p : 14},] ;

			case Std_V10 : 		[{a : Atk_N_7, p : 16},
								{a : Give_Slow, p : 4},
								{a : HandUpHeal, p : 3},
								{a : Atk_Ph_2, p : 10}] ;
			//

			case Noisy_0 : 		[{a : Atk_N_0, p : 16},
								{a : Atk_N_1, p : 11}, 
								{a : Atk_N_2, p : 8},
								{a : Atk_N_7, p : 4}] ;

			case Noisy_1 : 		[{a : Atk_N_1, p : 4}, 
								{a : Atk_N_2, p : 12}, 
								{a : Atk_N_3, p : 16}, 
								{a : Atk_N_4, p : 10}, 
								{a : Add_Tictic, p : 10}] ;

			case Noisy_2 :  	[{a : Atk_N_4, p : 12}, 
								{a : Atk_N_5, p : 5}, 
								{a : Atk_N_6, p : 8}, 
								{a : Add_Tictic, p : 10}, 
								{a : Add_Singing, p : 4}] ;

			case Psi_0 : 		[{a : Atk_Ps_0, p : 16},
								{a : Atk_Ps_1, p : 12}, 
								{a : Atk_Ps_2, p : 8}] ;

			case Psi_1 : 		[{a : Atk_Ps_1, p : 4}, 
								{a : Atk_Ps_2, p : 14}, 
								{a : Atk_Ps_3, p : 18}, 
								{a : Add_BoringGenerator, p : 6}, 
								{a : Add_Voodoo, p : 12}] ;

			case Psi_2 : 		[{a : Atk_Ps_3, p : 12}, 
								{a : Atk_Ps_4, p : 16}, 
								{a : Atk_Ps_7, p : 5},
								{a : Atk_Ps_5, p : -1}] ;

			case Physic_0 : 	[{a : Atk_Ph_0, p : 16}, 
								{a : Atk_Ph_1, p : 12}, 
								{a : Atk_Ph_2, p : 8}] ;

			case Physic_1 : 	[{a : Atk_Ph_1, p : 10}, 
								{a : Atk_Ph_2, p : 16}, 
								{a : Atk_Ph_3, p : 6}, 
								{a : Atk_Ph_5, p : 4}] ;

			case Physic_2 : 	[{a : Atk_Ph_1, p : 4}, 
								{a : Atk_Ph_3, p : 16}, 
								{a : Atk_Ph_4, p : 10},
								{a : NeighbourLaunch, p : -1}] ;

			case Funny : 		[{a : Atk_Ps_2, p : 8}, 
								{a : Give_Lol, p : 16}, 
								{a : Add_Lol, p : 14}, 
								{a : LaughingGas, p : -1}] ;

			case Joker :		[{a : Atk_N_6, p : 20},
								{a : Atk_Ph_9, p : 12},
								{a : Atk_Ph_4, p : 6},
								{a : Atk_Ph_5, p : 20}] ;

			case Fan :			[{a : Add_Singing, p : 12},
								{a : Atk_N_8, p : 18},
								{a : HandUpHeal, p : 4},
								{a : Concert, p : -1}] ;

			case Dreamer : 		[{a : Atk_N_7, p : 10},
								{a : Add_BigBoredom, p : 12},
								{a : Add_Moon, p : 6},
								{a : Give_Moon, p : 6}] ;

			case Hibernator : 	[{a : Add_Asleep, p : 14}, 
								{a : Give_Asleep, p : 12},
								{a : Atk_N_7, p : 10},
								{a : Morpheus, p : -1}] ;

			case Cruel : 		[{a : Atk_Ph_5, p : 16},
								{a : Atk_Ps_0, p : 8},
								{a : Add_Angry, p : 10},
								{a : BrokeHeart, p : 20},
								{a : Calumny, p : -1}] ;

			case Greedy : 		[{a : Add_Chewing, p : 12},
								{a : Give_Chewing, p : 8},
								{a : Atk_Ph_8, p : 10},
								{a : Dining, p : -1}] ;

			case Speedy : 		[{a : Atk_Ps_0, p : 10},
								{a : Atk_N_2, p : 10},
								{a : Add_BadBehaviour, p : 12},
								{a : AttackTwice, p : -1}] ;

			case Shy : 			[{a : HandUpOut, p : 7},
								{a : Add_Tictic, p : 12},
								{a : Atk_Ps_0, p : 6},
								{a : Dizzy, p : -1}] ;

			case Inquiring : 	[{a : HandUpQuestion, p : 14},
								{a : Add_Inverted, p : 10},
								{a : HandUpNote, p : 3},
								{a : Give_Speak, p : 6},
								/*{a : BadQuestion, p : -1}*/] ;

			case Dumb : 		[{a : Add_Inverted, p : 14},
								{a : Add_BoringGenerator, p : 14},
								{a : Atk_N_2, p : 8},
								{a : HelpMePlease, p : -1}] ;

			case Careless : 	[{a : Atk_N_3, p : 14},
								{a : Atk_N_7, p : 10},
								{a : Give_Speak, p : 6},
								{a : Tornado, p : -1}] ;

			case Wimpy : 		[{a : Add_Slow, p : 10},
								{a : Give_Slow, p : 10},
								{a : Atk_Ps_2, p : 6},
								{a : Add_BoringGenerator, p : 4},
								{a : SlowOthers, p : -1}] ;

			case Clever : 		[{a : HandUpQuestion, p : 12},
								/*{a : HandUpCheat, p : 8},*/
								{a : Atk_Ps_0, p : 10},
								{a : Atk_Ps_3, p : 6},
								{a : SelfKO, p : -1}] ;

			case Gossip : 		[{a : Atk_N_0, p : 12}, 
								{a : Atk_N_2, p : 8}, 
								{a : Atk_Ps_3, p : 6}, 
								{a : Give_Speak, p : 12},
								/*{a : HandUpCheat, p : 1}*/] ;

			case Pee : 			[{a : HandUpOut, p : 12},
								{a : Atk_Ps_0, p : 6},
								{a : Atk_Ps_6, p : 8}] ;

			case Fragile : 		[{a : Atk_N_9, p : 15}] ;

			case NoSleep :		[{a : Atk_N_4, p : 6},
								{a : Atk_N_7, p : 14}] ;

			case NoLaugh : 		[{a : Add_Tictic, p : 14},
								{a : Atk_Ps_3, p : 10},
								{a : HandUpQuestion, p : 6},
								/*{a : HandUpCheat, p : 2}*/] ;

			case CopyCat : 		[{a : CopyChar, p : 6},
								{a : Add_Clone, p : 16}] ;

			case SerialLover : 	[{a : FallInLove, p : 14},
								{a : Give_Speak, p : 8},
								{a : Atk_Ph_0, p : 7},
								{a : Add_Moon, p : 2},
								{a : HandUpHeal, p : 4},
								/*{a : DoctorLove, p : -1}*/] ; //supprimé

			case Wizard : 		[{a : Add_Invisibility, p : 8},
								{a : Give_Invisibility, p : 6},
								{a : Atk_Ps_0, p : 8},
								{a : Atk_Ph_6, p : 14}] ;

			case Collector :	[{a : Add_Voodoo, p : 8},
								{a : Atk_N_0, p : 10}] ;

			case Smell : 		[{a : Atk_Ps_6, p : 8},
								{a : Atk_Ph_7, p : 16},
								{a : Prout, p : -1}] ;	


		}
	}


}