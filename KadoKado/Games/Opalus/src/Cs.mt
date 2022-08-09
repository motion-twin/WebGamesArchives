class Cs{//}

	static var mcw = 300
	static var mch = 300
	
	static var SIZE = 20
	static var GRID_MAX = 15

	
	static var DIR = [[0,1],[1,0],[0,-1],[-1,0]]
	//static var PROB = [ 10, 10, 10, 10, 10, 10, 0, 3, 2, 1 ]
	static var PROB = [ 10, 10, 10, 10, 10, 10, 10]
	//static var SCORE:Array<KKConst>
	static var SCORE_FALL = KKApi.const(2500)
	static var SCORE_BALL = KKApi.const(750)
	static var SCORE_BONUS = KKApi.const(125)
	static var PROB_SUM = 0
	
	static var TIME_EXPLODE = 6
	static var TIME_FALL = 10
	static var TURN = KKApi.const(9)
	static var DEC_TURN = KKApi.const(-1)
	
	// GAMEPLAY

	// SCORE

	static var C1000 = KKApi.const(1000);

	static var game:Game;
	
	static function init(){
		for( var i=0; i<PROB.length; i++)PROB_SUM += PROB[i];
		//SCORE = KKApi.aconst([ 100, 100, 100, 100, 100, 100, 500, 1000, 5000 ])
	}
	
	static function setPercentColor( mc, prc, col ){	
		var color = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		var co = new Color(mc)
		var c  = prc/100
		var ct = {
			ra:int(100-prc),
			ga:int(100-prc),
			ba:int(100-prc),
			aa:100,
			rb:int(c*color.r),
			gb:int(c*color.g),
			bb:int(c*color.b),
			ab:0
		};
		co.setTransform( ct );
	}	

	static function mm(a,b,c){
		return Math.min(Math.max(a,b),c)
	}
	
	static function sMod(v,mod){

		while(v>=mod)v-=mod;
		while(v<0)v+=mod;
		return v;
	}
	
	static function hMod(v,mod){
		while(v>mod)v-=mod*2;
		while(v<-mod)v+=mod*2;
		return v;
	}	
	
	
//{	
}