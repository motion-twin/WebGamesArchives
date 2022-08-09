import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import mt.bumdum.Lib ;


enum FollowStep  {
	Wait ;
	Follow ;
}



class Follower { 
	
	static var MIN_DELTA_POS = 20.0 ;
	static var FEVER_SCALE = 160 ;
	
	public var step : FollowStep ;
	public var mc : {>flash.MovieClip, _p : flash.MovieClip, _clickMe : {>flash.MovieClip, _bBox : flash.MovieClip}, _bBox : flash.MovieClip } ;
	public var x : mt.flash.Volatile<Float> ;
	public var y : mt.flash.Volatile<Float> ;
		
	public var points : mt.flash.Volatile<Int> ;
	public var mcPoints : {>flash.MovieClip, _field : flash.TextField} ;
	
	public var shield : mt.flash.Volatile<Float> ;
	
	var effectTimer : Float ;
	var effect : Int ;
	var effectSpeed : Float ;
	
	var waitDownPoints : Bool ;
	
	public var feverOver : Army ;
		
	public var deltaLeader : {x : Float, y : Float} ;
	
		
	
	
	public function new(?startX : Float, ?startY : Float, ?noInit = false) {
		if (noInit)
			return ; 
		
		if (startX == null) { //follower
			var p = 20 ;
			
			while (x == null || Cs.getDist(x, y, Game.me.leader.x, Game.me.leader.y) < 20.0 + Std.int(Game.me.followers.length / 2) * Cs.DELTA_FOLLOW) {
				x = (Cs.mcw[1] - Cs.mcw[0] - MIN_DELTA_POS * 2) / p * Std.random(p) + MIN_DELTA_POS + Cs.mcw[0] ; 
				y = (Cs.mch[1] - Cs.mch[0] - MIN_DELTA_POS * 2) / p * Std.random(p) + MIN_DELTA_POS + Cs.mch[0] ; 
			}
			step = Wait ;
			
			mc = cast Game.me.mdm.attach("follower", Game.DP_FOLLOW) ;
			mc.smc.gotoAndStop(Std.random(mc.smc._totalframes)+1);

			mc._rotation = (20 + Std.random(180 - 40)) * -1 ;
			
			mc._p._alpha = 50 ;
			Game.me.toGrab.push(this) ;
			
			points = KKApi.val(Cs.FOLLOW_POINTS) ;
			mcPoints = cast Game.me.mdm.attach("mcPoints", Game.DP_POINTS) ;
			mcPoints._field.text = Std.string(points) ;
			mcPoints._x = x;
			mcPoints._y = y - 13 ;
			waitDownPoints = true ;
			
			mc._x = x ;
			mc._y = y ;
			
			effectTimer = 0.0 ;
			effect = 1 ;
			effectSpeed = 1.0 ;
			mc._xscale = 0 ;
			mc._yscale = mc._xscale ;
			mcPoints._xscale = 0 ;
			mcPoints._yscale = mcPoints._xscale ;
			
			
		} else { //force leader
			mc = cast Game.me.gdm.attach("leader", 0) ;
			step = Follow ;
			
			deltaLeader = {x : 0.0, y : 0.0} ;
			Game.me.mcGroup._x = startX ;
			Game.me.mcGroup._y = startY ;
			x = startX ;
			y = startY ;
			
			mc._rotation = -90 ;
			
			mc._x = 0 ;
			mc._y = 0 ;
		}
		
	}
	
	
	public function getRootPos() : {x : Float, y : Float} {
		return {x : mc._x + Game.me.mcGroup._x, y : mc._y + Game.me.mcGroup._y} ;
	}
	
	
	public function setFever(a : Army) {
		feverOver = a ;
		mc._xscale = FEVER_SCALE ;
		mc._yscale = FEVER_SCALE ;
	}
	
	
	public function checkFever() {
		if (feverOver == null)
			return ;
		
		if (feverOver.mc == null || !feverOver.mc._bBox.hitTest(mc._bBox)) {
			feverOver = null ;
			mc._xscale = 100 ;
			mc._yscale = 100 ;
		} else 
			feverOver.block() ;
		
	}
	
	
	
	public function update() {
		if (shield != null) {
			shield = Math.max(0.0, shield - 1.0 * mt.Timer.tmod) ;
			if (shield == 0)
				shield = null ;
		}
		
		
		if (step == Wait && !waitDownPoints && points > KKApi.val(Cs.MIN_POINTS)) {
			points  = Std.int(Math.max(KKApi.val(Cs.MIN_POINTS), Std.int(points - mt.Timer.tmod * 15))) ;
			mcPoints._field.text = Std.string(points) ;
		}
		
		
		
		if (effect != null) {
			switch(effect) {
				case 0 : //cold 
					effectTimer = Math.min(effectTimer + 0.03 * effectSpeed * mt.Timer.tmod, 1) ;
					Col.setPercentColor(mc, 100 - effectTimer * 100, 0xFFFFFF) ;
					if (effectTimer == 1) {
						effectTimer = null ;
						effect = null ;
					}
				case 1 : //elastic init
					effectTimer = Math.min(effectTimer + 0.015 * effectSpeed * mt.Timer.tmod, 1) ;
					var delta = 1 - Cs.elastic(1.5, 1 - effectTimer) ;
								
					mc._xscale = delta * 100 ;
					mc._yscale = mc._xscale ;
					mcPoints._xscale = mc._xscale ;
					mcPoints._yscale = mc._yscale ;
				
					if (waitDownPoints&& mc._xscale > 60)
						waitDownPoints = false ;
				
					if (effectTimer == 1) {
						effectTimer = null ;
						effect = null ;
					}
			}
			
		}
		
		/*switch(step) {
			case Wait : 
				
			case Follow : 
			
		}*/
		
	}
	
	
	public function isFollowing() : Bool {
		return step == Follow ;
	}	
	
	
	
