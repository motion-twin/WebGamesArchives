class Cs{//}
	static var mcw = 300
	static var mch = 300
	
	// GAMEPLAY
	static var CDIF = 0.7//0.7
	
	// SCORES
	static var SCORE_ASTEROID = KKApi.aconst([ 50, 75, 150, 200, 300 ]);
	static var C5 = KKApi.const(5);
	static var C0 = KKApi.const(0);
	static var C500 = KKApi.const(500);
	
	
	static var C_OMEGA = 		KKApi.const(65);
	static var C_BLACKRON = 	KKApi.const(80);
	static var C_FURIA = 		KKApi.const(120);
	static var C_CUTTY_OPEN = 	KKApi.const(200);
	static var C_MINE = 		KKApi.const(300);
	static var C_BRIAROS = 		KKApi.const(350);
	static var C_GROMPH = 		KKApi.const(450);
	static var C_SHIELD = 		KKApi.const(500);
	static var C_CUTTY_CLOSE = 	KKApi.const(600);
	static var C_ORB = 		KKApi.const(800);
	static var C_BLOCK = 		KKApi.const(1000);
	static var C_SURGROMPH = 	KKApi.const(1500);
	static var C_GERGIN = 		KKApi.const(2400);
	static var C_NES = 		KKApi.const(5000);
	static var C_STORM = 		KKApi.aconst([ 2000, 3500, 8000 ]);


	
	
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
	
	// COLOR
	static function colToObj32(col){
		return {
			a:col>>>24
			r:(col>>16)&0xFF,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
	}
		
	// DIST ANG
	static function getDist(o1,o2){
		var dx = o1.x - o2.x;
		var dy = o1.y - o2.y;
		return Math.sqrt(dx*dx+dy*dy);
	}
	
	static function getAng(o1,o2){
		var dx = o1.x - o2.x;
		var dy = o1.y - o2.y;
		return Math.atan2(dy,dx)
	}
	
	// BITMAP
	static function zoom(bmp,z:float){

		var zimg = new flash.display.BitmapData(int(bmp.width*z),int(bmp.height*z),true,0x00000000)
		var m = new flash.geom.Matrix();
		m.scale(z,z);
		zimg.draw(bmp,m,null,null,null,null);
		
		m = new flash.geom.Matrix();
		m.translate(-(bmp.width*z-bmp.width)*0.5, -(bmp.height*z-bmp.height)*0.5 )
		
		/*
		var c = 0.98
		var o = -1
		var ct =new flash.geom.ColorTransform(c,c,c,1,o,o,o,0)
		Log.print(zimg.width)
		*/
		var ct = null
		//bmp.draw( zimg, m,ct, null, null, null );
		bmp.copyPixels( zimg, zimg.rectangle, new flash.geom.Point(-(bmp.width*z-bmp.width)*0.5, -(bmp.height*z-bmp.height)*0.5 ), null, null, null )
		zimg.dispose();
	}
	
	// FILTERS
	static function glow(mc, bl, str, col ){
		var fl = new flash.filters.GlowFilter();
		fl.blurX = bl;
		fl.blurY = bl;
		fl.strength = 1
		fl.color = col
		mc.filters = [fl]
	}
	
	// CHAIN MC COMMAND
	static function allGoto(mc:MovieClip,key:String,fr:int){
		var f = fun(str){
			var mmc:MovieClip = Std.getVar( mc,str)
			if( mmc._visible ){
				if(str.substr(0,key.length) == key ){
					mmc.gotoAndStop(string(fr));
				}
				allGoto(mmc,key,fr)
			}
		}
		downcast(Std).forin( mc, f )
	}
	
//{	
}