class Cs{//}
	static var mcw = 300
	static var mch = 300
	
	static var bact = 0;

	// GAMEPLAY
	static var DAMAGE_FIREBALL = 1
	static var DAMAGE_SPARK = 1
	static var DAMAGE_LASER = 0.25
	
	static var DAMAGE_BOMB = 4
	static var DAMAGE_TENTACULE = 0.25
	static var DAMAGE_HOMING = 2.5
		

	// SCORES

	static var C1 = KKApi.const(1);
	static var C1000 = KKApi.const(1000);
	static var C3000 = KKApi.const(3000);
	static var C10000 = KKApi.const(10000);
	static var C500 = KKApi.const(500);

	static var SCORE_GOLGOTH = 	KKApi.const(5000)
	static var SCORE_FROG = 	KKApi.const(1500)
	static var SCORE_DRAGON = 	 KKApi.const(100)
	static var SCORE_DRONE = 	  KKApi.const(15)
	static var SCORE_CARRIER = 	 KKApi.const(100)
	static var SCORE_RUNNER = 	 KKApi.const(300)
	static var SCORE_BACTERY = 	 KKApi.const(400)
	static var SCORE_MEDUSA = 	KKApi.const(7500)
	
	//
	static var GROUND = 14
	static var MY = 40
	static var GL = null//14
	
	
	
	// GFX
	static var SCROLL_SPEED = 5//20//5

	static var game:Game;
	
	static function init(){
		GL = Cs.mch+Cs.MY-GROUND
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

	
	// MONSTER MIROIR
	// MONSTRE SOUFFLEUR
	
//{	
}