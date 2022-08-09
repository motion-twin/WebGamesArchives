import mt.bumdum.Phys;
import mt.bumdum.Lib;
import Game.Pos ;
import Game.Step ;


enum TStatus {
	Nothing ;
	Rotate ;
	Charge ;
	OverCharge ;
	Explode ;
	Fall ;
}


class Tile extends Phys {

	public var tile : Int ;
	public var d : Int ;
	public var pos : Pos ;
	//public var bonus : Int ;
	public var isIn : Bool ;
	public var isOut : Bool ;
	public var pipes : Array<Bool> ;

	public var state : TStatus ;

	public var r : Float ;
	public var coef : Float ;
	public var gCoef : Float ;
	public var pY : Float ;
	public var fallTimer : Float ;
	public var parsed : Bool ;
	public var mc : flash.MovieClip ;


	public function new(t : Int, dir : Int, p : Pos, ?fallingFrom : Int) {

		this.tile = t ;
		this.d = dir ;
		this.pos = p ;
		isIn = false ;
		isOut = false ;
		pipes = new Array() ;
		gCoef = 0 ;

		state = if (fallingFrom != null) Fall else Nothing ;

		parsed = false ;

		mc = Game.me.dm.attach("tile", Game.DP_TILES) ;
		//mc._bg._over._visible = true;
		mc._x = Cs.BOARD_X + pos.x * Cs.TILE_SIZE ;
		mc._y = if (fallingFrom != null) fallingFrom else (getMcY()) ;

		mc._xscale = 100 ;
		mc._yscale = 100 ;

		mc.smc.gotoAndStop(t + 1) ;
		mc.smc.smc.gotoAndStop(1) ;
		mc._rotation = d * 90 ;
		super(mc) ;

		updatePipe() ;
		activate() ;

		if (fallingFrom != null)
			setFalling() ;
	}


	public function rotate() {
		if (Game.me.isLocked())
			return ;
		Game.me.lock() ;
		Game.me.dm.swap(mc,Game.DP_ANIM);
		r = d * 90 ;
		coef = 0 ;
		state = Rotate ;
		mc._xscale = 120;
		mc._yscale = 120;
	}

	public function rotateDone() {
		//resetState() ;
		state = Nothing ;
		d = Tile.sMod(d+ 1, 4) ;
		updatePipe() ;

		if (tile == Cs.TILE_3 || !Game.me.check(this))
			Game.me.unlock() ;
		mc._xscale = 100;
		mc._yscale = 100;
		Game.me.dm.swap(mc,Game.DP_TILES) ;

		launchRotateParts() ;

		tileOut() ;
	}


	public function charge(?from : Int) : Array<{t : Tile, d : Int}> {
		Game.me.links.remove(this) ;

		state = Charge ;

		return getNeighbours(from, true) ;

	}


	function getNeighbours(?from : Int, ?glowGoals : Bool) {
		if (tile == Cs.TILE_4)
			return [] ;

		var res = new Array() ;

		for(i in 0...4) {
			if (Tile.sMod(i + 2, 4) == from)
				continue ;

			var neighbour = Game.me.getNeighbour(i, pos) ;

			if (glowGoals && neighbour == null && Game.me.isGoal(this, i)) {
				var s = if (pos.x == 0) 0 else 1 ;
				Game.me.goals[s][pos.y].charge() ;
			}


			if (Lambda.exists(Game.me.links, function(x) {return x == neighbour ; })) {
				res.push({t : neighbour, d : i}) ;
			}
		}

		return res ;
	}



	public function explode(?from : Int) {
		Game.me.falls[pos.x]++ ; //count holes in each column
		Game.me.links.remove(this) ;

		Game.me.mcTime.start += 100 ; //gain d'1/10 de seconde

		Game.parts(x, y) ;

		mc._visible = false ;
		return getNeighbours(from) ;

	}


	public function destroy() {
		for (t in Game.me.board[pos.x]) {
			if (t != null && t == this)
				break ;
			t.setFalling() ;
		}
		kill() ;
	}

