import flash.Key ;
import mt.bumdum.Lib ;



class Map {
	
	public static var WIDTH = 300 ;
	public static var HEIGHT = 300 ;
	public static var SIZE = 14 ;
		
	public static var BUTTON_Y = 285 ;
	
	public static var DP_BG = 0 ;
	public static var DP_MAP = 1 ;
	public static var DP_COLOR = 2 ;
	public static var DP_FG = 4  ;
	public static var DP_INTERFACE = 5 ;
	public static var DP_OVER = 7 ;
	public static var DP_LOADING = 8 ;
	
	static public var me : Map ;
	
	public var root : flash.MovieClip ;
	public var mdm : mt.DepthManager ;
	public var mapdm : mt.DepthManager ;
	
	public var mcBg : flash.MovieClip ;
	public var mcFg : flash.MovieClip ;
	public var mcGrid : flash.MovieClip ;
	public var mcInterf : flash.MovieClip ;
	public var mcOver : flash.MovieClip ;
	public var mcLoading : flash.MovieClip ;
		
	public var grid : Array<Array<Zone>> ;
	public var town : Zone ;
	public var buildings  : List<Zone> ;
		
	//stats
	public var midZombies : Int ;
	public var midZombiesAll : Int ;
	public var zombieMax : Int ;
	public var zombieMin : Int ;
	public var zombieSum : Int ;
	
		
	public var selected : Zone ;
		
	public var cDay : Int ;
	public var days : Array<Day> ;
		
	public var nextButton : {>flash.MovieClip, field : flash.TextField} ;
	public var prevButton : {>flash.MovieClip, field : flash.TextField} ;
	public var mcInfoDay : {>flash.MovieClip, field : flash.TextField} ;
	
	public var mcStatus : {>flash.MovieClip, field : flash.TextField, field2 : flash.TextField, bg : flash.MovieClip} ;
	
	
	public function new(mc : flash.MovieClip) {
		me = this ;
		
		//SIZE = Std.random(5) + 10 ;
		SIZE = 12 ;
		
		mt.flash.Key.enableForWmode();
		this.root = mc ;
		mdm = new mt.DepthManager(root) ;
		
		initBg() ;
		createEmptyGrid() ;
		
		initZone() ;
		initZombies() ;
		
		initKeyListener() ;
		initButtons() ;
		
		mcStatus = cast mdm.attach("field",DP_OVER) ;
		mcStatus.field.text = "";
		mcStatus.field2.text = "";
		mcStatus.bg._visible = false;
		mcStatus.bg.filters = [ new flash.filters.GlowFilter(0xd7ff5b,1, 3,3,3) ];
		mcStatus.bg._alpha = 60;
		mcStatus._xscale = 85 ;
		mcStatus._yscale = mcStatus._xscale ;
	}
	
	
	function initBg() {
		if (mcBg != null)
			mcBg.removeMovieClip() ;
		
		mcBg = mdm.attach("blackMask", DP_BG) ;
		mcBg.gotoAndStop(1) ;
		
		mcFg = mdm.attach("interf", DP_FG) ;
		
	}
	
	function createEmptyGrid() {
		if (mcGrid != null)
			killGrid() ;
		
		
		mcGrid = mdm.empty(DP_MAP) ;
		var dmGrid = new mt.DepthManager(mcGrid) ;
		grid = new Array() ;
		var n = 1 ;
		for (x in 0...SIZE) {
			grid[x] = new Array() ;
			for (y in 0...SIZE) {
				grid[x][y] = new Zone(dmGrid.empty(1), x, y) ;
				n++ ;
			}
		}
	}
	
	
	function initZone() {
		days = new Array() ;
		cDay  = 0 ;
		
		chooseTown() ;
		makeBuildings() ;
	}
	
	
	function chooseTown() {
		var x = Std.random(SIZE - Cs.CityMinSpawnRadius * 2) ;
		var y = Std.random(SIZE - Cs.CityMinSpawnRadius * 2) ;
		
		town = grid[x + Cs.CityMinSpawnRadius ][y + Cs.CityMinSpawnRadius] ;
		town.safe = true ;
		town.mc.gotoAndStop(3) ;
	}
	
	
	function makeBuildings() {
		buildings = new List() ;
		
		var currentZone = null;
		var maxIter = 100;
		var count = Cs.MaxOutsideBuildings;

		while( count > 0 && maxIter-- > 0) {
			currentZone = grid[ Std.random(Map.SIZE)][Std.random(Map.SIZE)] ;
			if (currentZone == null || !currentZone.isFree())
				continue ;
			
			currentZone.building = true ;
			currentZone.mc.gotoAndStop(4) ;
			buildings.push(currentZone) ;
			count-- ;
		}
	}
	
	
	function initZombies() {
		
		for (b in buildings) {
			b.setZombies(b.level + 1) ;
		}
		
		
		for(n in 0...Cs.FreeSpawn) {
			var z = null ;
			while (z == null) {
				z = grid[Std.random(SIZE)][Std.random(SIZE)] ;
				if (z == null || !z.isFree() || z.hasZombies())
					z = null ;
			}
			
			z.setZombies(Std.random(3)) ;
				
		}
		days.push(new Day(cDay)) ;
		getMidZombies() ;
	}
	
