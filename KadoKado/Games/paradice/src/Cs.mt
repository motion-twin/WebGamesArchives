class Cs{//}

	
	static var mcw = 300
	static var mch = 300
	
	static var XMAX = 10
	static var YMAX = 10
	
	static var LIMIT_GAMEOVER = 9//9
	
	static var SQ = 24
	static var MD = 230
	static var ML = 0
	
	static var PLAY_LEVEL = 282;
	static var FILL_LEVEL = 320;
	
	// GAMEPLAY
	static var COMBO_SIZE = 4
	static var PLAY_TIMER = 180
	
	// RYTHM
	static var DESTROY_TIMER = 12
	static var GROUND_CONTROL_SPEED = 0.22
	
	// PARAMS
	static var FL_DISPLAY_TIMER = false;
	

	static var C0 = KKApi.const(0);
	
	static var game:Game;
	
	
	
	
	static function init(){
		ML = (Cs.mcw-(Cs.SQ*Cs.XMAX))*0.5
		
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