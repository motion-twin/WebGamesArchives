import KKApi;
import flash.Key ;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Lib;



typedef Pos = {x : Int, y : Int}


enum Step {
	Play ;
	Spout ;
	Bombing ;
	Explode ;
	NextLevel ;
	GameOver ;
}


class Game {
		
	public static var DP_BG = 0 ;
	public static var DP_BGPLAYS = 1 ;
	public static var DP_DROP = 3 ;
	public static var DP_SLIME = 4 ;
	public static var DP_ANIM = 5 ;
	public static var DP_PLAYS = 6 ;
	public static var DP_SCORING = 7 ;

	public static var DP_PARTS = 8 ;
	public static var DP_POINTS = 9 ;
	
	public static var MAX_PLAYS = 20 ;
	

	public var step:Step ;
	var timer : mt.flash.Volatile<Float>;	
	public var mcTime : {>flash.MovieClip, _timeLeft : flash.MovieClip, start : Float} ;

		
	var lockSlime : Bool ;
	public var level : mt.flash.Volatile<Int> ;
	public var plays : mt.flash.Volatile<Int> ;
	public var mcPlays : mt.flash.PArray<flash.MovieClip> ;
	public var mcScore : {>flash.MovieClip, _field : flash.TextField, timer : Float} ;
	public var explosion : mt.flash.Volatile<Int> ;
		
	public var flGameOver : Bool ;
	public var dm : mt.DepthManager ;
	public var root : flash.MovieClip ;
	public var sdm : mt.DepthManager ;
	public var slimeMc : flash.MovieClip ;
	public var mcBomb : flash.MovieClip ;
		
	
	public var bg:flash.MovieClip ;
	public var mcLevel : {>flash.MovieClip, _field : flash.TextField,_burn : {>flash.MovieClip, _field : flash.TextField}} ;
	static public var me:Game ;

	
	public var slimes : mt.flash.PArray<Slime> ;
	public var allSlimes : mt.flash.PArray<Slime> ;
	public var toReduce : mt.flash.PArray<Slime> ;
	public var drops : mt.flash.PArray<Drop> ;
	


	public function new( mc : flash.MovieClip ) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
	
		root = mc ;
		me = this ;
		dm = new mt.DepthManager(root) ;
		
		slimeMc = dm.empty(DP_SLIME) ;
		sdm = new mt.DepthManager(slimeMc) ;
		
		flGameOver = false ;
		
		lockSlime = false ;
		level = 0 ;
		explosion = 0 ;
		
		slimes = new mt.flash.PArray() ;
		allSlimes = new mt.flash.PArray() ;
		drops = new mt.flash.PArray() ;
		
		initBg() ;
		initPlays() ;
		initScore() ;
		prepareLevel() ;
		initTime() ;
		
