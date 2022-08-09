import mt.bumdum.Lib ;

class MiniMap extends DefaultLoader {
	
	public static var DP_BG = 1 ;
	
	public var root : MovieClip ;
	public var mdm : mt.DepthManager ;
	public var scroll : flash.MovieClip ;
	public var bg : flash.MovieClip ;
	public var mcPlace : flash.MovieClip ;
	
	var data : String ;
	var pid : String ;
	var inf : String ;
	var version : String ;
	public var loaded : Int ;
	
	
	
	
	public function new(r : flash.MovieClip) {
		super(r) ;
		for (d in ["www","beta","data"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		loaded = 0 ;
		
		root = r ;
		mdm = new mt.DepthManager(root) ;
		
		dataDomain = Reflect.field(flash.Lib._root,"ud") ;
		data = Reflect.field(flash.Lib._root,"d") ;
		if (data == null)
			return ;
		
		
		scroll = mdm.empty(DP_BG) ;
		scroll._x = -10 ;
		scroll._y = -10 ;

		var sd = data.split(";") ;
		pid = sd[0] ;
		inf = sd[1] ;
		version = sd[2] ;
		
		flash.Lib.current.onEnterFrame = loop ;
		
		loadMap() ;
	}
	
	
	function loadMap() {
		var mcl = new flash.MovieClipLoader();
		mcl.onLoadInit = mapLoaded ;
		mcl.onLoadComplete = mapLoaded ;
		
		bg= scroll.createEmptyMovieClip("d",0) ;
		mcl.loadClip(dataDomain + "/swf/mapData.swf?v=" + version, bg) ;
		loaded = 0 ;
	}
	
	
	
	function mapLoaded(mc) {
		loaded++ ;
		if (loaded < 2) return ;
				
		bg = Reflect.field(bg, "_map") ;
		bg._xscale = 100 ;
		bg._yscale = bg._xscale ;
		
		bg.smc._visible = false ;
		
		mcPlace = bg.attachMovie(pid, pid, 1) ;
		
		mcPlace._xscale = 125 ;
		mcPlace._yscale = mcPlace._xscale ;
		
		var tinf = inf.split(":") ;
		var px = Std.parseFloat(tinf[0]) * 1.25 ;
		var py = Std.parseFloat(tinf[1]) * 1.25 ;
		
		mcPlace._x = px ;
		mcPlace._y = py ;
		
		bg._x = -1 * px - scroll._x + 50  ;
		bg._y = -1 * py - scroll._y + 50 ;
		
		var c = 0xFCF89C ;
		mcPlace.filters = [new flash.filters.GlowFilter(c,0.9,1.3,1.3,10, 2, true, true),
				new flash.filters.GlowFilter(c,0.6,6.4,6.4,2, 2, false, false)] ;
		
	}
	
	
	
	public function loop() {
		
	}
	
	
	
	public static function main() {
		new MiniMap(flash.Lib.current) ;
	}
}
