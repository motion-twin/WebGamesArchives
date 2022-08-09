import GameData._ArtefactId ;


class ObjectMc {
	
	
	static public var DATA_URL : String = null ;
	static public var ORIGIN_MC : {>flash.MovieClip, _set : String -> Void} = null ;
	static public var AV_BMP : Hash<flash.display.BitmapData> ;
	static public var mcl : flash.MovieClipLoader ;
	static public var SIZE_CHECK : Int = null ;
	static public var SIZE_ERROR : Bool = false ;
	static public var LOADED : Int = null ;
	static public var FPOST : Void -> Void = null ;
	
	static public var FLA_X = 6 ;
	static public var FLA_Y = 17 ;
	static public var FLA_WIDTH = 48 ;
	static public var FLA_HEIGHT = 55 ;
	static var SCR = 1.2 ;
	
	
	public var id : _ArtefactId ;
	public var infos : Array<Dynamic> ;
	public var pdm : mt.DepthManager ;
	public var dp : Int ;
	var gTimer : Float ;
	public  var mc : {>flash.MovieClip, _b : {>flash.MovieClip, _m : {>flash.MovieClip, _p : flash.display.BitmapData}}} ;
	public var mcQty : {>flash.MovieClip, _field : flash.TextField} ;
	var q : Int ;
	public var initScale : Int ;
	
	var loaded : Int ;
	public var f : Void -> Void ;
	
	
	
