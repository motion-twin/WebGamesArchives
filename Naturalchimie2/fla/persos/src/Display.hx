import Cs;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;

enum DisplayType {
	PERSO;
	THUMB;
	SPIRIT;
}

class Display {
	public var dm : mt.DepthManager ;
	public var type : DisplayType;
	
	var useMisc : Bool ;
	var x : Int ;
	var y : Int ;
	
	//perso attributes
	static var palette					: Array<Array<Int>> =[Cs.DEFPAL,Cs.DEFPAL,Cs.DEFPAL,Cs.DEFPAL];
	static var pface					: Array<Int> = [];
	static var pcolors					: Array<Int> = [];
	static var param					: Array<Int> = [];
	public  var fstr 					:	String ;
	public var MCalchemist 				: {>flash.MovieClip, _alchemist : {> flash.MovieClip, _p0 : flash.MovieClip}};
	public var MCalchemistBitmap 		: {>flash.MovieClip, bmp:flash.display.BitmapData};
	public var cadre        					: { x:Float, y:Float, h:Float , w:Float };
	var pbar							: {>flash.MovieClip, bar:flash.MovieClip};
	public var pbar2					: {>flash.MovieClip, _field:flash.TextField};
	public var mcLoading 				: flash.MovieClip ;
	var progressType 					: Int ;							
	var isLoaded  						: Bool;
	var onLoad 							: Void -> Void ;
	public var isUpdated  				: Bool;
	public var isDrawn  				: Bool;
	var initit 							: Bool;
	public var extraTypeView 			: Int ; //0 : normal / 1 : nobg / 2 : bg only
	
	public function new(baseMC : flash.MovieClip, ?pType : Int = 0){
		dm = new mt.DepthManager(baseMC) ;
		isLoaded  = false;
		isUpdated  = false;
		useMisc = false ;
		extraTypeView = 0 ;
		progressType = pType ;
	}
	
	public function update(){
		switch(type) {
			case PERSO: 
				if (  (MCalchemist._alpha < 100) && (isUpdated) ) {	MCalchemist._alpha += 10;	}
				if ( (isLoaded) && (!isUpdated) ){	display();	}
			case THUMB: 
				if ( (isLoaded) && (!isUpdated) ){	display();	}
				if ( (isLoaded) && (isUpdated) ){
					if (!isDrawn){
						applyThumb();
						isDrawn = true;
					}
				}
			case SPIRIT: 
		}
		updateSprites() ;
	}
		
	public function updateSprites() {
		var list = Sprite.spriteList.copy() ; 
		for (s in list) s.update() ;
	}
	
	public function initPerso(x:Int, y:Int ,faceStr:String, ?f : Void -> Void){
		type = PERSO ;
		this.x = x ;
		this.y = y ;
		updatePerso(faceStr);
		
		checkMiscUse() ;
		
		isLoaded  = false;
		MCalchemist = cast dm.empty(Cs.DP_PERSO);
		loadGenerator(Reflect.field(flash.Lib._root,"dom") + Cs.getLib(useMisc)+"?v="+Reflect.field(flash.Lib._root,"v"),MCalchemist);
		MCalchemist._x = x;
		MCalchemist._y = y ;
		if (f != null)
			onLoad = f ;
	}
	
	
	public function reinit(?f : Void -> Void) {
		isLoaded  = false;
		if (MCalchemist != null)
			MCalchemist.removeMovieClip() ;
		MCalchemist = cast dm.empty(Cs.DP_PERSO);
		loadGenerator(Reflect.field(flash.Lib._root,"dom") + Cs.getLib(useMisc)+"?v="+Reflect.field(flash.Lib._root,"v"),MCalchemist);
		MCalchemist._x = x;
		MCalchemist._y = y ;
		if (f != null)
			onLoad = f ; 
		
	}
	
	
	public function checkMiscUse() : Bool {
		var oldum = useMisc ;
		useMisc = pface[0] >= Cs.MISC_START ;
		
		return useMisc != oldum ; //return true if change done
	}
	
	
	public function initThumb(x:Int, y:Int ,faceStr:String, ?f : Void -> Void){
		type = THUMB ;
		this.x = x ;
		this.y = y ;
		updatePerso(faceStr);
		
		checkMiscUse() ;
		
		isLoaded  	= false;
		isUpdated  	= false;
		isDrawn  	= false;
		
		MCalchemist = cast dm.empty(Cs.DP_PERSO);
		loadGenerator(Reflect.field(flash.Lib._root,"dom") + Cs.getLib(useMisc)+"?v="+Reflect.field(flash.Lib._root,"v"),MCalchemist);
		MCalchemist._x = -1000;
		MCalchemist._y = 0;
		MCalchemist._visible = false ;
		
		var bmp = new flash.display.BitmapData(Cs.THUMBW,Cs.THUMBH,true,0);
		MCalchemistBitmap = cast dm.empty(Cs.DP_THUMB);
		MCalchemistBitmap._x = x -Cs.THUMBW/2;
		MCalchemistBitmap._y = y -Cs.THUMBH;
		MCalchemistBitmap.attachBitmap(bmp,0);	
		MCalchemistBitmap.bmp = bmp;
		
		//Filt.glow(MCalchemistBitmap,15,1,0xFF9900);
		MCalchemistBitmap._visible = false ;
		
		if (f != null)
			onLoad = f ;
	}
	