	public function moveTo(tx, ty) {
		x = tx ;
		y = ty ;
		
		if (this == Game.me.leader) {
			Game.me.mcGroup._x = x ;
			Game.me.mcGroup._y = y ;
		} else {
			mc._x = x ;
			mc._y = y ;
		}
		
	}
	
	
	
	public function move() {
		x = Game.me.leader.x + deltaLeader.x ;
		y = Game.me.leader.y + deltaLeader.y ;
		
		mc._x = x ;
		mc._y = y ;
		
	}
	
	
	public function grabbed() {
		if (step != Wait)
			return ;
		
		step = Follow ;
		
		var k = KKApi.cmult(KKApi.const(points), KKApi.const(Std.int(1 + Game.me.fMult * 0.2))) ;
		if (Game.me.fever)
			k = KKApi.const(Std.int(KKApi.val(k) * 1.12)) ;
		Game.me.addScore(k) ;
		
		Game.me.addToFever(points) ;
		
		points = null ;
		mcPoints.removeMovieClip() ;
		
		mc._clickMe._visible = false ;
		mc._p._alpha = 100 ;
		
		
		var p = Game.me.leader ;
		x = p.x ;
		y = p.y ;
		mc._x = x ;
		mc._y = y ;
				
		Game.me.toGrab.remove(this) ;
		var f = new Follower(null, null, true) ;
		f.shield = Cs.GRAB_SHIELD ;
		
		f.mc = cast Game.me.gdm.attach("follower", 0) ;
		f.mc.smc.gotoAndStop(mc.smc._currentframe);
		f.mc._rotation = mc._rotation ;
		f.mc._clickMe._visible = false ;
		
		//Game.me.gdm.ysort(0) ;
		/*f.mc._x = mc._x ;
		f.mc._y = mc._y ;*/
		f.step = step ;
		
		f.addToGroup() ;
		
		//Game.me.followers.push(this) ;
		/*if (Game.me.followers.length > 0)
			Game.me.followers[0].prev = this ;*/
		
		//Game.me.followers.unshift(this) ;
	
		//Game.me.updateFollowRepop(true) ;
		Game.me.followRepopTimer -= Cs.repopFollowDelay * (Math.random() / 3 + 0.75) ;
		kill() ;
	}
	
	
	public function kill() {
		if (mc != null)
			mc.removeMovieClip() ;
		if (mcPoints != null)
			mcPoints.removeMovieClip() ;
	}
		
	
	function addToGroup() {
		var choices = new Array() ;
		var place = 0 ;
		var l = Game.me.followers.length ;
		var mid = Std.int((l - 1) / 2) ;

		var test = function(i, j, m, forceCh) {
			var ch = null ;
			place++ ;
			ch = Std.int(Math.abs(mid - m)) + 1 ;
			
			if (forceCh != null)
				ch = forceCh ;
							
			if (choices[ch] == null)
				choices[ch] = new Array() ;
					
			choices[ch].push({i : i, j : j}) ;
			
		}
		
		
		for (i in 1...l - 1) {
			for (j in 1...l - 1) {
				if (Game.me.followers[i][j] != null)
					continue ;
				test(i, j, j, 0) ;
			}
		}
		
		for (t in [0, l - 1]) {
			for (i in 0...l) {
				if (Game.me.followers[t][i] != null)
					continue ;
				test(t, i, i, null) ;
			}
		}
		for (t in 1...l - 1) {
			for (i in [0, l - 1]) {
				if (Game.me.followers[t][i] != null)
					continue ;
				test(t, i, t, null) ;
			}
		}
		
		
		//choose place 
		var c = 0 ;
		while((choices[c] == null || choices[c].length == 0) && c < choices.length)
			c++ ;
		var ch = choices[c][Std.random(choices[c].length)] ;
		
		Game.me.fMult++ ;
		
		Game.me.followers[ch.i][ch.j] = this ;
		deltaLeader = {x : (ch.i - mid) * Cs.DELTA_FOLLOW/* + (Std.random(2) * 2 - 1) * Math.random() / 3*/,
					y : (ch.j - mid) * Cs.DELTA_FOLLOW/* + (Std.random(2) * 2 - 1) * Math.random() / 3*/} ;
					
		mc._x = deltaLeader.x ;
		mc._y = deltaLeader.y ;
		
		setEffect(0) ;
		
		if (place <= 1)
			Game.me.growGroup() ;
		
	}
	
	
	public function setEffect(e : Int, ?sp = 1.0 ) {
		if (effect != null)
			return ;
		effect = e ;
		effectTimer = 0 ;
		effectSpeed = sp ;
		
	}
	
}