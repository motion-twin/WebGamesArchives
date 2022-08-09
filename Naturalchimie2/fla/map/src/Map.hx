import flash.Key ;
import mt.bumdum.Lib ;
import MapData._MapData ;
import GameData._ArtefactId ;

typedef Bounds = {
	var xMin : Float ;
	var xMax : Float ;
	var yMin : Float ;
	var yMax : Float ;
}


enum MapStep {
	Region ;
	World ;
	Zoom(x : Int, y : Int, s : Int) ;
}

typedef Bmp = {>flash.MovieClip,bmp:flash.display.BitmapData}


class Map extends ScrollMap {
	
	public static var REGION_SCALE = 100 ;
	public static var COORD_SCALE = 125 ;
	public static var WORLD_SCALE = 100 ; //old with zoom : 35
	
	public static var DP_BLACK = 0 ;
	public static var DP_BG = 1 ;
	public static var DP_REGION = 2 ;
	public static var DP_WORLD = 3 ;
		
	public static var DP_GREY = 4 ;
	public static var DP_INTERFACE = 5 ;
	public static var DP_TEXT = 6 ;
	public static var DP_MSG = 7 ;
	public static var DP_BMP = 8 ;
	public static var DP_LOADING = 10 ;
	
	public static var COLOR_ROAD_GLOW = 0x25293D ;
	public static var COLOR_ROAD = 0x007787 ;
	public static var HIGHLIGHT_ROAD = 0xFF9900 ;
	
	public static var PLACE_COL = 0x1B1E29 ;
	public static var HIGHLIGHT_PLACE_COL = 0xFCF89C ;
	public static var TARGET_PLACE_COL = 0xFF9900 ;
	
	//public var loader : Loader ;
	public var data : _MapData ;
	public var step : MapStep ;

	
	public var root : flash.MovieClip ;
	public var mcBlack : flash.MovieClip ;
	public var mdm : mt.DepthManager ;
	
	//world map
	//public var wMap : WorldMap ;
	//public var wMc : flash.MovieClip ;
	static public var me : Map ;
	
	//regionMap
	public var rMap : RegionMap ;
	public var rMc : flash.MovieClip ;
	public var currentPPos : {x : Float, y : Float} ;
	public var mWidth : Float ;
	public var mHeight : Float ;
	public var loader : Load ;
	public var loaded : Int ;
	public var funcLoad : Void -> Void ;
	public var fRefill : _MapData -> Void ;
	
	//toggle
	public var mcInt : flash.MovieClip ;
	public var dm : mt.DepthManager ;
	public var toggle : flash.MovieClip ;
	public var regionText : {> flash.MovieClip, _field : flash.TextField } ;
	public var teleports : Array<{mc : flash.MovieClip, text : String, wait : String}> ;
	public var mcChains : Array<{o : ObjectMc, timer : Float, wait : Float}> ;
	public var chainTimer : Float ;
	public var chainPlace : Place ;
	public var toMoveChain : Bool ;
	public var currentPlace : Place ;
	
