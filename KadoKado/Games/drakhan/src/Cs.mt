class Cs{//}

	
	static var RAY = 12
	static var WW:float;
	static var HH:float;
	
	static var mcw = 300
	static var mch = 300
	
	static var GRID_RAY = 20
	static var WHEEL_RAY = 132//140
	static var LAUNCH_RAY = 160
	
	static var STEP_CONTROL =	1
	static var STEP_FLY = 		2
	static var STEP_BLAST =		3
	static var STEP_FALL =		4
	static var STEP_SPAWN_CENTER =	5
	static var STEP_DEATH =		6
	
	static var DIR = [[0,1],[1,0],[1,-1],[0,-1],[-1,0],[-1,1]]
	
	// GAMEPLAY
	
	static var COMBO_LIMIT = 3
	static var COLOR_START = 3
	static var COLOR_RYTHM = [ 10, 40, 70, 110, 200 ]
	
	static var ICE_TURN_MIN = 10
	static var ICE_PROGRESSION = 400
	static var ICE_MIN = 0.1
	static var ICE_MAX = 0.3
	
	static var MU_TURN_MIN = 50
	static var MU_PROGRESSION = 400
	static var MU_MIN = 0
	static var MU_MAX = 1
	// SCORE

	static var C1000 = KKApi.const(1000);
	static var C2000 = KKApi.const(2000);
	static var SCORE_COMBO_BASE = KKApi.const(200)
	static var SCORE_COMBO_BONUS = KKApi.const(100)
	static var SCORE_STAR = KKApi.aconst([50,50,50,75,100,150,250,500])


	static var game:Game;
	
	static function init(){
		WW = RAY*2.25
		HH = RAY*1.25
		
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
	
	static function getPos(x,y){
		var px = Math.round( ( y/HH + x/WW ) / 2 )
		var py = Math.round( x/WW - px )
		return {x:px,y:py}
	}
	
//{	
}