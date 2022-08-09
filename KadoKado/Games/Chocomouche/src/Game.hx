import KKApi ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import mt.bumdum.Part ;
import mt.bumdum.Lib ;



typedef Pos = {x : Int, y : Int}


enum Step {
	Play ;
	Explode ;
	NextLevel ;
	FinishLevel ;
	GameOver ;
}


class Game {

	public static var FL_DEBUG = true ;
		
	public static var DP_BG = 0 ;
	public static var DP_SHADE = 1 ;
	public static var DP_BGPLAYS = 2 ;
	public static var DP_PLAYS = 3 ;
	public static var DP_SLOT = 4 ;
	public static var DP_INFOS = 5 ;
	public static var DP_ANIM = 6 ;
	public static var DP_FX = 7 ;


	public var step : Step ;
	var timer : mt.flash.Volatile<Float>;	
	
	public var life : mt.flash.Volatile<Int> ;
	public var lives: List<flash.MovieClip> ;
	public var level : mt.flash.Volatile<Int> ;
	public var flGameOver : Bool ;
	public var dm:mt.DepthManager ;
	
	public  var mcGrid : flash.MovieClip ;
	public var gdm : mt.DepthManager ;
		
	public var root:flash.MovieClip ;
	public var bg:flash.MovieClip ;
	public var mcTime : {>flash.MovieClip, _timeLeft : flash.MovieClip, _max : flash.MovieClip, start : mt.flash.Volatile<Float>, max : mt.flash.Volatile<Float>} ;
	public var mcWarning : flash.MovieClip ;
	public var mcLevel : {>flash.MovieClip, _mLevel: {>flash.MovieClip, _field : flash.TextField}} ;
		
	static public var me:Game ;
	public var grid : Array<Array<Slot>> ;
	public var left : mt.flash.Volatile<Int> ;



	public function new( mc : flash.MovieClip ) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
	
		root = mc ;
		me = this ;
		dm = new mt.DepthManager(root) ;
		flGameOver = false ;
		level = 0 ;
		left = 100 ;
		initLife(3) ;
		
		initBg() ;
		initTime() ;
		
		mcGrid = dm.empty(DP_SLOT) ;
		gdm = new mt.DepthManager(mcGrid) ;
		initGrid() ;
		