	public function setFalling() {
		state = Fall ;
		pos.y++ ;
		fallTimer = flash.Lib.getTimer() ;
		pY = (getMcY() - y) ;
	}


	function getMcY() {
		return Cs.BOARD_Y + pos.y * Cs.TILE_SIZE ;
	}


	override public function update() {
		var m = mc.smc ;

		switch(state) {
			case Nothing : //nothing to do

			case Rotate :
				if (coef == 1)
					rotateDone() ;
				else {
					coef = Num.mm(0,coef+0.6*mt.Timer.tmod,1) ;
					r = d * 90 + coef * 90 ;
					mc._rotation = r ;
				}

			case Charge :

				Filt.glow(m, 10,2,0xFFFFFF) ;
				Filt.glow(m,2,2,0xFFFFFF, true) ;

				state = OverCharge ;

			case OverCharge :
				/*if (Game.me.step != Step.Explode && Std.random(4) == 0) {
					Filt.glow(m, 2,0.5,0xFFFFFF, Std.random(2) == 0) ;
				}*/

			case Explode :

			case Fall :
				pY -= mt.Timer.tmod * ((Cs.GRAVITY * (flash.Lib.getTimer() - fallTimer)) / 200) ;
				if( pY <= 0 ) {
					fallTimer = null ;
					state = Nothing ;
					pY = null ;
					y = getMcY() ;
				} else
					y = getMcY() - pY  ;
		}



		super.update() ;
	}


	public function activate() {
		root.onRollOver = tileOver ;
		root.onRollOut = tileOut ;
		root.onPress = rotate ;
		root.useHandCursor = true;
		KKApi.registerButton(root);
	}


	public function updatePipe() {
		switch (tile) {
			case Cs.TILE_0 : pipes = [true, false, true, false] ;
			case Cs.TILE_1 : pipes = [ false, false, true, true] ;
			case Cs.TILE_2 : pipes = [true, false, true, true] ;
			case Cs.TILE_3 : pipes = [true, true, true, true] ;
			case Cs.TILE_4 : pipes = [false, false, true, false] ;
		}
		if (tile != Cs.TILE_3)
			rotatePipe(d) ;
	}


	public function rotatePipe(?n : Int) {
		var r = if (n != null) n else 1 ;
		var old = pipes.copy() ;
		for(i in 0...old.length) {
			pipes[Tile.sMod(i + r, 4)] = old[i] ;
		}
	}


	public function checkEdge(from : Int) {
		if (from == Cs.WEST && pos.x == 0 && pipes[2]) { //board left
			setIn() ;
			return true ;
		} else if (from == Cs.EAST && pos.x == Cs.BOARD_WIDTH - 1 && pipes[0]) { //board right
			setOut() ;
			return true ;
		}
		return false ;
	}


	public function isPowered() : Bool {
		return isIn || isOut ;
	}


	public function setIn() {
		isIn = true ;
		updateState() ;
	}


	public function setOut() {
		isOut = true ;
		updateState() ;
	}


	public function isLinkage() : Bool {
		return isIn && isOut ;
	}


	public function isFalling() : Bool {
		return state == Fall ;
	}


	public function updateState() {
		var ns = null ;
		if (!isIn && !isOut)
			ns = 1 ;
		else if (isIn)
			ns = 2 ;
		else if (isOut)
			ns = 3 ;
		//if (ns != mc.smc.smc._currentframe) {
			mc.smc.smc.gotoAndStop(ns) ;
		//}
		if (this != Game.me.cTile)
			mc.smc.smc.smc.gotoAndPlay(Game.me.cTile.mc.smc.smc.smc._currentframe) ;
	}


	public function resetState() {
		isIn = false ;
		isOut = false ;
		updateState() ;
	}



	static public function sMod(n : Int,mod : Int){
		while(n >= mod) n -= mod ;
		while(n < 0) n += mod ;
		return n ;
	}


