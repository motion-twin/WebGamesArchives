import mt.bumdum9.Lib ;
using mt.bumdum9.MBut ;
import mt.bumdum9.Tools ;

import api.AKApi ;
import api.AKProtocol ;
import api.AKConst ;

#if sound
import mt.deepnight.Sfx;
#end

import TitleLogo ;


enum Step {
	S_Play ;
	S_Rot ;
	S_Grab ;
	S_Fall(grabAgain : Bool) ;
	S_Game_Over ;
}


typedef CGroup = {
	var id : Int ;
	var l : List<Slot> ;
}


class Game extends SP {

	//static var SBANK = Sfx.importDirectory("sounds");
	
	public static var DP_BG = 		0 ;
	//public static var DP_SCORE = 	1 ;
	public static var DP_STARS = 	2 ;
	public static var DP_STONES = 	3 ;
	public static var DP_EXIT = 	4 ;
	public static var DP_SLOTS = 	5 ;
	public static var DP_INTER = 	6 ;
	public static var DP_SCORE = 	7 ;
	public static var DP_FX = 		8 ;
	public static var DP_FG = 		9 ;
	public static var DP_CLICK =	10 ;

	public static var WIDTH = 600 ;
	public static var HEIGHT = 480 ;
	public static var STAGE_X = 120 ;
	public static var STAGE_Y = 35 ;
	public static var EXIT_DIST = 60 ;

	public static var DELTA_SELECT = 4 ;

	public static var COMBO_MULT = 0.8 ;
	public static var SHINE_WAIT = 10.0 ;

	public static var DIRS = [ [1, 0], [0, 1], [-1, 0], [0, -1] ] ;
	public static var SEL_DIRS = [ [0, 0], [1, 0], [1, 1], [0, 1] ] ;
	public static var STAGE_SIZE = 6 ;
	public static var COMBO_COUNT = 4 ;
	public static var PLAY_COUNT = [[10],
									[null, 13, 13, 13, 13, 13, 12, 12, 12, 12, 12, 11, 11, 11, 11, 11, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]] ;
	public static var PROGRESSION_SCORES = [null, 5000, 8000, 9500, 11000, 12500, 14000, 15500, 17000, 18500, 20000, 21500, 23000, 24500, 26000, 27500, 29000, 30500, 32000, 33500, 35000,
	/* NEWS - 18/04/14 */
	36500, 38000, 39500, 40500, 42000, 43500, 45000, 46500, 48000, 50000
	] ;
	public static var EXIT_STARTS = [[0, 1, 4, 5], [0, 2, 3, 5]] ;
	
	

	public static var me : Game ;
	var bg : SP ;
	var fg : SP ;


	public var dm : mt.DepthManager;
	public var fxm : mt.fx.Manager ;
	public var waitingFx : Int ;

	public var seed : mt.Rand ;
	
	var timer : Float ;
	public var level : Int ;
	var mode : GameMode ;
	//var score : AKConst ;
	var leftPlay : mt.flash.Volatile<Int> ;
	var maxPlay : mt.flash.Volatile<Int> ;
	var mcPlays : Array<MC> ;
	var toRefill : Array<Int> ;
	var comboCount : mt.flash.Volatile<Int> ;
	var playWithoutGrab : mt.flash.Volatile<Int> ;
	var shines : List<{id : Null<Int>, wait : Float}> ;
	public var falls : Array<Slot> ;

	public var step : Step ;

	public var grid : Array<Array<Slot>> ;
	public var allSlots : List<Slot> ;
	public var exits : Array<Exit> ;
	var curSelection : String ;
	public var selected : Array<Slot> ;

	public var avKPoints : Array<api.SecureInGamePrizeTokens> ;
	public var progLastKPoint : Null<Float> ;