	//zoom
	var zoomCoef : Float ;
	var zoomSpeed : Float ;
	
	
	public function new(mc : flash.MovieClip, l : Load, ?dat : _MapData, ?fload : Void -> Void) {
		super(null) ;
		me = this ;
		loader = l ;
		mt.flash.Key.enableForWmode();
		this.root = mc ;
		mdm = new mt.DepthManager(root) ;
		
		loader.initLoading(if (dat != null) 2 else 3) ;
			
		this.scroll = mdm.empty(Map.DP_BG) ;

		if (fload != null)
			funcLoad = fload ;
		
		if (dat == null)
			loadData() ;
		else {
			data = dat ;
			loadMap() ;
		}
	}
	
	
	function initMc() {
		mcBlack = mdm.empty(DP_BLACK) ;
		mcBlack.beginFill(0x000000, 100) ;
		mcBlack.moveTo(0, 0) ;
		mcBlack.lineTo(ScrollMap.WIDTH, 0) ;
		mcBlack.lineTo(ScrollMap.WIDTH, ScrollMap.HEIGHT) ;
		mcBlack.lineTo(0, ScrollMap.HEIGHT) ;
		mcBlack.lineTo(0, 0) ;
		mcBlack.endFill() ;
		
		farView = data._farView ;
		
		mcInt = mdm.empty(DP_INTERFACE) ;
		dm = new mt.DepthManager(mcInt) ;
		
		step = Region ;
		this.rMap = new RegionMap(this, data._region) ;
		
		showUser(currentPlace) ;
		
		regionText = cast dm.attach("region", 5) ;
		regionText.smc.gotoAndStop(data._align + 1) ;
		regionText._field.text = data._regionName ;
		regionText._x = 0 ;
		regionText._y = 0 ;
				
		initTeleports() ;
		initChain() ;
		
		rMap.showMap(true) ;
	}
	
	
	function initTeleports() {
		if (data == null || data._tp == null || data._tp.length == 0)
			return ;
		
		var dx = 35 ;
		var x = if (data._tp.length == 5) 470 else 450 ;
		var y = 3 ;
		
		
		
		var mcTp = dm.attach("tp", 0) ;
		mcTp._x = ScrollMap.WIDTH - (if (data._tp.length == 5) 0 else 30) + (5 - data._tp.length) * dx ;
		mcTp._y =  0  ;
				
		for (t in data._tp) {
			var mc = dm.attach("teleport", 1) ;
			mc.gotoAndStop(t._id) ;
			mc._x = x ;
			mc._y = y ;
			x -= dx ;
			
			var sw : String = null ;
			if (t._wait == null) { //available
				mc.onRelease = callback(teleport, t._id, false) ; 
				mc.onRollOut = mc.onReleaseOutside = callback(function(m : ScrollMap, mc : flash.MovieClip) {m.hideText() ; Col.setPercentColor(mc, 0, 0xFFFFFF) ;}, rMap, mc) ;
			} else {
				Col.setPercentColor(mc, 50, 0x000000) ;
				mc._alpha = 80 ;
				
				var w = t._wait / 1000 ;
				var h = Math.floor(w / 3600) ;
				w = w - 3600 * h ;
				var m = Math.floor(w / 60) ;
				sw = h + "h" + m + "m" ;
				mc.onRollOut = mc.onReleaseOutside = callback(function(m : ScrollMap, mc : flash.MovieClip) {m.hideText() ; Col.setPercentColor(mc, 50, 0x000000) ; mc._alpha = 80 ;}, rMap, mc) ;
			}
			
			var txt = (if (sw != null) "[" + sw + "] " else "") + t._name ;
			mc.onRollOver = callback(function(m : ScrollMap, mc : flash.MovieClip, sw) {m.showText(sw) ; if (mc.onRelease != null) Col.setPercentColor(mc, 50, 0xFFFFFF) ;}, rMap, mc, txt) ;
			
		}
	}
	
	
	function initChain() {
		mcChains = new Array() ;
		toMoveChain = null ;
		chainTimer = null ;
		
		var dx = 28 ;
		
		for (i in 0...4) {
			var o = new ObjectMc(/*_Unknown*/_Elt(Std.random(28)), rMap.dmt, 1, null, null, null, 75) ;
			
			o.mc._x = 20 + i * dx ;
			o.mc._y = 0 ;
			//o.mc._xscale = o.mc._yscale = 75 ;
			o.mc.filters = [new flash.filters.DropShadowFilter(2,75, 0x000000,0.5,2, 2, 3)] ;
				
			if (i == 3)
				toMoveChain = false ;
			
			mcChains[i] = {o : o, timer : null, wait : 0.0}  ;
		}
		
	}
	
	public function showChain(p : Place) {
		if (p.chain != null) {
			toMoveChain = true ;
			chainTimer = 0.0 ;
			chainPlace = p ;
			
			for (i in 0...4) {
				var o = mcChains[i] ;
				if (i < p.chain.length)
					o.o.set(ObjectMc.getInfos(_Elt(p.chain[i]))) ;
				else
					o.o.set(ObjectMc.getInfos(_Unknown)) ;
				
				o.wait = i * 0.09 ;
				o.timer = 0.0 ;
			}
		} 
	}
	
