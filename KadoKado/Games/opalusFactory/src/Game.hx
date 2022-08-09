import KKApi;
import flash.Key ;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Lib;



enum Step {
	Door ;
	Play ;
	Move(start : {x : Float, y : Float}, end : {x : Float, y : Float}, c : InCase) ;
	Roll(size : Int) ;
	GameOver ;
}

typedef Hole = {
	var mc : {>flash.MovieClip, _empty : flash.MovieClip, _count : {>flash.MovieClip, _field : flash.TextField}, _field : flash.TextField, _bounce : flash.MovieClip, _wheel : flash.MovieClip} ;
	var mcLock : flash.MovieClip ;
	var locks : Array<flash.MovieClip> ;
	var count : mt.flash.Volatile<Int> ;
	var id : Int ;
}


typedef InCase = {
	var mc : flash.MovieClip ;
	var coin : Coin ;
	var index : mt.flash.Volatile<Int> ;
	var l : RollLine ;
	var links : Array<InCase> ;
	var parsed : Bool ;
}

typedef RollLine = {
	var index : mt.flash.Volatile<Int> ;
	var tokened : Bool ;
	var mc : flash.MovieClip ;
	var recal : Float ; 
	var line : mt.flash.PArray<InCase> ;
	var sy : Float ;
	var sc : Float ;
	var fLimit : Float ;
}

typedef Goal = {
	var id : mt.flash.Volatile<Int> ;
	var goal : mt.flash.Volatile<Int> ;
	var count : mt.flash.Volatile<Int> ;
}

typedef Move = {
	var mc : flash.MovieClip ;
	var func : Float -> Float ;
	var speed : Float ;
	var start : {x : Float, y : Float} ;
	var end : {x : Float, y : Float} ;
	var timer : Float ;
}

typedef Glow = {
	var mc : flash.MovieClip ;
	var func : Float -> Float ;
	var speed : Float ;
	var start : Float ;
	var end : Float ;
	var timer : Float ;
}


typedef DropInfos = {
	var timer : Float ;
	var hole : Hole ;
	var coins : Array<{h : Float, c : Coin, spos : {x : Float, y : Float}, tpos : {x : Float, y : Float}}> ;
}

class Game {
	
	static public var gMove : Array<Move> = new Array() ;
	static public var gGlow : Array<Glow> = new Array() ;
	
	public static var DP_BG = 0 ;
	public static var DP_SUB_PARTS = 1 ;
	public static var DP_HOLE = 2 ;
	public static var DP_ROLL = 3 ;
	public static var DP_CASE = 4 ;
	public static var DP_COIN = 5 ;
	public static var DP_HERO = 6 ;
	public static var DP_INTER = 8 ;
	
	public static var DP_PARTS = 10 ;
	public static var DP_POINTS = 11 ;
	public static var DP_DOOR = 12 ;
	

	public var step:Step ;
	var timer : mt.flash.Volatile<Float> ;
	
	var goal : Goal ;
	var goalCount : mt.flash.Volatile<Int> ;
	var dropInfos : DropInfos ;

	public var flGameOver : Bool ;
	public var mdm : mt.DepthManager ;
	public var root : flash.MovieClip ;
	public var bg : flash.MovieClip ;
	static public var me : Game ;
	var mcWall : {>flash.MovieClip, _p1 : flash.MovieClip, _p2 : flash.MovieClip, _p3 : flash.MovieClip} ;
	var mcDoor : {>flash.MovieClip, _top : flash.MovieClip, _bottom : flash.MovieClip} ;
	
	public var rolldm : mt.DepthManager ;
	public var mcRoll : flash.MovieClip ;
		
	public var holes : Array<Hole> ;
	
	public var roll : mt.flash.PArray<RollLine> ;
	public var level : mt.flash.Volatile<Int> ;
	public var lastWasGoal : Bool ;
	public var lastLockPlay : Int ;
	var oldDeltaRoll : Float ;
	var flagBlockPart : Int ;
	public var currentBlockMove : {m : Move, onEnd : Void -> Void} ;
		
	public var mcHero : flash.MovieClip ;
	public var hsy : Float ;
	public var heroX : mt.flash.Volatile<Int> ;
	public var heroY : mt.flash.Volatile<Int> ;
		
	var lastParse : Array<InCase> ;


	public function new( mc : flash.MovieClip ) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
	
		root = mc ;
		me = this ;
		mdm = new mt.DepthManager(root) ;
		
		flGameOver = false ;
		
