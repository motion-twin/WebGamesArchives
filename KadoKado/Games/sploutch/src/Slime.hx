import mt.bumdum.Phys ;
import mt.bumdum.Sprite ;
import mt.bumdum.Lib ;
import Game.Pos ;



class Slime {

	static public var MAX_GROW = 4 ;

	public var grow : Int ;
	public var pos : Pos ;
	public var bonus : Bool ;
	public var wait : Float ;

	public var mc : flash.MovieClip ;
	public var mcBonus : flash.MovieClip ;



	public function new(p : Pos) {
		grow = 1 ;
		pos = p ;
		bonus = false ;

		mc = Game.me.sdm.attach("slime", 3) ;
		setSkin() ;
		var p = Cs.getPos(pos, true) ;
		mc._x = p.x ;
		mc._y = p.y ;
		mc._alpha = Cs.ALPHA_SLIME ;
		mc._xscale = (Std.random(2) * 2 - 1) * 100 ;


		mc.onRollOver = callback(function(mc : flash.MovieClip) {
								mc._xscale = 110 ;
								mc._yscale =mc._xscale ;
							}, this.mc) ;
		mc.onRollOut =  callback(function(mc : flash.MovieClip) {
								mc._xscale = 100 ;
								mc._yscale =mc._xscale ;
							}, this.mc) ;
		mc.onRelease = touch ;
		mc.useHandCursor = true;
		KKApi.registerButton(mc);
	}


	public function addBonus() {
		if (bonus)
			return ;

		bonus = true ;
		growTo(0) ;

		mcBonus = Game.me.sdm.attach("playBonus", 3) ;
		var p = Cs.getPos(pos, true) ;
		mcBonus._x = p.x ;
		mcBonus._y = p.y ;

	}


	public function toExplode() : Bool {
		return grow > 4 ;
	}


	public function growTo(l) { //for level init
		grow = l ;
		setSkin() ;
	}


	public function growing() {
		if (bonus) {
			explode() ;
			return ;
		}

		grow++;
		setSkin() ;

		if (bigEnough())
			explode() ;
	}


	public function ungrowing() : Bool {
		if (wait != null && wait > 0) {
			wait-- ;
			return false ;
		}

		var oldG = grow ;
		grow = 0 ;

		pSmoke() ;

		if (grow <= 0) {
			grow =0 ;

			var mcExplode = Game.me.dm.attach("burn", Game.DP_ANIM) ;
			mcExplode._x = mc._x ;
			mcExplode._y = mc._y ;
			mcExplode._xscale = Cs.SCALE_SLIME[oldG - 1] ;
			mcExplode._yscale = mcExplode._xscale ;


			setSkin() ;

			//Game.me.incExplode(pos) ;

			Game.me.slimes.remove(this) ;

			Game.me.addScore(Cs.SPOUT_POINTS) ;
		}
		return true ;
	}


	public function setSkin() {
		if (grow > 0)
			mc.gotoAndStop(grow) ;
		else
			mc.gotoAndStop(5) ;
	}


	public function bigEnough() : Bool {
		return grow > MAX_GROW ;
	}


	public function touch() {
		if (Game.me.isLocked() || Game.me.checkEnd() || bonus)
			return ;
		Game.me.lock() ;

		Game.me.downPlay() ;

		if (grow > 0) { //growing
			grow++ ;

			if (bigEnough()) {
				Game.me.initSploutch(this) ;
				return ;
			}
			mc.gotoAndStop(grow) ;

		} else {  //flame
			Game.me.toReduce = new mt.flash.PArray() ;
			for(s in Game.me.slimes) {
				if (s.grow == 0)
					continue ;
				if (isAdjacent(s.pos)) {
					s.wait = Std.random(7) ;
					Game.me.toReduce.push(s) ;
				}

				if (Game.me.toReduce.length == 8)
					break ;
			}

			Game.me.initBombing(pos) ;
			return ;
		}

		Game.me.setPlay() ;
	}


