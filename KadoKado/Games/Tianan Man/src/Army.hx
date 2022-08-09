import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import mt.bumdum.Lib ;

enum MoveStep  {
	Move ;
	Explode ;
}

class Army {
	
	static var BASE_SPEED = [0.44, 0.60, 0.32, 0.79, 0.25] ;
	static var POP_PROBS = [600, 400, 250, 100, 50] ;
	static var MAX_BLOCK  =400 ;
	static var SPEED_MULT= 5.8 ;
	static var DELTA_TRACE = 5.0 ;
	static var BLOOD_TIMER = 100 ;
	static var PROUTCH_SLOW = 0.2 ;
	static var ANIM_FRAMES = [	{id : "drive", start : 1, frames : 40, next : "drive"}, 
							{id : "break", start : 42, frames : 1, next : "drive"}] ;
	
	static var WEAPON_LEVEL = 2 ;
	static var WEAPON_LIMIT_START_ANG = [60, 120] ;
	static var WEAPON_MAX_DELTA_ANG = 25 ;
	static var WEAPON_RANGE = {min : 2.6, max : 4.0} ;

	
	static public var PLACES = [[{l : null, t : [Cs.mcw[0], Cs.mcw[1]]}], [{l : null, t : [Cs.mch[0], Cs.mch[1]]}]] ;
	
	public var level : mt.flash.Volatile<Int> ;
	public var mc : {>flash.MovieClip, _p : {>flash.MovieClip, _weapon : flash.MovieClip}, _bBox : flash.MovieClip, _bBoxMove : flash.MovieClip} ;
	public var x : mt.flash.Volatile<Float> ;
	public var y : mt.flash.Volatile<Float> ;
	public var typeDir : mt.flash.Volatile<Int> ;
	public var dir : Array<Int> ;
	public var lastTrace : Array<Float> ;
	public var place : {l : Array<Army>, t : Array<Float>} ; //save place taken in static tab PLACES
	public var blood : {leftTimer : Float, rightTimer : Float} ; //0 : all, 1 : left, 2 : right
	public var proutchTimer : mt.flash.Volatile<Float> ;
		
	public var cAnim : {id :String, start : Int, frames : Int, next : String} ; 
	
	var weaponTimer : mt.flash.Volatile<Float> ;
	var weaponStep : mt.flash.Volatile<Int> ;
	var weaponInfos : {ang : Float, fromAng : Int, toAng : Int, target : {>flash.MovieClip, _field : flash.TextField}, bomb : flash.MovieClip, bsx : Float, bsy : Float} ;
	
	
	var warning : flash.MovieClip ;
	var warningTimer : Float ;
		
	public var speed : mt.flash.Volatile<Float> ;
		
	var step : MoveStep ;
	var timer : Float ;
	var subStep : Int ;
	
	var creationTime : Float ;
	var moved : Bool ;
	var blocked : {nb : Int, by : Army} ;
	
	
	
	public function new(diff : Int, ?forceLevel : Int) {
		var hide = Cs.HIDE_START ;
		
		step = Move ;
		subStep = 0 ;
		timer = 0 ;
				
		blocked = null ;
		moved = false ;
		proutchTimer = null ;
		creationTime = Date.now().getTime() ;
		
		blood = {leftTimer : null, rightTimer : null} ;
		
		cAnim = ANIM_FRAMES[0] ;
		
		typeDir = Std.random(4) ;
		var i = 0 ;
		var found = false ;
		mc = cast Game.me.adm.attach("army", 0) ;
		mc._p.gotoAndStop(cAnim.start) ;
		
		/*mc.onRelease = callback(function(x : Army) {
						trace("clic on " + Std.string(x) + " # " + Std.string(x.blocked)) ;
					}, this) ;	*/
					
		while (!found) {
			//level = Std.random(Std.int(Math.min(diff + 1, BASE_SPEED.length)) - i) ;
			level = if (forceLevel != null) forceLevel else Cs.randomProbs(POP_PROBS.slice(0, Std.int(Math.min(diff + 1, POP_PROBS.length)) - i)) ;
			//speed = BASE_SPEED[level] ;
			speed = 0.1 ;
			mc.gotoAndStop(level + 1) ;
			
			i++ ;
			
			var p = findPlace(typeDir, this) ;
			
			if (p == null) {
				if (i > 2)
					break ;
				if (typeDir == 0 || typeDir == 2)
					typeDir = Std.random(2) * 2 + 1 ;
				else
					typeDir = Std.random(2) * 2 ; 
				continue ;
			}
			
			found = true ;
			
			warning = Game.me.mdm.attach("warning", Game.DP_WARNING) ;
			warningTimer = 100 ;
			var warningDelta = 4 ;
			switch(typeDir) {
				case 0 : //from north
					dir = [0, 1] ;
					mc._rotation = -90 ;
					x = p ;
					y = Cs.mch[0] -hide ;
					var c = getCenter() ;
					warning._rotation = -90 ;
					warning._x = c.x ;
					warning._y = Cs.mch[0] + warningDelta ;
				case 1 : //from east
					dir = [-1, 0] ;
					mc._rotation = 0 ;
					x = Cs.mcw[1] + hide ;
					y = p ;
					var c = getCenter() ;
					warning._rotation = 0 ;
					warning._x = Cs.mcw[1] - warningDelta ;
					warning._y = c.y ;
				case 2 : //from south
					dir = [0, -1] ;
					mc._rotation = 90 ;
					//mc._p._yscale = -100 ;
					x = p + mc._width ;
					y = Cs.mch[1] + hide ;
					var c = getCenter() ;
					warning._rotation = 90 ;
					warning._x = c.x ;
					warning._y = Cs.mch[1] - warningDelta ;
				case 3 : //from west 
					dir = [1, 0] ;
					mc._rotation = 180 ;
					//mc._p._yscale = -100 ;
					x = Cs.mcw[0] -hide ;
					y = p + mc._height ;
					var c = getCenter() ;
					warning._rotation = 180 ;
					warning._x = Cs.mcw[0] + warningDelta ;
					warning._y = c.y ;				
			}
		}
		
		if (!found) {
			kill() ;
			//trace("#################################### NOT FOUND ") ;
			return ;
		}
		
		mc._x = x ;
		mc._y = y ;
		
		if (level == WEAPON_LEVEL)
			initWeapon() ;
		
		Game.me.army.push(this) ;
		
		
		
		
		//trace("new army : " + level + " # " + diff) ;
	}
	
	
	public function setProutch() {
		if (proutchTimer != null)
			return ;
		proutchTimer = 0 ;
		speed -= PROUTCH_SLOW ;
	}
	
