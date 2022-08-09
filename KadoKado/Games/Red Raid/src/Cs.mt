class Cs{//}

	static var mcw = 300
	static var mch = 300
	
	static var game:Game;
	
	static var C1 = KKApi.const(1);
	static var C15 = KKApi.const(15);
	static var C250 = KKApi.const(250);
	static var C500 = KKApi.const(500);
	static var C1500 = KKApi.const(1500);
	static var C2000 = KKApi.const(2000);
	static var C5000 = KKApi.const(5000);

	static var RENFORT_STATS = [1,0.5,0.4,0.3,0.2,0.1,0.05]
	
	static var SELECT_TRESHOLD =  1.3
	static var DIF_RATE = 0.007//0.005
	
	static var GAME_MODE = 1	// 0:RENFORT 1:BONUS
	static var SELECT_MODE = 1	// 0:CLASSIC 1:MIX 2:SEB
	static var SPACE_MODE = 1	// 0:ALL 1:INVERSE
	
	
	static function init(){
		Ally.sel = []
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
	
	static function getOutPos(ray){
		var rnd = Std.random(4)
		var w = Cs.mcw
		var h = Cs.mch
		switch(rnd){
			case 0:
				return {x:-ray, y:Math.random()*h}
			case 1:
				return {x:w+ray, y:Math.random()*h}
			case 2:
				return {x:Math.random()*w, y:-ray}
			case 3:
				return {x:Math.random()*w, y:h+ray}
		}
		return null
	}
	
//{	
}