	public function explode() {
		if (!bigEnough() && !bonus)
			return ;

		var mcExplode = null ;

		if (bonus) {
			Game.me.getBonus(pos) ;

			var mcExplode = Game.me.dm.attach("bExplod", Game.DP_ANIM) ;
			mcExplode._x = mc._x ;
			mcExplode._y = mc._y ;
			/*if (bonus)
				Col.setPercentColor(mcExplode, 100, Cs.BONUS_COLOR) ; */
			pBonus() ;
		} else  {
			Game.me.incExplode(pos) ;
			var points = KKApi.cadd(Cs.SPOUT_POINTS, KKApi.cmult(KKApi.const(Game.me.explosion), Cs.SPOUT_CHAIN)) ;
			Game.me.addScore(points) ;

			var mcExplode = Game.me.dm.attach("explode", Game.DP_ANIM) ;
			mcExplode._x = mc._x ;
			mcExplode._y = mc._y ;
		}



		grow = 0 ;
		mc.gotoAndStop(5) ;
		Game.me.slimes.remove(this) ;

		if (!bonus)  {
			Drop.launch(pos) ;
		} else  {
			mcBonus.removeMovieClip() ;
			bonus = false ;
		}
	}


	public function kill() {
		mc.removeMovieClip() ;

		Game.me.allSlimes.remove(this) ;
		Game.me.slimes.remove(this) ;
	}


	public function isAdjacent(p : Pos) : Bool {
		if (p == null)
			return false ;
		return Math.abs(p.x - pos.x) <= 1 &&  Math.abs(p.y - pos.y) <= 1 ;
	}


	static public function getRandomGrow(l : Int) : Int {
		var r = Std.random(100) ;

		var mod = Math.floor(l * 2) ;
		var g = 0 ;

		var caps = [23, 38, 55, 81] ;

		if (r < caps[0] - Std.int(mod / 2))
			g = 0 ;
		else if (r < caps[1] - Std.int(mod / 2))
			g = if (l == 0) 2 else (if (l > 10) Std.random(2) + 1 else 1) ;
		else if (r <  caps[2] + mod)
			g = if (l > 10) Std.random(2) + 1 else 2 ;
		else if (r < caps[3] + mod)
			g = 3 ;
		else
			g = 4 ;
		return g ;
	}



	//### PARTS
	public function pBonus() {
		var nb = 10 + Std.random(5)  ;
		var dsx = 20 ;
		var dsy = 20 ;
		var p = Cs.getPos(pos, true) ;
		var px = p.x ;
		var py = p.y ;
		var vr = 0 ;

		for (i in 0...nb) {
			var mc = Game.me.dm.attach("partLight", Game.DP_PARTS) ;

			var a = (i+Math.random())/nb *6.28 ;
			var ca = Math.cos(a) ;
			var sa = Math.sin(a) ;
			var sp = 0.5+Math.random()*10 ;

			var dx = ca*sp + 0.4 ;
			var dy = sa*sp + 0.4 ;

			var s = new Phys(mc) ;
			s.root.blendMode = "add" ;
			var sc = 40 + Std.random(60) ;
			s.root._xscale = sc ;
			s.root._yscale = sc ;

			s.x = px ;
			s.y = py ;
			s.frict = 0.9;
			s.vx = dx ;
			s.vy = dy ;
			s.fadeType = 5 ;
			s.timer =  10 + Std.random(10) ;

			if (Sprite.spriteList.length - 81 > 40 && i > 3)
				break ;
		}

	}


	public function pSmoke() {
		var nb = 10 + Std.random(5)  ;
		var dsx = 20 ;
		var dsy = 20 ;
		var p = Cs.getPos(pos, true) ;
		var px = p.x ;
		var py = p.y ;
		var vr = 0 ;

		for (i in 0...nb) {
			var mc = Game.me.dm.attach("partSmoke", Game.DP_PARTS) ;

			var dx = (Math.random() * 2 -1) * (Math.random() * 1) ;
			var dy =  -1 ;

			var s = new Phys(mc) ;
			s.root.gotoAndStop(1) ;
			s.root._alpha = 20 + Std.random(40) ;
			s.x = px ;
			s.y = py ;
			s.weight = -0.2 ;
			//s.frict = 0.90 ;
			s.vx = dx ;
			s.vy = dy ;
			s.vr = (Std.random(2) * 2 -1) * Math.random() * 50 ;
			s.fadeType = 5 ;
			s.timer =  10 + Std.random(10) ;
			s.sleep = Std.random(10) ;

			if (Sprite.spriteList.length - 81 > 40 && i > 3)
				break ;
		}
	}




}
