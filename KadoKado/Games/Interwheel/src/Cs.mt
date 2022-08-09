class Cs{//}

	static var mcw = 300
	static var mch = 300
	
	static var SIDE = 10
	static var SPACE = 8

	static var VIEW_WHEEL = 50
	static var START_WHEEL_ID = 10
	// GAMEPLAY
	static var WMAX = 50
	static var DIF = 120	
	
	static var WHEEL_SPEED_MIN = 0.05
	static var WHEEL_SPEED_MAX = 0.25
	static var WHEEL_SPEED_RANDOM = 0.05
	
	static var WHEEL_DIST_MIN = 60
	static var WHEEL_DIST_MAX = 120
	
	static var WHEEL_RAY_MIN = 8
	static var WHEEL_RAY_MAX = 32
	static var WHEEL_RAY_RANDOM = 50
	
	static var DIF_RANDOMIZER = 0.1;
	
	static var WATER_TIMER = 0
	static var WATER_SPEED = 1
	static var WATER_SPEED_INC = 0.0003
	static var DROWN_LIMIT = 100
	
	// SCORE
	static var SCORE_PASTILLE = KKApi.aconst([250,1000,5000]) //KKApi.const(150)

	static var game:Game;
	
	
	
	static function init(){

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
	
	static function getDist(o,o2){
		var dx = o2.x - o.x;
		var dy = o2.y - o.y;
		return Math.sqrt(dx*dx+dy*dy)
	}

	//
	static function drawMcAt(bmp,mc,x,y){
		var m = new flash.geom.Matrix()
		m.translate(x,y)
		//m.tx = x;
		//m.ty = y;
		bmp.draw( mc, m, null, null, null, null )
	}
	//
	/*
	static function getPercentColorCt(prc,col){

		var c = (1-prc/100)
		var ct = new flash.geom.ColorTransform(null,null,null,1,null,null,null,0)
		ct.rgb = col
		ct.redMultiplier = c
		ct.greenMultiplier = c
		ct.blueMultiplier = c
		return ct;
		
	}
	*/
	static function blurMc(mc,d){
		var fl = new flash.filters.BlurFilter()
		fl.blurX = d;
		fl.blurY = d;
		mc.filters = [fl]
	}
	
	
//{	
}