	static public function getBlockedDirection(c : Int) : Int {
		switch (c) {
			case Cs.TILE_4 : return Std.random(4) ; //impasse
			case Cs.TILE_3 : return 0 ; //croix
 			case Cs.TILE_2 : return 3 ; //T
			case Cs.TILE_1 : return if (Std.random(2) == 0) 0 else 3 ; //coude
			case Cs.TILE_0 : return 1 ; //ligne
			default : throw "unknown case" ;
		}
	}


	static public function getRandomCase(?except : Array<Int>, ?easyMode : Bool) : Int {
		var mod = 0 ;
		if (easyMode)
			mod = -3 ;
		else
			mod = Std.int(Math.min(Game.me.explosionCount / 2.5, 11)) ;

		var r = Std.random(100) ;
		var res = null ;
		if (r < 4 + mod)
			res = Cs.TILE_4 ; //impasse
		else if (r < 20)
			res = Cs.TILE_3 ; //croix
		else if (r < 40 - mod)
			res = Cs.TILE_2 ; //T
		else if (r < Std.int(70 - mod))
			res =  Cs.TILE_0 ; //ligne
		else
			res = Cs.TILE_1 ; //coude
		return if (except != null && except.remove(res)) (if (Std.random(2) == 0) Cs.TILE_0 else Cs.TILE_1) else res ;
	}


	public function tileOver() {
		if (Game.me.isLocked())
			return ;

		var glow:flash.filters.GlowFilter = new flash.filters.GlowFilter();
		glow.color = 0x2E95C0;
		glow.alpha = 1.8;
		glow.blurX = 10;
		glow.blurY = 10;
		glow.strength = 0.9;
		mc.filters = [glow];

		Game.me.dm.swap(mc,Game.DP_ANIM);
		/*mc._xscale = 120;
		mc._yscale = 120;*/
	}

	public function tileOut() {
		mc.filters = null;
		Game.me.dm.swap(mc,Game.DP_TILES);
		mc._xscale = 100;
		mc._yscale = 100;
	}


	override public function kill() {
		Game.me.board[pos.x].remove(this) ;

		super.kill() ;
	}




	//### PARTS


	function launchRotateParts() {
		//ROTATE PARTS
		var nb = 4 ;
		var dsx = 20 ;
		var dsy = 20 ;
		var px = x ;
		var py = y ;

		for (i in 0...4) {
			var n = Game.me.getNeighbour(i, pos) ;
			var neighbourIn = Tile.sMod(i + 2, 4) ;

			if ((n == null && !Game.me.isGoal(this, i)) || (n != null && (!(pipes[i] && n.pipes[neighbourIn]) || !(n.isPowered()))))
				continue ;


			switch (i) {
				case Cs.EAST :
					px = x + Cs.TILE_SIZE / 2 ;
					py = y ;
				case Cs.SOUTH :
					px = x ;
					py = y + Cs.TILE_SIZE / 2 ;
				case Cs.WEST :
					px = x - Cs.TILE_SIZE / 2 ;
					py = y ;
				case Cs.NORTH :
					px = x ;
					py = y - Cs.TILE_SIZE / 2 ;
			}
			px += (Math.random()*2 - 1) * 2 ;
			py += (Math.random()*2 - 1) * 2 ;


			for (i in 0...nb) {
				var mc = Game.me.dm.attach("part1", Game.DP_FX) ;
				mc._xscale = 40 ;
				mc._yscale = 40 ;

				var c = Cs.GREEN ;
				if (isLinkage())
					c = if (Std.random(2) == 0) Cs.GREEN else Cs.BLUE ;
				else
					c = if (isIn) Cs.GREEN else Cs.BLUE ;

				Col.setColor(mc, c) ;
				mc.blendMode = "add" ;

				var s = new Phys(mc) ;
				s.x = px  ;
				s.y = py  ;
				s.weight = 1 ;
				s.alpha = 80 ;
				s.vx = (Math.random() * 2 -1) * 5 ;
				s.vy = (Math.random() * 2 -1) * 7 ;
				s.fadeType = 5 ;
				s.timer =  10 ;
			}
		}
	}

}