	public function hideChain() {
		toMoveChain = false ;
		chainTimer = null ;
		chainPlace = null ;
		for (o in mcChains) {
			o.o.mc._y = 0 ;
			o.timer = null ;
		}
	}
	
	
	function loadMap() {
		var mcl = new flash.MovieClipLoader();
		mcl.onLoadInit = mapLoaded ;
		mcl.onLoadComplete = mapLoaded ;
		
		bg= scroll.createEmptyMovieClip("d",0) ;
		mcl.loadClip(data._url, bg) ;
		loaded = 0 ;
	}
	
	
	function mapLoaded(mc) {
		loaded++ ;
		if (loaded < 2) return ;
				
		bg = Reflect.field(bg, "_map") ;
		bg._xscale = REGION_SCALE ;
		bg._yscale = bg._xscale ;
		bg._x = -25 ;
		bg._y = -100 ;
		
		
		bg.smc._visible = false ;
		
		mWidth = bg._width ;
		mHeight = bg._height ;
		
		initMc() ;
		
		var d = loader.done() ;
		if (d != null && d)
			onLoadDone() ;
		
	}
	
	
	public function showRegion(r : Int) {
		if (loader.isLocked())
			return ;
		
		if (rMap == null) {
			loader.initLoading() ;
			rMap = new RegionMap(this, r) ;
			return ;
		}
		
		if (rMap.regionId == r) { //loaded map requested
			switchZoom(false, false) ;
			return ;
		}
		
		loader.initLoading() ;
		rMap.kill() ;
		rMap = new RegionMap(this, r) ;
		switchZoom(false, false) ;
	}
	
	

	/*public function showRText(t : String) {
		regionText._field.text = t ;
		regionText._visible = true ;
	}
	
	
	public function hideRText() {
		regionText._visible = false ;
		regionText._field.text = "" ;
		
	}
*/
	
