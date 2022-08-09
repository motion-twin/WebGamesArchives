import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Lib;
//import mt.bumdum.Plasma;



typedef Pos = {x : Int, y : Int}


enum Step {
	Play ;
	Charge ;
	Explode ;
	Fall ;
	GameOver ;
}


class Game {

	public static var FL_DEBUG = true ;

	public static var DP_BG = 0 ;
	public static var DP_SHADE = 1 ;
	public static var DP_GOALS = 4 ;
	public static var DP_TILES = 5 ;
	public static var DP_SCORING = 6 ;
	public static var DP_ANIM = 7 ;
	public static var DP_FX = 8 ;
	public static var DP_POINTS = 9 ;

	public static var DP_AMBIANT = 15 ;


	public var step:Step ;
	public var flGameOver : Bool ;
	public var dm:mt.DepthManager ;
	public var root:flash.MovieClip ;
	public var bg:flash.MovieClip ;
	public var mcScoring : {>flash.MovieClip, _t : {>flash.MovieClip, _pts : flash.TextField, _mult : flash.TextField}} ;
	static public var me:Game ;

	public var board : Array<Array<Tile>> ;
	public var goals : Array<Array<Goal>> ;

	var start : Tile ;
	public var links : List<Tile> ;
	public var toExplode : List<Tile> ;
	public var toKill : List<Tile> ;
	public var toApply  : Array<{t : Tile, d : Int }> ;


	var timer : mt.flash.Volatile<Float>;

	public var explode : Array<mt.flash.Volatile<Int>> ;
	public var explosionCount : mt.flash.Volatile<Int>;
	public var combo : mt.flash.Volatile<Int>;

	public var falls : Array<Int> ;

	public var lockTile : Bool ;

	public var mcTime : {>flash.MovieClip, _timeLeft : flash.MovieClip, start : Float} ;
	public var cTile : Tile ;




	public function new( mc : flash.MovieClip ) {
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;

		root = mc ;
		me = this ;
		dm = new mt.DepthManager(root) ;
		flGameOver = false ;

		explode = [0, 0] ;
		explosionCount = 0 ;
		links = new List() ;

		initBg() ;
		initGoals() ;
		initBoard() ;
		initTime() ;
		initPlay() ;
	}


	function initBg() {
		var bg = dm.attach("mcBg", DP_BG) ;
		bg._x = 0 ;
		bg._y = 0 ;

		mcScoring = cast dm.attach("scoring", DP_SCORING) ;
		mcScoring._x = Cs.mcw ;
		mcScoring._y = Cs.mch - 20 ;

		mcScoring._t._pts.embedFonts = true;
		mcScoring._t._mult.embedFonts = true;

		var format = new flash.TextFormat() ;
		format.font = "TexasLED" ;
		mcScoring._t._pts.setTextFormat(format) ;
		mcScoring._t._mult.setTextFormat(format) ;

		mcScoring.gotoAndStop(1) ;


		/*var ambiant = dm.attach("ambiance", DP_AMBIANT) ;
		ambiant._x = 0 ;
		ambiant._y = 0 ;
		ambiant.blendMode = "add" ;
		ambiant._alpha = 50 ;
		ambiant.gotoAndStop(1) ;*/

	}


	function initTime() {
		mcTime = cast Game.me.dm.attach("timeLine", Game.DP_GOALS) ;
		mcTime.start = flash.Lib.getTimer() ;
		mcTime._x = Cs.TIME_X ;
		mcTime._y = Cs.TIME_Y ;

	}


	public function parse(tile : Tile, from : Int, checkState : Int) {
		if (tile.parsed)
			return ;

		tile.parsed = true ;
		if (checkState == Cs.PARSE_IN)
			links.add(tile) ;

		switch (checkState) {
			case Cs.PARSE_IN :  tile.setIn() ;
			case Cs.PARSE_LIGHT :  tile.setIn() ;
			case Cs.PARSE_OUT : tile.setOut() ;
		}

		for(i in 0...4) {
			if (Tile.sMod(i + 2, 4) == from)
				continue ;

			var neighbour = getNeighbour(i, tile.pos) ;

			if (checkState == Cs.PARSE_IN && isGoal(tile, i)) {
				var side = if (tile.pos.x == 0) 0 else 1 ;
				goals[side][tile.pos.y].activate(checkState) ;
			}

			if (neighbour == null)
				continue ;

			var neighbourIn = Tile.sMod(i + 2, 4) ;
			if (!(tile.pipes[i] && neighbour.pipes[neighbourIn])) //no link
				continue ;

			parse(neighbour, i, checkState) ;
		}
	}