	public function new(o : _ArtefactId, d : mt.DepthManager, dp : Int, ?fPost : Void -> Void, ?qty : Int, ?param : Int, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		this.infos = getInfos(o ,param) ;
		id = o ;
		
		this.pdm =d ;
		this.dp = dp ;
		this.f = fPost ;
		this.q = qty ;
	
		this.initScale = sc ;
		createMc(withBmp) ;
		
	}
	
	
	function createMc(withBmp) {
		mc = cast pdm.empty(dp) ;
		mc._x = 0 ;
		mc._y = -60 ;
		
		mc._b = cast mc.createEmptyMovieClip("b", 1) ;
		mc._b._x = 15 ;
		mc._b._y = 15 ;
		
		mc._b._m = cast mc._b.createEmptyMovieClip("m", 1) ;
		
		var delta = if (initScale != null && initScale > 100) initScale else 100 ;
		
		mc._b._m._x = -FLA_X * delta / 100 - 15 ;
		mc._b._m._y = -FLA_Y * delta / 100 - 15 ; 
		
		
		setMc(withBmp) ;
		
		if (f != null)
			f() ;
	}
	
	
	public function getBmp() : flash.display.BitmapData {
		if (mc == null)
			return null ;
		return mc._b._m._p ;
	}
	
	
	public function setMc(?withBmp : flash.display.BitmapData) {
		if (LOADED < 2) {
			trace("error : movieClip not loaded") ;
			return ;
		}
		
		
		var mid = infos.join(";") ;

		var av = if (withBmp == null)
					AV_BMP.get(mid) ;
				else
					withBmp ;
				
		if (initScale != null && initScale != 100) {
			ORIGIN_MC._set(mid) ;
						
			/*ORIGIN_MC.smc.smc._xscale = initScale ;
			ORIGIN_MC.smc.smc._yscale = ORIGIN_MC.smc.smc._xscale ;
			
			var bmp = new flash.display.BitmapData(Std.int(FLA_WIDTH * initScale / 100), Std.int(FLA_HEIGHT * initScale / 100), true , 0xFFFFFF) ;
			bmp.draw(ORIGIN_MC) ;
			
			ORIGIN_MC.smc.smc._xscale = 100 ;
			ORIGIN_MC.smc.smc._yscale = ORIGIN_MC.smc.smc._xscale ;*/
			
			if (initScale >100) {
				ORIGIN_MC._xscale = initScale * SCR ;
				ORIGIN_MC._yscale = ORIGIN_MC._xscale ;
			}
			ORIGIN_MC.smc.smc._xscale = initScale ;
			ORIGIN_MC.smc.smc._yscale = ORIGIN_MC.smc.smc._xscale ;
			
			if (initScale > 100) {
				ORIGIN_MC.smc._x = FLA_X * initScale * SCR * 1.7 / 100 ;
				ORIGIN_MC.smc._y = FLA_Y * initScale * SCR / 100 ;
			}

			var delta = if (initScale > 100) initScale else 100 ;
			var bmp = new flash.display.BitmapData(Std.int(FLA_WIDTH * delta / 100), Std.int(FLA_HEIGHT * delta / 100), true , 0xFFFFFF) ;
			bmp.draw(ORIGIN_MC) ;
			
			ORIGIN_MC._xscale = 100 ;
			ORIGIN_MC._yscale = ORIGIN_MC._xscale ;

			ORIGIN_MC.smc.smc._xscale = 100 ;
			ORIGIN_MC.smc.smc._yscale = ORIGIN_MC.smc.smc._xscale ;
			
			ORIGIN_MC.smc._x = FLA_X ;
			ORIGIN_MC.smc._y = FLA_Y ;
			
			av = bmp ;
			
		}
		
		if (av == null) {
			ORIGIN_MC._set(mid) ;
			var bmp = new flash.display.BitmapData(FLA_WIDTH, FLA_HEIGHT, true , 0xFFFFFF) ;
			bmp.draw(ORIGIN_MC) ;
			AV_BMP.set(mid, bmp) ;
			av = bmp ;
		}
		
		mc._b._m._p = av.clone() ;
		mc._b._m.attachBitmap(mc._b._m._p, 1) ;
		
		if (q != null)
			setQuantity(q) ;
	}
	
	
	static public function initMc(url : String, d : mt.DepthManager, dp : Int, f : Void -> Void) {
		DATA_URL = url ;
		AV_BMP = new Hash() ;
		ORIGIN_MC = cast d.empty(0) ;
		ORIGIN_MC._x = -1000 ;
		ORIGIN_MC._y = -1000 ;
		FPOST = f ;
		
		mcl = new flash.MovieClipLoader() ;
		mcl.onLoadInit = mcLoaded ;
		//mcl.onLoadError = onError ;
		mcl.onLoadComplete = mcLoaded ;
		
		mcl.onLoadProgress = function(mc, loaded, total) {
			if (SIZE_CHECK == null && total > 0)
				SIZE_CHECK = total ;
			
			if (SIZE_CHECK != null && total != SIZE_CHECK)
				SIZE_ERROR = true ;
			
			//trace("hop" + Std.string(mcl.getProgress(ORIGIN_MC)) + " # " + SIZE_CHECK + " # " + SIZE_ERROR) ;
		}
		
		LOADED = 0 ;
		
		
		mcl.loadClip(DATA_URL, ORIGIN_MC) ;
		
	}
	
	
	static function mcLoaded(m) {
		LOADED++ ;
		if (LOADED < 2) return ;
		
		if (SIZE_ERROR || SIZE_CHECK == null) {
			SIZE_ERROR = true ;
			return ;
		}
		
		
		ORIGIN_MC._set("element;1") ;
		
		if (FPOST != null) {
			FPOST() ;
			FPOST = null ;
		}
		
	}
	
	
	
	public function setQuantity(q : Int) {
		if (mcQty == null)
			initMcQty() ;
		mcQty._field.text = Std.string(q) ;
	}
	
	function initMcQty() {
		mcQty = cast this.mc.attachMovie("mcQty", "mcQty_", 2) ;
		
		mcQty._x = -17 ;
		mcQty._y = 13 ;
		
		if (initScale != null) {
			mcQty._xscale = mcQty._yscale = initScale ;
		} 
	}
	
	/*function loadData() {
		mc = cast pdm.empty(dp) ;
		mc._x = 0 ;
		mc._y = -60 ;
		
		var mcl = new flash.MovieClipLoader() ;
		mcl.onLoadInit = mcLoaded ;
		mcl.onLoadError = onError ;
		mcl.onLoadComplete = mcLoaded ;
		loaded = 0 ;
		mcl.loadClip(DATA_URL, mc) ;
	}*/
	
	//## #DEBUG

	
	
	public function set(ids : Array<Dynamic>) {
		this.infos = ids ;
		
		setMc() ;
	}
	
	
	function onError(m, err) {
		trace("error on element loading : " + err + " # " + LOADED) ;
	}
	
	
	/*function mcLoaded(m) {
		loaded++ ;
		if (loaded < 2) return ;
		
		mc._set(infos.join(";")) ;
		if (q != null)
			setQuantity(q) ;
		
		if (f != null)
			f() ;
	}*/
	
	
	/*public function updateId(nid : _ArtefactId, ?param : Int) {
		infos = getInfos(nid ,param) ;
		id = nid ;
		mc._set(infos.join(";")) ;
	}*/
	
