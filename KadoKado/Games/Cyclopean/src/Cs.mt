class Cs{//}

	static var mcw = 300
	static var mch = 300
	
	static var LEVEL_SIDE = 1600
	static var LEVEL_SIZE = 100
	
	static var MARGIN = 0

	static var SCORE_GREEN = KKApi.const(1000);
	static var SCORE_BONUS = KKApi.aconst([1500,4000,8000])
	static var SPAWN = [	0,0,0,0,0,					// GREEN
				1,1,						// BLUE
				2,						// PINK
				3,3,3,3,					// TIME
				4,4,4,4,4,4,4,4,4,4,4,4,4,4			// BALL
			]
	
	static var TIME_MAX = 3600
	static var BONUS_TIME = 1000
	
	static var SCORE_LAP = 2
	static var SCORE_BASE = KKApi.const(3)
	
	
	static var DIR = [
		{x:1,y:0},
		{x:0,y:1},
		{x:-1,y:0},
		{x:0,y:-1}
	]
	

	static var game:Game;
	static var dm:DepthManager;
		
	static var AUTO_MODE = false;	
	
	
	
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
	
	static function averageMod(list, mod){
		/*
		var min = mod
		for( var i=0; i<list.length; i++ ){
			min = Math.min(mod,list[i])
		}
		var sum = 0
		for( var i=0; i<list.length; i++ ){
			var dif = Cs.sMod(min-list[i],mod*2)
			sum += dif
		}
		return Cs.hMod( min-sum/list.length, mod )
		*/
		
		var sum = 0
		for( var i=0; i<list.length; i++ ){
			sum += list[i]/list.length
		}		
		return sum

	}
	
	//

	static function blurMc(mc,d){
		var fl = new flash.filters.BlurFilter()
		fl.blurX = d;
		fl.blurY = d;
		mc.filters = [fl]
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
		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -255 + mc._alpha*2.55 )
		var b = mc.blendMode
		bmp.draw( mc, m, ct, b, null, null )
	}
	
	static function drawMcAt(bmp,mc,x,y){
		var m = new flash.geom.Matrix()
		m.translate(x,y)
		bmp.draw( mc, m, null, null, null, null )
	}
	
	static function texturize(mask,link,ts){
		//return mask
		// MASK
		/*
		var mcMask = dm.empty(DP_TEST);
		var mcCont = Std.createEmptyMC(mcMask,0)
		var ddm = new DepthManager(mcCont);
		var max = 2+w*0.2
		var sc = Math.min(w*0.1,80)
		for( var i=0; i<max; i++ ){
			var mc = ddm.attach("mcForm",0);
			mc._rotation = rnd.rand()*360;
			mc._x = rnd.rand()*w
			var c = 1-Math.abs((mc._x-w*0.5)/(w*0.5))
			mc._y = ((rnd.rand()*2-1)-0.6)*(w*0.1)*c;
			mc._xscale = 15+c*sc;
			mc._yscale = mc._xscale;
			mc.gotoAndStop(string(rnd.random(mc._totalframes)+1))
		}
		mcCont._rotation = rot
		var b = mcMask.getBounds(root);
		var mcw = int(b.xMax-b.xMin);
		var mch = int(b.yMax-b.yMin);
		var mask = new flash.display.BitmapData(mcw,mch,true,0x00000000)
		var m = new flash.geom.Matrix();
		m.rotate(rot*0.0174)
		m.translate(-b.xMin,-b.yMin)
		mask.draw(mcCont,m,null,null,null,null)
		mcMask.removeMovieClip();
		*/
		// TEXTURE
		var rect = new flash.geom.Rectangle(0,0,ts,ts)
		var text = new flash.display.BitmapData(ts,ts,true,0x50000000)
		var mct = dm.attach(link,0)
		text.drawMC(mct,0,0)
		mct.removeMovieClip();
		
		// MAPPING
		var map = new flash.display.BitmapData(mask.width,mask.height,true,0x00000000)
		for( var x=0; x<mask.width; x+=ts ){
			for( var y=0; y<mask.height; y+=ts ){
				map.copyPixels(text,rect,new flash.geom.Point(x,y),null,null,null);
			}
		} 
		
		// BASE FINAL
		var bmp = new flash.display.BitmapData(mask.width,mask.height,true,0x00000000)
		bmp.copyPixels( map, new flash.geom.Rectangle(0,0,mask.width,mask.height),new flash.geom.Point(0,0),mask,null,true )	
		
		// CLEAN
		mask.dispose();
		text.dispose();
		map.dispose();
		return bmp;
		
	}

//{	
}