	public var nextMudPart : Int ;

		
	public function new() {
		super();
		me = this ;
		level = 0 ;
		haxe.Log.setColor(0xFFFF00) ;
		haxe.Firebug.redirectTraces() ;

		nextMudPart = 80 + Std.random(80) ;
		
		seed = new mt.Rand(AKApi.getSeed()) ;
		mode = AKApi.getGameMode() ;
		level = AKApi.getLevel() ;
		//score = AKConst.make(0) ;
		playWithoutGrab = 0 ;
		selected = new Array() ;
		falls = new Array() ;
		curSelection = "" ;
		waitingFx = 0 ;

		leftPlay = switch(AKApi.getGameMode()) {
						case GM_PROGRESSION :
							PLAY_COUNT[1][AKApi.getLevel()] ;
						case GM_LEAGUE :
							PLAY_COUNT[0][0] ;
					} ;
		maxPlay = leftPlay ;

		avKPoints = api.AKApi.getInGamePrizeTokens().copy() ;
		progLastKPoint = 0.0 ;


		if (Type.enumEq(AKApi.getGameMode(), GM_PROGRESSION))
			AKApi.setStatusText("0/" + Std.string(PROGRESSION_SCORES[AKApi.getLevel()]) + " pts") ;


		toRefill = new Array() ;
		fxm = new mt.fx.Manager() ;
		dm = new mt.DepthManager(this) ;
		
		// BG
		bg = cast new gfx.Background() ;
		dm.add(bg, DP_BG) ;
		bg.cacheAsBitmap = true ;
	
	
		//ALPHA FG
		var bottomFg = new gfx.Foreground() ;
		dm.add(bottomFg, DP_FG) ;

		bottomFg._g0.gotoAndStop(rand(4) + 1) ;
		bottomFg._g0._pk.visible = false ;
		bottomFg._g1.gotoAndStop(rand(4) + 1) ;
		bottomFg._g1._pk.visible = false ;
		bottomFg._g2.gotoAndStop(rand(4) + 1) ;
		bottomFg._g2._pk.visible = false ;
		bottomFg._g3.gotoAndStop(rand(4) + 1) ;
		bottomFg._g3._pk.visible = false ;
		bottomFg._g4.gotoAndStop(rand(4) + 1) ;
		bottomFg._g4._pk.visible = false ;
		bottomFg.cacheAsBitmap = true ;

		
		fg = new SP() ;
		fg.graphics.beginFill(0xeeeeee, 0) ;
		fg.graphics.drawRect(0, 0, WIDTH, HEIGHT ) ;
		fg.useHandCursor = true ;
		dm.add(fg, DP_CLICK) ;
		fg.onClick(emitRotation) ;

		initStage() ;
		initInter() ;
		setStep(S_Play) ;
		#if sound
		sound(new sound.Music()).playLoop(0);
		#end
	}


	public function rand(n) : Int {
		return seed.random(n) ;
	}
	
	#if sound
	public function sound(s:flash.media.Sound) {
		return new Sfx(s);
	}
	#end


	function initInter() {
		mcPlays = new Array() ;

		for (i in 0...leftPlay) {
			var p = new gfx.Play() ;
			dm.add(p, DP_INTER) ;
			p.gotoAndStop(1) ;
			/*p.x = 20 + i * 30 ;
			p.y = 20 ;*/
			p.x = 25 ;
			p.y = 20 + i * 30 ;
			mcPlays.push(p) ;
		}
		
	}


	function initStage() {
		reset() ;
		comboCount = 0 ;
		allSlots = new List() ;
		exits = new Array() ;
		grid = new Array() ;
		var toCheck = new Array() ;
		for (x in 0...STAGE_SIZE) {
			grid[x] = new Array() ;
			for (y in 0...STAGE_SIZE) {
				grid[x][y] = new Slot(x, y) ;
				toCheck.push(grid[x][y]) ;
			}
		}

		for (i in EXIT_STARTS[rand(EXIT_STARTS.length)]) {
			var e = new Exit() ;
			grid[i][STAGE_SIZE - 1].setExit(e) ;
			exits.push(e) ;
		}

		shines = new List() ;
		for (i in 0...Stone.getMaxId())
			shines.add({id : i, wait : SHINE_WAIT + (Std.random(2) * 2 - 1 )* SHINE_WAIT / 2 }) ;
		//	shines.add({id : -1, wait : SHINE_WAIT}) ;


		//insert stones into grid
		insertStones(toCheck, 3) ;
		//remove automatic combos
		killAutoCombo(toCheck) ;
	}