	function getStart() : Float {
		switch(typeDir) {
				case 0 : //from north
					return Cs.mch[0] -Cs.HIDE_START ;
				case 1 : //from east
					return  Cs.mcw[1] + Cs.HIDE_START ;
				case 2 : //from south
					return Cs.mch[1] + Cs.HIDE_START ;
				case 3 : //from west 
					return Cs.mcw[0] -Cs.HIDE_START ;
				default : return null ;
			}
	}
	
	
	function initWeapon(?inGame = false) {
		if (travelDone(65.0)) {
			if (weaponInfos.target != null)
				weaponInfos.target.removeMovieClip() ;
			weaponInfos = null ;
			return ;
		}
		
		weaponTimer = 100 ;
		weaponStep = 0 ;
		
		var left = false ;
		var right = false ;
		var t = [] ;
		var fromAng = 0 ;
		var sway = 1 ;
		if (inGame) {
			fromAng = Std.int(mc._p._weapon._rotation) ;
			if (fromAng == 0)
				fromAng = 1 ;
			sway = Std.int((fromAng / Math.abs(fromAng)) * (if (Math.abs(fromAng) > (WEAPON_LIMIT_START_ANG[1] - WEAPON_LIMIT_START_ANG[0] + WEAPON_LIMIT_START_ANG[0]) / 2) -1 else 1)) ;
			//trace("new sway " + fromAng + " ==> " + sway) ;
		} else {
			var pc = 0.6 ;
			var wd = mc._p._weapon._width ;
			var minPlace = WEAPON_RANGE.max * wd * pc ;
			switch (typeDir) {
				case 0 :
					right = x - Cs.mcw[0] >= minPlace ;
					left =  Cs.mcw[1] - x >= minPlace ;
				case 1 :
					right = y - Cs.mch[0] >= minPlace ;
					left =  Cs.mch[1] - y >= minPlace ;
				case 2 :
					left = x - Cs.mcw[0] >= minPlace ;
					right = Cs.mcw[1] - x >= minPlace ;
				case 3 :
					left = y - Cs.mch[0] >= minPlace ;
					right = Cs.mch[1] - y >= minPlace ;
			}
			
			
			
			if (left)
				t.push([WEAPON_LIMIT_START_ANG[0], WEAPON_LIMIT_START_ANG[1], -1]) ;
			if (right)
				t.push([WEAPON_LIMIT_START_ANG[0], WEAPON_LIMIT_START_ANG[1], 1]) ;
			
			
			if (t.length == 0)
				return ;
			
			var r = t[Std.random(t.length)] ;
			fromAng = Std.int((r[0] + Std.random(r[1] - r[0])) * r[2]) ;
			sway = r[2] * (if (Math.abs(fromAng) > (WEAPON_LIMIT_START_ANG[1] - WEAPON_LIMIT_START_ANG[0]) / 2 + WEAPON_LIMIT_START_ANG[0]) -1 else 1) ;
				
			
			//trace("minPlace " + minPlace + " # " + x + ", " + y + " ==>" + left + " / " + right + " ==> " + fromAng + " -- " + sway) ;
		}
		
		
		weaponInfos = {ang : 0.0, fromAng : fromAng, toAng : fromAng + (sway *  (10 + Std.random(Std.int(WEAPON_MAX_DELTA_ANG - 10)))), target : null, bomb : null, bsx : null, bsy : null} ;
		
		mc._p._weapon._rotation = fromAng ;
	
	}
	
	
	public function resetMoveFlag() {
		moved = false ;
	}
	