	public function updateId(nid : _ArtefactId, ?param : Int) {
		infos = getInfos(nid ,param) ;
		id = nid ;
		setMc() ;
	}
	
	
	public function update() {
		if (gTimer == null)
			return ;
		
		gTimer += 0.06 ;
		var f = Math.sin(gTimer) ;
		  
		
		if ( f < -0.9 ) {
			gTimer = 0.0 ;
			f=0.0 ;
		}
		
		mc.smc.smc.smc.smc._alpha = Math.max(0.0, f * 100) ;
	}
	
	
	public function kill() {
		if (mc != null && mc._b._m._p != null)
			mc._b._m._p.dispose() ;
		if (mc != null)
			mc.removeMovieClip() ;
	}
	
	
	
	static public function getInfos(o : _ArtefactId, ?param : Int) : Array<Dynamic> {
		var te = "element" ;
		var ta = "artefact" ;
		
		switch (o) {
			case _Elt(e) : return [te, e + 1] ;
			// artefacts 
			case _Alchimoth : return [ta, "alchimoth"] ;
			case _Destroyer(e) : return [ta, "destroyer", e + 1] ; 
			case _Dynamit(v) : return [ta, "dynamit", v + 1] ;
			case _Protoplop(level) : return [ta, "protoplop",level + 1] ;
			case _PearGrain(level) : return [ta, "pear", level + 1] ;
			case _Jeseleet(level) : return [ta, "jeseleet", level + 1] ;
			case _Dalton : return [ta, "dalton"] ;
			case _Wombat : return [ta, "wombat", 1] ;
			case _MentorHand : return [ta, "mentorhand", 1] ;
			case _Patchinko : return [ta, "patchinko"] ;
			case _RazKroll : return [ta, "razkroll"] ;
			case _Delorean(level) : return [ta, "delorean", level + 1] ;
			case _Dollyxir(level) : return [ta, "dollyxir", level + 1] ;
			case _Detartrage : return [ta, "detartrage"] ;
				
			case _Teleport : return [ta, "teleport"] ;
			case _Tejerkatum : return [ta, "tejerkatum"] ;
			case _PolarBomb : return [ta, "polarbomb"] ;
			case _Pistonide : return [ta, "pistonide"] ;
			case _Grenade(level) : return [ta, "grenade", level + 1] ;
				
			//auto falls 
			case _Block(level),_CountBlock(level) : return [ta, "enforced", level] ;
			case _Neutral : return [ta, "neutral", if (param != null) param else (Std.random(20) + 1)] ;
			case _Catz : return [ta, "catz", 1] ;
			case _SnowBall : return [ta, "snowball"] ;
			case _Choco : return [ta, "choco"] ;
			case _Empty : return [ta, "empty"] ;
			case _Surprise(level) : return [ta, "surprise", level + 1] ;
				
			case _Pa : return [ta, "pa"] ;
			case _Stamp : return [ta, "stamp"] ;
			case _QuestObj(id) : 
				if (id == "pickSkat")
					return [ta, "quest", id, if (param != null) param else (Std.random(20) + 1)] ;
				else
					return [ta, "quest", id] ;
			case _DigReward(o) : return getInfos(o) ;
			case _Unknown : return [ta, "unknown"] ;
			case _GodFather : return [ta, "godfather"] ;
			case _Pumpkin(id) : return [ta, "pumpkin", id + 1] ;
			case _NowelBall : return [ta, "NowelBall", if (param != null) param else (Std.random(4) + 1)] ;
			case _Gift : return [ta, "kadonowel"] ;
			case _Sct(id) : return [ta, id] ;
			case _Slide(level) : return [ta, "pendulor", level + 1] ;
			case _Skater : return [ta, "skatisateur"] ;

			
			//#################UNUSED FOR OBJECTMC (ONLY HERE FOR COMPILATION CHECK)
			case _Elts(e, p) : return null ;
			case _Joker : return null ;
			
				
		}
		
		
	}
	
	
	
	
	
}