		step = Play ;
	}
	
	
	function initTime() {
		mcTime = cast Game.me.dm.attach("timeLine", Game.DP_SLIME) ;
		mcTime.start = flash.Lib.getTimer() ;
		mcTime._rotation = -90 ;
		mcTime._alpha = 80;
		mcTime._x =  5 ;
		mcTime._y = 230 ;

	}	

	function initBg() {
		var bg = dm.attach("mcBg", DP_BG) ;
		bg._x = 0 ;
		bg._y = 0 ;
	}
	
	
	function initPlays() {
		var i = 0 ;
		plays = Cs.INIT_PLAYS ;
		mcPlays = new mt.flash.PArray() ;
		var h = false ;
		
		var p = {x : 12.8, y : 13} ;
		
		var pm = dm.empty(DP_PLAYS) ;
		pm._x = Cs.PLAYS_X  ;
		pm._y = Cs.PLAYS_Y  ;
		var pdm = new mt.DepthManager(pm) ;
		
		while (i < Cs.MAX_PLAYS) {
			var mc = pdm.attach("play", if (h) 1 else 2) ;
			mc.gotoAndStop(if (i < plays) 2 else 1) ;
			
			mc._x = i * p.x ;
			mc._y =  (if (h) 0 else p.y) ;
			mcPlays.push(mc) ;
			
			i++ ;
			h = !h ;
		}
		
		pm.cacheAsBitmap = true ;
		
	}
	
	
	function initScore() {
		mcScore = cast dm.attach("score", DP_SCORING) ;
		mcScore._x = 268 ;
		mcScore._y = 265 ;
		mcScore._field.text = "" ;
		
	}
	
	
	
	
	public function isLocked() {
		return lockSlime || flGameOver ;
	}
	
	
	public function lock() {
		lockSlime = true ;
	}
	
	
	public function unlock() {
		lockSlime = false ;
	}
	
	
	public function resetExplosion() {
		explosion = 0 ;
		mcScore.timer = Cs.ALPHA_SCORE ;
	}
	
	
	public function cheatDetected() : Bool {
		if (mcPlays != null && mcPlays.cheat)
			return true ;
		if (slimes != null && slimes.cheat)
			return true ;
		if (allSlimes != null && allSlimes.cheat)
			return true ;
		if (toReduce != null && toReduce.cheat)
			return true ;
		if (drops != null && drops.cheat)
			return true ;
		
		return false ;
	}
	
	
	public function update() {
		if (cheatDetected())
			KKApi.flagCheater() ;
		
		/*if (Key.isDown(Key.CONTROL))
			trace(mt.Timer.fps()) ;*/
		
		updateSprites() ;
		updateScore() ;
		
		switch(step) {
			case Play : 
				updateTime() ;
			
				if (flGameOver) {
					KKApi.gameOver({}) ;
					step = GameOver ;
				}

			case Spout :
				if (!noMoreDrops())
					return ;
				
				if (checkNextLevel()) {
					initNextLevel() ;
					return ;
				}
				
				checkEnd() ;
				setPlay() ;

			case Bombing : 
				if (mcBomb == null || mcBomb._currentframe >= 20) {
					if (toReduce != null) {
						step = Explode ;
						return ;
					} else {
						if (checkNextLevel()) {
							initNextLevel() ;
							return ;
						}
				
						checkEnd() ;
						setPlay() ;
					}
				}

			case Explode : 
					for (s in toReduce) {
						if (s.ungrowing())
							toReduce.remove(s) ;
					}

					if (toReduce.length > 0)
						return ;
					
					if (checkNextLevel()) {
						initNextLevel() ;
						return ;
					}

					checkEnd() ;
					setPlay() ;

			case NextLevel : 
				timer -= 5 * mt.Timer.tmod ;
				if (mcLevel._burn == null && timer < 0) {
					timer = null ;
					prepareLevel() ;
					setNextLevel(false) ;
					setPlay() ;
				} else 
					mcLevel._burn._field.text = Std.string(level + 1) ;

			case GameOver :

			default:
		}
		
	}
	

	function updateTime() { //update TimeLine && check gameover
		var now = flash.Lib.getTimer() ;
		var c= Cs.PLAY_TIME - (now - mcTime.start) ;
			
		if (c > 0)
			mcTime._timeLeft._xscale = c / Cs.PLAY_TIME * 100 ;
		else
			forceReduce() ;
		
		//TIME PARTS
		var nb = 1 + Std.random(4) ;
		var drop = {x  : mcTime._timeLeft._height  , y : 230 - mcTime._timeLeft._width + 1} ;
		for (i in 0...nb) {
			var mc = dm.attach("part1", DP_PARTS) ;
			mc._xscale = 40 +Math.random() * 10;
			mc._yscale = 40 ;
			Col.setColor(mc, 0xFF9900) ;
			mc.blendMode = "add" ;

			var s = new Phys(mc) ;
			s.x = 6 + i * (drop.x / nb) ;
			s.y = drop.y ;
			s.weight = -0.2 ;
			s.alpha = 90 ;
			s.vx = Math.random() * 1 ;
			s.vy = Math.random() * -4  ;
			s.fadeType = 5 ; //alpha
			s.timer = 5 ;
		}
	}
	
	public function resetTime() {
		mcTime.start = flash.Lib.getTimer() ;
		mcTime._timeLeft._xscale = 100 ;
		
	}
	
	function forceReduce() {
		resetTime() ;
		
		var slime = null ;
		var count = 30 ;
		while (slime == null && count > 0) {
			count-- ;
			slime = slimes[Std.random(slimes.length)] ;
			
			if (slime != null && slime.grow == 1)
				slime = null ;
		}
		
		if (slime == null) //not found
			return ;
		
		slime.growTo(slime.grow - 1) ;
	}
	
	
	
	function updateScore() {
		if (mcScore.timer == null)
			return ;
		mcScore.timer -= 5 * mt.Timer.tmod ;
		if (mcScore.timer <= 0) {
			mcScore._field.text = "" ;
			mcScore._field._alpha = Cs.ALPHA_SCORE ;
		} else {
			mcScore._field._alpha = mcScore.timer ;
		}
		
	}
	
	
	public function setPlay() {
		resetExplosion() ;
		if (toReduce != null)
			toReduce = null ;
		
		if (checkNextLevel()) {
			initNextLevel() ;
			return ;
		}
		
		step = Play ;
		resetTime() ;
		
		if (checkEnd())
			setGameOver() ;
		
		unlock() ;
	}
	
	
	public function noMoreDrops() : Bool {
		return drops == null || drops.length == 0 ;
	}
	
	
	public function initSploutch(from : Slime) {
		if (step == Spout || from == null || !from.bigEnough())
			return ;
		
		step = Spout ;
		from.explode() ;
		
	}
	
	
	public function checkNextLevel() {
		if (slimes == null || slimes.length == 0)
			return true ;
		for (s in slimes) {
			if (!s.bonus)
				return false ;
		}
		return true ;
	}
	
	
	public function initNextLevel() {
		step = NextLevel ;
		level++ ;
		
		Game.me.addScore(Cs.BONUS_LEVEL) ;
		
		mcScore._field.text = "" ;
		mcScore._field._alpha = Cs.ALPHA_SCORE ;
		
		upPlay() ;
		timer = 100 ;
		
		setNextLevel(true) ;
	}
	
	
	public function downPlay() {
		var mc = mcPlays[plays - 1] ;
		if (mc != null)
			mc.gotoAndStop(1) ;
		plays-- ;
	
	}
	
	
	public function upPlay(?p : Pos) {
		if (plays >= Cs.MAX_PLAYS)
			return ;
		plays++ ;
		
		var mc = mcPlays[plays - 1] ;
		if (mc != null) {
			mc.gotoAndStop(3) ;
			launchLights(mc) ;
		}
	}
	
	
	public function initBombing(p : Pos) {
		step = Bombing ;
		
		mcBomb = dm.attach("flame", DP_PARTS) ;
		var pos = Cs.getPos(p, true) ;
		mcBomb._x = pos.x ;
		mcBomb._y = pos.y ;
	}
	
	
	public function getBonus(p : Pos) {
		powerUp(p, true) ;
		for (i in 0...Cs.BONUS_PLAYS) {
			upPlay() ;
		}
	}
	
	
	public function incExplode(p : Pos) {
		explosion++ ;
		
		mcScore.timer = null ;
		mcScore._field._alpha = Cs.ALPHA_SCORE ;
		mcScore._field.text = "x" + explosion ;

		if (Lambda.exists(Cs.WIN_PLAYS, function (x) { return x == Game.me.explosion ; })) {
				upPlay(p) ;
				powerUp(p, false) ;
		}
	}
	
	
	public function powerUp(p : Pos, bonus : Bool) {
		var mc = dm.attach("powerup", DP_POINTS) ;
		mc.smc.gotoAndStop(if (bonus) 2 else 1) ;
		var pos = Cs.getPos(p, true) ;
		mc._x = pos.x ;
		mc._y = pos.y ;
		
	}
	
	
	
	public function checkEnd() : Bool {
		if (flGameOver)
			return true ;
		return plays <= 0 ;
	}
	
	
	public function setGameOver() {
		flGameOver = true ;
	}
	
	
	//create new board for level l
	function prepareLevel() {

		for(s in allSlimes) {
			s.kill() ;
		}
		allSlimes = new mt.flash.PArray() ;
		slimes = new mt.flash.PArray() ;
		for (x in 0...Cs.BOARD_WIDTH) {
			for (y in 0...Cs.BOARD_HEIGHT) {
				var grow = Slime.getRandomGrow(level) ;

				var s = new Slime({x : x, y : y}) ;
				
				if (level == 0 && grow ==  0)
					grow = Std.random(2) + 1 ;
				
				s.growTo(grow) ;
				allSlimes.push(s) ;
				
				
				if (grow != 0) {
					if (Std.random(18) == 0) {
						if (Std.random(10) == 0)
							s.addBonus() ;
					}
					slimes.push(s) ;
				}
			}
		}

	}
	
	
	public function addScore(sc) {
		KKApi.addScore(sc) ;
		//var score = KKApi.val(sc) ;
	}
	
	
	function updateSprites() {
		var list =  Sprite.spriteList.copy() ;
		for(sp in list)sp.update() ;
	}
	
	
	//NEXT LEVEL MC
	function setNextLevel(on : Bool) {
		if (on) {
			if (mcLevel != null)
				mcLevel.removeMovieClip() ;
			mcLevel = cast dm.attach("nextLevel", DP_ANIM) ;
			mcLevel._burn._field.text = Std.string(level + 1) ;
			//trace(mcLevel._burn._field) ;
			/*mcLevel._x = 0 ;
			mcLevel._y = 0 ;*/
		} else {
			if (mcLevel == null)
				return ;
			mcLevel.removeMovieClip() ;
			mcLevel = null ;
		}
	}
	
	
	//### PARTS
	
	public function launchLights(mc : flash.MovieClip) {
		// PARTS LIGHT
		var max = 8 ;
		var cr = 2 ;
		for( i in 0...max ) {
			var a = (i+Math.random())/max *6.28 ;
			var ca = Math.cos(a) ;
			var sa = Math.sin(a) ;
			var sp = 0.5+Math.random()*10 ;
			var p = new Phys(Game.me.dm.attach("partLight",Game.DP_PARTS)) ;
			var sc = 40 + Std.random(60) ;
			p.root._xscale = sc ;
			p.root._yscale = sc ;
			
			p.root.blendMode = "add" ;
			p.x = Cs.PLAYS_X + mc._x+ca*sp*cr ;
			p.y = Cs.PLAYS_Y + mc._y+sa*sp*cr ;
			p.vx = ca*sp + 0.4 ;
			p.vy = sa*sp + 0.4 ;
			p.frict = 0.8 ;
			p.fadeType = 5 ;
			p.timer = 10+Math.random()*15;
		}
	}
	
	
}