	public function getCurProgression() : Float {
		switch(AKApi.getGameMode()) {
			case GM_PROGRESSION :
				return  AKApi.getScore() / PROGRESSION_SCORES[AKApi.getLevel()] ;

			case GM_LEAGUE : return 0.0 ;
		}
	}


	public function countAvKPoints() : Int {
		var c = 0 ;
		if (avKPoints.length == 0)
			return 0 ;

		switch(AKApi.getGameMode()) {
			case GM_PROGRESSION :
				if (progLastKPoint < getCurProgression())
					c++ ;

			case GM_LEAGUE :
				for (i in 0...avKPoints.length) {
					if (avKPoints[i].score.get() > api.AKApi.getScore())
						break ;
					c++ ;
				}
		}
		return c ;
	}


	public function getNextKPoint() {
		if (avKPoints.length == 0)
			return null ;

		if (isProgression())
			progLastKPoint = getCurProgression() ;

		return avKPoints.shift() ;
	}


	public function isProgression() {
		return Type.enumEq(mode, GM_PROGRESSION) ;
	}


	function countStones() : Int {
		var count = 0 ;
		for (s in allSlots) {
			if (s.stone != null && s.stone.isStone())
				count++ ;
		}
		return count ;
	}


	function insertStones(changeable : Array<Slot>, ?force = 0) {
		var weights = [20, 48, 30, 2] ;


		var nStones = force ;
		if (nStones == 0) {
			var canHave = randomProbs(weights) ;
			nStones = canHave - countStones() ;
		}
		nStones += Std.int(Math.round(playWithoutGrab / 10.0)) ;
		nStones = Std.int(Math.min(nStones, changeable.length)) ;

		while (nStones > 0) {
			var slot = changeable[Game.me.rand(changeable.length)] ;
			if (slot.stone.isStone() || slot.y == STAGE_SIZE - 1)
				continue ;
			slot.stone.setId(10) ;
			nStones-- ;
		}
	}


	function killAutoCombo(changeable : Array<Slot>) {
		while(true) {
			var groups = getGroups() ;
			var autoCombo = false ;
			for (g in groups) {
				if (g.l.length < COMBO_COUNT)
					continue ;
				autoCombo = true ;
				break ;
			}
			if (autoCombo) {
				for (s in changeable) {
					if (s.stone.isStone())
						continue ;
					s.stone.draw() ;
				}
			} else
				break ; //success
		}
	}


	function parse(from : Slot, into : List<Slot>) { //recurse function for getGroups
		from.group.l.push(from) ;
		for (d in DIRS) {
			var nx = from.x + d[0] ;
			var ny = from.y + d[1] ;
			if (nx < 0 || nx >= STAGE_SIZE || ny < 0 || ny >= STAGE_SIZE)
				continue ;
			var s = grid[nx][ny] ;
			if (s.group != null || s.stone == null || s.stone.isStone() || from.stone.id != s.stone.id)
				continue ;
			into.remove(s) ;
			s.group = from.group ;
			parse(s, into) ;
		}
	}


	function getGroups() : Array<CGroup> {
		resetGroups() ;
		var s = allSlots.filter( function(x : Slot) { return x.stone != null && !x.stone.isStone() ; }) ;
		var groups = new Array() ;

		while(s.length > 0) {
			var a = s.pop() ;
			a.group = {id : groups.length, l : new List()} ;
			groups.push(a.group) ;
			parse(a, s) ;
		}

		return groups ;
	}


	function resetGroups() {
		for (g in grid)
			for (s in g)
				s.killGroup() ;
	}


	function reset() {
		selected = new Array() ;
		if (allSlots != null) {
			for (s in allSlots)
				s.kill() ;
		}
		allSlots = null ;
		grid = null ;
	}


