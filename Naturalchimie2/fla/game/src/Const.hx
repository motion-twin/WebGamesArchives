import GameData._ArtefactId ;

typedef Art = { //because cheat 
	var idx : mt.flash.Volatile<Int> ;
	var s : String ;
	var i : mt.flash.Volatile<Int> ;
	var a : Art ;
}


class Const {
	
	public static var FL_DEBUG = false ;
		
	public static var PICK_COLOR = /*0xf7ff1e*/ 0xFFFFFF ;
		
	public static var BOT_MODE = false ;
		
	public static var JS_DELAY = 500 ;
	
	//MC
	public static var WIDTH = 287 ;
	public static var HEIGHT = 356 ;
		
	//INTERFACE
	public static var INTER_DX = 5 ;
	public static var INTER_X = 189 ;
	public static var INTER_SCORE_Y = 23 ;
	public static var INTER_SPIRIT_BOX_Y = 45 ;
	public static var INTER_NEXT_Y = 132 ;
	
	public static var SPIRIT_CENTER = {x : 247.0, y : 75.0} ;

	public static var DP_PRE_LOAD = 0 ;
	public static var DP_SOUND = 1 ;	
	public static var DP_BLACK_LOADING = 2 ;
	public static var DP_BG = 3 ;
	public static var DP_INFO = 4 ;
	public static var DP_STAGE = 5 ;
	public static var DP_STAGE_MASK = 6 ;
	
	public static var DP_GROUP = 7 ; 
	
	public static var DP_ICE = 8 ; 

	public static var DP_INTERFACE = 9 ;
	public static var DP_INVENTORY = 10 ; 
	public static var DP_NEXT_GROUP = 11 ;
	public static var DP_GROUP_BOX = 12 ;
	
	public static var DP_ANIM = 13 ;
	public static var DP_MASK = 14 ;
	public static var DP_PART = 15 ;
	
	public static var DP_BMP = 16 ;
	public static var DP_WAITING = 17 ;
	public static var DP_MISSION = 18 ;
	public static var DP_PYRAM = 19 ;
	public static var DP_ERROR = 20 ;
	public static var DP_LOADING = 21 ;
	
	//STAGE DEPTH
	public static var DP_WALLPAPER = 0 ;
	public static var DP_EFFECT = 1 ;
	public static var DP_FADER = 2 ;
	public static var DP_LIMITE = 3 ;
	public static var DP_BLACK = 4 ;

	
	
	
	
	//SIZES
	public static var ELEMENT_SIZE = 30.0 ;
	public static var NEXTPOS = {x : 230, y : 181} ;
	
	//GROUP
	public static var GROUP_LINE = 2 ; 
	public static var GROUP_Y = ELEMENT_SIZE * GROUP_LINE ;
		
	//BOUNCE
	public static var BOUNCE_DEEP = 4 ;
		
	//CHAIN ### DEPRECATED
	/*public static var CHAIN = [0, 1, 2, 3, 4, 5, 6, 7] ;*/
	//public static var CHAIN = [17, 18, 19, 20, 21, 22, 23, 24] ;
	
	public static var TRANSMUT_LIMIT = 3 ;
	public static var TRANSMUT_TARGET = 0 ;

	//POINTS
	public static var COMBO_BONUS : mt.flash.Volatile<Int> ;
	//public static var POINTS : Array<mt.flash.Volatile<Int>> = [1, 3, 9, 27, 81, 243, 729, 2187, 6561, 19683, 59049, 177147] ; 
	public static var POINTS : Array<mt.flash.Volatile<Int>> ;

	static public function initialize() {
		COMBO_BONUS = 10 ;
		POINTS = new Array() ;
		POINTS.push(1) ;
		POINTS.push(3) ;
		POINTS.push(9) ;
		POINTS.push(27) ;
		POINTS.push(81) ;
		POINTS.push(243) ;
		POINTS.push(729) ;
		POINTS.push(2187) ;
		POINTS.push(6561) ;
		POINTS.push(19683) ;
		POINTS.push(59049) ;
		POINTS.push(177147) ;
	}
	
	
	//UTILS
	static public function sMod(n : Int,mod : Int) {
		while(n >= mod) n -= mod ;
		while(n < 0) n += mod ;
		return n ;
	}
	
	
	static public function randomProbs(t : Array<Int>) : Int {
		var n = 0 ;
		for(i in t) {
			//trace("randomProbs check : " + i) ;
		    n += i;
		}
		n = Std.random(n) ;
		var i = 0 ;
		while( n >= t[i]) {
		    n -= t[i] ;
		    i++ ;
		}
		return i ;
	}
	
	static public function randomObjectProbs(t : Array<{weight : Int}>) : Dynamic {
		var n = 0 ;
		for(e in t) {
		    n += e.weight ;
		}
		n = Std.random(n) ;
		var i = 0 ;
		while( n >= t[i].weight) {
			n -= t[i].weight ;
			i++ ;
		}
		return t[i] ;
	}



	static public function getArt(o : _ArtefactId) : Art {
		if (o == null)
			return null ;

		var v : mt.flash.Volatile<Int> = 0 ;
		v = Type.enumIndex(o) ;
		var res : Art = {idx : null, s : null, i : null, a : null}
		res.idx = v ;

		switch (o) {
			case _Elt(e), _Destroyer(e), _Dynamit(e), _Protoplop(e), _PearGrain(e), _Jeseleet(e), _Delorean(e), _Dollyxir(e), _Grenade(e), _Block(e), _CountBlock(e), _Surprise(e), _Pumpkin(e), _Slide(e) : 
				var v : mt.flash.Volatile<Int> = 0 ;
				if (e != null)
					v = e ;
				else
					v = -1 ;
				res.i = v ;
			
			case _Alchimoth, _Dalton, _Wombat, _MentorHand, _Patchinko, _RazKroll, _Detartrage, _Teleport, _Tejerkatum, _PolarBomb, _Pistonide, _Neutral, _Catz, _SnowBall, _Choco, _Empty, _Pa, _Stamp, _Unknown, _GodFather, _NowelBall, _Gift, _Skater, _Joker : 
				//nothing to do
			
			case _QuestObj(s), _Sct(s) : 
				res.s = s ; 

			case _DigReward(r) : 
				res.a = getArt(r) ;
			
			case _Elts(e, p) : 
				var v : mt.flash.Volatile<Int> = 0 ;
				v = e ;
				res.i = v ;
				res.a = getArt(p) ;
				
		}

		return res ;
	}

	static public function fromArt(a : Art) : _ArtefactId {
		if (a == null)
			return null ;
		
		var params : Array<Dynamic> = new Array() ;
		if (a.i != null)
			params.push(if (a.i == -1) null else a.i) ;
		if (a.s != null)
			params.push(a.s) ;
		if (a.a != null)
			params.push(fromArt(a.a)) ;

		return Type.createEnumIndex(_ArtefactId, a.idx, if (params.length > 0) params else null) ;
	}
	

	static var _ = initialize() ;
}
	
