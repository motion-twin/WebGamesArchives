class Cs{//}
	static var mcw = 300;
	static var mch = 300;
	static var SEC = 32;
	static var MARGE = 20;
	static var SCORE_FROG = 	KKApi.const(1500);
	
	// SCORES


	static var SCORE_CRABE 	= 	KKApi.const(250)
	static var SCORE_OCTO 	= 	KKApi.const(400)
	static var SCORE_BOMBER = 	KKApi.const(600)
	static var SCORE_OYSTER = 	KKApi.const(800)	
	static var SCORE_BOSS 	= 	KKApi.const(4000)
	
	static var SCORE_BONUS = KKApi.aconst([1000,3000,8000])


	
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

//{	
}