	override public function loop() {
		if (loader.isLoading()) 
			return ;
		
		/*if (userViewer != null)
			userViewer.update() ;
		*/
		
		if (toMoveChain) {
			var spc = 0.09 ;
			for (o in mcChains) {
				if (o.wait > 0.0)  {
					o.wait = Math.max(0.0, o.wait - spc * mt.Timer.tmod) ;
					continue ;
				}
					
				if (o.timer == null)
					continue ;
				
				o.timer = Math.min(o.timer + spc * mt.Timer.tmod ,1.0) ;
				var delta = 1 - anim.TransitionFunctions.quart(1 - o.timer) ;
				o.o.mc._y = 45 * delta ;
					
				if (o.timer == 1.0)
					o.timer = null ;
			}
			
		}
		
		//super.loop() ;
		switch(step) {
			case Region : 
				rMap.loop() ;
			case World : 
				//wMap.loop() ;
			case Zoom(x, y, s) : updateZoom(x, y, s) ;
		}
		
		
	}
	
	
	public function initZoom() {
		var sens = if (step == Region) -1 else 1 ;
		zoomCoef = if (sens > 0) 0 else 1 ;
		var x = 0 ;
		var y = 0 ;
		/*if (step != Region) //zoom out to world
			wMap.unHighlight() ;*/
					
		x = Std.int(rMap.dcoords.x  * Map.REGION_SCALE / 100)  ;
		y = Std.int(rMap.dcoords.y  * Map.REGION_SCALE / 100) ;
		
		var oldStep = step ;
		step = Zoom(x, y, sens) ;
		
		rMap.showMap(false) ;
		if (oldStep == Region) {
			updateZoom(x, y, sens) ;
			//wMap.showWorld(true) ;
		}
		//wMap.hideText() ;
	}
	
	
	public function updateZoom(x : Int, y : Int, sens : Int) {
		if (sens==1)
			zoomCoef = Num.mm( 0, (zoomCoef+0.005*mt.Timer.tmod)*1.5, 1 ) ;
		else
			zoomCoef = Num.mm( 0,  (zoomCoef-0.05*mt.Timer.tmod)*0.8, 1 ) ;
				
		bg._xscale = WORLD_SCALE*(1-zoomCoef)+zoomCoef * REGION_SCALE ;
		bg._yscale = WORLD_SCALE*(1-zoomCoef)+zoomCoef * REGION_SCALE ;
				
		var tx = ScrollMap.WIDTH * 0.5 - (x + 0.5) ;
		var ty = ScrollMap.HEIGHT * 0.5 - (y + 0.5) ;

		bg._x = tx * zoomCoef - 15 * (1 - zoomCoef) ;
		bg._y = ty * zoomCoef ;
		
		if (zoomCoef == 1)
			initRegion() ;
		else if (zoomCoef == 0) {
			initWorld() ;
		}
	}
	
	
	public function initRegion() {
		cleanScreen() ;
		step = Region ;
		//toggle._visible = true ;
		mcInt._visible = true ;
		rMap.showMap(true) ;
		//wMap.showWorld(false) ;
		loader.unlock() ;
	}
	
	
	public function initWorld() {
		step = World ;
		//toggle._visible = false ;
		mcInt._visible = false ;
		rMap.showMap(false) ;
		/*wMap.showWorld(true) ;
		wMap.showCurrent() ;*/
		loader.unlock() ;

	}
	
	
	function cleanScreen() {
		/*if (mcScreenshot != null)
			mcScreenshot.removeMovieClip() ;*/
	}
	
	
	public function switchZoom(w : Bool, ?zoomOff : Bool) {
		if (zoomOff == null)
			zoomOff = false ;
		
		if (zoomOff) {
			step = if (w) World else Region ;
			//toggle._visible = !w ;
			mcInt._visible = !w ;
			rMap.showMap(!w) ;
			//wMap.showWorld(w) ;
		} else {
			if (loader.isLocked())
				return ;
			
			loader.lock() ;
			//toggle._visible = false ;
			mcInt._visible = false ;
			initZoom() ;
		}
	}

	
	function loadData() {
		var dat = Reflect.field(flash.Lib._root,"mdata") ;
		if( dat != null ) {
			onMapData(dat) ;
			return ;
		}
		var h = new haxe.Http(Reflect.field(flash.Lib._root,"url"));
		var me = this;
		h.onData = onMapData;
		h.onError = loader.reportError;
		h.request(false);
	}
	
	
	function onMapData(dat : String) {
		try {
			var s = secure.Utils.decode(secure.Utils.getKey(loader.k, dat, loader.s, loader.n)) ;
			data = haxe.Unserializer.run(s) ;
			/*Pnj.DATA_URL = data._pnj_url ;
			ObjectMc.DATA_URL = data._object_url ;
			Spirit.DATA_URL = data._spirit_url ;*/
		} catch( e : Dynamic ) {
			loader.reportError(e);
			return;
		}
		var d = loader.done() ;
		if (d != null && d)
			onLoadDone() ;
		initMc() ;
		
		loadMap() ;
	}
	
	
	//go back to zone =>
	public function exit() {
		flash.external.ExternalInterface.call("_swm") ;
	}
	
	public function refill() {
		loader.initLoading(1) ;
		
		var h = new haxe.Http(loader.domain + "/act/refillMap");
		var me = this;
		h.onData = onRefill ;
		h.onError = loader.reportError ;
		h.request(false);
	}
	
	function onRefill(dat : String) {
		loader.done() ;
		var s = secure.Utils.decode(secure.Utils.getKey(loader.k, dat, loader.s, loader.n)) ;
		data = haxe.Unserializer.run(s) ;
		
		if (fRefill != null)
			fRefill(data) ;
		
		flash.external.ExternalInterface.call("_wtg", 0, 0, data._pa) ;
		
		if (rMap != null && rMap.info != null)
			rMap.info.kill() ;
		
		if (rMap != null)
			rMap.kill() ;
		rMap = new RegionMap(this, data._region) ;
	}
	
	
	public function onLoadDone() {
		switchZoom(false, true) ;
		if (funcLoad != null)
			funcLoad() ;
	}
	
	
	override public function kill() {
		if (mcBlack != null)
			mcBlack.removeMovieClip() ;
		
		if (rMap != null)
			rMap.kill() ;
		/*if (wMap != null)
			wMap.kill() ;*/
		root.removeMovieClip() ;
	}
	

}