	public function setStep(s : Step) {
		switch(s) {
			case S_Play :
				if (leftPlay <= 0) {
					var win = switch(AKApi.getGameMode()) {
										case GM_PROGRESSION : AKApi.getScore() >= PROGRESSION_SCORES[AKApi.getLevel()] ;
										case GM_LEAGUE : true ;
									} ;
					AKApi.gameOver(win) ;
					s = S_Game_Over ;
				}

			default : //nothing to do
		}

		step = s ;

	}

	function getCurSelection() : String {

		var px = Std.int( ( mouseX - (STAGE_X + Slot.SIZE / 2) ) / Slot.SIZE ) ;
		var py = Std.int( ( mouseY - (STAGE_Y + Slot.SIZE / 2) ) / Slot.SIZE ) ;

		if (px < 0 || px > 4 || py < 0 || py > 4)
			return "" ;

		return Std.string((px + 1) * 10 + py) ;
	}


	function unselect() {
		for (s in selected.copy())
			s.unselect() ;
		curSelection = "" ;
	}


	function updateSelection(?force = false) {
		
		if (AKApi.isReplay())
			return ;


		var nsel = getCurSelection() ;
		if (nsel == curSelection && !force)
			return ;

		unselect();

		curSelection = nsel ;
		if (nsel == "") //out of grid
			return ;
			
		//roll over sur 4 blocs
		#if sound
		var s = [sound(new sound.Rocks_mouseover1()),sound(new sound.Rocks_mouseover2()),sound(new sound.Rocks_mouseover3()),sound(new sound.Rocks_mouseover4()),sound(new sound.Rocks_mouseover5()),sound(new sound.Rocks_mouseover6())];
		s[ Std.random(s.length) ].play();
		#end

		var s = getCurSelCoords() ;
		var firstSlot = null ;
		for (i in 0...4) {
			var slot = grid[s.x + SEL_DIRS[i][0]][s.y + SEL_DIRS[i][1]] ;
			slot.select(DIRS[i]) ;
			if (firstSlot == null)
				firstSlot = slot ;
		}


		var pnb = 3 + Std.random(3) ;
		var selPos = Slot.getStonePos(firstSlot.x, firstSlot.y) ;
		selPos.x += Std.int(Slot.SIZE / 2) ;
		selPos.y += Std.int(Slot.SIZE / 2) ;
		for (i in 0...pnb) {
			var star : SP = switch(Std.random(3)) {
						case 0 : cast new gfx.Sparkle() ;
						case 1 : cast new gfx.Sparkle2() ;
						case 2 : cast new gfx.Sparkle3() ;
					} ;
			Game.me.dm.add(star, Game.DP_FX) ;
			
			star.x = selPos.x + (Std.random(2) * 2 - 1) * (12 + Std.random(Std.int(Slot.SIZE / 2))) ;
			star.y = selPos.y + (Std.random(2) * 2 - 1) * (12 + Std.random(Std.int(Slot.SIZE / 2))) ;

			var p = new mt.fx.Part(cast star) ;
			p.fadeType = 1 ;
			p.timer = 15 ;
			p.weight = 0.2 ;
		}

	}


	public function getCurSelCoords(?sel : String) : {x : Int, y : Int } {
		if (sel == null && curSelection == "")
			return null ;

		var s = if (sel != null) sel else curSelection ;

		return { x : Std.parseInt(s.charAt(0)) - 1,
				 y : Std.parseInt(s.charAt(1)) } ;
	}


	public function getFreeExitSlots(?withoutIdx : Int) : Array<Slot> {
		var res = new Array() ;
		for (i in 0...STAGE_SIZE) {
			if (withoutIdx != null && i == withoutIdx)
				continue ;
			var s = grid[i][STAGE_SIZE - 1] ;
			if (s.exit == null)
				res.push(s) ;
		}
		return res ;
	}