	public function isGoal(tile : Tile, dir : Int) {
		return ((tile.pos.x == Cs.BOARD_WIDTH - 1 && dir == Cs.EAST && tile.pipes[dir]) || (tile.pos.x == 0 && dir == Cs.WEST && tile.pipes[dir])) ;
	}


	public function resetLinks() {
		links = new List() ;
	}

	
	public function check(?t : Tile) {
		lock() ;
		resetParsing(true) ;
		for(t in board[0]) {
			if (!isConnected()) {
				resetLinks() ;
				resetExplode() ;
				resetGoalsActivation() ;
			}

			if (t.checkEdge(Cs.WEST)) {
				var mode =  if (isConnected()) Cs.PARSE_LIGHT else Cs.PARSE_IN ;
				goals[0][t.pos.y].activate(mode) ;
				parse(t, Cs.EAST, mode) ;
			} else
				goals[0][t.pos.y].shutdown() ;
		}


		if (!isConnected())
			resetExplode() ;

		for(t in board[Cs.BOARD_WIDTH - 1]) {
			if (t.checkEdge(Cs.EAST)) {
				if (goals[1][t.pos.y].toExplode)
					continue ;
				goals[1][t.pos.y].activate(Cs.PARSE_OUT) ;
				parse(t, Cs.WEST, Cs.PARSE_OUT) ;
			} else
				goals[1][t.pos.y].shutdown() ;
		}


		if (isConnected()) {
			combo++ ;
			start = t ;
			initCharge() ;
			return true ;
		}
		unlock() ;
		return false ;

	}


	public function isLocked() {
		return lockTile || flGameOver ;
	}


	public function lock() {
		lockTile = true ;
	}


	public function unlock() {
		lockTile = false ;
	}


	public function getNeighbour(i : Int, p : Pos) : Tile {
		switch (i) {
			case Cs.EAST : return board[p.x + 1][p.y] ;
			case Cs.SOUTH : return board[p.x][p.y + 1] ;
			case Cs.WEST : return board[p.x - 1][p.y] ;
			case Cs.NORTH : return board[p.x][p.y - 1] ;
			default : throw "unknown direction" ;
		}
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


			case Charge :
					timer -= 200 * mt.Timer.tmod ;
					if (timer <= 0) {
						if (linksDone()) {
							timer = null ;
							initExplode() ;
						} else
							next(function (t, i) { return t.charge(i) ; }) ;
					}

			case Explode :
					timer -= 400 * mt.Timer.tmod ;
					if (timer <= 0) {
						if (linksDone()) {
							timer = null ;
							finishExplode() ;
							step = Fall ;
							initFall() ;
						} else
							next(function (t, i) { return t.explode(i) ; }) ;
					}

			case Fall : if (!fallDone())
						return ;
					if (!check())
						initPlay() ;

			case GameOver : updateGameOver() ;

			default:
		}

