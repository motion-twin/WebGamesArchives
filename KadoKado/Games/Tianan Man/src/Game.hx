import KKApi;
import flash.Key ;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Plasma;
import mt.bumdum.Lib;



enum Step {
	Wait ;
	Play ;
	GameOver ;
}


class Game {
	
	static public var BloodList:Array<Phys> = new Array() ;
	static public var ExplosionList:Array<flash.MovieClip> = new Array() ;
	
	public static var DP_BG = 0 ;
	public static var DP_GROUND = 1 ;
	public static var DP_BLOOD = 2 ;
	public static var DP_TRACES = 3 ;
		
	public static var DP_FOLLOW = 5 ;
	public static var DP_PLAYER = 6 ;
		
	public static var DP_WARNING = 7 ;
	
	public static var DP_ARMY = 8 ;
	public static var DP_FEVER = 9 ; 
	public static var DP_TARGET = 10 ;
	public static var DP_POINTS = 11 ;
	public static var DP_BOMB = 12 ;
	public static var DP_PARTS = 13 ;
	
	public static var DP_INTERF = 14 ;
	public static var DP_OVER = 15 ;
	public static var DP_START = 16 ;

	public var flGameOver : Bool ;
	public var mdm : mt.DepthManager ;
	public var root : flash.MovieClip ;
	public var bg : flash.MovieClip ;
	public var idm : mt.DepthManager ;
	public var step:Step ;
	static public var me : Game ;
	var timer : mt.flash.Volatile<Float> ;
	
	public var difficulty : mt.flash.Volatile<Float> ;
	
	public var lifeLeader : mt.flash.Volatile<Int> ;
	public var lifeFollowers : mt.flash.Volatile<Int> ;
	public var fMult : mt.flash.Volatile<Int> ;
	var mcLifeLeader : flash.MovieClip ;
	var mcLifeFollowers : Array<flash.MovieClip> ;

	public var mcGroup : flash.MovieClip ;
	public var gdm : mt.DepthManager ;
	public var faceDown : Bool ;
		
	public var mcArmy : flash.MovieClip ;
	public var adm : mt.DepthManager ;
	
	public var leader : Follower ;
	public var followRepopTimer : mt.flash.Volatile<Float> ;
	public var toGrab : mt.flash.PArray<Follower> ;
	public var followers : mt.flash.PArray<mt.flash.PArray<Follower>> ;
	var armyRepopTimer : mt.flash.Volatile<Float> ;
	public var army : mt.flash.PArray<Army> ;
		
	var mcStart : flash.MovieClip ;
	var mcOver : flash.MovieClip ;
	
	public var bTimer : BulletTimer ;
		
	public var plasma : Plasma ;
	public var waitPlasmaUpdate : Float ;
		
	public var fever : Bool ;
	public var feverTimer  : mt.flash.Volatile<Float> ;
	public var feverStock : mt.flash.Volatile<Int> ;
	var feverFlash : Int ;
	var feverLastCol : Int ;
	var feverGlow : Float ;
	var mcFever : flash.MovieClip ;
	
	
	static public var debugPause : Bool ; //debug only
	static public var mcTrace : flash.MovieClip ;
	static public var mcTraceTwo : flash.MovieClip ;


	public function new( mc : flash.MovieClip ) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		debugPause =false ;
		
	
		root = mc ;
		me = this ;
		mdm = new mt.DepthManager(root) ;
		
		flGameOver = false ;
		
		initBg() ;
		initGame() ;
		initInterface() ;
		
