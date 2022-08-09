import flash.Key ;
import mt.bumdum.Lib;
import Day.ZoneInfos ;

import horde.CrowdControl.Behaviour ;
import horde.CrowdControl.Leader ;


class Zone {
	
	public static var SIZE = 26 ;
	
	static var DP_ICON = 1 ;
	static var DP_COLOR = 2 ;
	static var DP_ZOMBIES = 3 ;
	static var DP_OVER = 5 ;
	
	static var DANGER_COLOR : Array<Int> = [
		0xffff00, // 1-2
		0xffa040, // 3-4
		0xff0000, // 5-6
		0xff0000, // 7-8
		0x6873f4, // 9+
	] ;
	
	public var x : Int ;
	public var y : Int ;
	public var pmc : flash.MovieClip ;
	public var dm : mt.DepthManager ;
	public var mc : {>flash.MovieClip, hashes : flash.MovieClip} ;
	public var mcColor : flash.MovieClip ;
	public var mcZombies : flash.MovieClip ;
	public var ab : flash.MovieClip ;
	
	var scale : Float ;
	public var safe : Bool ;
	public var level : Int ;
	public var building : Bool ;
	public var zombies : Int ;
	public var zombieKills : Int ;
	public var deads : Int ;
		
	
	public var done : Bool ;
	public var modZombie : Int ;
		
	
	//crowdControl mods
	//public var leadBehaviour : Behaviour ;
	public var leads : Array<{leader : Leader, weight : Int}> ;
	
	
	public function new(pmc : flash.MovieClip, x : Int, y : Int) {
		this.x = x ;
		this.y = y ;
		
		zombies = 0 ;
		zombieKills = 0 ;
		deads = 0 ;
		safe = false ;
		
		
		var c = Math.floor(Map.SIZE / 2) ;
		level = getZoneLevel({x : c, y : c}, {x : x, y : y}) ;
		
		
		this.pmc = pmc ;
		dm = new mt.DepthManager(pmc) ;
		mc = cast dm.attach("mapIcon", DP_ICON) ;
		mc.gotoAndStop(1) ;
		mc.hashes.gotoAndStop(1) ;
		
		mcColor = dm.attach("danger", DP_COLOR) ;
		mcColor._alpha = 0 ;
		
		ab = dm.attach("activeBox", DP_OVER) ;
		active(false) ;
		
		scale = Math.min( Map.WIDTH*0.9 / (30*Map.SIZE), Map.HEIGHT*0.9 / (30*Map.SIZE) ) ;
		
		pmc._x = Math.floor(Map.WIDTH*0.05 + x * 30 * scale) ;
		pmc._y = Math.floor(Map.HEIGHT*0.03 + y * 30 * scale) ;
		pmc._xscale = scale * 100 ;
		pmc._yscale = scale * 100 ;
	
		
		pmc.onRollOver = callback(Map.me.showStatus, this) ;
		pmc.onRollOut = callback(Map.me.hideStatus) ;
		
		pmc.onRelease = callback(Zone.fingerGod, this) ;
		pmc.onReleaseOutside = ab.onRelease ;
		
	}
	
	
	public function addZombie(?n : Int) {
		setZombies(zombies + if (n == null) 1 else n) ;
	}
	
	
	public function killZombie(?n : Int) {
		if (zombies == 0)
			return ;
		
		zombieKills += if (n != null) n else 1 ;
		
		if (n == null)
			setZombies(zombies - 1) ;
		else
			setZombies(Std.int(Math.max(zombies - n, 0))) ; 
	}

	
	