	function spendPlay() {
		//#if debug
			//return ;
		//#end

		if (leftPlay <= 0)
			return ;

		leftPlay-- ;

		var cp = new gfx.Play() ;
		dm.add(cp, DP_FX) ;
		cp.x = mcPlays[leftPlay].x ;
		cp.y = mcPlays[leftPlay].y ;
		cp.gotoAndStop(1) ;
		var p = new mt.fx.Vanish(cp, 12, 12, true) ;
		p.curveIn(5) ;
			
	
		mcPlays[leftPlay].gotoAndStop(2) ;

		if (leftPlay >= maxPlay)
			mcPlays[leftPlay].visible = false ;
	}


	public function addPlay(n : Int) {
		for (i in leftPlay...(leftPlay + n) ) {
			if (i >= maxPlay) {
				if (mcPlays[i] == null) {
					var p = new gfx.Play() ;
					p.gotoAndStop(2) ;
					p.visible = false ;
					dm.add(p, DP_INTER) ;
					/*p.x = 20 + i * 30 ;
					p.y = 20 ;*/
					p.x = 25;
					p.y = 20 + i * 30 ;
					mcPlays[i] = p ;

				} /*else
					mcPlays[i].visible = true ;*/
			}


			var fade = new mt.fx.FadeTo(mcPlays[i], 0.08, 0, 0xFFFFFF) ;
			fade.curveInOut() ;
			fade.reverse() ;

			var sleep = new mt.fx.Sleep(fade,
									callback(function(mc : MC) {
										mc.gotoAndStop(1) ;
										mc.visible = true ;
										var pnb = 2 + Std.random(3) ;
										for (i in 0...pnb) {
											var star : SP = switch(Std.random(3)) {
														case 0 : cast new gfx.Sparkle() ;
														case 1 : cast new gfx.Sparkle2() ;
														case 2 : cast new gfx.Sparkle3() ;
													} ;
											Game.me.dm.add(star, Game.DP_FX) ;
											star.blendMode = flash.display.BlendMode.OVERLAY ;
									
											
											star.x = mc.x - Math.random() * mc.width / 1.5 ;
											star.y = mc.y + (Std.random(2) * 2 - 1) * (mc.height / 2) * Math.random() ;
											var p = new mt.fx.Part(cast star) ;
											p.fadeType = 4 ;
											p.timer = 8 + Std.random(12) ;

											p.frict = 1.10 ;
											p.vx = 0.15 + Std.random(3) / 10.0 ;


											//p.weight = -0.15 ;
											p.sleep(Std.random(3)) ;
										
										}
									}, mcPlays[i]),
									(i - leftPlay) * 1) ;

		}

		leftPlay += n ;
	}


	function emitRotation() {
		if (AKApi.isReplay() || !Type.enumEq(step, S_Play) || curSelection == "")
			return ;

		 AKApi.emitEvent(Std.parseInt(curSelection)) ;
	}


	function startRotation(selId : Int) {

		spendPlay() ;
		
		var s = getCurSelCoords(Std.string(selId)) ;


		if (AKApi.isReplay())
			selected = new Array() ;

		for (i in 0...4) {
			var slot = grid[s.x + SEL_DIRS[i][0]][s.y + SEL_DIRS[i][1]] ;
			if (AKApi.isReplay())
				selected.push(slot) ;
			slot.rotate(i) ;
		}

		setStep(S_Rot) ;
		
		//fais tourner les blocs
		//SBANK.rocks_rotate().play();
		#if sound
		sound(new sound.Rocks_rotate()).play();
		#end
	}


	public function rotationDone() {
		var newOrder = Lambda.array(Lambda.map(selected, function(s : Slot) { return s.stone ; } )) ;
		newOrder.unshift(newOrder.pop()) ;

		for (i in 0...selected.length)
			selected[i].setStone(newOrder[i]) ;

		comboCount = 0 ;
		updateSelection(true) ;
	}