	public function applyThumb(){
		//var bmp = new flash.display.BitmapData(Cs.THUMBW,Cs.THUMBH,true,0);
		//MCalchemistBitmap.attachBitmap(bmp,0);	
		//MCalchemistBitmap.bmp = bmp;
		var m = new flash.geom.Matrix();
		MCalchemistBitmap.bmp.fillRect(new flash.geom.Rectangle(0,0,Cs.THUMBW,Cs.THUMBH),0);
		
		var sx = Cs.THUMBW/cadre.w;
		var sy = Cs.THUMBH/cadre.h;
		var tx = -cadre.x;
		var ty = -cadre.y ;
	
		m.translate(tx,ty);
		m.scale(sx,sy);
		m.translate(Cs.THUMBW/2,Cs.THUMBH);

		MCalchemistBitmap.bmp.draw(MCalchemist,m,null,"normal");
		MCalchemist._visible = false ;
		MCalchemistBitmap._visible = true ;
		//MCalchemist.removeMovieClip() ;
	}
	
	
	
/*************************************************************************************************************************************  DISPLAYZ */
		
	function display(){
		switch(type) {
			case PERSO: 
				applyPerso(MCalchemist,pface,pcolors); 
				isUpdated = true;
			case THUMB: 
				applyPerso(MCalchemist,pface,pcolors); 
				MCalchemist._visible = false ;
				isUpdated = true;
			
			case SPIRIT: 
		}
		
	}
	
	public function updatePerso(faceStr){
		fstr = faceStr ;
		if (type == THUMB){
			isDrawn = false;
		}
		isUpdated = false;
		param = new Array();
		pcolors = new Array();
		pface = new Array();
		palette = new Array();
		var tmp:Array<String>  = new Array();
 		tmp = faceStr.split(";");
		pface = Lambda.array(Lambda.map(tmp, function(i) return Std.parseInt(i)));
		for (i in 0...Cs.CMAX)	pcolors.push(pface.pop());
		pcolors.reverse();
	}
	
	
	
	
	static function initPalette(mc:flash.MovieClip,pl:Array<Int>) {
		for (field in flash.Lib.keys(mc)){
			var e = Reflect.field(mc, field);		
			if(Std.is(e,flash.MovieClip)){
				var name : String = cast e._name;
				if (name.substr(0,2) == "_p"){
					var pid = Std.parseInt(e._name.substr(2,2));
					var frame = pl[pid] % e._totalframes;
					param.push(pid);
					e.gotoAndStop(frame+1);		
				}
			}
		}
		
		var mcw = Std.int(mc._width);
		var mch = Std.int(mc._height);
		var bmp:flash.display.BitmapData = new flash.display.BitmapData(mcw,mch,false,0xFFFFFF); 
		bmp.draw(mc);
		mc.removeMovieClip();
		palette = new Array();
		for( i in 0...Cs.CMAX) {
			var pi = new Array();
			var py = i * 11 + 5;
			while( true ) {
				var c = bmp.getPixel32(pi.length * 11 + 5,py);
				if( c == 0 || c == -1 )
					break;
				pi.push(c & 0xFFFFFF);
			}
			palette.push(pi);
		}
		bmp.dispose();
	}
		