		//debug only
		//initKeyListener() ;
	}
	

	function initBg() {
		var bg = mdm.attach("mcBg", DP_BG) ;
		bg._x = 0 ;
		bg._y = 0 ;
	}
	
	
	function initInterface() {
		var mcInt = mdm.empty(DP_INTERF) ;
		idm = new mt.DepthManager(mcInt) ; 
		var bgInter = idm.attach("bgInterface", 0) ;
		
		var lifeY = 16 ;
		
		mcLifeLeader = idm.attach("intLeader", 1) ;
		mcLifeLeader._x = 5 ;
		mcLifeLeader._y = lifeY ;
		mcLifeFollowers = new Array() ;
		for (i in 0...lifeFollowers) {
			var m = idm.attach("intFollow", 1) ;
			m.gotoAndStop(1);
			m.smc.gotoAndPlay(2*i+1);
			m._x = 28 + i * 15 ;
			m._y = lifeY ;
			mcLifeFollowers.push(m) ;
		}
		
		mcFever = idm.attach("fever", 2) ;
		mcFever._x = 256 ;
		mcFever._y = 4.5 ;
		mcFever.smc.gotoAndStop(if (fever) 100 else 1) ;
		
	}
	
	
	function initGame() {
		lifeLeader = Cs.LEADER_LIFE ;
		lifeFollowers = Cs.FOLLOWERS_LIFE ;
		difficulty = -1.0 ;
		fMult = 0 ;
		
		armyRepopTimer = Cs.repopArmyDelay ;
		army = new mt.flash.PArray() ;
		
		followRepopTimer = 0.0 ;
		
		toGrab = new mt.flash.PArray() ;
		
		var p = mdm.empty(DP_TRACES) ;
		p._x = 0 ;
		p._y = 0 ;
		

		
		plasma = new Plasma(p, 300, 300) ; 
		var bf = 1.03125 ;
		plasma.filters.push( new flash.filters.BlurFilter(bf, bf));
		plasma.root.blendMode = "overlay";
		
		waitPlasmaUpdate = 100 ;
		
		var startX = (Cs.mcw[1] - Cs.mcw[0]) / 2 ;
		var startY = (Cs.mch[1] - Cs.mch[0]) / 2 + Cs.mch[0] ;
		
		mcGroup = mdm.empty(DP_PLAYER) ;
		gdm = new mt.DepthManager(mcGroup) ;
		faceDown = true ;
		
		mcArmy = mdm.empty(DP_ARMY) ;
		adm = new mt.DepthManager(mcArmy) ;
		makeShadows();
		
		fever = false ;
		feverStock = 0 ;
				
		leader = new Follower(startX, startY) ;
		//KKApi.registerButton(leader.mc._clickMe._bBox) ;
		leader.mc._clickMe._visible = false ;
		
		mcStart = mdm.attach("mcStart", DP_FOLLOW) ;
		mcStart._x = startX ;
		mcStart._y = startY ;
		//KKApi.registerButton(mcStart) ;
		
		mcOver = mdm.empty(DP_OVER) ;
		mcOver.beginFill(0xFFFFFF, 0) ;
		mcOver.moveTo(Cs.mcw[0], Cs.mch[0]) ;
		mcOver.lineTo(Cs.mcw[1], Cs.mch[0]) ;
		mcOver.lineTo(Cs.mcw[1], Cs.mch[1]) ;
		mcOver.lineTo(Cs.mcw[0], Cs.mch[1]) ;
		mcOver.lineTo(Cs.mcw[0], Cs.mch[0]) ;
		mcOver.endFill() ;
		
		
		//followers = [[null, null, null], [null, leader, null], [null, null, null]] ;
		var ef = new mt.flash.PArray() ;
		for (i in 0...3)
			ef.push(null) ;
		followers = new mt.flash.PArray() ;
		followers.push(ef) ;
		var lf = new mt.flash.PArray() ;
		lf.push(null) ;
		lf.push(leader) ;
		lf.push(null) ;
		followers.push(lf) ;
		ef = new mt.flash.PArray() ;
		for (i in 0...3)
			ef.push(null) ;
		followers.push(ef) ;
		
		
	
		setStart() ;
		
		KKApi.registerButton(mcOver) ;
		KKApi.registerButton(mcStart) ;

		step = Wait ;
	}
	
	
	public function setStart() {
		mcStart.onPress = callback(function(x : Game) {
			x.start() ;
			x.mcStart._x = -1000 ;
			x.mcStart._y = -1000 ;
			x.mcOver.onRollOut = x.setPause ;
		}, this) ;
	}
	
	
	public function setPause() {
		flash.Mouse.show() ;
		if (!flGameOver) {
			mdm.swap(mcStart, DP_START) ;
			mcStart._x = mcGroup._x ;
			mcStart._y = mcGroup._y ;
			step = Wait ;
			setStart() ;
		}
	}
	
	
	
	public function start() {
		flash.Mouse.hide() ;
		
		leader.setEffect(0, 2.3) ;
		
		bTimer.delta = {x : leader.x - root._xmouse, y : leader.y - root._ymouse} ;
		bTimer.update() ;
		step = Play ;
		
		if (difficulty < 0)
			difficulty = 0.0 ;
	}
	
	
	public function cheatDetected() : Bool {
		if (army != null && army.cheat)
			return true ;
		if (toGrab != null && toGrab.cheat)
			return true ;
		if (followers != null) {
			if (followers.cheat)
				return true ;
			for (tf in followers) {
				if (tf != null && tf.cheat)
					return true ;
			}
		}
			
		
		
		return false ;
	}
	
	
	public function update() {
		if (cheatDetected()) {
			//trace("cheat ! ")  ;
			KKApi.flagCheater() ;
		}
		
		/*if (Key.isDown(Key.CONTROL)) //DEBUG
			trace(BloodList.length + "    #     " + mt.Timer.fps() + " # " + mt.Timer.tmod) ;*/
		
		if (bTimer == null)
			bTimer = new BulletTimer() ;
		
		var haveFeverOver = false ;
		for (tf in followers) {
			for (f in tf) {
				if (f == null)
					continue ;
				
				if (f.feverOver != null)
					haveFeverOver = true ;
				f.update() ;
			}
		}
		
		updateFever() ;
		
		for (f in toGrab)
			f.update() ;
		
		if (difficulty >= 0)
			difficulty = difficulty + 1.4 * mt.Timer.tmod ;
		
		switch(step) {
			case Wait : 
				if (flGameOver) {
					KKApi.gameOver({}) ;
					step = GameOver ;
					return ;
				}
			
			case Play : 
				
				updateSprites() ;
			
				bTimer.update() ;
				if (step != Play || bTimer.outOfGround())
					return ;
				
				//#################### DEBUG
				/*if(Key.isDown(Key.SHIFT))
					debugPause = !debugPause ;
				if (debugPause)
					return ;*/
				//####################
				
				if (flGameOver) {
					KKApi.gameOver({}) ;
					step = GameOver ;
					return ;
				}
				
				if (!bTimer.isMoving())
					return ;
				
				updateMoves() ;
				updateArmyRepop() ;
				updateFollowRepop() ;

			case GameOver :
				updateArmyMove(mt.Timer.tmod) ; 
			
				checkDeath() ;
				updateArmyRepop() ;
		}
		
	}
	

	public function growGroup() {
		for (f in followers) {
			f.unshift(null) ;
			f.push(null) ;
		}
		
		var a = new mt.flash.PArray() ;
		var b = new mt.flash.PArray() ;
		for (i in 0...followers[0].length) {
			a.push(null) ;
			b.push(null) ;
		}
		followers.unshift(a) ;
		followers.push(b) ;
		
	}
	
	
	function updateLeader(p : Int, nb : Int) {
		if (p == 0 && bTimer.isRotating() || (fever && p == nb - 1)) {			
			var r = Cs.rotateMc(leader.mc, bTimer.x, bTimer.y, bTimer.lastX, bTimer.lastY) ;
			var doUnder = false ;
			if (r > 0) {
				if (faceDown) {
					doUnder = true ;
					faceDown = false ;
					
				}
			} else {
				if (!faceDown) {
					gdm.ysort(0) ;
					faceDown = true ;
				}
			}
			
			for (tf in followers) {
				for (f in tf) {
					if (f == null)
						continue ;
					f.mc._rotation = r ;
					
					if  (doUnder)
						gdm.under(f.mc) ;
					
					//if (fever) 
					f.checkFever() ;
				}
			}
			
		}
		
		leader.moveTo(bTimer.lastX + (bTimer.x - bTimer.lastX) / nb * (p + 1), bTimer.lastY + (bTimer.y - bTimer.lastY) / nb * (p + 1)) ;
	}
	
	
	function checkDeath(?last = false) {		
		for (a in army) {
			if (!a.mc._bBox.hitTest(mcGroup))
				continue ;
			
			for (tf in followers) {
				for (i in 0...tf.length) {
					var f = tf[i] ;
					if (f == null || f.shield != null)
						continue ;
					if (fever) {
						if (a.mc._bBox.hitTest(f.mc._bBox)) {
							a.explose() ;
							break ;
						}
						/*if (f.feverOver == null && a.mc._bBox.hitTest(f.mc._bBox)) {
							a.block() ;
							f.setFever(a) ;
						}	*/
					} else { //kill
						if (a != f.feverOver && a.mc._bBox.hitTest(f.mc._bBox)) {
							a.setProutch() ;
							killFollower(f, a) ;
							if (f != leader)
								tf[i] = null ;
						}
					}
				}
			}
		}
		
		return lifeLeader <= 0 || lifeFollowers <= 0 ;
	}
	
	
	public function killFollower(f : Follower, ?a : Army) {
		var scroutch = mdm.attach("bloodPart", DP_BLOOD) ;
		scroutch.gotoAndStop(Std.random(scroutch._totalframes)+1);
		scroutch.smc.gotoAndStop(1) ;
		
		scroutch._xscale = 150 ;
		scroutch._yscale = 150 ;
		var side = Std.random(2) * 2 - 1 ;
		if (a != null) {
			switch(a.typeDir) {
				case 0 : scroutch._rotation = -90 + side * Std.random(10) ;
				case 1 : scroutch._rotation = -10 + side * Std.random(10) ;
				case 2 : scroutch._rotation = 90 + side * Std.random(10) ;
				case 3 : scroutch._rotation = 180 + side * Std.random(10) ;
			}
		} else 
			scroutch._rotation = 180 + side * Std.random(10) ;
		var pos = f.getRootPos() ;
		scroutch._x = pos.x ;
		scroutch._y = pos.y ;
		var p = new Phys(scroutch) ;
		p.fadeType = 6 ;
		p.fadeLimit = Cs.TRACE_FADE ;
		p.timer = Cs.TRACE_TIMER * 2 ;
		
		Game.BloodList.push(p) ;
		
		
		downFever(Cs.FEVER_LOSE_PER_KILL - Std.random(2)) ;
		
		if (f == leader) {
			leader.kill() ;
			setGameOver() ;
			lifeLeader = 0 ;
			mcLifeLeader._alpha = 25 ;
		} else {
			lifeFollowers-- ;
			fMult-- ;
			
			if (lifeFollowers <= 0)
				setGameOver() ;
			
			f.kill() ;
			mcLifeFollowers[mcLifeFollowers.length - 1].gotoAndStop(2);
			mcLifeFollowers.pop() ;
		}
		
	}
	
	function checkGrabs() {
		for (g in toGrab) {
			
			var found = false ;
			for (tf in followers) {
				for (f in tf) {
					if (f == null)
						continue ;
					
					var c = if (fMult < 5) 
							f.mc._clickMe._bBox ;
						else
							f.mc._bBox ;
					
					if (g.mc._bBox.hitTest(c)) {
						g.grabbed() ;
						found = true ;
						break ;
					}
				}
				
				if (found) 
					break ;
			}
			
			
		}
	}
	
	
	function updateSprites() {
		var list =  Sprite.spriteList.copy() ;
		for(sp in list)sp.update() ;
	}
	
	
	function updateBloodAnim(mod : Float) {
		var fps = Cs.FPS ;
		for(b in BloodList) {
			if (b == null || b.root == null)
				continue ;
			
			
			var c = b.root.smc._currentframe ;
			var tot = b.root.smc._totalframes ;
			
			if (c == null || c >= tot)
				continue ;
			
			var nf = Std.int(fps * mod) ;
			
			if (nf  + c < tot)
				b.root.smc.gotoAndStop(nf + c) ;
			else {
				b.root.smc.gotoAndStop(tot) ;
			}
		
		}
	}
	
	
	function updateExplosionAnim(mod : Float) {
		var fps = Cs.FPS / 30 ;
		var list = Game.ExplosionList.copy() ; 
		for (e in list) {
			var c = e._currentframe ;
			var nf = Std.int(fps * mod) ;
			
			var tot = e._totalframes ;
			
			if (nf  + c < tot)
				e.gotoAndStop(nf + c) ;
			else {
				Game.ExplosionList.remove(e) ;
				e.removeMovieClip() ;
			}
			
		}
	}
	
	
	function updateArmyRepop() {
		if (army.length > Cs.ARMY_MAX) {
			return ;
		}
		
		var armyMax = difficulty * 0.0032 - 0.15 ;
		
		armyRepopTimer = Math.max(0.0, armyRepopTimer - 1.0 * mt.Timer.tmod) ;
		if (armyRepopTimer > 0.0)
			return ;
		
		var rand = if (armyMax > 0.3 && Std.random(25) == 0) 1 else 0 ; 
			
		var l = army.length ;
		for (a in army) {
			if (a.travelDone(140))
				l -= if (Std.random(3) > 0) 1 else 0 ;
		}
		
		if (l < armyMax + rand) {
			new Army(Std.int(armyMax - 1)) ;
			armyRepopTimer = Cs.repopArmyDelay + (Std.random(2) * 2 - 1) * Cs.repopArmyDelay / (Std.random(2) + 1) ; // [0, Cs.repopDelay * 2]
		}
	}
	
	
	public function updateFollowRepop(?force = false) {
		if (toGrab.length > Cs.GRAB_MAX)
			return ;
		
		if (toGrab.length > 0 && Std.random(Std.int(Math.max(200, 5000 - difficulty))) > 0)
			return ;
		
		if (!force) {
			followRepopTimer = Math.max(0.0, followRepopTimer - 1.0 * mt.Timer.tmod) ;
			if (followRepopTimer > 0.0)
				return ;
		}
				
		var f = new Follower() ;
		followRepopTimer = Cs.repopFollowDelay ;
	}
	
	
	function updateArmyMove(mod) {
		for (a in army)
			a.resetMoveFlag() ;
		
		for (a in army.copy())
			a.update(mod) ;
		
		updateBloodAnim(mod) ;
		updateExplosionAnim(mod) ;
		updatePlasma(mod) ;
	}
	
	
	function updateMoves() {
		var d = bTimer.getDist() ;
		var nb = Std.int(Math.max(1, d / 14)) ;
		var mod = mt.Timer.tmod + d * 0.035 ;
	
		var dead = false ;
		for (i in 0...nb) {
			if (lifeLeader > 0)
				updateLeader(i, nb) ;
			
			for (a in army)
				a.resetMoveFlag() ;
		
			for (a in army.copy())
				a.update(mod / nb * (i + 1)) ;
			
			dead = dead || checkDeath(i == nb - 1) ;
			
			if (!dead)
				checkGrabs() ;
		}
		
		updateBloodAnim(mod) ;
		updateExplosionAnim(mod) ;
		updatePlasma(mod) ;
	}
	
	
	
	function updatePlasma(mod : Float) {
		if (plasma == null)
			return ;
		
		waitPlasmaUpdate = Math.max(0, waitPlasmaUpdate - 30.0 * mt.Timer.tmod) ;
					
		if (waitPlasmaUpdate == 0) {
			plasma.update() ;
			waitPlasmaUpdate = 100.0 ;
		}		
	}
	
	
	public function setGameOver() {
		flGameOver = true ;
	}
	
	
	public function addScore(sc) {
		KKApi.addScore(sc) ;
	}
	
	
	public function resetFever() {
		if (!fever)
			return ;
		fever = false ;
		mcGroup.filters = [] ;
		mcFever.filters = [] ;
		Col.setPercentColor(mcGroup,0,0xFFFFFF) ;
		
		feverStock = 0 ;
		mcFever.smc.gotoAndStop(1) ;		
		
		for (tf in followers) {
			for (f in tf) {
				if (f == null)
					continue ;
				f.shield = Cs.GRAB_SHIELD ;
			}
		}
		
	}
	
	
	public function downFever(?by : Int = 100) {
		if (fever)
			return ;
		
		feverStock = Std.int(Math.max(0, feverStock - by)) ;
		mcFever.smc.gotoAndStop(feverStock + 1) ;
	}
	
	
	public function addToFever(x : Int) {
		if (fever)
			return ;
		
		var fMax = KKApi.val(Cs.FOLLOW_POINTS) ;
		var fLimit = Std.int(fMax / 8 * 1) ;
		if ( x <= fLimit)
			return ;
		var fp = 0.0 ;
		fp = if (x > fMax / 16 * 15) //750
					3
				else if (x > fMax / 8 * 7) // 700
					2.6
				else if (x > fMax / 8 * 6) //600
					1.75
				else if (x > fMax / 8 * 5) //500
					1.4
				else if (x > fMax / 8 * 4) //400
					1.15
				else if (x > fMax / 8 * 3) //300
					0.8
				else if (x > fMax / 8 * 2) //200
					0.65 ;
				else if (x > fMax / 8 * 1) //100 //only active with enough people
					0.35 ;
				
		var old = fp ;
		fp = Std.int(fp * (1 + fMult * 0.01715)) ;
				
		//trace(fp + " # " + x + " # " + fMult) ;
				
		feverStock = Std.int(Math.min(feverStock + fp, 100)) ;
		//trace("stock " + feverStock) ;
		mcFever.smc.gotoAndStop(feverStock + 1) ;
		if (feverStock >= 100)
			startFever() ;
	}
	
	
	public function startFever() {
		fever= true ;
		mcFever.smc.gotoAndStop(100) ;
		feverTimer = 100.0 ;
		feverFlash = 0 ;
		feverGlow = 0.0 ;
	}
	
	
	public function updateFever() {
		if (!fever)
			return ;
		var flashy = true ;
		var warningLimit = 30 ;
		
		var col = Col.objToCol( Col.getRainbow(Math.random())) ;
		
		feverTimer = Math.max(0.0, feverTimer - 0.365 * mt.Timer.tmod) ;
		if (feverTimer < warningLimit) {
			var frame = Std.int(warningLimit / 10 * feverTimer) + 1 ;
			mcFever.smc.gotoAndStop(frame) ;
			feverFlash = (feverFlash + 1) % 6 ;
			flashy = feverFlash > 3 ;
			col = feverLastCol ;
		}
			
		//mcGroup.filters = [] ;
		feverGlow += 0.13 ;
		var ga = Math.abs(Math.sin(feverGlow)) ;
		new flash.filters.GlowFilter(0xffffff, ga,8,8,2) ;
		
		mcFever.filters = [new flash.filters.GlowFilter(0xFF0000, ga,10,10,3) ] ; 
		mcGroup.filters = [new flash.filters.GlowFilter(col, ga, 10,10,3)] ;
		//Filt.glow(mcGroup, 8, 1, 0xFFFFFF) ;
		
		if (flashy) {
			Col.setPercentColor(mcGroup,60,col) ;
		} else
			Col.setPercentColor(mcGroup,0,col) ;
		feverLastCol = col ;
		
		if (feverTimer == 0)
			resetFever() ;
		

	}
	
	
	//######## DEBUG ONLY
	//#################
	/*
	function initKeyListener() {
		var kl = {
			onKeyDown:callback(onKeyPress),
			onKeyUp:callback(onKeyRelease)
		}
		flash.Key.addListener(kl) ;
	}
	
	public function onKeyRelease() {
		var n = flash.Key.getCode() ;
		switch(n) {
			case flash.Key.SPACE :
				feverStock = 100 ;
				mcFever.smc.gotoAndStop(feverStock + 1) ;
				if (feverStock >= 100)
					startFever() ;
			case 97 : //1
				new Army(0, 0) ;
				
			case 98 : //2
				new Army(0, 1) ;
			case 99  : //3
				new Army(0, 2) ;
			case 100 : //4
				new Army(0, 3) ;
			case 101 : //5
				new Army(0, 4) ;
			setPause() ;
		}
	}
	
	
	public function onKeyPress() {
		var n = Key.getCode() ;
		
		if (Key.isDown(Key.SHIFT)) {
			trace(n) ;
		}
	}*/
	
	
	public function makeShadows() {
		mcGroup.filters = [
			new flash.filters.GlowFilter(0x000033, 2,2,2,3),
			new flash.filters.DropShadowFilter(5,75,0x000033,5, 5,5,0.6)
			] ;
		mcArmy.filters = [
			new flash.filters.GlowFilter(0x000033, 2,2,2,3),
			new flash.filters.DropShadowFilter(5,75,0x000033,5, 5,5,0.6)
			] ;	
		
	}
	
}