	function getCombos() : { has : Bool, toDestroy : List<CGroup>, toGrab : List<Exit> } {
		var res = { toDestroy : Lambda.filter(getGroups(), function(x : CGroup) { return x.l.length >= COMBO_COUNT ; } ),
					toGrab : Lambda.filter(exits, function(e : Exit) { return e.slot.stone != null && e.slot.stone.isStone() ; } ),
					has : false } ;
		res.has = res.toDestroy.length > 0 || res.toGrab.length > 0 ;
		return res ;
	}

	
	function update(render:Bool) {
		fxm.update() ;

		var rid = AKApi.getEvent() ;
		if (rid != null)
			startRotation(rid) ;

		for (s in allSlots)
			s.update() ;

		for (s in falls)
			s.fall() ;


		if (render) {
			nextMudPart-- ;
			if (nextMudPart < 0)
				addMudParts() ;
		}
			

		switch(step) {
			case S_Play :
				updateShine() ;
				updateSelection() ;

			case S_Rot : //nothing to do, waiting for anim end
				updateShine() ;

				if (waitingFx > 0)
					return ;
				resetWait() ;
				rotationDone() ;

				var combos = getCombos() ;

				if (combos.toGrab.length > 0)
					playWithoutGrab = 0 ;
				else
					playWithoutGrab++ ;

				if (!combos.has)
					setStep(S_Play) ;
				else {
					startGrab(combos.toDestroy, combos.toGrab) ;
					setStep(S_Grab) ;
				}
			

			case S_Grab :
				if (waitingFx > 0)
					return ;
				resetWait() ;
				startFall() ;

				var combos = getCombos() ;

				if (!combos.has) {
					startRefill() ;
					setStep(S_Fall(false)) ;
				} else
					setStep(S_Fall(true)) ;

			case S_Fall(grabAgain) :
				if (falls.length > 0)
					return ;
				resetWait() ;

				if (grabAgain) {
					var combos = getCombos() ;
					comboCount++ ;
					startGrab(combos.toDestroy, combos.toGrab) ;
					setStep(S_Grab) ;
				} else
					setStep(S_Play) ;

			case S_Game_Over :


		}
		
		

		/*AKApi.addScore( AKConst.make(1) );
		score ++ ;
		AKApi.setProgression(score / 500) ;
		
		if(score > 500) {
			onWin() ;
		}*/
		
	}


	function updateShine() {
		var sh = shines.pop() ;
		sh.wait -= 0.1 ;
		if (sh.wait > 0.0) {
			shines.push(sh) ;
		} else {
			if (sh.id != null) {
				for (sl in allSlots) {
					if (sl.stone.id == sh.id)
						sl.setShine() ;
				}
			}

			sh.wait = SHINE_WAIT + (Std.random(2) * 2 - 1 )* SHINE_WAIT / 2 ;
			shines.add(sh) ;
		}

	}

	
	public function waitDone() {
		waitingFx-- ;
	}


	function resetWait() {
		waitingFx = 0 ;
	}


	function resetRefill() {
		toRefill = new Array() ;
		for (x in 0...STAGE_SIZE) {
			toRefill[x] = 0 ;
			for (y in 0...STAGE_SIZE) {
				if (grid[x][y].stone == null)
					toRefill[x]++ ;
			}
		}
	}


	public function addScore(s : Int) {
		var sc = api.AKApi.const(s) ;
		api.AKApi.addScore(sc) ;
	//	score = AKConst.make(s + score.get()) ;

		switch(AKApi.getGameMode()) {
			case GM_PROGRESSION :
				var score = AKApi.getScore();
				AKApi.setProgression( getCurProgression() ) ;

				AKApi.setStatusText(Std.string(score) + "/" + Std.string(PROGRESSION_SCORES[AKApi.getLevel()]) + " pts") ;
				//trace("progression score : "+score);


			case GM_LEAGUE : //nothing to do
		}
	}


