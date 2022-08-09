class Cs{//}
	static var mcw = 622//600
	static var mch = 424//414
	
	static var DIR = [[1,0],[0,1],[-1,0],[0,-1]]

	
	// GAMEPLAY
	static var INTERFACE_MARGIN = 30
	
	
	// COLOR MATRIX
	static var CM_GREY = []
	static var CM_STD = []
	
	//
	static var logText:String;
	
	// GFX
	static var game:Game;
	static var cacheLevel:flash.display.BitmapData;
	static var cacheLevelIron:flash.display.BitmapData;
	
	static var PIOU_COLOR_MATRIX = [
		[
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	50,
			0,	0,	0.8,	0,	0,
			0,	0,	0,	1,	0 
		],
		[
			0.8,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	70,
			0,	0,	0,	1,	0 
		],
		[
			0.8,	0,	0,	0,	0,
			0,	1,	0,	0,	50,
			0,	0,	1,	0,	10,
			0,	0,	0,	1,	0 
		],
		[
			1,	0,	0,	0,	50,
			0,	1,	0,	0,	10,
			0,	0,	0.7,	0,	0,
			0,	0,	0,	1,	0 
		]		
	]
	
	
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
		
		logText = "";
		
		// COLOR MATRIX
		var r = 0.3
		var g = 0.5
		var b = 0.1
		var a = 30
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
	
	// GET RY
	static function gry(y){
		return Level.bmp.height-y
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

	static function setColorMatrix(mc, m, dec){
		if(dec!=null){
			m = m.duplicate();
			for( var i=0; i<3; i++){
				m[4+5*i] = dec
			}		
		}
		var fl = new flash.filters.ColorMatrixFilter();

		fl.matrix = m
		mc.filters = [fl]
	}
	
	static function col32to16(c){
		var o = upcast(colToObj32(c))
		return objToCol(o)
	}
	
	
	//
	static function traceBmp(bmp){
		var mc = Cs.game.mdm.empty(12)
		mc.attachBitmap(bmp,0)
	}
	
	
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
	
	//
	static function log(str){
		logText += str+"\n"
		//Log.trace(str)
	}
	
//{	
}