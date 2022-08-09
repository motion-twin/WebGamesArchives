import GameData._ProductData ;


class ShopMc {
	
	
	static public var DATA_URL : String = null ;
	
	public var id : _ProductData ;
	public var infos : Array<Dynamic> ;
	public var pdm : mt.DepthManager ;
	public var dp : Int ;
	public  var mc : {>flash.MovieClip, _set : String -> Void} ;
	
	var loaded : Int ;
	public var f : Void -> Void ;
	
	
	
	public function new(o : _ProductData, d : mt.DepthManager, dp : Int, ?fPost : Void -> Void) {
		this.infos = getInfos(o) ;
		id = o ;
		
		this.pdm =d ;
		this.dp = dp ;
		this.f = fPost ;
		
		loadData() ;
	}
	
	function loadData() {
		mc = cast pdm.empty(dp) ;
		mc._x = 0 ;
		mc._y = -60 ;
		
		var mcl = new flash.MovieClipLoader() ;
		mcl.onLoadInit = mcLoaded ;
		mcl.onLoadComplete = mcLoaded ;
		
		mcl.loadClip(DATA_URL, mc) ;
		loaded = 0 ;
	}
	
	
	public function set(ids : Array<Dynamic>) {
		this.infos = ids ;
		mc._set(infos.join(";")) ;
	}
	
	
	function mcLoaded(m) {
		loaded++ ;
		if (loaded < 2) return ;
		
		mc._set(infos.join(";")) ;
		/*switch(id) {
			case Elt(i) :
				if (i == 11 || i == 15) //gold or flocinne (ça fait purée vico, "flocinne")
					gTimer = 0.0 ;
			default :
		}*/
		
		if (f != null)
			f() ;
	}
	
	
	public function kill() {
		if (mc != null)
			mc.removeMovieClip() ;
	}
	
	
	
	static public function getInfos(o : _ProductData) : Array<Dynamic> {
		switch(o) {
			case _Col(s) : 
				return ["col", s] ;
			case _Fx(s) : 
				return ["fx", s] ;
			case _Recipe(c) : 
				return ["recipe", c + 1] ;
			case _Art(a, q) : //nothing to do here. ObjectMc needed
				return null ;
			case _Special(s) :
				return ["special", s] ;
		}
	}
	
	
}