	function startGrab(toDestroy : List<CGroup>, toGrab : List<Exit>) {
		unselect() ;
		resetRefill() ;

		for (g in toDestroy) {
			var scorePerStone = Std.int(g.l.first().stone.getPoints() * (1.0 + COMBO_MULT * comboCount) * toDestroy.length) ;
			//trace("combocount : "+comboCount+", toDestroy : "+toDestroy.length);
			#if sound
			switch(Std.int(comboCount)) {
				
				case 0:
					switch(toDestroy.length) {
						case 1 : sound(new sound.Blocks_X4L1()).play();
						default : sound(new sound.Blocks_XXL1()).play();
					}
				case 1:
					switch(toDestroy.length) {
						case 1 : sound(new sound.Blocks_X4L2()).play();
						default : sound(new sound.Blocks_XXL2()).play();
					}
				default:
					switch(toDestroy.length) {
						case 1 : sound(new sound.Blocks_X4L3()).play();
						default :sound(new sound.Blocks_XXL3()).play();
					}
			}
			#end

			addScore( Std.int(g.l.length * scorePerStone ) ) ;
			for (s in g.l) {
				s.prepareScore(scorePerStone) ;

				var fl = new mt.fx.Flash(s.stone.mc) ;
				fl.glow(4, 20) ;

				var fx = new mt.fx.Vanish(s.stone.mc, 14, 12) ;
				fx.setFadeScale(1, 1) ;
				fx.curveInOut() ;

				fx.onFinish = callback(function(x : Slot, sps : Int) { x.vanishStone(sps) ;  Game.me.waitDone() ;  }, s, scorePerStone ) ;

				var sleep = new mt.fx.Sleep(fx, callback(function(x : MC) { x.gotoAndPlay(1) ; }, s.stone.mc._stone), rand(6)) ;

				waitingFx++ ;
				toRefill[s.x]++ ;
			}
		}

		for (g in toGrab) {
			var nx = g.slot.stone.mc.x + g.dir[0] * EXIT_DIST ;
			var ny = g.slot.stone.mc.y + g.dir[1] * EXIT_DIST ;
			waitingFx++ ;
			toRefill[g.slot.x]++ ;

			new mt.fx.Flash(g.slot.exit.mc) ;
						

			var fTube = new mt.fx.Grow(g.slot.exit.mc, 0.15, 1.25) ;
				
			
			dm.over(g.slot.exit.mc) ;
			fTube.curveInOut() ;
			fTube.onFinish = callback(function(s : Slot, nx, ny) {
					var fx = new mt.fx.Tween(s.stone.mc, nx, ny, 0.125) ;
					fx.onFinish = callback(function(x : Slot) {
						x.removeStone() ; /* Game.me.waitDone() ; */
						x.exit.proc() ;
						
						//pierre dans gobelet
						#if sound
						var s : Sfx;
						switch(g.fx) {
							case Ex_Play_2:
								s = sound(new sound.Blackrock_life2());
							case Ex_Play_3:
								s = sound(new sound.Blackrock_life3());
							case Ex_Play_5:
								s = sound(new sound.Blackrock_life4());
							case Ex_Play_8:
								s = sound(new sound.Blackrock_life4());
							case Ex_Points_1:
								s = sound(new sound.Blackrock_points1());
							case Ex_Points_2:
								s = sound(new sound.Blackrock_points2());
							case Ex_Points_3:
								s = sound(new sound.Blackrock_points2());
							default :
								s = sound(new sound.Blackrock_points2());
						}
						s.play();
						#end
						
					}, s) ;
				}, g.slot, nx, ny) ;
		}
	}


