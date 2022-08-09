import mt.bumdum.Lib ;


class Pnj {
	
	
	//static public var mcData : flash.MovieClip ;
	static public var DATA_URL : String = null ;
	static public var GLOW_TYPE : Int = null ;
	static var PNJ_DX = -90 ;
	static var PNJ_DY = -190 ;
	static public  var HIDE_FRAME = "hide" ;
	
	
	public var id : String ;
	public var file : String ;
	var defaultFrame : String ;
	public var currentFrame : String ;
	var currentPnj : String ;
	public var loader : Load ;
	public var pdm : mt.DepthManager ;
	public var dp : Int ;
	public  var mc : {>flash.MovieClip, _setPnj : String -> Void, _next : Void -> Void} ;
	var loaded : Int ;
	var f : Void -> Void ;
	
	
	
	public function new(id : String, d : mt.DepthManager, dp : Int, l : Load, ?fPost : Void -> Void, ?noRequest = false) {
		this.id = id ;
		this.currentPnj = id ;
		loader = l ;
		//this.defaultFrame = df ;
		
		getFile() ;
		
		this.pdm =d ;
		this.dp = dp ;
		this.f = fPost ;
		
		if (noRequest)
			return ;
		
		loadData() ;
	}
	
	public function getFile() {
		switch(currentPnj.substr(0, 2)) {
			case "gu" : file = "Gu" ;
			case "ca" : file = "Caul" ;
			case "ap" : file = "Ap" ;
			case "jz" : file = "Jz" ;
			case "gm" : file = "Gm" ;
			case "sk" : file = "Sk" ;
		}
	}
	
	public function setPnj(?f : String) {
		var s = "1;" + Std.string(currentPnj) + ";" + (if (f != null) f else "1") ;
		mc._setPnj(s) ;
	}
	
	
	public function setNext(f : Dynamic) {
		if (mc == null)
			return ;
		Reflect.setField(mc, "_next", f) ;
	}
	
	
	public function setGlow() {
		if (Pnj.GLOW_TYPE == null)
			Pnj.GLOW_TYPE = 0 ;
		
		switch(Pnj.GLOW_TYPE) {
			case 0 : //dark
				Filt.glow(mc, 2, 2, 0x1A1612, true) ;
				Filt.glow(mc, 6, 0.5, 0x1A1612) ;
				//Filt.glow(mc, 45, 1.3, 0x02051c) ;
			case 1 : //light
				Filt.glow(mc, 2, 2, 0xF5EEA8, true) ;
				Filt.glow(mc, 6, 0.5, 0xF5EEA8) ;
				//Filt.glow(mc, 4, 2, 0x1A1612) ;
				//Filt.glow(mc, 15, 1.1, 0xf8f8f8) ;
		}
	}
	
	
	public function setFrame(f : String) {
		if (currentFrame == f)
			return ;
		
		var s = f.split(":") ;
		if (s.length == 2) {
			f = s[1] ;
			currentPnj = s[0] ;
			var oldFile = file ;
			getFile() ;
			if (oldFile != file) {
				kill() ;
				
				this.f = callback(function(p : Pnj, ff : String) {
					p.setFrame(ff) ;
				}, this, f) ;
				loadData() ;
			} else {
				
				setPnj(f) ;
				currentFrame = f ;
			}
			return ;
		} 
		
		currentFrame = f ;
		if (f == "start")
			mc.smc.smc.smc.gotoAndPlay(f) ;
		else
			mc.smc.smc.smc.gotoAndStop(f) ;
	}
	
	public function isSameFrame(f : String) {
		return f == currentFrame ;
	}
	
	
	public function isHideNeeded(f : String) : Bool {
		if (f == null)
			return false ;
		var tf = f.split(":") ;
		if (tf.length == 2)
			return tf[0] != currentPnj ;
		else
			return f == HIDE_FRAME ;
	}
		
	
	
	function loadData() {

		mc = cast pdm.empty(dp) ;
		
		var mcl = new flash.MovieClipLoader() ;
		mcl.onLoadInit = mcLoaded ;
		mcl.onLoadComplete = mcLoaded ;
		
		mcl.loadClip(StringTools.replace(DATA_URL, "__", file), mc) ;
		loaded = 0 ;
		
		loader.initLoading(1) ;
	}
	
	
	function mcLoaded(m) {
		loaded++ ;
		if (loaded < 2) return ;
		
		
		mc._alpha = 0 ;
		mc._x = 500 ;
		mc._y = 300 ;
		mc.smc._x = 0 ;
		mc.smc._y = 0 ;
		setPnj() ;
		
		loader.done() ;
		
		if (f != null)
			f() ;
	}
	
		
	public function kill() {
		if (mc != null)
			mc.removeMovieClip() ;
	}
	
	
	
	
	
}