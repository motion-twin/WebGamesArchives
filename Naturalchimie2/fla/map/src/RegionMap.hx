import flash.Key;
import Map.Bounds ;
import Map.MapStep ;
import PopInfo.TypeInfo ;
import MapData._MapData ;
import mt.bumdum.Lib ;


class RegionMap extends ScrollMap {
	
		
	static var DEFAULT_LINK = "/act/map" ;
	static var GOTO_LINK = "/act/move?to=" ;
	static var TELEPORT_LINK = "/act/tp?to=" ;
	
	public var regionId : Int ;
	public var regionName : String ;
	public var pmc : flash.MovieClip ;
	public var info : PopInfo ;
		

	public function new(m : Map, id : Int) {
		super(m) ;
		
		//scale = Map.REGION_SCALE / 100 ;
		scale = 100 / Map.REGION_SCALE ;
		
		//scale = 100 ;
		//scale = 0.7 ;
		
		farView = m.farView ;
		
		this.scroll = m.scroll ;
		this.bg = m.bg ;
		
		regionId = id ;
		mt.flash.Key.enableForWmode();
		
		initMap(map.data) ;
		var d = map.loader.done() ;
		if (d != null && d) 
			map.onLoadDone() ;
		
		
	}

	
	public function initMap(data : _MapData) {
		//scale = 100 / Map.REGION_SCALE ;
		
		blinks = new Array() ;
		dots = new Array() ;

		var rdm = new mt.DepthManager(bg) ;
		pmc = rdm.empty(0) ;
		dmanager = new mt.DepthManager(pmc) ;
		
		/*for (r in data._regions) {
			if (r._iid == regionId) {
				regionName = r._name ;
				break ;
			}
		}*/
		
		if (regionId == data._region)
			initCurrentRegion(data) ;
		else
			initFarRegion(data) ;
		//map.updateScroll(0);
	}
	
	
	public function initFarRegion(data : _MapData) {
		/*var dplace = null ;
		for (r in data._regions) {
			if (r._iid == regionId) {
				dplace = Lambda.array(Lambda.map(r._dplace.split(":"), function(x) { return Std.parseFloat(x) ; })) ;
				break ;
			}
		}
		if (dplace == null)
			dplace = [bg._width / 2 , bg._height / 2] ;
		dcoords = {x : dplace[0], y : dplace[1] } ;
			
		var b = {
			xMin : dplace[0],
			xMax : dplace[0],
			yMin : dplace[1],
			yMax : dplace[1]
			} ;
		setToCenter(dcoords) ;
		setBounds(b) ;*/
	}
	
	
	public function initCurrentRegion(data : _MapData) {
		inf = dmanager.empty(0) ;
		//inf.setMask(bg.smc) ;
		
		places = new Hash();
		for(p in data._places) {
			var p = new Place(this,p, dmanager);
			places.set(p.id,p);
			if( p.id == data._cur ) {
				current = p;
				dcoords = {x : current.px, y : current.py} ;
				current.mc.gotoAndStop(2) ;
			}
		}
		
		var b = current.getBounds() ;
		ba = {xMin : b.xMin, xMax : b.xMax, yMin : b.yMin, yMax : b.yMax} ;
		
		for(n in data._nexts) {
			var p = places.get(n._id) ;
			p.selectAsTarget(n._text,n._conf, n._pa, places.get(n._from)) ;
			var pfrom = if (p.from != null) p.from else current ;
			var points = null ;
			
			if (p.valid && p.target) {
				if( p.px < ba.xMin ) ba.xMin = p.px ;
				if( p.px > ba.xMax ) ba.xMax = p.px ;
				if( p.py < ba.yMin ) ba.yMin = p.py ;
				if( p.py > ba.yMax ) ba.yMax = p.py ;
					
				if( p.px < b.xMin ) b.xMin = p.px ;
				if( p.px > b.xMax ) b.xMax = p.px ;
				if( p.py < b.yMin ) b.yMin = p.py ;
				if( p.py > b.yMax ) b.yMax = p.py ;
			}
			
			if (n._road == null || n._road == "") {
				if (!n._qway && ((pfrom.pa == null && p.pa == 0) || (pfrom.pa == p.pa)))
						continue ;
				
				points = [[pfrom.px, pfrom.py], [p.px, p.py]] ;
				p.road = points ;
				b = traceRoad(points, b, pfrom, p, n._qway) ;
				points = null ;
			} else {
				var pp = n._road.split(",") ;
				if (Std.parseInt(pp[0].split(":")[0]) == p.px)
					points.reverse() ;
				points = Lambda.array(Lambda.map(pp, function(x) { var e = x.split(":") ; return [Std.parseFloat(e[0]) * Map.COORD_SCALE / 100, Std.parseFloat(e[1]) * Map.COORD_SCALE / 100] ;} )) ;
				
				var ppfrom = if (pfrom.px == points[0][0]) pfrom else p ;
				var ppto = if (pfrom.px == points[0][0]) p else pfrom ;
				p.road = points ;	
				b = traceRoad(points, b, ppfrom, ppto, n._qway) ;
			}
			
			
			//### DEBUG
			//break; 
			
		}
		
		
		/*var sb = Map.REGION_SCALE / 100 ;
		b.xMin = b.xMin * sb ;
		b.xMax = b.xMax * sb ;
		b.yMin = b.yMin * sb ;
		b.yMax = b.yMax * sb ;*/
		
		current.selectAsCurrent() ;

		inf.filters = [	new flash.filters.GlowFilter(Map.COLOR_ROAD_GLOW,0.4,1.9,1.9,4, 2, false, false)] ;
				
		setToCenter({x : current.px, y : current.py}, Map.me.step == Region) ;
	//	trace(b) ;
		setBounds(b) ;
		
		/*
		if (data._pa == 0) {
			info = new PopInfo(if (data._ppa > 0) MorePa else if (data._siflex) Chouettex else Tired, this, ba) ;
		}
		*/
		
		map.currentPPos = dcoords ;
		
		//if ( data._nexts.length==0 ) {
		/*if (data._pa == 0) {
			blinks.push({mc:current.mc,t:0.0} );
			fl_moveMode = false;
		}*/
	}
	
	
	function traceRoad(points : Array<Array<Float>>, bounds : Bounds, pfrom : Place, p : Place, highlight : Bool) : Bounds {
		if (points.length < 2)
			return bounds ;
		var b = bounds ;
		
		
		var rmc = inf ;
		
		rmc.lineStyle(2,if (highlight) Map.HIGHLIGHT_ROAD else Map.COLOR_ROAD,70, false, null, "none","MITER") ;
		
		
		var end = null ;
		var i = 1 ;
		
		//points[0] = getIntersect(points[1], points[0], pfrom) ; 
		var start = getIntersect(points[1], points[0], pfrom) ; 
		rmc.moveTo(start[0],start[1]) ;
		
		while(i < points.length) {
			if (i == points.length - 1) {
				end = getIntersect(start, points[i], p) ; 
				//points[i] = end ;
			}else
				end = points[i] ;
			
			 if (p.target) {
				if( end[0] < b.xMin ) b.xMin = end[0] ;
				if( end[0] > b.xMax ) b.xMax = end[0] ;
				if( end[1] < b.yMin ) b.yMin = end[1] ;
				if( end[1] > b.yMax ) b.yMax = end[1] ;
			}
			rmc.lineTo(end[0], end[1]) ;
			start = end ;
			i += 1 ;
		}
		rmc.endFill() ;
		
		return b ;
	}
	
	
	function getIntersect(start : Array<Float>, end : Array<Float>, p : Place) : Array<Float> {
		var a = (end[1] - start[1]) / (end[0] - start[0]) ;
		var b = start[1] - a * start[0] ;
		
		var done = false ;
		var curTab = [start.copy(), end.copy()] ;
		var lastHit = 0 ;
		var cx = 0.0 ;
		var cy = 0.0 ;
		
		var deltaMin = 2.0 ;
		
		var c = 0 ;
		
		var bf = p.mc.getBounds(bg) ;
		var bd : Bounds = {xMin : bf.xMin, xMax : bf.xMax, yMin : bf.yMin, yMax : bf.yMax} ;
	
		
		
		/*trace("### PRE : " + p.id) ;
		trace(a + " . x + " + b + " = y") ;
		trace("start " + start) ;
		trace("end " + end) ;
		trace("mc :" + p.px + ", " + p.py) ;
		trace("hit test : " + hit(bd, p.px, p.py)) ;
		trace("bounds bg : " + Std.string(bd)) ;
		trace("###") ;*/
				
		while (!done) {
			cx = curTab[0][0] + (curTab[1][0] - curTab[0][0]) / 2 ;
			cy = a * cx + b ;
			
			//trace(cx + ", " + cy) ;
			if (hit(bd, cx, cy)) {
				//trace("### HIT !") ;
				curTab[1] = [cx, cy] ;
				lastHit++ ;
			} else
				curTab[0] = [cx, cy] ;
			
			c++ ;
			if (lastHit >= 2 || c > 30)
				done = true ;
			
		}
		
		//trace("intersect : " + Std.string(end) + " ==> " + Std.string([cx, cy])) ;
		
		return [cx, cy] ;
	}
	
	
	function hit(b : Bounds, cx : Float, cy : Float) {
		return cx >= b.xMin && cx <= b.xMax && cy >= b.yMin && cy <= b.yMax ;
	}

	override public function loop() {
		super.loop() ;
		
		mouseScroll() ;
		//updateScroll(0.7) ;
	}


	
	
	public function showMap(b : Bool) {
		pmc._visible = b ;
		/*if (b)
			map.showRText(regionName) ;
		else
			map.hideRText() ;*/
	}
	
	
	public function getCurrentPercentPos() : {x : Int, y : Int} {
		var b = bg.getBounds(bg) ;	
		
		//trace(regionId+  " perc " + Std.string(dcoords)) ; 
		
		return  {x : Std.int(dcoords.x / b.xMax * 100) , y : Std.int(dcoords.y / b.yMax * 100)} ;
	}
	
	
	override public function kill() {
		if (info != null)
			info.kill() ;
		super.kill() ;
	}
	
	
	

}