	function startFall() {
		/*trace("##### pre fall") ;
		for (y in 0...STAGE_SIZE) {
			var l = "" ;
			for (x in 0...STAGE_SIZE) {
				l += "[" + (if (grid[x][y].stone != null) Std.string(grid[x][y].stone.id) else "n") + "] " ;
				
			}
			trace(l) ;
		}*/
		
		//nouvelles pierres tombent
		if(toRefill.length > 0) {
			//var s = [sound(new sound.Rock_fall1()),sound(new sound.Rock_fall2()),sound(new sound.Rock_fall3()),sound(new sound.Rock_fall4()),sound(new sound.Rock_fall5()),sound(new sound.Rock_fall6()),sound(new sound.Rock_fall7()),sound(new sound.Rock_fall8()),sound(new sound.Rock_fall9()),];
			//s[Std.random(s.length)].play();
		}

		for (x in 0...toRefill.length) {
			if (toRefill[x] == 0)
				continue ;

			var y = STAGE_SIZE - 1 ;
			var count = 0 ;
			while(y > 0) {
				if (grid[x][y].stone == null) {
					var sy = y ;
					var dy = y - 1 ;
					while (dy >= 0) {
						if (grid[x][dy].stone != null) {
							grid[x][sy].setStone(grid[x][dy].stone, false) ;
							grid[x][dy].stone = null ;
							grid[x][sy].setFall(count * 2) ;
							count++ ;

							sy-- ;
						}
						dy-- ;
					}
				}
				y-- ;
			}
		}
	}

	function startRefill() {
		var toCheck = new Array() ;

		for (x in 0...toRefill.length) {
			if (toRefill[x] == 0)
				continue ;

			var nStones = new Array() ;
			var delta = rand(20) ;
			for (i in 0...toRefill[x]) {
				var st = new Stone(true) ;
				grid[x][i].setStone(st, false) ;
				toCheck.push(grid[x][i]) ;
				st.mc.x = Slot.getStonePos(x, i).x ;
				st.mc.y = -5 - delta - (toRefill[x] - i) * (Slot.SIZE + 50) ;
				grid[x][i].setFall() ;
				grid[x][i].stone.isNew = true ;
			}
		}

		insertStones(toCheck) ;
		killAutoCombo(toCheck) ;


		var haveAvKPoint = Game.me.countAvKPoints() ;
		if (haveAvKPoint == 0)
			return ;

		while (haveAvKPoint > 0 && toCheck.length > 0) {
			var choice = toCheck[rand(toCheck.length)] ;
			toCheck.remove(choice) ;
			if (choice.stone.isStone())
				continue ;

			choice.stone.setPK() ;
			haveAvKPoint-- ;
		}
	}


	function addMudParts() {

		nextMudPart = 70 + Std.random(70) ;

		var n = 1 ;
		var nb = Std.random(10) ;
		if (nb < 2)
			n += 2 ;
		else if (nb < 5)
			n += 1 ;

		var minX = 40 ;
		var bigDone = 0 ;

		for (i in 0...n) {
			var sp = new gfx.MudPart();
			sp.gotoAndStop(Std.random(5) + 1) ;
			sp.scaleX = (Std.random(2) == 0) ? 1.0 : -1.0 ;
			sp.rotation = Std.random(100) ;

			dm.add(sp, DP_FX) ;


			var p = new mt.fx.Part(sp) ;
			p.x = minX + Std.random(WIDTH - minX * 2) ;
			p.y = -50 - Std.random(250) ;

			sp.x = p.x ;
			sp.y = p.y ;

			p.weight = 0.92 + Math.random() * 0.1 ;

			p.timer = 300 ;
			p.fadeType = 1 ;
			p.vr = (2.0 + Math.random() * 20) * (Std.random(2) * 2 - 1) ;


			var size = Std.random(40) + bigDone ;
			if (size == 0) {
					sp.scaleX = sp.scaleY = 5.0 ;
					Filt.blur(sp, 5, 5) ;
					bigDone++ ;
			} else if (size <= 9) { //8
					sp.scaleX = sp.scaleY = 2.0 ;
					p.weight = 1.0 + Math.random() ;
			}

			if (n > 0)
				new mt.fx.Sleep(p, null, 30 * n + Std.random(30)) ;
		}
	}
	
	
	public function onWin() {
		AKApi.gameOver(true);
	}


	static public function randomProbs(t : Array<Int>) : Int {
		var n = 0 ;
		for(e in t) {
		    n += e ;
		}
		n = Game.me.rand(n) ;
		var i = 0 ;
		
		while( n >= t[i]) {
			n -= t[i] ;
			i++ ;
		}
		
		return i ;
	}
	

	
}