	public function getMidZombies() {
		midZombies = 0 ;
		zombieMax = 0 ;
		zombieMin = 50000000 ;
		zombieSum = 0 ;
		
		var a = 0 ;
		for (x in 0...Map.SIZE) {
			for (y in 0...Map.SIZE) {
				var z  = grid[x][y].zombies ;
				zombieSum += z ;
				if (z > 0 && zombieMin > z)
					zombieMin = z ;
				if (zombieMax < z)
					zombieMax = z ;
				
				if (z > 0)
					a++ ;
			}
		}
		
		
		
		midZombies = Std.int(Math.floor(zombieSum / a)) ; 
		midZombiesAll = Std.int(Math.floor(zombieSum / (SIZE * SIZE))) ; 		
	}
	
	
	public function loop() {
		
		
	}
	
	
	function killGrid() {
		if (mcGrid != null)
			mcGrid.removeMovieClip() ;
		grid = null ;
	}
	
	
	
	//### DAYS 
	function prevDay() {
		if (cDay == 0)
			return ;
		cDay-- ;
		restoreGrid(days[cDay]) ;
		updateDay() ;
	}
	
	
	function nextDay() {
		if (cDay == days.length - 1) {
			horde.Horde.grow(this) ;
			days.push(new Day(cDay +1)) ;
		} else
			restoreGrid(days[cDay + 1]) ;
		
		cDay++ ;
		updateDay() ;
		
	}
	
	
	function restoreGrid(d : Day) {
		for (x in 0...Map.SIZE) {
			for (y in 0...Map.SIZE) {
				grid[x][y].setInfos(d.infos[x][y]) ;
			}
		}
		
	}
	
	
	function updateDay() {
		mcInfoDay.field.text = "Day  " + (cDay + 1) + " / " + (days.length) + " [avg: " + midZombies + " - " + midZombiesAll + "]" ;
		getMidZombies() ;
		if (selected != null)
			showStatus(selected) ;
		else {
			if (mcStatus.bg._visible)
				moreStats() ;
		}
	}
	

	//### KEYS
	function initKeyListener() {
		var kl = {
			onKeyDown:callback(onKeyPress),
			onKeyUp:callback(onKeyRelease)
		}
		Key.addListener(kl) ;
	}
	
	function onKeyRelease() {
		var n = Key.getCode() ;
		
	
		
		switch(n) {
			case Key.LEFT : prevDay() ;
			case Key.RIGHT : nextDay() ;
				
		}
	}
	
	
	function onKeyPress() {
	}

	
	
	function initButtons() {
		mcInterf = mdm.empty(DP_INTERFACE) ;
		mcOver = mdm.empty(DP_OVER) ;
		
		var depth = 0 ;
		prevButton = cast attachButton("previous", prevDay, depth++) ;
		prevButton._x = 10 ;
		prevButton._y = BUTTON_Y ;
		
		mcInfoDay = cast mcInterf.attachMovie("mapButton", "b_" + depth++, depth) ;
		mcInfoDay.gotoAndStop(5) ;
		mcInfoDay._x = 73 ;
		mcInfoDay._y = BUTTON_Y ;
		mcInfoDay._xscale = 85 ;
		mcInfoDay._yscale = 85 ;
		updateDay() ;
		
		mcInfoDay.onRollOver = moreStats ;
		mcInfoDay.onRollOut = clearStatus ;
		
		
		nextButton = cast attachButton("next", nextDay, depth++) ;
		nextButton._x = 230 ;
		nextButton._y = BUTTON_Y ;
	}
	
	
	function moreStats() {
		setStatus(null, null, "more stats", "total zombies : " + zombieSum + "\nzombies max : "+ zombieMax + "\nzombieMin : " + zombieMin) ;
		
	}
	
	
	function attachButton(label, cb, n : Int) {
		var but = cast mcInterf.attachMovie("mapButton", "b_" + n, n) ;
		but.gotoAndStop(4) ;
		but.field.text = label ;
		but.onRollOver = function() { but.filters = [ new flash.filters.GlowFilter(0xf0d79e,1, 3,3, 3) ]; } ;
		but.onRollOut = function() { but.filters = []; } ;
		but.onRelease = cb ;

		return but ;
	}
	
	
	
	//### STATUS 
	function setStatus(x : Int,y : Int, txt:String,?txt2:String) {
		mcStatus.field.text = txt;
		if ( txt2!=null ) {
			mcStatus.field2.text = txt2;
			mcStatus.field2._y = mcStatus.field._y+mcStatus.field.textHeight;
		} else
			mcStatus.field2.text = "";
		var w = Math.max(mcStatus.field.textWidth, mcStatus.field2.textWidth);
	
		if (x != null) {
			mcStatus._x = 55 ;
			if (y >=Math.floor(SIZE / 2))
				mcStatus._y = 30 ;
			else
				mcStatus._y = 230 ;
		} else { //avg more infos
			mcStatus._x = 150 ;
			mcStatus._y = 230 ;
			
		}
		mcStatus.bg._visible = true;
		mcStatus.bg._width = w+10;
		mcStatus.bg._height = mcStatus.field.textHeight + mcStatus.field2.textHeight + 5 ;
	}
	
	function clearStatus() {
		mcStatus.bg._visible = false ;
		mcStatus.field.text = "" ;
		mcStatus.field2.text = "" ;
	}
	
	public function showStatus(z : Zone) {
		selected = z ;
		z.active(true) ;
		
		setStatus(z.x, z.y, z.x + ", " + z.y + (if (z.building) " - batiment" else ""), "zombies : " + z.zombies + "\nzombies tués : "+ z.zombieKills + "\ncadavres : " + z.deads) ;
	}
	
	
	public function hideStatus() {
		if (selected != null)
			selected.active(false) ;
		selected = null ;
		clearStatus() ;
	}

	
	public function modDone(z : Zone) { 
		days[cDay].infos[z.x][z.y] = z.getInfos() ;
		getMidZombies() ;
		
		if (cDay < days.length - 1) //past changed, futur has to be truncated. omg
			days.splice(cDay + 1, days.length) ;
		
	}

	
}
	