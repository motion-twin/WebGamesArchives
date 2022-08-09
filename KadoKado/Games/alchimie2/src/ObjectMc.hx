import GameData.ArtefactId ;


class ObjectMc {
	
		
	public var id : ArtefactId ;
	public var infos : Array<Dynamic> ;
	public var pdm : mt.DepthManager ;
	public var dp : Int ;
	var gTimer : Float ;
	public  var mc : {>flash.MovieClip, _set : String -> Void} ;
	public var mcQty : {>flash.MovieClip, _field : flash.TextField} ;
	var q : Int ;
	
	var loaded : Int ;
	public var f : Void -> Void ;
	
	
	
	public function new(o : ArtefactId, d : mt.DepthManager, dp : Int, ?fPost : Void -> Void, ?qty : Int) {
		this.infos = getInfos(o) ;
		id = o ;
		
		this.pdm =d ;
		this.dp = dp ;
		this.f = fPost ;
		this.q = qty ;
		
		
		loadData() ;
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
	}
	
	
	function loadData() {
		//mc = cast pdm.empty(dp) ;
		mc = cast pdm.attach("object", dp) ;
		mc._x = 0 ;
		mc._y = -60 ;
		
		
		//mc._set(infos.join(";")) ;
		
		var s = cast mc ;
		for (f in infos) {
			s.gotoAndStop(f) ;
			s = cast s.smc ;
		}
		
		if (q != null)
			setQuantity(q) ;
		
		if (f != null)
			f() ;
		
		/*
		var mcl = new flash.MovieClipLoader() ;
		mcl.onLoadInit = mcLoaded ;
		mcl.onLoadComplete = mcLoaded ;
		
		mcl.loadClip(DATA_URL, mc) ;
		loaded = 0 ;*/
	}
	
	
	public function set(ids : Array<Dynamic>) {
		this.infos = ids ;
		//mc._set(infos.join(";")) ;
			var s = cast mc ;
		for (f in infos) {
			s.gotoAndStop(f) ;
			s = cast s.smc ;
		}
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
		if (mc != null)
			mc.removeMovieClip() ;
	}
	
	
	
	static public function getInfos(o : ArtefactId) : Array<Dynamic> {
		var te = "element" ;
		var ta = "artefact" ;
		
		switch (o) {
			case Elt(e) : return [te, e + 1] ;
			// artefacts 
			case Alchimoth : return [ta, "alchimoth"] ;
			case Destroyer(e) : return [ta, "destroyer", e + 1] ; 
			case Dynamit(v) : return [ta, "dynamit", v + 1] ;
			case Protoplop(level) : return [ta, "protoplop",level + 1] ;
			case PearGrain(level) : return [ta, "pear", level + 1] ;
			case Jeseleet(level) : return [ta, "jeseleet", level + 1] ;
			case Dalton : return [ta, "daltonian"] ;
			case Wombat : return [ta, "wombat", 5] ;
			case MentorHand : return [ta, "mentorhand", 1] ;
			case Patchinko : return [ta, "patchinko"] ;
			case RazKroll : return [ta, "razkroll"] ;
			case Delorean(level) : return [ta, "delorean"] ;
			case Dollyxir(level) : return [ta, "dollyxir"] ;
			case Detartrage : return [ta, "detartrage"] ;
			case Grenade(level) : return [ta, "grenade", level + 1] ;

				
			case Teleport : return [ta, "teleport"] ;
			case Tejerkatum : return [ta, "tejerkatum"] ;
			case PolarBomb : return [ta, "polarbomb"] ;
			case Pistonide : return [ta, "pistonide"] ;
				
			//auto falls 
			case Block(level) : return [ta, "enforced", level] ;
			case Neutral : return [ta, "neutral", 1] ;
				
			case Pa : return [ta, "pa"] ;
			case Stamp : return [ta, "stamp"] ;
			
			//#################UNUSED FOR OBJECTMC (ONLY HERE FOR COMPILATION CHECK)
			case Elts(e, p) : return null ;
			case Joker : return null ;
		}
		
		
	}
	
	
	
	
	
}