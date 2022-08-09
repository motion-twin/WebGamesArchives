class Cs{//}
	static var mcw = 600
	static var mch = 440
	
	static var DIR = [[1,0],[0,1],[-1,0],[0,-1]]
	//
	static var LOG_PRIORITY = 1//1
	
	//
	static var logText:String;
	
	
	
	// GFX
	static var game:Game;
	

	static function init(){
		logText =""
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
	
	static function mergeColor(col1,col2,c){
		var o1 = colToObj(col1)
		var o2 = colToObj(col2)
		var o3 = {
			r:int(o1.r*c + o2.r*(1-c))
			g:int(o1.g*c + o2.g*(1-c))
			b:int(o1.b*c + o2.b*(1-c))
		}
		return objToCol(o3)
	}
	
	// BMP
	static function drawMc(bmp,mc){

		var m = new flash.geom.Matrix();
		m.scale(mc._xscale/100, mc._yscale/100)
		m.rotate(mc._rotation*0.0174)
		m.translate(mc._x,mc._y)
		
		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, 0)
		var b = mc.blendMode
		
		bmp.draw( mc, m, ct, b, null, false )	
	}
	
	// FILTERS
	static function glow(mc,b,s,col){
		var fl = new flash.filters.GlowFilter();
		fl.blurX = b;
		fl.blurY = b;
		fl.color = col;
		fl.strength = s;
		mc.filters = [fl]
	}
	
	// UTILS
	static function setStartPos(o,card){
		o.x = card.x + (Math.random()*Card.WW-Card.WW*0.5)*card.scale/100
		o.y = card.y + (Math.random()*Card.HH-Card.HH*0.5)*card.scale/100
	}
	static function setSidePos(o,card){
		
		var r0 = (Std.random(2)*2-1)
		var r1 = Math.random()*2-1
		var a = [r0,r1]
		if(Std.random(2)==0)a=[r1,r0];
		o.x = card.x + (a[0]*Card.WW*0.5)*card.scale/100
		o.y = card.y + (a[1]*Card.HH*0.5)*card.scale/100
	}	
	// 
	static function traceBmp(bmp){
		var mc = Cs.game.dm.empty(12)
		mc.attachBitmap(bmp,0)
	}
	
	// HTML
	static function getBold(txt){
		return "<b>"+txt+"</b>"
	}
	static function getItalic(txt){
		return "<i>"+txt+"</i>"
	}
	static function getColFont(txt,col){
		//return txt;
		return "<font color=\""+col+"\">"+txt+"</font>"	
	}
	static function getSizeFont(txt,size:float){
		//return txt;
		return "<font size=\""+size+"\">"+txt+"</font>"	
	}
	
	// TOOLS
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
	
	// INTERN
	static function loadAvatar(mc){
		var mcl = new MovieClipLoader()
		mcl.onLoadComplete = callback(Cs,avatarLoaded)
		mcl.onLoadInit = callback(Cs,avatarLoaded)
		mcl.onLoadError = callback(Cs,avatarError)
		mcl.loadClip("http://data.dinocard.net/swf/avatar.swf",mc.trg);

	}
	/*
	static function avatarStart(mc){
		Log.trace("Debut du chargement")
	}	
	static function avatarError(mc,error){
		Log.trace("Erreur de chargement des avatars: "+error)
	}	
	*/
	static function avatarLoaded(mc){
		if(mc.loadId==null)mc.loadId = 0
		mc.loadId++
		if(mc.loadId==2){
			Cs.initAvatar(mc);
		}
	}
	static function avatarError(mc,error){
		Log.trace(error)

	}
		
	static function initAvatar(mc){
		/*
		Log.trace("----------")
		Log.trace(mc.apply)
		Log.trace(mc.p0)
		Log.trace(mc.p0b)
		*/
		Std.cast(mc).cl = Std.cast(mc)._parent.cl//[0,3,3,4,5,6]
		//Std.cast(mc).cl = [0,3,3,4,5,6]
		mc.apply();
	}
	static function applyAvatar(mc,cl){
		mc.cl = cl;
		mc.apply();
		
		//Log.trace("apply")		
		//Log.trace("cl")		
		//Log.trace(mc.apply)		
	}
	
	// LOG	
	static function log(str:'a, pr){
		if(pr<LOG_PRIORITY)return;
		logText += Std.cast(str)+"\n"
		Cs.game.mcConsole.field.htmlText = logText
		Cs.game.mcConsole.field.scroll = Cs.game.mcConsole.field.maxscroll-1
	}
	
//{	
}