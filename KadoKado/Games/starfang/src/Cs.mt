class Cs{//}
	static var mcw = 300
	static var mch = 300
	
	static var START_SAFE_DIST = 40
	static var WEAPON_POWER_MAX = 4
	// GAMEPLAY
	
	static var DAMAGE_BOMB = 4
	static var DAMAGE_TENTACULE = 0.25
	static var DAMAGE_HOMING = 2.5
	
	// SCORES
	static var SCORE_ASTEROID = KKApi.aconst([ 50, 75, 150, 200, 300 ]);
	static var C5 = KKApi.const(5);
	static var C0 = KKApi.const(0);
	
	//

	
	static var game:Game;
	
	static function init(){
		
	}
	
	static function mm(a,b,c){
		return Math.min(Math.max(a,b),c)
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