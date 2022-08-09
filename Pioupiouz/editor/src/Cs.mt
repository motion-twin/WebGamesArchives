class Cs{//}
	static var mcw = 622
	static var mch = 500
	
	static var CAB = true;
	
	static var DIM = [ [592,424], [1200,424], [592,800], [1200,800], [1800,424], [592,1200], [1200,1200], [1600,1600], [2100,800], [2100,1200]]
	

	static var INTERFACE_MARGIN = 140
	static var ARTWORK_MAX = 100
	
	static var CM_GREY = []
	static var CM_STD = []
	
	// GFX
	static var game:Game;
	
	static function init(){
		
		var lid = downcast(Std.getRoot()).$lang
		switch(lid){
			
			case "en":
				Lang = LangEn;
				break;
			case "es":
				Lang = LangEs;
				break;
			case "fr":
			default:
				Lang = LangFr;
				break;			
		}
		
		//mch -= INTERFACE_MARGIN
		// COLOR MATRIX
		var r = 0.3
		var g = 0.5
		var b = 0.1
		var a = 40
		CM_GREY = [
				r,	g,	b,	0,	a,
				r,	g,	b,	0,	a,
				r,	g,	b,	0,	a,
				0,	0,	0,	1,	0 
		]
		
		//
		CM_STD = [
				1,	0,	0,	0,	0,
				0,	1,	0,	0,	0,
				0,	0,	1,	0,	0,
				0,	0,	0,	1,	0 
		]		
		
		
		
		
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
	
	// COLOR
	static function colToObj(col){
		return {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
	}
	
	static function objToCol(o){
			return (o.r << 16) | (o.g<<8 ) | o.b
	}		
	
	static function colToObj32(col){
		return {
			a:col>>>24
			r:(col>>16)&0xFF,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
	}
	
	static function objToCol32(o){
			return (o.a << 24) | (o.r << 16) | (o.g<<8 ) | o.b
	}		

	static function setPercentColor( mc, prc, col ){	
		var color = colToObj(col)
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
	
	static function setColor( mc, col, dec ){
		if(dec==null)dec =-255;
		var o = colToObj32(col)
		var co = new Color(mc)
		var ct = {
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:o.r+dec,
			gb:o.g+dec,
			bb:o.b+dec,
			ab:0
		};
		co.setTransform( ct );
	}	

	static function col32to16(c){
		var o = upcast(colToObj32(c))
		
		return objToCol(o)
	}
	
	//
	static function blur(mc,n){
		var fl = new flash.filters.BlurFilter();
		fl.blurX = n
		fl.blurY = n
		mc.filters = [fl]
	}
	
	// DEBUG
	static function log(str){
		//Log.trace(str)
	}
	
	static function traceBmp(bmp){
		var mc = Cs.game.mdm.empty(12)
		mc.attachBitmap(bmp,0)
	}
	
	//
	static function getAng(o,o2){
		var dx = o.x - o2.x;
		var dy = o.y - o2.y;
		return Math.atan2(dy,dx)
	}
	static function getDist(o,o2){
		var dx = o.x - o2.x;
		var dy = o.y - o2.y;
		return Math.sqrt(dx*dx+dy*dy)
	}
	
//{	
}