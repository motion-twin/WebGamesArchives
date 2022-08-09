import flash.Key;


class WorldMap extends ScrollMap {
	
	
	public var dm : mt.DepthManager ;
	public var regions : Array<flash.MovieClip> ;
	public var rmc : flash.MovieClip ;
	
	
	public function new(m : Map) {
		super(m) ;
		bf = 30 ;
		
		scale = 100 / Map.WORLD_SCALE ;
		//scale = Map.WORLD_SCALE / 100 ;
		
		
		this.scroll = m.scroll ;
		this.bg = m.bg ;
		
		
		blinks = new Array() ;
		
		initWMap() ;
	}
	
	
	function initWMap() {
		dm = new mt.DepthManager(bg) ;
		rmc = dm.attach("zones", 1) ;
		dmanager = new mt.DepthManager(rmc) ;
		regions = new Array() ;
		for (r in map.data._regions) {			
			var infos = Lambda.array(Lambda.map(r._inf.split(":"), function(x) { return Std.parseInt(x) ; })) ;
			
			var mc : flash.MovieClip = untyped rmc[Std.string(r._id)] ;
			regions[r._iid] = mc ;

			mc.onRollOver = callback(highlight, mc) ;
			mc.onRollOut = mc.onReleaseOutside = callback(unHighlight, mc) ;
			mc.onRelease = callback(map.showRegion, r._iid) ;
			
			
		}
		
		rmc._visible = false ;
		
	}
	
	
	
	override public function loop() {
		super.loop() ;
		
		//updateScroll(0.7) ;
	}
	
	
	
	function createCurrent() {
		if (current != null)
			current.kill() ;
		
		var pPos = map.currentPPos ;
		
		var inf = Std.string(pPos.x) + ":" + Std.string(pPos.y) ;
				
		var infos = {_id : "current", _name : "Vous êtes ici", _inf : inf, _known : true, _valid : true, _quests : 0, _schoolCup : false} ;
		current = new Place(this, infos, dmanager) ;
		current.mc._xscale = 250 ;
		current.mc._yscale = 250 ;
		hideCurrent() ;
		current.mc.onRelease = callback(map.showRegion, map.data._region) ;
		//setWorldBounds() ;
	}
	
	
	public function showWorld(b : Bool) {
		if (b) {
			createCurrent() ;
			//updateScroll(0) ;
			//map.hideRText() ;
		} else 
			hideText() ;
		rmc._visible = b ;
		
	}
	
	
	public function setWorldBounds() {
		//if (current == null)
			return ;
		
		var b = current.getBounds() ;
		
		b.xMin -= ScrollMap.ZBORDER;
		b.xMax += ScrollMap.ZBORDER;
		b.yMin -= ScrollMap.ZBORDER;
		b.yMax += ScrollMap.ZBORDER;
		b.xMax -= ScrollMap.WIDTH;
		b.yMax -= ScrollMap.HEIGHT;
		if( b.xMin < 0 ) b.xMin = 0;
		if( b.yMin < 0 ) b.yMin = 0;
		var bounds = bg.getBounds(bg);
		bounds.xMax -= ScrollMap.WIDTH;
		bounds.yMax -= ScrollMap.HEIGHT;
		if( b.xMax > bounds.xMax ) b.xMax = Std.int(bounds.xMax);
		if( b.yMax > bounds.yMax ) b.yMax = Std.int(bounds.yMax);
				
		
		if( b.xMax - b.xMin < ScrollMap.SMIN * 2 ) {
			var h = Std.int((b.xMax + b.xMin) / 2);
			if( h < ScrollMap.SMIN ) h = ScrollMap.SMIN else if( h > bounds.xMax - ScrollMap.SMIN ) h = Std.int(bounds.xMax - ScrollMap.SMIN);
			b.xMin = h - ScrollMap.SMIN;
			b.xMax = h + ScrollMap.SMIN;
		}
		if( b.yMax - b.yMin < ScrollMap.SMIN * 2 ) {
			var h = Std.int((b.yMax + b.yMin) / 2);
			if( h < ScrollMap.SMIN ) h = ScrollMap.SMIN else if( h > bounds.yMax - ScrollMap.SMIN ) h = Std.int(bounds.yMax - ScrollMap.SMIN);
			b.yMin = h - ScrollMap.SMIN;
			b.yMax = h + ScrollMap.SMIN;
		}
		wbounds = b ;
	}
	
	
	
	
	public function highlight(mc : flash.MovieClip) {
		unHighlight(mc) ;
		blinks.push({mc:mc,t:0.0, c : 0xffffff}) ;
	}
	
	
	public function unHighlight(?mc : flash.MovieClip) {
		for (b in blinks) {
			if (mc != null && b.mc == mc) {
				blinks.remove(b) ;
				mc.filters = [] ;
				return ;
			} else if (mc == null) {
				b.mc.filters = [] ;
				blinks.remove(b) ;
			}
		}
	}
	
	
	public function hideCurrent() {
		current.mc._visible = false ;
		hideText() ;
	}
	
	
	public function showCurrent() {
		current.mc._visible = true ;
	}
	
	
}