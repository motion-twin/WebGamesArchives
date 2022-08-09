import GameData.ArtefactId ;

class Const {
	
	public static var FL_DEBUG = false ;
		
	public static var PICK_COLOR = /*0xf7ff1e*/ 0xFFFFFF ;
	public static var HIDE_CHAIN_COL = 0x373862 ;
		
	public static function getDataGame() : GameData {
		var res =	{  mode : "Default",
				chain : new mt.flash.PArray(),
				chWeight : new mt.flash.PArray(),
				artefacts : new mt.flash.PArray(),
				helps : null} ;
				
		for (i in 0...12) {
			res.chain.push(Elt(i)) ;
			res.chWeight.push(switch(i) {
							case 4 : 12 ;
							case 5 : 8 ;
							case 6 : 7 ;
							case 7 : 5 ;
							case 8 : 4 ;
							case 9, 10 : 1 ;
							case 11 : 0 ;
							default : 18 ;
							
							}) ;
		}
		
		for (i in 0...11) {
			res.artefacts.push(switch(i) {
							case 0 : {id : Elts(2, null), freq : 1400} ;
							case 1 : {id : Elts(2, Block(3)), freq : 1800} ;
							case 2 : {id : Elts(2, Block(4)), freq : 1550} ;
							
							case 3 : {id : Elts(3, null), freq : 400} ;
							case 4 : {id : Elts(3, Block(3)), freq : 600} ;
							case 5 : {id : Elts(3, Block(4)), freq : 500} ;
							
							case 6 : {id : Dynamit(0), freq : 18} ; 
							case 7 : {id : Dynamit(2), freq : 5} ;
							case 8 : {id : PearGrain(0), freq : 15} ;
							case 9 : {id : Alchimoth, freq : 10} ;
							case 10 : {id : Grenade(1), freq : 3} ;
						}) ;
		}
		
		
		return res ;
		
	}
	
	//MC
	public static var WIDTH = 300 ;
	public static var HEIGHT = 300 ;
		
	//INTERFACE
	public static var INTER_DX = 5 ;
	public static var INTER_X = 189 ;
	public static var INTER_SCORE_Y = 23 ;
	public static var INTER_SPIRIT_BOX_Y = 45 ;
	public static var INTER_NEXT_Y = 132 ;
	
	public static var SPIRIT_CENTER = {x : INTER_X + /*48.0*/52.0, y : INTER_SPIRIT_BOX_Y + /*40.0*/95.0} ;


	//DEPTHS
	public static var DP_BG = 0 ;
	public static var DP_INFO = 1 ;
	public static var DP_STAGE = 2 ;
	public static var DP_GROUP = 3 ; //5
	public static var DP_INTERFACE = 4 ; //3
	public static var DP_INVENTORY = 5 ; //4
	public static var DP_NEXT_GROUP = 6 ;
	public static var DP_GROUP_BOX = 7 ;
	
	public static var DP_ANIM = 8 ;
	public static var DP_MASK = 9 ;
	public static var DP_PART = 10 ;
	
	public static var DP_BMP = 11 ;	
	public static var DP_WAITING = 12 ;
	public static var DP_LOADING = 13 ;
	
	//STAGE DEPTH
	public static var DP_WALLPAPER = 0 ;
	public static var DP_EFFECT = 1 ;
	public static var DP_FADER = 2 ;
	public static var DP_LIMITE = 3 ;


	//SIZES
	public static var ELEMENT_SIZE = 30.0 ;
	public static var NEXTPOS = {x : 233, y : 49} ;
	
	public static var GROUP_MASK_X = 206 ;
	public static var GROUP_MASK_Y = 14 ;
	
	//GROUP
	public static var GROUP_LINE = 2 ; 
	public static var GROUP_Y = ELEMENT_SIZE * GROUP_LINE ;
	
	//BOUNCE
	public static var BOUNCE_DEEP = 4 ;
	
	
	public static var TRANSMUT_LIMIT = 3 ;
	public static var TRANSMUT_TARGET = 0 ;

	
	//POINTS
	//public static var COMBO_BONUS = KKApi.const(10) ;
	public static var POINTS = [KKApi.const(5), 
							KKApi.const(15), 
							KKApi.const(45), 
							KKApi.const(135), 
							KKApi.const(405), 
							KKApi.const(1215), 
							KKApi.const(3645), 
							KKApi.const(10935), 
							KKApi.const(32805), 
							KKApi.const(98415), 
							KKApi.const(295245), 
							KKApi.const(885735)] ;
							
	
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
	
	
}
	