	function warningUpdate() : Bool {
		if (warning == null)
			return false ;
		
		if (warningTimer != null) {
			warningTimer = Math.max(0.0, warningTimer - 3.0 * mt.Timer.tmod) ;
			if (warningTimer == 0 || !Cs.outOfBounds(x, y, 25))
				warningTimer = null ;
			return (warningTimer != null && warningTimer > 15.0) ;
		}
		
		warning._alpha -= 2.0 * mt.Timer.tmod ;
		if (warning._alpha <= 0.0) {
			warning.removeMovieClip() ;
			warning = null ;
		}
		return false ;
	}
	
	
	public function update(mod : Float) {
		
		if (warningUpdate())
			return ;
		
		switch(step) {
			
			case Move : 
				var isBlocked = checkBlock(mod) ;
			
				if (weaponInfos != null)
					updateWeapon(isBlocked, mod) ;
				
				if (!isBlocked) {
					switch(subStep) {
						case 0 : 
							/*if (timer == 0.0)
								mc.gotoAndPlay("_start") ;*/

							timer = Num.mm(0.0, timer + 0.05 * /*mt.Timer.tmod*/mod, 1.0) ;
						
							var delta = Math.pow(timer, 3) ;
							speed = BASE_SPEED[level] * delta ;
							
							if (timer == 1.0)
								subStep = 2 ;
						
						case 2 : //normal move, nothing to do here
							if (proutchTimer != null) {
								proutchTimer = Num.mm(0.0, proutchTimer + 0.05 * /*mt.Timer.tmod*/mod, 1.0) ;
						
								var delta = Math.pow(proutchTimer, 5) ;
								speed = BASE_SPEED[level] - PROUTCH_SLOW + PROUTCH_SLOW * delta ;
								
								if (proutchTimer == 1)
									proutchTimer = null ;
							}
						
					}
					
					
					if (speed > 0.0) {
						updateAnim(mod) ;
						move(mod) ;
					}
				}
				
			case Explode : 
				switch (subStep) {
					case 0 : 
						if (timer == 0) {
							for (a in Game.me.army) {
								if (a != this && a.blocked != null && a.blocked.nb >  MAX_BLOCK / 2)
									a.blocked.nb -= Std.int(MAX_BLOCK / 6) ;
							}
						}
					
						timer = Math.min(timer + 0.05 * /*mt.Timer.tmod*/mod, 1) ;
						Col.setPercentColor(mc._p, timer * 100, 0xFFFFFF) ;
						if (timer == 1.0) {
							timer = 0 ;
							subStep = 1 ;
						}
						
					case 1 : 
						timer = Math.min(timer + 0.08 * /*mt.Timer.tmod*/mod, 1) ;
						mc._p._alpha = if (mc._p._alpha < 50) 100 else 20 ;
						if (timer == 1.0) {
							timer = 0 ;
							subStep = 2 ;
						}
						
					case 2 :
						explose() ;
				}
		}
	}
	
	
	function getAnim(name : String) {
		for (a in ANIM_FRAMES) {
			if (a.id == name)
				return a ;
		}
		//trace("anim name : " + name + " not found.") ;
		return null ;
	}
	
	
	function updateAnim(mod : Float) {
		var fps = Cs.FPS ;
		var c = mc._p._currentframe ;
		var nf = Std.int(fps * mod) ;
		
		var a = cAnim ;
		
		if (nf  +c <= a.start + a.frames)
			mc._p.gotoAndStop(nf + c) ;
		else {
			if (a.next == a.id) //repeat anim
				mc._p.gotoAndStop(a.start + (nf + c - a.start) % a.frames)  ;
			else //goto next 
				mc.gotoAndStop(parseNextFrame(a, c, nf)) ;
		}
		
		if (weaponInfos == null || weaponInfos.bomb == null)
			return ;
		
		c = weaponInfos.bomb._currentframe ;
		var tot = weaponInfos.bomb._totalframes ;
		
		weaponInfos.bomb.gotoAndStop((c + nf) % tot) ;
		weaponInfos.bomb.smc.gotoAndStop((weaponInfos.bomb.smc._currentframe + nf) % weaponInfos.bomb.smc._totalframes) ;
		
		c = weaponInfos.bomb.smc.smc._currentframe ;
		tot = weaponInfos.bomb.smc.smc._totalframes ;
		if (c + nf < tot) {
			weaponInfos.bomb.smc.smc.gotoAndStop(Std.int(Math.min(c + nf, tot - 1))) ;
		}
	}
	
	
	function parseNextFrame(a : { start : Int, next : String, id : String, frames : Int }, from : Int, f : Int) : Int {
		var todo = a.start + a.frames - from ;
		if (f <= todo) {
			cAnim = a ;
			return from + f ;
		}
		
		return parseNextFrame(getAnim(a.next), a.start + a.frames, f - todo) ;
	}
	
	
	public function explose() {
		var c = getCenter() ;
		var bmc = Game.me.mdm.attach("tankBoom", Game.DP_PARTS) ;

		bmc._x = c.x ;
		bmc._y = c.y ;
		bmc._xscale = 120 ;
		bmc._yscale = bmc._xscale ;
		bmc.gotoAndStop(1) ;
		Game.ExplosionList.push(bmc) ;
		
		kill() ;
	}
	

	
	function updateWeapon(isBlocked : Bool, mod : Float) {
		if (weaponInfos == null || (Cs.outOfBounds(x, y) && beginTravel()))
			return ;
		
		switch(weaponStep) {
			case 0 : //sleep 
				if (Cs.outOfBounds(x, y))
					return ; 
			
				weaponTimer = Math.max(0.0, weaponTimer - 9 * mod) ;
				if (weaponTimer == 0) {
					weaponStep = 1 ;
					weaponTimer = 100 ;
				}
					
			
			case 1 : //rotate weapon
				weaponInfos.ang += mod * 0.4 ;
				var delta = weaponInfos.toAng - weaponInfos.fromAng ;
				var pdelta = Math.abs(delta) ;
				if (weaponInfos.ang > pdelta) {
					weaponStep = 2 ;
					weaponTimer = 100 ;
					weaponInfos.ang = pdelta ;
					/*if (!isBlocked)
						block(this) ;*/
					
					initWeaponTarget() ;
				}
				
				mc._p._weapon._rotation = weaponInfos.fromAng + weaponInfos.ang * delta / pdelta ;
				
			case 2 : //init fire
				var wp = getWeaponPoint() ;
				Cs.rotateMc(mc._p._weapon, weaponInfos.target._x,  weaponInfos.target._y, wp.x, wp.y, -mc._rotation) ;
			
				var save = weaponTimer ;
				weaponTimer = Math.max(0.0, weaponTimer - 3.0 * mod) ;
				
				var tier = 100 / 3 ;
				for (i in 1...4) {
					if (save > 100 - tier * i && weaponTimer <= 100 - tier * i) {
						var t = 3 - i ;
						weaponInfos.target._field.text = Std.string(t) ;
						break ;
					}
				}
				
				if (weaponInfos.bomb != null) {
					var bt = weaponTimer * 2 / 100 ;
					weaponInfos.bomb._x = weaponInfos.bsx * bt + weaponInfos.target._x * (1 - bt) ;
					weaponInfos.bomb._y = weaponInfos.bsy * bt + weaponInfos.target._y * (1 - bt) ;
					//weaponInfos.bomb._rotation += mod * 20 ;
				} else {
					if (weaponTimer < 50) {
						weaponInfos.bomb = Game.me.mdm.attach("bomb", Game.DP_BOMB) ;
						weaponInfos.bomb.gotoAndStop(1) ;
						weaponInfos.bomb.smc.gotoAndStop(1) ;
						weaponInfos.bomb.smc.smc.gotoAndStop(1) ;
						var b = mc._p._weapon.smc.getBounds(Game.me.root) ;
						weaponInfos.bsx = b.xMax ;
						weaponInfos.bsy = b.yMin ;
						weaponInfos.bomb._x = weaponInfos.bsx ;
						weaponInfos.bomb._y = weaponInfos.bsy ;
						weaponInfos.bomb._rotation = Std.random(360) ;
					}
				}
				
			
				if (weaponTimer == 0) {
					weaponStep = 0 ;
					weaponTimer = 100 ;
					 
					fire() ;
					
					initWeapon(true) ;
				}
		}
	}
	
	
	function fire() {
		//mc._p._weapon.smc.gotoAndPlay(2) ;
		var bmc = Game.me.mdm.attach("mcExplosion", Game.DP_PARTS) ;
		bmc.gotoAndStop(1) ;
		bmc._x = weaponInfos.target._x ;
		bmc._y = weaponInfos.target._y ;
		Game.ExplosionList.push(bmc) ;
		
		//bmc._rotation = Math.random() * 360 ;
		
		for (a in Game.me.army.copy()) {
			if (a != this && a.mc._bBox.hitTest(weaponInfos.target))
				a.explose() ;
		}
		
		
		if (!Game.me.fever && weaponInfos.target.hitTest(Game.me.mcGroup)) {
			for (tf in Game.me.followers) {
				for (i in 0...tf.length) {
					var f = tf[i] ;
					if (f.mc._bBox.hitTest(weaponInfos.target)) {
						Game.me.killFollower(f) ;
						if (f != Game.me.leader)
							tf[i] = null ;
					}
				}
			}
		}
		
		weaponInfos.bomb.removeMovieClip() ;
		weaponInfos.target.removeMovieClip() ;
		weaponInfos.target = null ;
		
		if (Game.me.lifeLeader <= 0 || Game.me.lifeFollowers <= 0)
			Game.me.setGameOver() ;
	}
		
	
	function getWeaponPoint() : {x : Float, y : Float} {
		var s ={x : null, y : null} ;
		switch (typeDir) {
			case 0 :
				s.x = mc._x + mc._p._y + mc._p._weapon._y ;
				s.y = mc._y - mc._p._x - mc._p._weapon._x ;
			case 1 : 
				s.x = mc._x + mc._p._x + mc._p._weapon._x ;
				s.y = mc._y + mc._p._y + mc._p._weapon._y ;
			case 2 : 
				s.x = mc._x - mc._p._y - mc._p._weapon._y ;
				s.y = mc._y + mc._p._x + mc._p._weapon._x ;
			case 3 : 
				s.x = mc._x - mc._p._x - mc._p._weapon._x ;
				s.y = mc._y - mc._p._y - mc._p._weapon._y ;
		}
		
		return s; 
		
	}
	
	
	function initWeaponTarget() {
		var b = mc._p._weapon.smc.getBounds(Game.me.root) ;
		var s = getWeaponPoint() ;
		var t = {x : b.xMin, y : b.yMax} ;
		var tt = null ;
		var maxTries = 10 ;
		var tries = 0 ;
		var range = null ;
		while (tries < maxTries && (tt == null || Cs.outOfBounds(tt.x, tt.y, 20))) {
			tries++ ;
			range = WEAPON_RANGE.min + Math.random() * (WEAPON_RANGE.max - WEAPON_RANGE.min) ;
		
			var dx = t.x - s.x ;
			var dy = t.y - s.y ;
			tt = {x : s.x + dx * range, y : t.y + dy * range} ;
		}
		
		if (Cs.outOfBounds(tt.x, tt.y, 15)) {
			initWeapon(true) ;
			weaponTimer = 100 ;
			weaponStep = 0 ;
			return ;
		}
		
		var mcTarget = Game.me.mdm.attach("target", Game.DP_TARGET) ;
		mcTarget._x = tt.x ;
		mcTarget._y = tt.y ;
		
		//trace("put target : " + tt.x + ", " + tt.y + " # by " + Std.string(this)) ;
		
		weaponInfos.target = cast mcTarget ;
	}
	
	
	