		step = Play ;
	}
	

	function initBg() {
		var grid = dm.attach("bg", DP_BG) ;
		grid._x = 0 ;
		grid._y = 0 ; 
		grid._alpha = 95 ;

	}
	
	
	
	public function isLocked() {
		return step != Play || flGameOver ;
	}
	
	
	public function update() {
		//trace(mt.Timer.fps()) ;
		
		updateSprites() ;
		
		switch(step) {
			case Play : 
				if (flGameOver) {
					KKApi.gameOver({});
					step = GameOver ;
				}
				updateTime() ;				
			case Explode :
				step = Play ;
			
			case FinishLevel : 
				timer -= 4 * mt.Timer.tmod ;
				mcGrid._alpha = timer  ;
				if (timer <= 0) {
					mcGrid._alpha = Cs.GRID_ALPHA ;
					timer = null ;
					initNextLevel() ;
				}
				
			case NextLevel : 
				timer -= 1.5 * mt.Timer.tmod ;
				if (mcGrid._alpha < 100)
					mcGrid._alpha = 100 - timer ;
				if (timer <= 0 && mcLevel._mLevel == null) {
					mcGrid._alpha = 100 ;
					timer = null ;
					//prepareLevel() ;
					resetTime() ;
					step = Play ;
					setNextLevel(false) ;
				}
				
			case GameOver :
				
		}
		
	}

	
	public function checkEnd() : Bool {
		if (flGameOver)
			return true ;
		if (life <= 0)
			flGameOver = true ;
		
		return flGameOver ;
	}
	
	
	public function checkLevel() {
		if (left > 0)
			return ;
		finishLevel() ;
	}
	
	
	function finishLevel() {
		step = FinishLevel ;

		for(x in grid) {
			for(s in x) {
				if (!s.isDiscovered() && s.isBomb())
					s.markMe() ;
			}
		}
		timer = 100 ;
	}
	
	
	function initNextLevel() {
		step = NextLevel ;
		level++ ;
		getLevelBonus() ;
		timer = 100 ;
		
		setNextLevel(true) ;
		prepareLevel() ;
	}
	
	
	//create new grid for level l
	public function prepareLevel(?from : Pos) {
		if (from == null) {
			initGrid() ;
		}
		
		var b = Cs.getLevelBombs(level) ;
		left = Cs.GRID_WIDTH * Cs.GRID_HEIGHT - b ;
		while (b > 0) {
			var x = Std.random(Cs.GRID_WIDTH) ;
			var y = Std.random(Cs.GRID_HEIGHT) ;
			if (from != null && from.x == x && from.y == y)
				continue ;
			var s = grid[x][y] ;
			if (!s.isBomb()) {
				s.placeBomb() ;
				b-- ;
			}
		}
		
		//resetTime() ;
		//step = Play ;
	}
	
	
	function initGrid() {
		if (grid != null) {
			for(x in grid) {
				for (s in x) {
					if (s == null)
						continue ;
					s.kill() ;
				}
			}
		}
		
		grid = new Array() ;
		for (x in 0...Cs.GRID_WIDTH) {
			grid[x] = new Array() ;
			for (y in 0...Cs.GRID_HEIGHT) {
				grid[x][y] = new Slot({x : x, y : y}, false) ;
				
			}
		}
		setGridGlow() ;
	}
	
	
	public function setGridGlow() {
		mcGrid.filters = [] ;
		Filt.glow(mcGrid, 1.2, 20, 0x232323) ;
		
		var sh= new flash.filters.DropShadowFilter() ;
		
		sh.color =  0x000000;
		sh.alpha = 0.15 ;
		sh.blurX = 2 ;
		sh.blurY = 2 ;
		sh.angle = 45 ;
		sh.distance = 2.5 ;
		sh.strength = 3 ;
		sh.quality = 100 ;
		sh.inner = false ;
		sh.knockout= false ;
		var a = mcGrid.filters ;
		a.push(sh);
		mcGrid.filters = a;
		
	}
	
	
	function updateSprites() {
		var list =  Sprite.spriteList.copy() ;
		for(sp in list)sp.update() ;
	}
	
	
	//### LIFE
	function initLife(l : Int) {
		life = l ;
		lives = new List() ;
		for (i in 0...life) {
			var mc = dm.attach("life", DP_INFOS) ; 
			mc._x = Cs.LIFE_X ;
			mc._y = Cs.LIFE_Y - lives.length * (20 + 3) ; // => (life_width + ecart);
			Filt.glow(mc, 2, 3, 0xFFFFFF) ;
			lives.push(mc) ;
		}
	}
	
	
	function lifeLoss() {
		life-- ;
		
		var mcl = lives.pop() ;
		if (mcl != null) {
			var rf = dm.attach("redF",DP_FX) ;
			rf._x = 0 ;
			rf._y = 0 ;
			mcl.removeMovieClip() ;
		}
			
		checkEnd() ;
	}
	
	
	public function getSlot(x : Int, y : Int) {
		if (x < 0 || y < 0 || x >= Cs.GRID_WIDTH || y >= Cs.GRID_HEIGHT)
			return null ;
		return grid[x][y] ;
	}
	
	
	// POINTS
	
	public function getPoints(start : Float, end : Float, max : Float) {
		var c = (max - (end - start)) / max ;
		var p = c * (Cs.POINTS + Cs.MULT_LEVEL * (Cs.INITIAL_TIME - max) / 1000) ;
		
		addScore(KKApi.const(Std.int(p))) ;
	}
	
	
	public function getLevelBonus() {
		addScore(Cs.LEVEL_BONUS) ;
	}
	
	
	public function addScore(sc) { //pr ajouter au score du joueur
		KKApi.addScore(sc) ;
	}
	
	
	// TIME
	function initTime() {
		mcTime = cast Game.me.dm.attach("timeLine", Game.DP_INFOS) ;
		mcTime._x = Cs.TIME_X ;
		mcTime._y = Cs.TIME_Y ;
		resetTime() ;
	}
	
	
	public function resetTime(?bomb : Bool) {
		var now = flash.Lib.getTimer() ;
		if (bomb != null && !bomb)
			getPoints(mcTime.start, now, mcTime.max) ;
		
		mcTime.start = now ;
		mcTime.max = Cs.getLevelTime(level) ;
		//mcTime._max._xscale = (Cs.INITIAL_TIME - (Cs.INITIAL_TIME - mcTime.max)) / Cs.INITIAL_TIME * 100 ;		

		setWarning(false) ;
		checkLevel() ;
	}
	
	
	function updateTime() { //update TimeLine && check lifeloss
		var now = flash.Lib.getTimer() ;

		var c = mcTime.max - (now - mcTime.start) ;
		if (c > 0) {
			//mcTime._timeLeft._xscale = c / Cs.INITIAL_TIME * 100 ;
			mcTime._timeLeft._xscale = c / mcTime.max * 100 ;
			if (mcTime._timeLeft._xscale < 40)
				setWarning(true) ;
		} else {
			//trace("hop : " + c) ;
			lifeLoss() ;
			resetTime() ;
		}
	}

	
	public function explode(from : Pos) {
		step = Explode ;
		lifeLoss() ;
	}
	
	
	public function resetParsing() {
		for(x in grid) {
			for (s in x) {
				if (s == null)
					continue ;
				s.resetParse() ;
			}
		}
	}
	
	
	//WARNING
	function setWarning(on : Bool) {
		if (on) {
			if (mcWarning != null)
				return ;
			mcWarning = dm.attach("warning", DP_FX) ;
		} else {
			if (mcWarning == null)
				return ;
			mcWarning.removeMovieClip() ;
			mcWarning = null ;
		}
	}
	
	
	//NEXT LEVEL MC
	function setNextLevel(on : Bool) {
		if (on) {
			if (mcLevel != null)
				return ;
			mcLevel = cast dm.attach("nextLevel", DP_ANIM) ;
			mcLevel._mLevel._field.text = Std.string(level + 1) ;
			mcLevel._x = 0 ;
			mcLevel._y = 30 ;
		} else {
			if (mcLevel == null)
				return ;
			mcLevel.removeMovieClip() ;
			mcLevel = null ;
		}
	}
	
}