		updateTime() ;
	}


	function updatePlay() {

	}


	function updateSprites() {
		var list =  Sprite.spriteList.copy() ;
		for(sp in list)sp.update() ;
	}


	//CHARGE

	function initCharge() {
		step = Charge ;

		toExplode = new List() ;
		toKill = new List() ;
		for (t in links) {
			toExplode.push(t) ;
			toKill.push(t) ;
		}

		timer = 100 ;
		if (start == null) {
			start = links.first() ;
			toApply  = links.first().charge(Cs.WEST) ;
		} else
			toApply  = start.charge() ;

	}


	function next(f : Tile -> Int -> Array<{t : Tile, d : Int}>) {
		if (toApply == null || toApply.length == 0) {
			resetLinks() ;
			return ;
		}

		timer= 100 ;

		var t = toApply .copy() ;
		toApply  = new Array() ;
		for (e in t) {
			var newTiles = f(e.t, e.d) ;
			for (n in newTiles) {
				if (!Lambda.exists(toApply , function(x) { return x.t == n.t ; }))
					toApply .push(n) ;
			}
		}
	}


	function linksDone() {
		return links == null || links.length == 0 ;
	}





	//### EXPLOSION


	function initExplode() { //explode board and give points
		step = Explode ;
		explosionCount++ ;

		links = new List() ;
		for (t in toExplode) {
			links.add(t) ;
		}

		timer = 100 ;
		toApply  = start.explode() ;

	}


	public function finishExplode() {
		resetFall() ;
		start = null ;

		mcScoring._t._pts.text = Std.string(KKApi.val(KKApi.cmult(KKApi.cmult(Cs.GOAL_POINTS, KKApi.const(getExplosions())), KKApi.const(Cs.COMBO_MULT[Game.me.combo])))) ;
		mcScoring._t._mult.text = "x" + Std.string(getExplosions()) ;
		mcScoring.gotoAndPlay(1) ;

		while(toKill.length > 0) {
			var t = toKill.pop() ;
			t.destroy() ;
			falls[t.pos.x]++ ; //count holes in each column
		}

		for (side in goals) {
			for(g in side) {
				g.unLight() ;
				if (g.toExplode)
					g.explode() ;
			}
		}

	}



	//### FALL

	function resetFall() {
		falls = new Array() ;
		for (i in 0...Cs.BOARD_WIDTH) {
			falls.push(0) ;
		}
	}


	function initFall() { //create and check next board validity
		resetParsing(true) ;
		var checked = false ;
		var newTiles = null ;
		var easyMode = false ;

		var s = flash.Lib.getTimer() ;

		while (!checked) {
			newTiles = makeNewTiles(easyMode) ;
			checked = testBoard() ;
			if (!checked) {
				Lambda.map(newTiles, function(t) { t.kill() ;}) ;
				easyMode = true ;
			}
		}
	}


	function makeNewTiles(easyMode : Bool) { //create new tiles in board holes
		var res = new List() ;
		for (i in 0...Cs.BOARD_WIDTH) {
			var f = falls[i] ;
			var y = -50 ;
			for (j in 0...f) {
				var t = new Tile(Tile.getRandomCase(easyMode), Std.random(4), {x : i, y : f - j - 2}, y) ;
				board[i].insert(0, t) ;
				res.add(t) ;
				y -= Cs.TILE_SIZE ;
			}
		}
		return res ;
	}


	function fallDone() {
		for (b in board) {
			for (t in b) {
				if (t.isFalling())
					return false ;
			}
		}
		return true ;
	}


	function initBoard() {
		cTile = new Tile(0, 0, {x : -10, y : -10}) ;
		cTile.setIn() ;

		board = new Array() ;
		for(i in 0...Cs.BOARD_WIDTH) {
			board[i] = new Array() ;
			for(j in 0...Cs.BOARD_HEIGHT) {
				var t = Tile.getRandomCase(if (i == Cs.BOARD_WIDTH - 1) [Cs.TILE_3, Cs.TILE_4] else [Cs.TILE_4]) ;
				var dir = if (i == Cs.BOARD_WIDTH - 1) Tile.getBlockedDirection(t) else Std.random(4) ;
				var e = new Tile(t, dir, {x : i, y : j}) ;
				board[i][j] = e ;
				e.updatePipe() ;
			}
		}

		//trace first green links
		for(t in board[0]) {
			if (t.checkEdge(Cs.WEST)) {
				goals[0][t.pos.y].activate() ;
				parse(t, Cs.EAST, Cs.PARSE_IN) ;
			} else
				goals[0][t.pos.y].shutdown() ;
		}
		resetParsing() ;
	}


	function initGoals() {
		goals = new Array() ;

		for (j in 0...2) {
			goals[j] = new Array() ;
			for(i in 0...Cs.BOARD_HEIGHT) {
				var g = new Goal() ;
				g.setPos(j, i) ;
				goals[j].push(g) ;
			}
		}
	}


	function resetGoalsActivation() {
		for (j in 0...2) {
			for(i in 0...Cs.BOARD_HEIGHT) {
				goals[j][i].toExplode = false ;

			}
		}
	}

	public function resetParsing(?unlink : Bool) {
		resetExplode() ;
		for (b in board) {
			for (t in b) {
				t.parsed = false ;
				if (unlink)
					t.resetState() ;
			}
		}
	}


	function resetExplode() {
		explode = [0, 0] ;
	}


	function initPlay() {
		step = Play ;
		combo = 0 ;
		unlock() ;
	}



	// GAMEOVER
	function initGameOver(){
		lock() ;
		flGameOver = true ;
	}


	function updateGameOver() {

	}


	function updateTime() { //update TimeLine && check gameover
		var now = flash.Lib.getTimer() ;

		var c= Cs.PLAY_TIME - (now - mcTime.start) ;

		if (c > 0) {
			mcTime._timeLeft._xscale = c / Cs.PLAY_TIME * 100 ;
		} else
			initGameOver() ;

		//TIME PARTS
		var nb = 1 + Std.random(3) ;
		var drop = {x  : Cs.TIME_X + mcTime._timeLeft._width - 1  , y : mcTime._timeLeft._height} ;
		for (i in 0...nb) {
			var mc = dm.attach("part1", DP_FX) ;
			mc._xscale = 40 ;
			mc._yscale = 40 ;
			Col.setColor(mc, 0x2AB9D6) ;
			mc.blendMode = "add" ;

			var s = new Phys(mc) ;
			s.x = drop.x ;
			s.y = Cs.TIME_Y + i * (drop.y /nb) ;
			s.weight = -0.2 ;
			s.alpha = 90 ;
			s.vx = Math.random() * 4 ;
			s.vy = Math.random() * 1  ;
			s.fadeType = 5 ; //alpha
			s.timer = 5 ;
		}
	}





	// TOOLS
	public function addScore(sc) { //pr ajouter au score du joueur
		KKApi.addScore(sc);
		var score = KKApi.val(sc);

		//TODO

	}


	//### TEST PARSING

	public function parseTest(tile : Tile, from : Int) : Bool {
		if (tile.parsed)
			return false ;

		tile.parsed = true ;
		var entries = Cs.TEST_PARSING[tile.tile] ;


		for(e in entries) {
			var dir = Tile.sMod(from + e, 4) ;

			var neighbour = getNeighbour(dir, tile.pos) ;

			if (neighbour == null) {
				if (isTestGoal(tile, from)) {
					return true ;
				} else
					continue ;
			}

			var res = parseTest(neighbour, Tile.sMod(dir + 2, 4)) ;
			if (res)
				return true ;
		}

		return false ;
	}


	function isTestGoal(tile : Tile, from : Int) {
		if (tile.pos.x != Cs.BOARD_WIDTH - 1)
			return false ;

		var entries = Cs.TEST_PARSING[tile.tile] ;
		for(e in entries) {
			var dir = Tile.sMod(from + e, 4) ;
			if (dir == Cs.EAST)
				return true ;
		}
		return false ;
	}



	function testBoard() {
		for(t in board[0]) {
			resetParsing() ;
			if (parseTest(t, Cs.WEST))
				return true ;
		}
		return false ;
	}


	public function getExplosions() : Int {
		return explode[0] + explode[1] ;
	}


	public function isConnected() : Bool {
		return explode[0] > 0 && explode[1] > 0 ;
	}


	//EXPLODE PARTS
	static public function parts(x : Float, y : Float) {
		var nb = 5 ;
		var dsx = 10 ;
		var dsy = 10 ;

		for (i in 0...nb) {
			var mc = Game.me.dm.attach("part1", Game.DP_FX) ;
			var size = 20 + Std.random(4) * 10 ;
			mc._xscale = size ;
			mc._yscale = size ;

			Col.setColor(mc,0xFFFFFF) ;
			mc.blendMode = "add" ;

			var s = new Phys(mc) ;
			s.x = x  + (Math.random() * 2 -1) * dsx ;
			s.y = y + (Math.random() * 2 -1) * dsy ;
			s.weight = (Math.random() * 2 -1) + 0.8 ;
			s.alpha = 90 ;
			s.vx = (Math.random() * 2 -1) * 10 ;
			s.vy = (Math.random() * 2 -1) * 10 ;
			s.fadeType = 5 ; //alpha
			s.timer = 10 ;
		}
	}

}



