	function checkBlock(mod) {
		if (blocked == null)
			return false ;
			
		if (blocked.by.mc != null && hit(this, blocked.by, /*mt.Timer.tmod*/mod, blocked.nb) != null /*this.mc._p._bBoxMove.hitTest(blocked.by.mc._p._bBoxMove)*/) {
			blocked.nb++ ;
			
			if (blocked.nb > MAX_BLOCK)
				setStep(Explode) ;
			moved = true ;
			return true ;
		} else {
			unblock() ;
			return false ;
		}
		
	}
	
	
	public function move(mod : Float) {
		if (travelDone()) {
			if (weaponInfos != null && weaponInfos.target != null) {
				//trace("block in fire : " + Std.string(this) + " # "+ speed) ;
				return ;
			}
			kill() ;
			return ;
		}
		var delta = [dir[0] * mod * speed * SPEED_MULT, dir[1] * mod * speed * SPEED_MULT] ;
		
		x += delta[0] ;
		y += delta[1] ;
		
		var b = getBlockers(this) ;
		if (b.length > 0) {
			for (a in b) {
				if ((a.blocked == null || a.blocked.by != this)) { 	/*this.mc._p._bBoxMove.hitTest(a.mc._p._bBoxMove) && */
					var h = hit(this, a, mod) ;
					if (h == null)
						continue ;
					if (h == this) {
						block(a) ; 
					} else {
						if (a.blocked == null) {
							a.block(this) ;
						}
					}
				}
			}
		}
		
		moved = true ;
		if (blocked != null)
			return ;
		
		
		//if (level == 0 || level == 3)
			makeTraces() ;
			
		mc._x = x ;
		mc._y = y ;
		
	}
	
	
	public function block(?by : Army) {
		
		if (by != null)
			blocked = {nb : 1, by : by} ;
		//trace("paf : " + Std.string(this)) ;
		if (mc._p._currentframe == 1 && speed > 0.30)
			mc._p.gotoAndPlay("_brake") ;
		speed = 0.0 ;
		subStep = 0 ;
		timer = 0 ;
	}
	
	
	public function unblock() {
		blocked = null ;
		//mc._p.gotoAndStop(1) ;
		setStep(Move) ;
		if (blocked.by.typeDir == typeDir)
			speed -= 0.02 ;
	}
	
	
	function setStep(s : MoveStep) {
		if (step != s) {
			subStep = 0 ;
			timer = 0 ;
		}
		step = s ;
	}
	
	
	function makeTraces() {
		if (lastTrace == null || Math.abs(x - lastTrace[0]) >= DELTA_TRACE || Math.abs(y - lastTrace[1]) >= DELTA_TRACE) {
			lastTrace = [x, y] ;
			/*var t = new Phys( Game.me.mdm.attach("tTrace", Game.DP_GROUND)) ;
			t.root.gotoAndStop(level + 1) ;*/
			//t.fadeType = Cs.TRACE_FADE ;
			//t.timer = Cs.TRACE_TIMER /*/ SPEED_MULT*/ ;
			
			var t = Game.me.mdm.attach("tTrace", Game.DP_GROUND) ;
			t.gotoAndStop(level + 1 ) ; 
			
			var c = getCenter() ;
			
			var pc = 0.80 ;
			switch(typeDir) {
				case 0 : 
					t._rotation = -90 ;
					/*t.x = c.x ;
					t.y = c.y ;*/
				/*	t.x = x + mc._p.smc._width / 2 ;
					t.y = y - Math.abs(mc._p.smc._height) * pc ;	*/			
				case 1 : 
					/*t.x = c.x ;
					t.y = c.y ;*/
					/*t.x = x + mc._p.smc._width * pc ;
					t.y = y + mc._p.smc._height / 2 ;*/
				case 2 : 
				/*	t.x = x - Math.abs(mc._p.smc._width) / 2 ;
					t.y = y + Math.abs(mc._p.smc._height) * pc ;*/
					t._rotation = 90 ;
				case 3 : 
					t._rotation = -180 ;
				/*	t.x = x - Math.abs(mc._p.smc._width) * pc ;
					t.y = y - Math.abs(mc._p.smc._height) / 2 ;*/
			}
			
			t._x = c.x ;
			t._y = c.y ; 
			
			/*t.root._x = t.x ;
			t.root._y = t.y ;*/
			
			if (blood.leftTimer == null || blood.rightTimer == null) {
				for (b in Game.BloodList.copy()) {
					if (b == null || b.root == null || b.timer <= 0.0) {
						Game.BloodList.remove(b) ;
						continue ;
					}
					

					if (blood.leftTimer == null && b.root._alpha > 50 && b.root.hitTest((cast t.smc)._left))
						blood.leftTimer = BLOOD_TIMER ;
					if (blood.rightTimer == null && b.root._alpha > 50 && b.root.hitTest((cast t.smc)._right))
						blood.rightTimer = BLOOD_TIMER ;
				}
			} 
			
			if (blood.leftTimer != null ) {
				Col.setPercentColor((cast t.smc)._left, 95, 0xBA0202) ;
				blood.leftTimer = Math.max(0, blood.leftTimer - 1.0 * mt.Timer.tmod) ;
			//	trace("timer : " + blood.leftTimer) ;
				if (blood.leftTimer == 0)
					blood.leftTimer = null ;
				
			}
			if (blood.rightTimer != null ) {
				Col.setPercentColor((cast t.smc)._right, 95, 0xBA0202) ;
				blood.rightTimer = Math.max(0, blood.rightTimer - 1.0 * mt.Timer.tmod) ;
				if (blood.rightTimer == 0)
					blood.rightTimer = null ;
			}
			
			Game.me.plasma.drawMc(t) ;
			t.removeMovieClip() ;
		}
		
	}
	
	
	public function travelDone(?delta : Float = 0.0) : Bool {
		switch (typeDir) {
			case 0 : //from north
				return y - mc._height > Cs.mch[1] + Cs.HIDE_END - delta ;
			case 1 : //from east
				return x + mc._width < Cs.mcw[0] - Cs.HIDE_END + delta ;
			case 2 : //from south
				return y + mc._height < Cs.mch[0] -Cs.HIDE_END + delta ;
			case 3 : //from west
				return x - mc._width > Cs.mcw[1] + Cs.HIDE_END - delta ;
			default : 
				return true ;
		}
	}
	
	
	function beginTravel(?delta : Float = 0.0) : Bool {
		switch (typeDir) {
			case 0 : //from north
				return y < Cs.mch[0] + delta ;
			case 1 : //from east
				return x > Cs.mcw[1] - delta ;
			case 2 : //from south
				return y > Cs.mch[1] - delta ;
			case 3 : //from west
				return x < Cs.mcw[0] + delta ;
			default : 
				return true ;
		}
	}
	