		initBg() ;
		initGame() ;
	}
	

	function initBg() {
		var bg = mdm.attach("mcBg", DP_BG) ;
		bg._x = 0 ;
		bg._y = 0 ;
	}
	
	
	function initGame() {
		mdm = new mt.DepthManager(root) ;
		level = Cs.INIT_LEVEL ;
		
		initMcs() ;
		initRoll() ;
		initHero() ;
		goalCount = 0 ;
		setGoal() ;
		initPlays() ;
		step = Door ;
		timer = 0.0 ;
		
		mcDoor = cast mdm.attach("door", DP_DOOR) ;
	}
	
	
	function initMcs() {
		var y = 23 ;
		var x = Cs.HOLE_X ;
		
		holes = new Array() ;
		
		var submc = mdm.attach("subRoll", DP_SUB_PARTS) ;
		submc._x = 1 ;
		submc._y = 6 ;
		
		var mc = mdm.attach("blockHole", DP_HOLE) ;
		mc._x = 262.5 ;
		mc._y = 244 ;
		
		
		var h : Hole  ={
				id : 0,
				mc : cast mc,
				mcLock : (cast mc)._empty.createEmptyMovieClip("mcLock2", 1),
				locks : new Array(),
				count : null
			} ;
		
		/*h.count = Cs.INIT_COUNT ;
		h.mc._count._field.text = Std.string(h.count) ;*/
		h.mc._wheel.gotoAndStop(1) ;
		holes.push(h) ;
		h.count = 0 ;	
		addLocks(Cs.INIT_COUNT) ;
		for (m in holes[0].locks)
			m.gotoAndStop(m._currentframe) ;
		
		for(i in 1...level) {
			mc = mdm.attach("order", DP_HOLE) ;
			mc._x = x ;
			mc._y = y ;
			mc.smc.gotoAndStop(i) ;
			
			y += 25 ;
			
			h = {id : i,
				mc : cast mc,
				mcLock : null,
				locks : new Array(),
				count : null
			} ;
			h.count = 0 ;
			(cast h.mc.smc)._field._visible = false ;
			holes.push(h) ;
		}
		
		mcWall = cast mdm.attach("wallUp", DP_INTER) ;
		
	}
	
	
	function initRoll() {
		mcRoll = mdm.empty(DP_ROLL) ;
		mcRoll._x = 20 ;
		rolldm = new mt.DepthManager(mcRoll) ;
		
		roll = new mt.flash.PArray() ;
		
		createLine(Cs.ROLL_LENGTH) ;
	}
	
	
	function initHero() {
		heroX = Std.random(3) + 1 ;
		heroY = 8 ;
		
		var ch = roll[heroY].line[heroX] ;
		ch.coin.kill() ;
		
		var pos = getHeroPos() ;
		mcHero = mdm.attach("hero", DP_HERO) ;
		mcHero._x = pos.x ;
		mcHero._y = pos.y ;
		
	}
	
	
	function setGoal() {
		var oldId = null ;
		if (goal != null) {
			goalCount += 1 ;
			
			if (goalCount == Cs.GOAL_UP_LEVEL)
				upLevel() ;
			
			(cast holes[goal.id].mc.smc)._field._visible = false ;
			oldId = goal.id ;
			
			var gm : Move = {
				mc : cast holes[goal.id].mc,
				timer : 0.0,
				speed : 0.05,
				func : function(x : Float) { return 1 - AnimFunc.bounce(1 - x) ;},
				start : {x : holes[goal.id].mc._x, y : 0.0},
				end : {x : Cs.HOLE_X, y : 0.0}
			} ;
		
			gMove.push(gm) ;
			
		}
		
		
		goal = {id : null, goal : null, count : null} ;
		while (goal.id == null) {
			goal.id = Std.random(level - 2) + 1 ;
			
			if (oldId != null && goal.id == oldId)
				goal.id = null ;
		}
		goal.goal = Std.int(level / 2 + Std.random(level)) ;
		goal.count = 0 ;
		
		(cast holes[goal.id].mc.smc)._field.text = Std.string(goal.goal) ;
		(cast holes[goal.id].mc.smc)._field._visible = true ;
		
		var gm : Move = {
			mc : cast holes[goal.id].mc,
			timer : 0.0,
			speed : 0.05,
			func : function(x : Float) { return 1 - AnimFunc.bounce(1 - x) ;},
			start : {x : holes[goal.id].mc._x, y : 0.0},
			end : {x : Cs.GOAL_X, y : 0.0}
		} ;
	
		gMove.push(gm) ;
	}
	
	
	function upLevel() {
		if (level == 8) 
			return ;
		
		level = Std.int(Math.min(8, level + 1)) ;
		goalCount = 0 ;
		
		
		var mc = mdm.attach("order", DP_HOLE) ;
		mc._x = Cs.HOLE_X ;
		mc._y = holes[holes.length - 1].mc._y + 25 ;
		mc.smc.gotoAndStop(level - 1) ;
				
		var h : Hole = {id : level - 1,
			mc : cast mc,
			mcLock : null,
			locks : new Array(),
			count : null
		} ;
		h.count = 0 ;
		(cast h.mc.smc)._field._visible = false ;
		holes.push(h) ;
		
		/*var gm : Move = {
			mc : cast h.mc,
			timer : 0.0,
			speed : 0.05,
			func : function(x : Float) { return 1 - AnimFunc.bounce(1 - x) ;},
			start : {x : h.mc._x, y : 0.0},
			end : {x : Cs.HOLE_X, y : 0.0}
		} ;
		
		gMove.push(gm) ;*/
		
	}
	
	
	public function getHeroPos() : {x : Float, y : Float} {
		return {x : mcRoll._x + roll[heroY].mc._x + roll[heroY].line[heroX].mc._x,
			y : mcRoll._y + roll[heroY].mc._y + roll[heroY].line[heroX].mc._y} ;
	}
	
	
	public function getCasePos(c : InCase) : {x : Float, y : Float} {
		return {x : mcRoll._x + roll[cast c.l.index].mc._x + roll[cast c.l.index].line[cast c.index].mc._x,
			y : mcRoll._y + roll[cast c.l.index].mc._y + roll[cast c.l.index].line[cast c.index].mc._y} ;
	}
	
	
	public function getHeroCase() : InCase {
		return roll[heroY].line[heroX] ;
	}
	
	
	public function setHeroCase(c : InCase) {
		heroX = c.index ;
		heroY = c.l.index ;
		//trace("hero case " + (cast c.index) + ", " + (cast heroY) + " # " + c) ;
	}
	
	public function isGoalComplete() : Bool {
		return goal != null && goal.count == 0 && lastWasGoal ;
	}
	
	
	function getLevel() {
		if (Std.random(1300) == 0)
			return Cs.GOLDEN_COIN ;
		
		return Std.random(level) ;
	}
	
	
	public function cheatDetected() : Bool {
		if (roll != null && roll.cheat)
			return true ;
		if (roll != null) {
			for (l in roll) {
				if (l.line != null && l.line.cheat)
					return true ;
			}
		}

		return false ;
	}
	
	
	public function update() {
		if (cheatDetected())
			KKApi.flagCheater() ;
		
		/*if (Key.isDown(Key.CONTROL))
			trace(mt.Timer.fps()) ;*/
		
		updateSprites() ;
		updateGoalMoves() ;
		updateGlow() ;
		
		if (step != GameOver) {
			var hp = getCasePos(getHeroCase()) ;
			Cs.rotateMc(mcHero, root._xmouse, root._ymouse, hp.x, hp.y) ;
			
		}
		
		switch(step) {
			case Door : 
				timer = Math.min(timer + 0.03 * mt.Timer.tmod, 1.0) ;
						
				var f = AnimFunc.quint ;
				var d = if (timer <= 0.5) f(2 * timer) / 2 else ((2 - f(2 * (1 - timer))) / 2) ;
				
				mcDoor._top._y =  (1 - d) - mcDoor._top._height * d ;
				mcDoor._bottom._y = Cs.mch * (1 - d) + (Cs.mch + mcDoor._bottom._height) * d ;
				
			
				if (timer == 1) {
					step = Play ;
					timer = 0.0 ;
					//mcDoor.removeMovieClip() ;
				}
			
			
			
			case Play : 
				if (flGameOver) {
					KKApi.gameOver({}) ;
					timer = 0.0 ;
					step = GameOver ;
				}
				
			case Move(s, e, c) :
				if (timer < 1.0) {
					timer = Math.min(timer + 0.1 * mt.Timer.tmod, 1.0) ;
					var d = 1 - AnimFunc.quint(1 - timer) ;
					mcHero._x = s.x * (1 - d) + e.x * d ;
					mcHero._y = s.y * (1 - d) + e.y * d ;
				}
			
				if (dropInfos == null && timer > 0.25) {
					resetParse() ;
					dropInfos = initCoinDrop(c) ;
				}
				
				if (dropInfos != null && dropInfos.timer != null) {
					dropInfos.timer = Math.min(dropInfos.timer + 0.14 * mt.Timer.tmod, 1.0) ;
					var d = /*1 - AnimFunc.quart(1 - dropInfos.timer) ; */ dropInfos.timer ;
					for (cc in dropInfos.coins) {
						cc.c.mc._x = cc.spos.x * (1 - d) + cc.tpos.x * d ;
						cc.c.mc._y = cc.spos.y * (1 - d) + cc.tpos.y * d ;
						//cc.c.mc._y -= Math.sin((3.14) * d) * cc.h ;
					}
					
					
					if (dropInfos.timer != null && dropInfos.timer == 1.0) {
						addToHole(dropInfos.hole, dropInfos.coins.length) ;
						for (cc in dropInfos.coins)
							cc.c.kill() ;
						dropInfos.timer =  null ;
					}
				}
				
				if (flagBlockPart != null)
					launchBlockParticles() ;
				
				
				if (timer == 1 && ((dropInfos.coins.length > 0 && dropInfos.timer == null) || dropInfos.coins.length == 0)) {
					resetLinks() ;
					setHeroCase(c) ;
					startRoll(dropInfos.coins.length == 0, lastWasGoal) ;
				}

			case Roll(size) :
				var s = if (size < 0) -1 else 1 ;
				var oldTimer = timer ;
				timer = Math.min(timer + 0.06 * mt.Timer.tmod / Math.abs(size / 2), 1.0) ;
				var d = 1 - AnimFunc.bounce(1 - timer) ;
				
				/*var frames = 44 * (d - oldDeltaRoll) * s ;
				trace(frames + " # " + holes[0].mc._wheel._currentframe + " # " + (Std.int((holes[0].mc._wheel._currentframe + frames) % 12))) ;
				holes[0].mc._wheel.gotoAndStop(Std.int((holes[0].mc._wheel._currentframe + frames) % 6)) ;
				oldDeltaRoll = d ;*/
				
				
				for (i in 0...roll.length) {
					var l = roll[i] ;
					
					if (l.sy == null) {
						l.sy = l.mc._y ;
						l.sc = l.mc._yscale ;
					}
					
					/*if (timer == 1)
						trace(i + " # " + l.index + " # " + (i - size) + " # " + (l.index - size)) ;*/
					
					if (l.index - size < 5) {
						var nextPos = l.index - size ;
						var startInfos = if (l.index < 0)
										[0, 275 + l.index * Cs.ROLL_LINE_Y / 6]
									else if (l.index < 5)
										Cs.ROLL_VOID_INFOS[l.index]
									else 
										[100.0, 0] ;
						var endInfos = null ;
						if(nextPos < 0)
							endInfos = [0, 275 + nextPos * Cs.ROLL_LINE_Y / 6] ;
						else if (nextPos < 5) 
							endInfos = Cs.ROLL_VOID_INFOS[nextPos]
						else
							endInfos = [100.0, 0] ;
						
						/*if (timer == 1)
							trace(i + " # " + l.index + " # " +" # " + (l.index - size) + " # " + Std.string(startInfos)+ " # " + Std.string(endInfos)) ;*/
						
						l.mc._y = (l.sy) * (1 - d) + (endInfos[1]) * d ;
						var oldScale = l.mc._yscale ;
						l.mc._yscale  = startInfos[0] * (1 - d) + (endInfos[0]) * d ;
						
						
						if (s > 0 && endInfos[0] == 0)
							l.mc._alpha = Math.max(0, 150 - timer * 200) ;
						
						if (s < 0 && startInfos[0] == 0)
							l.mc._alpha = Math.min(timer * 400, 100) ;
						
						
						if (s > 0 && nextPos < 3) {
							if (l.mc._yscale < l.fLimit && oldScale >= l.fLimit)
								coinFalls(l) ; 
						}
						
						
						var lim = 0.3 ;
						if (oldTimer <= lim && timer > lim) {
							setLineShadow(l, l.index - size) ;
						}
						
						
						
					} else {
						if (s > 0)
							l.mc._y = l.sy * (1 - d) + (l.sy + size * Cs.ROLL_LINE_Y) * d ;
						else {
							l.mc._y = l.sy * (1 - d) + (Cs.ROLL_BOTTOM - (l.index - size) * Cs.ROLL_LINE_Y) * d ;
							if (l.sc != 100)
								l.mc._yscale  = l.sc * (1 - d) + (100) * d ;
						}
					}
					
					if (timer == 1)
						l.sy = null ;
				}
				
				if (heroX != null) 
					mcHero._y = hsy * (1 - d) + (hsy + size * Cs.ROLL_LINE_Y) * d ;
			
				if (timer == 1) {
					timer = 0.0 ;
					recalRoll(size) ;
					step = Play ;
				}

			case GameOver :
				if (timer != null) {
					timer = Math.min(timer + 0.03 * mt.Timer.tmod, 1.0) ;
							
					var f = AnimFunc.quint ;
					var d = if (timer <= 0.5) f(2 * timer) / 2 else ((2 - f(2 * (1 - timer))) / 2) ;
					
				
					mcDoor._top._y =  -mcDoor._top._height * (1 - d) ;
					mcDoor._bottom._y =  (Cs.mch + mcDoor._bottom._height) * (1 - d) + Cs.mch * (d);
				
				
					if (timer == 1)
						timer = null ;
				}

		}
		
	}
	
	
	function addToHole(h : Hole, nb : Int) {
		if (nb <= 0)
			return ;
				
		//h.count += nb ;
		
		var gg : Glow = {
			mc : (if (h.id == 0) cast h.mc else cast h.mc),
			func : function(x : Float) {return 1 - AnimFunc.quint(1 - x) ;},
			start : 2.0,
			end : 0.0,
			speed : 0.05,
			timer : 0.0
		} ;
		Game.gGlow.push(gg) ;
		
		
		if (goal != null && h.id == goal.id) {
			lastWasGoal = true ;
			
			//goal.count += nb ;
			var d = Std.int(Math.max(0, goal.goal - goal.count)) ;
			
			(cast h.mc.smc)._field.text = Std.string(d) ;
			
			if (d == 0) // goal complete
				setGoal() ;
			
		} else if (h.id == 0) {
			h.mc._field.text = Std.string(h.count) ;
			
		}
		
	}
	
	
	function coinFalls(l : RollLine) {
		for(c in l.line) {
			var hasHero = c == getHeroCase() ;
			if (c.coin == null && !hasHero)
				continue ;
			
			if (c.coin != null) {
				var mc = mdm.empty(DP_PARTS) ;
				var cmc = mc.attachMovie("coin", "coin", 0) ;
				
				
				cmc.gotoAndStop(c.coin.id + 1) ;
				
				cmc.filters = [new flash.filters.DropShadowFilter(2, -90, 0x171B24, 5, 1, 1, 0.6)] ;
				
				var p = getCasePos(c) ;
				mc._x = p.x + c.coin.mc._x ;
				mc._y = p.y + c.coin.mc._y ;
				
				cmc._yscale = l.mc._yscale ;
				
				var sp = new FPhys(mc) ;
				
				sp.x = mc._x ;
				sp.y = mc._y ;
				sp.vsc = 0.97 ;
				sp.timer = 25 + Std.random(15) ;
				sp.fadeType = 6 ;
				
				sp.weight = -0.055 ;
				//sp.vx = (Std.random(2) * 2 - 1) * Std.random(6) / 20 ;
				
				var vx = (c.index - 2) * -0.35 ;
				
				sp.vx = vx ;
				sp.vy = 2.75 ;
				sp.frict = 0.95 ;
				
				sp.onEnd = callback(vanish, sp) ;
				
				c.coin.kill() ;
				
			}
			
			if (hasHero)
				heroFall() ;
		}
		
	}
	
	
	public function heroFall() {
				
		var sp = new FPhys(mcHero) ;
		
		sp.x = mcHero._x ;
		sp.y = mcHero._y ;
		sp.vsc = 0.97 ;
		sp.timer = 25 + Std.random(15) ;
		sp.fadeType = 6 ;
		
		sp.weight = -0.055 ;
		sp.vx = (Std.random(2) * 2 - 1) * Std.random(6) / 20 ;
		sp.vy = 2.75 ;
		sp.frict = 0.95 ;
		
		sp.onEnd = callback(vanish, sp) ;
		
		heroX = null ;
		heroY = null ;
		setGameOver() ;
		
	}
	
	
	function startRoll(?noDrop = false, ?isGoal = false) {
		var size = if (noDrop) 4 else /*if (isGoal) */3 /*else 3*/ ;
	
		if (isGoalComplete())
			size = Std.int(Math.min(Cs.GOAL_ROLL_UPWARD, Cs.UP_LIMIT - 2 - heroY)) * -1 ;
		
		if (size > 0 && (holes[0].count > 0 || lastLockPlay != null))
			size -= 2 ;
			
		
		holes[0].mc._count._field.text = Std.string(holes[0].count) ;
		
		oldDeltaRoll = 0.0 ;
		timer = 0.0 ;
		hsy = mcHero._y ;
		
		if (size > 0) {
			for(i in (roll.length - 3)...roll.length) {
				var l = roll[i] ;
				if (l.tokened)
					continue ;
				l.tokened = true ;
				for(c in l.line) {
					if (c.coin != null)
						c.coin.mc._visible = true ;
				}
			
			}
		}
		
		var ls = if (size < 0)
				size 
			else
				Std.int(Math.max(0, size - (roll.length - Cs.ROLL_LENGTH))) ;
		createLine(ls) ;
		
		if (size != 0)
			step = Roll(size) ;
		else {
			recalRoll(0) ;
			step = Play ;
		}
	}
	
	
	function recalRoll(size : Int) {
		for (i in 0...size) {
			var l = roll.shift() ;
			l.mc.removeMovieClip() ;
		}
		
		flagBlockPart = null ;
		
		holes[0].mc._wheel.gotoAndStop(holes[0].mc._wheel._currentframe) ;
		for (m in holes[0].locks) {
			m.gotoAndStop(m._currentframe) ;
		}
		
		for (i in 0...roll.length) {
			
		//	setLineShadow(roll[i].mc, i) ;
			
			roll[i].index = i ;
		}
		
		heroY = heroY - size ;
		initPlays() ;
		
	}
	
	
	function setLineShadow(l : RollLine, index : Int) {
		l.mc.filters = [new flash.filters.DropShadowFilter(Std.int(Math.max(1, (6 - index) / 2)), -90, 0x808CBF, 5, 1, 1, 0.6)] ;
		
		for (c in l.line) {
			if (c.coin == null)
				continue ;
			c.coin.mc.filters = [new flash.filters.DropShadowFilter(Std.int(Math.max(1,(6 - index) / 2)), -90, 0x171B24, 5, 1, 1, 0.6)] ;
			
		}
		
	}
	
	
	function addLocks(n : Int) {
		var h = holes[0] ;
		var old = h.count ;
		h.count += n ;
		h.mc._count._field.text = Std.string(h.count) ;
		
		/*if (n <= 1)
			return ;*/
		
		var w = 0 ;
		//var f = if (h.locks.length > 0) h.locks[0]._currentframe else 1 ;
		
		for (i in 0...n) {
			var mc = h.mcLock.attachMovie("ecrou_2", "ecrou_2_" + (old + i), old + i) ;
			mc._x = 10 - 8 * (old + i + 1) ;
			
			mc.gotoAndPlay(Std.random(5) + 1) ;
			mc._y = 0 ;
			w += 8 ;
			h.locks.push(mc) ;
		}
			
		
		var f = function(x : Float) { return 1 - AnimFunc.quint(1 - x) ;} ;
		var m1 : Move = {
			mc : cast h.mcLock,
			timer : 0.0,
			speed : 0.05,
			func : f,
			start : {x : h.mcLock._x, y : 0.0},
			end : {x : h.mcLock._x + w, y : 0.0}
		} ;
		
		
		var m2 = {
			mc : cast h.mc._bounce,
			timer : 0.0,
			speed : 0.05,
			func : f,
			start : {x : h.mc._bounce._x, y : 0.0},
			end : {x : h.mc._bounce._x + w, y : 0.0}
		} ;
		
		if (currentBlockMove == null) {
			gMove.push(m1) ;
			gMove.push(m2) ;
			currentBlockMove = {
							m : m1,
							onEnd : callback(function() {Game.me.currentBlockMove = null ;})
						} ;
		} else {
			currentBlockMove.onEnd = callback(function(mm1 : Move, mm2 : Move) {
											Game.me.currentBlockMove = {
																	m : mm1,
																	onEnd : callback(function() {Game.me.currentBlockMove = null ;})
																	
																} ;
											Game.gMove.push(mm1) ;
											Game.gMove.push(mm2) ;
										}, m1, m2) ;
		}
		
		holes[0].mc._count._field.text = Std.string(holes[0].count) ;
	}
	
	
	function removeLock(n : Int) {
		var h = holes[0] ;
		if (h.count - n < 0)
			n = h.count ;
		
		var old = h.count ;
		h.count -= n ;
		h.mc._count._field.text = Std.string(h.count) ;
		
		/*if  (lastLockPlay == 1)
			return ;*/
		
		var w = 0 ;
		for (i in 0...n) {
			var mc = h.locks.pop() ;
			mc.removeMovieClip() ;
			
			w += 8 ;
		}
		
		var f = function(x : Float) { return 1 - AnimFunc.elastic(1, 1 - x) ;} ;
		var m1 : Move = {
			mc : cast h.mcLock,
			timer : 0.0,
			speed : 0.05,
			func : f,
			start : {x : h.mcLock._x, y : 0.0},
			end : {x : h.mcLock._x - w, y : 0.0}
		} ;
		
		var m2 = {
			mc : cast h.mc._bounce,
			timer : 0.0,
			speed : 0.05,
			func : f,
			start : {x : h.mc._bounce._x, y : 0.0},
			end : {x : h.mc._bounce._x - w, y : 0.0}
		} ;
		
		
		if (currentBlockMove == null) {
			gMove.push(m1) ;
			gMove.push(m2) ;
			currentBlockMove = {
							m : m1,
							onEnd : callback(function() {Game.me.currentBlockMove = null ;})
						} ;
		} else {
			currentBlockMove.onEnd = callback(function(mm1 : Move, mm2 : Move) {
											Game.me.currentBlockMove = {
																	m : mm1,
																	onEnd : callback(function() {Game.me.currentBlockMove = null ;})
																	
																} ;
											Game.gMove.push(mm1) ;
											Game.gMove.push(mm2) ;
										}, m1, m2) ;
		}
		
		holes[0].mc._count._field.text = Std.string(holes[0].count) ;
		
	}
	
	
	function createLine(nb : Int) {
		if (nb == 0) 
			return ;
		
		
		var s = if (nb > 0) 1 else -1 ;
		var from = if (s > 0) roll.length - 1 else 0 ;
		nb = Std.int(Math.abs(nb)) ;
		
		var ly = if (roll.length == 0)
				Cs.ROLL_BOTTOM ;
			else
				roll[from].mc._y - Cs.ROLL_LINE_Y ;
		var r = if (roll.length == 0 || roll[from].recal == 0)
				Cs.ROLL_LINE_RECAL
			else 
				0.0 ;
		
		var begin = roll.length ;
		var end = roll.length + nb ;
		if (s < 0) {
			begin = 1 ;
			end = nb + 1 ;
		}
			
			
		for (ii in begin...end) {
			var i = ii * s ;
			var l : RollLine= {index : null, mc : rolldm.empty(i), recal : r, line : new mt.flash.PArray(), sy : null, sc : null, fLimit : 50.0 + Std.random(10), tokened : null} ;
			l.index = i ;
			l.mc._y = ly ;
			l.mc._x = r ;
			ly -= Cs.ROLL_LINE_Y ;
			for (j in 0...Cs.CASE_PER_LINE) {
				var c : InCase = {
					mc : l.mc.attachMovie("case", "case_" + j, j),
					coin : null,
					l : l,
					index : null ,
					links : null,
					parsed : false
				} ;
				
				
				c.index = j ;
				c.mc._x = j * Cs.ROLL_LINE_X ;
				c.mc._y = 0 ;
				
				if (i >= 3) {
					c.coin = new Coin(getLevel(), c.mc) ; 
					c.coin.myCase = c ;
				}
				
				c.mc.onRollOver = callback(caseOver, c) ;
				c.mc.onRollOut = callback(caseOut, c) ;
				c.mc.onReleaseOutside = callback(caseOut, c) ;
				c.mc.onRelease = callback(play, c) ;
				
				KKApi.registerButton(c.mc);
				
				l.line.push(c) ;
			}
			
			if (i < 0) {
				l.mc._yscale = 0 ;
				l.mc._alpha = 0 ;
				l.mc._y = 275 + i * Cs.ROLL_LINE_Y / 6 ;
			}else if (i < 4) {
				l.mc._yscale = Cs.ROLL_VOID_INFOS[i][0] ;
				l.mc._y = Cs.ROLL_VOID_INFOS[i][1] ;
			}
			
			if (s > 0)
				roll.push(l) ;
			else 
				roll.unshift(l) ;
			
			if (r > 0)
				r = 0.0 ;
			else
				r = Cs.ROLL_LINE_RECAL ;
		}
		
		
		for (i in 0...roll.length) {
			var l = roll[i] ;
			
			setLineShadow(l, i) ;
			
			rolldm.swap(l.mc, l.index) ;
			if (l.tokened == null) {
				if (s > 0 && i >= roll.length - 1) {
					l.tokened = false ;
					for (c in l.line) {
						if (c.coin != null)
							c.coin.mc._visible = false ;
					}
				} else
					l.tokened = true ;
			} 
			
			
		}
	}
	
	
	
	function initCoinDrop(c: InCase) : Dynamic {
		/*if (c.coin == null)
			return null ;*/
		var th = null ;
		
		lastLockPlay = null ;
		
		if (c.coin == null) {
			if (holes[0].count > 0) {
				removeLock(1) ;
				makeBlockParticles(c) ;
				lastLockPlay = 1 ;
			}
			return {th : null, timer : null, coins : []} ;
		}
			
		if (c.coin.id == Cs.GOLDEN_COIN) { //BONUS
			c.coin.kill() ;
			setScore(c, Cs.GOLDEN_BONUS) ;
		} else {
			for (h in holes) {
				if (h.id == c.coin.id) {
					th = h ;
					break ;
				}
			}
		}
		
		if (th == null) {
			//trace("Hole not found for " + c.coin.id) ;
			return null ;
		}
		
		
		var res = {
			hole : th,
			coins : new Array(),
			timer : 0.0
		}
		
		var dp = 8.0 ;
		
		if (th.id == 0) {
			lastLockPlay = c.links.length ;
			makeBlockParticles(c) ;
			addLocks(c.links.length -1) ;
		} else {
			if (holes[0].count > 0) {
				removeLock(1) ;
				makeBlockParticles(c) ;
				lastLockPlay = 1 ;
			}
			th.count += c.links.length ;
			if (th.id == goal.id)
				goal.count += c.links.length ;
		}
		
		for (cc in c.links) {
			var nc = cc.coin.copy(mdm, DP_COIN) ;
			var p = getCasePos(cc) ;
			nc.mc._x = p.x + cc.coin.mc._x ; // + nc.mc 
			nc.mc._y = p.y + cc.coin.mc._y ;
			
			res.coins.push({ 
					h : 10.0 + Std.random(60),
					c : nc,
					spos : {x : nc.mc._x, y : nc.mc._y},
					tpos : {x : th.mc._x + dp / 2  + Std.random(Std.int(dp /2)),
						y : th.mc._y + dp / 2  + Std.random(Std.int(dp /2))}
				}) ;
				
				
			if (th.id > 0) {
				if (th.id == goal.id) {
					setScore(cc, KKApi.cadd(Cs.GOAL_POINTS, KKApi.cmult(KKApi.const(c.links.length),Cs.MULTI_BONUS))) ;
				} else
					setScore(cc, KKApi.cadd(Cs.POINTS, KKApi.cmult(KKApi.const(c.links.length),Cs.MULTI_BONUS))) ;
				
			}
				
			cc.coin.kill() ;
		}
		
		
		
		return res ;
	}
	
	function parseLinks(c : InCase) {
		resetParse() ;
		 if (c.coin == null || c.coin.id == Cs.GOLDEN_COIN) {
			c.links = [c] ;
		 } else {
			//trace("FROM : " + (cast c.index) + ", " + (cast c.l.index)) ; 
			c.links = parseL(c) ;
			for (cc in c.links) {
				cc.links = c.links ;
			}
		}
		
		//lastParse = c.links ;
	}
	
	
	function resetLinks() {
		//lastParse = null ;
		for (r in roll) {
			for (c in r.line) {
				/*c.parsed = false ;
				c.mc.filters = [] ;*/
				c.links = null ;
			}
		}
	}
	
	
	function resetParse(?v = false) {
		lastParse = null ;
		for (r in roll) {
			for (c in r.line) {
				c.parsed = v ;
				c.mc.filters = [] ;
			}
		}
		getHeroCase().parsed = true ;
	}
	
	
	function parseL(c : InCase) : Array<InCase> {
		var res = [c] ;
		c.parsed = true ;
		
		for(pos in Cs.getAround(c)) {
			var nc = getCase(c.index + pos[0], c.l.index + pos[1]) ;
			if (nc == null || nc.parsed || nc.l.index > Cs.UP_LIMIT)
				continue ;
			
			nc.parsed = true ;
			if (nc.coin == null || (cast nc.coin.id) != c.coin.id || nc.coin.mc._visible == false || c.l.index >= Cs.UP_LIMIT)
				continue ;
			res = res.concat(parseL(nc)) ;
		}
		
		return res ;
	}
	
	
	public function getCase(x, y) : InCase {
		if (x < 0 || x >= Cs.CASE_PER_LINE || y < 0 || y >= Cs.ROLL_LENGTH)
			return null ;
		
		return roll[y].line[x] ;
	}
	
	
	public function canBePlayed(c : InCase) {
		if (c.l.index < Cs.DOWN_LIMIT || c.l.index > Cs.UP_LIMIT - 1 || heroX == null)
			return false ;
		var diff = [c.index - heroX, c.l.index - heroY] ;
		
		for (p in Cs.getAround(getHeroCase())) {
			if (p[0] == diff[0] && p[1] == diff[1])
				return true ;
		}
		return false ;
	}
	
	public function caseOver(c : InCase) {
		if (step != Play)
			return ;
		
		
		if (c.links == null) {
			/*if (canBePlayed(c)) {
				parseLinks(c) ;
				setFocus(c.links) ;
			} else*/
				setFocus(null) ;
		} else {
			var p = canBePlayed(c) ;
			if (!p) 
				setFocus(null) ;
			else {
				if (lastParse != c.links)
					setFocus(c.links) ;
			}
		}
	}
	
	
	function setFocus(t : Array<InCase>) {
		if (lastParse != null) {
			for (c in lastParse) {
				c.mc.filters = [] ;
			}
		}
		
		lastParse = t ;
		if (t != null) {
			for (c in t) {
				Filt.glow(c.mc, 2, 10, 0xFFFFFF, true) ;
			}
		}	
	}
	
	public function caseOut(c : InCase) {
		//nothing to do
	}
	
	
	function initPlays() {
		var hc = getHeroCase() ;
		var focus = null ;
		
		for(pos in Cs.getAround(hc)) {
			var c = getCase(hc.index + pos[0], hc.l.index + pos[1]) ;
			
			if (c.l.index < Cs.DOWN_LIMIT || c.l.index > Cs.UP_LIMIT)
				continue ;
			
			parseLinks(c) ;
			
			if (c.mc.hitTest(root._xmouse, root._ymouse)) {
				focus = c.links ;
			}

		}
		
		if (focus != null)
			setFocus(focus) ;
		
		
		
	}
	
	
	function isCompletingGoal(c : InCase) {
		return goal != null && c.coin != null && c.coin.id == goal.id && goal.goal <= goal.count + c.links.length ;
	}
	
	public function play(c : InCase) {
		if (step != Play || !canBePlayed(c))
			return ;
		
		/*if (c.links == null) {
			parseLinks(c) ;
			setFocus(c.links) ;
		}*/
		
		timer = 0.0 ;
		dropInfos = null ;
		lastWasGoal = false ;
		
		var d = 0 ;
		if (isCompletingGoal(c)) //goal complete
			d += 6 ;
				
		holes[0].mc._wheel.gotoAndPlay(holes[0].mc._wheel._currentframe + (if (holes[0].mc._wheel._currentframe > 6) -6 else 0) + d) ;
		for (m in holes[0].locks) {
			m.gotoAndPlay(m._currentframe + (if (m._currentframe > 6) -6 else 0) + d) ;
		}
		
		if (d == 0) {
			if (roll[0].recal > 0) {
				if (!roll[19].tokened) {
					mcWall._p1.gotoAndPlay(4) ;
				}
				//mcWall._p3.gotoAndPlay(3) ;
			}else {
				if (!roll[19].tokened)
					mcWall._p2.gotoAndPlay(4) ;
			}
		}
		
		
		
		
		step = Move(getCasePos(getHeroCase()), getCasePos(c), c) ; 
	}
	
	
	function updateSprites() {
		var list =  Sprite.spriteList.copy() ;
		for(sp in list)sp.update() ;
	}
	
	
	public function setGameOver() {
		flGameOver = true ;
		
	}
	
	
	function updateGlow() {
		var list = Game.gGlow.copy() ; 
		for (m in list) {
			m.timer = Math.min(m.timer + m.speed * mt.Timer.tmod, 1.0) ;
			var d= m.func(m.timer) ;
			
			m.mc.filters = [] ;
			Filt.glow(m.mc, 40, m.start * (1 - d) + m.end * d, 0xFFFFFF, true) ;
			
			if (m.timer == 1) {
				Game.gGlow.remove(m) ;
			}
		}
	}
	
	
	function updateGoalMoves() {		
		var list = Game.gMove.copy() ; 
		for (m in list) {
			m.timer = Math.min(m.timer + m.speed * mt.Timer.tmod, 1.0) ;
			//var d = 1 - AnimFunc.bounce(1 - m.timer) ;
			var d= m.func(m.timer) ;
			m.mc._x = m.start.x * (1 - d) + m.end.x * d ;
			
			if (m.timer == 1) {
				if (currentBlockMove != null && currentBlockMove.m == m)
					currentBlockMove.onEnd() ;
				
				Game.gMove.remove(m) ;
			}
		}
	}
	
	
	function setScore(c, sc) {
		var mc : {> flash.MovieClip, _p : {>flash.MovieClip, _field : flash.TextField}} = cast mdm.attach("points", DP_PARTS) ;
		mc._p._field.text = Std.string(KKApi.val(sc)) ;
		var p = getCasePos(c) ;
		mc._x = p.x ;
		mc._y = p.y ;
		
		/*var sp = new Phys(mc) ;
		var p = getCasePos(c) ;
		sp.x = p.x ;
		sp.y = p.y ;
		sp.timer = 30 ;
		sp.weight = -0.03 ;
		sp.frict = 0.98 ;
		sp.fadeType = 1 ;*/
		
		addScore(sc) ;
	}
	
	
	public function addScore(sc) {
		KKApi.addScore(sc) ;
	}
	
	
	
	function makeBlockParticles(c : InCase) {
		if (!isCompletingGoal(c))
			flagBlockPart = 50 ;
	}
	
	function launchBlockParticles() {
		var nb = Std.int(flagBlockPart / 6);
		var s = 1 ;
		
		for(i in 0...nb) {
			var mc = mdm.attach("parts", DP_PARTS) ;
			mc.blendMode = "add" ;
			
			var sc = 80 + Std.random(40) ;
			mc._xscale = sc ;
			mc._yscale = sc ;
			
			var p = new Phys(mc) ;
			p.x = holes[0].mc._x + Std.random(2) + 3 ;
			p.y = holes[0].mc._y - 4 + i * (25 / nb) + Std.random(1) ;
						
			p.frict = 0.97 ;
			p.timer = 5 + Std.random(15) ;
			p.fadeType = 6 ;
			p.weight = Math.random() / 5 ;
			
			p.vx = Math.random() *  3.5 ;
			p.vy = s * Math.random() * 20 * (if (Std.random(25) == 0) -1 else 1)  ;

		}
		
		flagBlockPart -= 5 ;
		if (flagBlockPart < 0)
			flagBlockPart = null ;
		
	}
	
	
	
	public static  function vanish(s : FPhys) {
		var mc = Game.me.mdm.attach("vanish", Game.DP_SUB_PARTS) ;
		mc.blendMode = "add" ;
		mc.gotoAndPlay(10 + Std.random(15)) ; 
		mc._rotation = Std.random(360) ;
		var sp = new FPhys(mc) ;
		sp.x = s.x ;
		sp.y = s.y ;
		sp.fadeType = 6 ;
		sp.timer = 40 ;
	}
	
	
	



}