	public function setZombies(n : Int) {
		if (mcZombies != null) 
			mcZombies.removeMovieClip() ;
		mcZombies = dm.empty(DP_ZOMBIES) ;
		
		zombies = n ;
		setColor() ;
		
		var s = (1.2 - scale) * 100 + 100 ;
		
		if (n == 0)
			return ;
		for (i in 0...Std.int(Math.min(n, 4))) {
			var m = mcZombies.attachMovie("dot", "dot_" + i, i + 1) ;
			m.gotoAndStop(2) ;
			m._xscale = s ;
			m._yscale = s ;
			m._x = Std.random(18) + 4 ;
			m._y = Std.random(18) + 4 ;
		}
		
		
		if (n >= 5) {
			var m = mcZombies.attachMovie("mapTag", "zombies", 20) ;
			m.gotoAndStop(if (n < 9) 7 else 8) ;
			m._xscale = s ;
			m._yscale = s ;
		}
	}
	
	
	function setColor() {
		if (zombies == 0) {
			mcColor._alpha = 0 ;
			return ;
		}
		
		var cid = Std.int(Math.min(Math.floor(zombies / 2), 4)) ;
		
		Col.setPercentColor(mcColor, 100, DANGER_COLOR[cid]) ;
		mcColor._alpha = 30 ;
	}
	
	
	public function hasZombies() : Bool {
		return zombies > 0 ;
	}
	
	
	public function isTown() : Bool {
		return this == Map.me.town ;
	}
	
	
	public function isFree() : Bool {
		return !safe && !isTown() && !building ;
	}
	
	
	public function isSafe() : Bool {
		return safe || isTown() ;
	}
	
	
	public function getInfos() : ZoneInfos {
		return {
			zombies : zombies,
			zombieKills : zombieKills,
			deads : deads
		}
	}
	
	
	public function setInfos(infos : ZoneInfos) {
		setZombies(infos.zombies) ;
		zombieKills = infos.zombieKills ;
		deads = infos.deads ;
	}
	
	
	public function active(b : Bool) {
		if (b) {
			ab._alpha = 75 ;
			ab.filters = [ new flash.filters.GlowFilter(0xd7ff5b,1, 6,6,2) ] ;
		} else {
			ab._alpha = 0 ;
			ab.filters = [] ;
		}
	}
	
	
	static public function fingerGod(z : Zone) {
		if (z.safe || z.isTown())
			return ;
		
		if (Key.isDown(Key.CONTROL)) { //kill zombie
			z.killZombie(1) ;

		} else if (Key.isDown(Key.SHIFT)) { //add player corpse
			z.deads++ ;
		} else if (Key.isDown(Key.END)) { //kill all zombies
			z.killZombie(z.zombies) ;
		} else { //addZombie
			z.addZombie(1) ;
		}
		
		Map.me.modDone(z) ;
		
		Map.me.showStatus(z) ;
	}
	
	
	public static function getZoneLevel( v1 : {x:Int,y:Int}, v2 : {x:Int,y:Int} ) {
		var ax = Math.abs( if( v1.x > v2.x ) v1.x - v2.x else v2.x - v1.x );
		var ay = Math.abs( if( v1.y > v2.y ) v1.y - v2.y else v2.y - v1.y );
		return Math.round( Math.sqrt( ax * ax + ay * ay ) );
	}

	
	
	
	//### CROWDCONTROL MODS
	public function addLead(l : Leader, w : Int) {
		if (leads == null)
			leads = new Array() ;
		leads.push({leader : l, weight : w}) ; 
		
	}
	
	
	public function getBehaviour() : Leader {
		var s = x + ", " + y + " >> " ;
		
		/*if (leads == null)
			s += "nothing" ;
		else {
			for (l in leads) {
				switch (l.leader.behaviour) {
					case Grow(power) : s += "GROW(" + power + ")" ;
					case Eat(power) : s += "EAT(" + power + ")" ;
					case Move(out, tx, ty, max, power) : s += Std.string(l.leader.behaviour) ;
				}
				
				s += " ## " + l.weight + " || " ;
				
			}
		}
		
		trace(s );*/
		
		var b = horde.CrowdControl.randomProbs(cast leads) ;
		leads.remove(b) ;
		return b.leader ;
	}
	
	
	public function getAdjacentCoords(d : Int) : {x : Int, y : Int} {
		switch (d) {
			case 0 : //THIS - CENTER
				return {x : x, y : y } ;
			case 1 : //EAST 
				return {x : x + 1, y : y} ;
			case 2 : //SOUTH
				return {x : x, y : y + 1} ;
			case 3 : //WEST 
				return {x : x - 1, y : y} ;
			case 4 : //NORTH
				return {x : x, y : y + 1} ;
			default :
				trace("unknown dir") ;
				throw "unknown dir" ;
		}
		
	}
	
	
}