	function toString() {
		return "#" + typeDir + " - " + level + " -- " + x + ", " + y + " -- " +  step + ", " + subStep ;
	}
	
	
	function kill() {
		var vv = null ;
		
		if (place.l.length > 1) {
			place.l.remove(this) ;
		} else {
			vv = getPlaceTab(typeDir) ;
			var index = null ;
			for(i in 0...vv.length) {
				if (vv[i] != place)
					continue ; 
				index = i ;
				break ;
			}
			
			if (index == null) {
				//trace("place index not found for kill wtf") ;
			}else {
				var done = false ;
				var pi = place ;
				while(!done) {
					var prev = vv[index - 1] ;
					var next = vv[index + 1] ;
					
					if (prev == null && next == null) {
						done = true ;
						continue ;
					}
					
					var neighbour = null ;
					if (index == 0) {
						neighbour = next ;
						done = true ;
					} else if (index == vv.length - 1) {
						neighbour = prev ;
						done = true ;
					} else {
						if (prev.l == null && next.l != null)
							neighbour = prev ;
						else if (prev.l != null && next.l == null)
							neighbour = next ;
						else
							neighbour = if (Std.random(2) == 0) next else prev ;
					}
					
					if (neighbour.l == null) {
						if (neighbour == prev) {
							index  = index - 1 ;
							neighbour.t[1] = pi.t[1] ;
						} else
							neighbour.t[0] = pi.t[0] ;
						vv.remove(pi) ;
						pi = neighbour ;
					} else {
						done = true ;
						place.l = null ;
					}
				}
			}
		}
		
		mc.removeMovieClip() ;
		mc = null ;
		if (warning != null)
			warning.removeMovieClip() ;
		if (weaponInfos != null) {
			if (weaponInfos.target != null)
				weaponInfos.target.removeMovieClip() ;
			if (weaponInfos.bomb != null)
				weaponInfos.bomb.removeMovieClip() ;
		}
		Game.me.army.remove(this) ;
	}
	
	
	static function findPlace(td : Int, m : Army) : Float {
		var vv = getPlaceTab(td) ;
		var need = m.mc._height ;
			
		var disps = [] ;
		var otherSideDisps = [] ;
		for (i in 0...vv.length) {
			var v = vv[i] ;
			if (v.t[1] - v.t[0] >= need) {
				if (v.l == null)
					disps.push({index : i, v : v}) ;
				else {
					var a : Army = v.l[0] ;
					if (a.typeDir == td) {
						if (canBeAdded(m, v.l))
							disps.push({index : i, v : v}) ;
					}else {
						if (canBeAdded(m, v.l, true))
							otherSideDisps.push({index : i, v : v}) ;	
					}
				}
			}
		}
		
		if (disps.length == 0) {
			if (otherSideDisps.length == 0) {
				//trace("no place wtf for " + Std.string(m)) ;
				return null ;
			} else {
				disps = otherSideDisps ;
				td = (td + 2) % 4 ;
				m.typeDir = td ;
			}
		}
		
		
		var d = disps[Std.random(disps.length)] ;
		var res = d.v.t[0] + Std.random(Std.int((d.v.t[1] - d.v.t[0]) - need)) ;
		
		if (d.v.l != null) {
			d.v.l.push(m) ;
			m.place = d.v ;
		} else {
			var vMid = null ;
			var vEnd = null ;
			
			var minSize = 8.0 ;
			var oldEnd = d.v.t[1] ;
			if (res - d.v.t[0] < minSize) {
				d.v.t[1] = res + need ;
				d.v.l = [m] ;
				vMid = {l : null, t : [res + need, oldEnd]} ;
				vv.insert(d.index+1, vMid) ;
				m.place = d.v ;
			} else {
				d.v.t[1] = res ;
				vMid = {l : [m], t : [res, res + need]} ;
				if (oldEnd - (res + need) < minSize)
					vMid.t[1] = oldEnd ;
				else
					vEnd = {l : null, t : [res + need, oldEnd]} ;
			
				vv.insert(d.index+1, vMid) ;
				if (vEnd != null)
					vv.insert(d.index+2, vEnd) ;
				m.place = vMid ;
			}
		}
	
		
		return res ;
	}
	
	
	public static function canBeAdded(m : Army, l : Array<Army>, ?otherSide = false) : Bool {
		if (l == null)
			return true ;
		
		var d = if (!otherSide ) m.typeDir else ((m.typeDir + 2) % 4) ;
		
		for (a in l) {
			if (a.speed < m.speed) //speed
				return false ;
			switch(d) { //place
				case 0 : 
					if (a.y - a.mc._height - Cs.MIN_DELTA_QUEUE < m.getStart())
						return false ;
				case 1 : 
					if (a.x + a.mc._width + Cs.MIN_DELTA_QUEUE > m.getStart())
						return false ;
				case 2 : 
					if (a.y + a.mc._height + Cs.MIN_DELTA_QUEUE > m.getStart())
						return false ;
				case 3 :
					if (a.x - a.mc._width - Cs.MIN_DELTA_QUEUE < m.getStart())
						return false ;
			}
		}
		return true ;
	}		
	
	
	static public function getBlockers(m : Army) : Array<Army> {
		var res = new Array() ;
		if (m.place.l != null) {
			for (a in m.place.l) {
				if (a == m)
					break ;
				res.push(a) ;
			}
		}
		
		var vv = getPlaceTab(m.typeDir, true) ; 
		var front = if (m.typeDir == 0 || m.typeDir == 2) m.y else m.x ;
		var cut = false ;
		var delta = 0 ;
		for (v in vv) {
			if (front >= v.t[0] - delta && front < v.t[1] + delta) {
				if (v.l != null) {
					cut = true ;
					res = res.concat(v.l) ;
				} else {
					//if (v.t[1] - v.t[0] > 15)
						cut = true ;
				}
			} 
			
			if (cut)
				break ;
		}
		
		return res ;
	}
	
	
	public function getCenter() : {x : Float, y : Float} {
		switch (typeDir) {
			case 0  :
				return 	{	x : x + mc._p._y  + mc._p.smc._y + mc._p.smc._height / 2,
							y : y - mc._p._x - mc._p.smc._x - mc._p.smc._width / 2} ;
			case 1 : 
				return 	{	x : x + mc._p._x + mc._p.smc._x + mc._p.smc._width / 2,
							y : y + mc._p._y + mc._p.smc._y + mc._p.smc._height / 2} ;
			case 2 : 
				return 	{	x : x - mc._p._y - mc._p.smc._y - mc._p.smc._height / 2,
							y : y + mc._p._x + mc._p.smc._x + mc._p.smc._width / 2} ;
			case 3 : 
				return 	{	x : x - mc._p._x -  mc._p.smc._x - mc._p.smc._width / 2,
							y : y - mc._p._y - mc._p.smc._y - mc._p.smc._height / 2} ;
			default :
				trace("bad dir for getCenter") ;
				return null ;
		}
		
	}
	
	
	public function getMoveBox(?mod : Float = 0.0) : flash.geom.Rectangle<Float> {
		var w = mc._bBoxMove._width ;
		var h = mc._bBoxMove._height ;
		if (typeDir == 0 || typeDir == 2) {
			var t = w ;
			w = h ;
			h = t ;
		}
		
		var m = if (moved || blocked != null)
					[0.0, 0.0]
				else
					[dir[0] * mod * speed * SPEED_MULT, dir[1] * mod * speed * SPEED_MULT] ;
		
		switch (typeDir) {
			case 0  :
				return new flash.geom.Rectangle(/*mc._p._y +*/ mc._bBoxMove._y + x + m[0], /*-mc._p._y*/ - mc._bBoxMove._x + y + m[1] - h, w, h) ;
			case 1 : 
				return new flash.geom.Rectangle(/*mc._p._x +*/ mc._bBoxMove._x + x + m[0], /*mc._p._y +*/ mc._bBoxMove._y + y + m[1], w, h) ;
			case 2 : 
				return new flash.geom.Rectangle(/*-mc._p._y */- mc._bBoxMove._y + x + m[0] - w, /*mc._p._x +*/ mc._bBoxMove._x + y + m[1], w, h) ;
			case 3 : 
				return new flash.geom.Rectangle(/*-mc._p._x*/ -mc._bBoxMove._x + x + m[0] - w, /*-mc._p._y*/ - mc._bBoxMove._y + y + m[1] - h, w, h) ;
			default :
				trace("bad dir for moveBox") ;
				return null ;
		}
	}
	
	
	//return null if no hit, army object to stop otherwise
	public static function hit(a : Army, b : Army, mod : Float, ?nb : Int = 0) : Army {
		var ar = a.getMoveBox(mod) ;
		var br = b.getMoveBox(mod) ;
		
		if (!ar.intersects(br))
			return null ;
		var inter = ar.intersection(br) ;
		//trace("hit found betWeen " + Std.string(a) + " [" + Std.string(ar) + "] " + " and" + Std.string(b) + " [" + Std.string(br) + "] "  + " ==> " + Std.string(inter)) ;
		
		
		var minInter = 2.0 ;
		var minInterOut = 2.0 ;
		
		
		if (a.typeDir == b.typeDir) 
			return if (a.creationTime <= b.creationTime) b else a ;
		else {
			var wArmy = if (a.typeDir == 0 || a.typeDir == 2) a else b ;
			var hArmy = if (wArmy == a) b else a ;
			if (inter.width > inter.height) {
				if (inter.width > minInter) {
					if (inter.height < minInterOut && isGoingAway(hArmy, wArmy))
						return null ;
					else 
						return wArmy ;
				} else 
					return null ;
			} else if (inter.width < inter.height) {
				if (inter.height > minInter) {
					if (inter.width < minInterOut && isGoingAway(wArmy, hArmy))
						return null ;
					else 
						return hArmy ;
				} else 
					return null ;
			} else {
				if (inter.width > minInter)
					return if (a.speed >= b.speed) a else b ;
				else 
					return null ;
			}
			
		}
		
	}
	
	
	static function isGoingAway(a : Army, b : Army) : Bool {
		var res = false ;
		switch(a.typeDir) {
			case 0 :
				if (b.typeDir == 1)
					res = b.x < a.x ;
				else if (b.typeDir == 3)
					res = b.x > a.x ;
			case 1 :
				if (b.typeDir == 0)
					res = b.y > a.y ;
				else if (b.typeDir == 2)
					res = b.y < a.y ;
			case 2 :
				if (b.typeDir == 1)
					res = b.x < a.x ;
				else if (b.typeDir == 3)
					res = b.x > a.x ;
			case 3 :
				if (b.typeDir == 0)
					res = b.y > a.y ;
				else if (b.typeDir == 2)
					res = b.y < a.y ;
		}
		
		return res ;
	}
	
	
	static public function getPlaceTab(dir : Int, ?otherOne = false) {
		if (otherOne)
			return PLACES[if (dir == 0 || dir == 2) 1 else 0] ;
		else
			return PLACES[if (dir == 0 || dir == 2) 0 else 1] ;
	}
	
	
	//########### FOR DEBUG ONLY
	//#######################
	
	
	static public function traceBoxes() {
		var mod = mt.Timer.tmod ;
		//trace("trace boxes") ;
		for (a in Game.me.army) {
			
			var r = a.getMoveBox() ;
			var mc = Game.me.mdm.empty(Game.DP_TRACES) ;
			if (a.blocked != null)
				continue ;
			
			mc.beginFill(0xFFFFFF, 3) ;
			mc.moveTo(0, 0) ;
			mc.lineTo(r.width, 0) ;
			mc.lineTo(r.width, r.height) ;
			mc.lineTo(0, r.height) ;
			mc.lineTo(0, 0) ;
			mc.endFill() ;
			mc._x = r.x ;
			mc._y = r.y ;
			//trace(Std.string(a) + mc._x + ", "  +  mc._y) ;
			var p = new Phys(mc) ;
			p.fadeType = 6 ;
			p.timer = 28 ;
			
		}
	}
	
	
	
}