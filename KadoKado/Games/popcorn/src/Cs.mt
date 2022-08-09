class Cs{//}

	static var mcw = 300
	static var mch = 300
	
	static var HEIGHT = 900//1000
	static var MARGIN = 0

	static var COMBO = KKApi.aconst([ 25,50,75,100,150,200,300,400,500 ])
	static var SCORE_BOSS = KKApi.const(50000);
	static var SCORE_HIT = KKApi.const(5000);
	
	static var DIR = [
		{x:1,y:0},
		{x:0,y:1},
		{x:-1,y:0},
		{x:0,y:-1}
	]
		
	// COLOR MATRIX
	static var CM_GREY = []
	static var CM_STD = []

	//
	static var game:Game;
	
	
	static function init(){
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
	
	static function averageMod(list, mod){
		
		var sum = 0
		for( var i=0; i<list.length; i++ ){
			sum += list[i]/list.length
		}		
		return sum

	}
	
	//
	static function drawMcAt(bmp,mc,x,y){
		var m = new flash.geom.Matrix()
		m.translate(x,y)
		bmp.draw( mc, m, null, null, null, null )
	}
	
	static function draw(bmp,mc){
		var m = new flash.geom.Matrix();
		
		m.scale(mc._xscale/100, mc._yscale/100)
		m.rotate(mc._rotation*0.0174)
		m.translate(mc._x,mc._y)
		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -255 + mc._alpha*2.55)
		//ct.alphaOffset = -255 + mc._alpha*2.55
		var b = mc.blendMode
		bmp.draw( mc, m, ct, b, null, null )
	}
	
	// FILTER
	static function blurMc(mc,d){
		var fl = new flash.filters.BlurFilter()
		fl.blurX = d;
		fl.blurY = d;
		mc.filters = [fl]
	}

	static function cellShadeMc(mc,col,d){
		if(d==null)d=2
		var fl = new flash.filters.GlowFilter();
		fl.blurX = d;
		fl.blurY = d;
		fl.color = col;
		fl.strength = 255
		mc.filters = [fl];
		
	}
	
	// COLOR MATRIX
	static function getGreyMatrix(a){
		var r = 0.3
		var g = 0.5
		var b = 0.1
		return [
				r,	g,	b,	0,	a,
				r,	g,	b,	0,	a,
				r,	g,	b,	0,	a,
				0,	0,	0,	1,	0 
		]
	}
	
	static function getAlmostGreyMatrix(a){
		var rnd = 20
		var rr = (Math.random()*2-1)*rnd
		var rg = (Math.random()*2-1)*rnd
		var rb = (Math.random()*2-1)*rnd
		var r = 0.3
		var g = 0.5
		var b = 0.1
		return [
				r,	g,	b,	0,	a+rr,
				r,	g,	b,	0,	a+rg,
				r,	g,	b,	0,	a+rb,
				0,	0,	0,	1,	0 
		]
	}
	
	// COLOR
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
	
	// BITMAP DATA
	static function drawMC(bmp,mc){
		var m = new flash.geom.Matrix();
		m.scale(mc._xscale/100, mc._yscale/100)
		m.rotate(mc._rotation*0.0174)
		m.translate(mc._x,mc._y)
		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -255 + mc._alpha*2.55)
		var b = mc.blendMode
		bmp.draw( mc, m, ct, b, null, null )
	}
	
//{	
}