	function applyPerso(mc:flash.MovieClip, pl:Array<Int>, cl:Array<Int>){		
				
		for (field in flash.Lib.keys(mc)){
			var e = Reflect.field(mc, field);		
			if(Std.is(e,flash.MovieClip)){
				var cid = null;
				if (e._name.substr(0,5) == "_view") {
					//if ( type == THUMB ) {
						cadre = { x:e._x, y:e._y, h:e._height , w:e._width };	
					//}
					e._visible = false;
				}
				
				if( e._name.substr(0,8) == "_palette" ){initPalette(untyped e, pl);}
				var name : String = cast e._name;
								
				if (name.substr(0,2) == "_p"){
					var pid = Std.parseInt(e._name.substr(2,2));
					var frame = pl[pid] % e._totalframes;
					
					param.push(pid);
					e.gotoAndStop(frame + 1);	
					
					
					switch(extraTypeView) {
						case 1 : //no bg
							if (name == "_p5")
								e._alpha = 0 ;
						case 2 : //bgOnly
							if (name == "_p0")
								e._alpha = 0 ;
					}
				}else {
					if (name.substr(0,4) == "_col"){
						cid = Std.parseInt(e._name.substr(4,2));
					}
				}
				if(cid!=null){
					var pal = palette[cid];
					Reflect.callMethod(MCalchemist,Reflect.field(MCalchemist,"_setColor"),[untyped e, pal[cl[cid]%pal.length]]);
					//setColor(untyped e, pal[cl[cid]%pal.length]);
				} 
				applyPerso(untyped e, pl, cl);
			}				
		}
	}
	

/****************************************************************************************************************************************  GETTERZ */
	public function getPalette() : Array<Array<Int>> { return palette;}
	public function getParam() : Array<Int> { return param;}
	
	public function setPersoPos(x:Int , y:Int) { 
		MCalchemist._x = x;
		MCalchemist._y = y;
		}
	
/****************************************************************************************************************************************  TOOLZ */	
	
	// INIT the pcolors Array
	static function colorSet(mc){
		var nbColor:Int = Std.parseInt(mc.nbColor.text);
		var bitmap:flash.display.BitmapData = new flash.display.BitmapData(10*nbColor,10,false,0xFFFFFF); 
		bitmap.draw(mc);
		pcolors = new Array();
		for ( i in 0 ... nbColor){
				var c:Int = bitmap.getPixel(5+i*10,5);
				pcolors.push(c);			
			}		
	}

	// Apply color 2 mc ==> moved in .as in persos.fla
	/*static function setColor(mc:flash.MovieClip,col:Int){		
		var c = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		var co = new flash.Color(mc);
		var ct : Dynamic = {} ;
			ct.ra=100 ;
			ct.ga=100 ;
			ct.ct.ba=100 ;
			ct.aa=100 ;
			ct.rb=c.r-255 ;
			ct.gb=c.g-255 ;
			ct.bb=c.b-255 ;
			ct.ab=0 ;
		//};
		
		trace(ct) ;
		co.setTransform( ct );
	}*/

	static function hexStr( i : Int ) : String {
			var s:String = "";
			for( x in 0...8 ) {
				var n = i & 15;
				if( n < 10 )
					s +=Std.string(n);
				else
					s += String.fromCharCode("A".charCodeAt(0)+n-10);
				i >>= 4;
			}
			return s;
		}	
	
	public function loadGenerator(url,mc){	
		var me = this;
		var loadStep = 0;
		var loader = new flash.MovieClipLoader();
		var nextStep = function(mc){
			loadStep++;
			if (loadStep==2){
				me.progress(null);
				loadStep = 0;
				switch(me.progressType) {
					case 0 :
						me.pbar.removeMovieClip();
					case 1 : 
						me.pbar2.removeMovieClip() ;
						me.mcLoading.removeMovieClip() ;
				}
				me.isLoaded  = true;
				me.display();
				if ( me.type == THUMB){
					me.applyThumb();
				}
				if (me.onLoad != null)
					me.onLoad() ;
			}
		}
		loader.onLoadComplete 	= nextStep;
		loader.onLoadInit 		= nextStep;
		loader.onLoadProgress 	= function(mc,l,t) { me.progress(l/t); }
		loader.onLoadError 		= function(mc,str) { trace("onLoadError: "+str);	}	
		loader.loadClip(url,mc);
	}

	function progress(ratio:Float){
		switch (progressType) {
			case 0 : 
				if (ratio==null || ratio>=1){
					if (ratio>=1) 
						pbar.bar._xscale = 100;
					return;
				}
				if (pbar._name == null){
					pbar = cast(dm.attach("progress_bar",Cs.DP_MISC));
					pbar._x = 10;
					pbar._y = 10;
				}
				pbar.bar._xscale = ratio*100;
			case 1 : 
				if (ratio==null || ratio>=1){
					if (ratio>=1) {
						pbar2.smc._xscale = 100 ;
						pbar2._field.text = "100" ;
					}
					return;
				}
				if (pbar2._name == null){
					mcLoading = dm.attach("loading", Cs.DP_MISC) ;
					mcLoading.smc.smc.gotoAndStop(1) ;
					pbar2 = cast dm.attach("loadingBar", Cs.DP_MISC + 1) ;
					mcLoading._x = pbar2._x = 130 ;
					mcLoading._y = pbar2._y = 150 ;
					pbar2._y += 10 ;
				}
				pbar2.smc._xscale = ratio*100;
				pbar2._field.text = Std.string(Std.int(ratio * 100)) ;
		}
	}	
}