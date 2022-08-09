package horde ;


typedef Leader = {
	var behaviour : Behaviour ;
	var zone : Zone ;
}

enum Behaviour {
	Move(out : Bool, tx : Int, ty : Int, max : Int, power : Int) ;
	Grow(power : Int) ;
	Eat(power : Int) ;
}

enum LeadStimulus { //stimulated by...
	Deads(d : Int) ; //players deads on zone
	ZombieKills(k : Int) ; //zombies friends killed by players on zone
	OwnWay ; //no external stimulus, just a will of the zombie crowd to do something tonight
}



class CrowdControl {
	
	static public var DIST_ATTENUATION = [1.0, 0.60, 0.25, 0.10, 0.05, 0.05] ;
	
	static var map : Map ;
	static var zones : Array<Zone> ;
	static var baseZones : Array<Zone> ;
	static var emptyZones : Array<Zone> ;
	static var withDeads : Array<Zone> ;
	static var withZombieKills : Array<Zone> ;
	static var orderedZombies : Array<Zone> ;
	
	static var leaders : Array<Leader> ;
	static var nbLeader : Int ;
	
	
	
	
	static public function process(map : Map) {
		CrowdControl.map = map ;
		prepare() ;
		prepareLead() ;
		diffuseLeads() ;
		
		
		for(x in 0...Map.SIZE) {
			for(y in 0...Map.SIZE) {
				var z = map.grid[x][y] ;
				
				if (z.isTown() || z.leads == null)
					continue ;
				
				var zc = z.zombies ;
				while (z.leads != null && z.leads.length > 0 && zc > 0) {
					var zl = z.getBehaviour() ;
		
					switch(zl.behaviour) {
						case Grow(power) : //GROW
							var p = power ;
							while (p > 0) {
								var cc = zl.zone.getAdjacentCoords(Std.random(5)) ; //0 : center, 1 : east, 2 : south, etc... 
								var z2 = map.grid[cc.x][cc.y] ;
								if (z2 == null || z2.isTown())
									continue ;
								
								z2.addZombie(1) ;
								p-- ;
								zc-= Std.random(2) + 1 ;
							}
						
						case Eat(power) : //EAT
							if (z.zombies <= 0)
								continue ;
							var k = Std.random(Std.int(power / 10) + 1) ;
							z.killZombie(k) ;
							zc -= k * 2 ;
							
						case Move(out, tx, ty, max, power) :  //MOVE
							
							var tz = map.grid[tx][ty] ;
							var tlevel = Zone.getZoneLevel(cast z, cast tz) ;
							var v = {vx : tz.x - z.x, vy : tz.y - z.y} ;
							
							var motivation = Std.int(power / 5) ;
							for(n in 0...zc) {
								if (!out) {
									var m = Std.random(tlevel + Std.int(motivation / 2)) ;
									if (m == 0) { //zombie doesn't move. 
										continue ;
									}
									
									var p = m / (tlevel + Std.int(motivation / 2)) ;
									
									
										
										var dx = Std.int(v.vx * p) ; 
										var dy = Std.int(v.vy * p) ; 
										
										var z2 = map.grid[z.x + dx][z.y + dy] ;
										if (z2 == null || z2.isTown()) {
										var r1 = Std.random(2) ;
										var r2 = 1 - r1 ;
										z2 = map.grid[z.x + dx + getSide() * r1][z.y + dy + getSide() * r2] ;
										if (z2 == null)
											continue ;
									}
										z2.addZombie(1) ;
										z.killZombie(1) ; 
								} else {
									
									//### TODO ##################################################################################"
									
									var d = Std.int(Math.max(1, 15 - tlevel - Std.int(motivation / 2))) ;
									var m = Std.random(d) ;
									if (m == 0) //zombie doesn't move. 
										continue ;	
									
									var p = 1 - m / d ;

									var dx = if (v.vx == 0) getSide() * Std.random(2) else Std.int(v.vx * -p) ; 
									var dy = if (v.vy == 0) getSide() * Std.random(2) else Std.int(v.vy * -p) ; 
									
									var z2 = map.grid[z.x + dx][z.y + dy] ;
									if (z2 == null || z2.isTown()) {
										var r1 = Std.random(2) ;
										var r2 = 1 - r1 ;
										z2 = map.grid[z.x + dx + getSide() * r1][z.y + dy + getSide() * r2] ;
										if (z2 == null)
											continue ;
									}
										
									z2.addZombie(1) ;
									z.killZombie(1) ; 
								
								}
								
								zc-- ;
								motivation++ ;
							}
					}
					
					
				}
			}
		}
		
		
		
		trace("DONE") ;
		
		clean() ;
	}
	
	
	
	static function prepareLead() {
		
		nbLeader = Std.random(15) + Std.int(Math.max(10, map.cDay)) ;
		leaders = new Array() ;
		
		var r =  2 ;
		if (withDeads.length > 1) {
			for(i in 0...withDeads.length) {
				var z = withDeads[i] ;
				if (z == null)
					continue ;
				
				//trace(" i : "  +i) ;
				for (j in (i + 1)...withDeads.length) {
					//trace(" J : "  +j) ;
					var z2 = withDeads[j] ;
					if (z2 == null)
						continue ;
					
					var l = Zone.getZoneLevel(cast z, cast z2) ;
					if (l <= 2) { //concat deads
						//trace("### (" + l+ " ) >> " + z2.x + ", " + z2.y + " go to " + z.x + ", " + z.y) ;
						z.deads += Std.int(z2.deads / l) ;
						z2.deads = 0 ;
						withDeads[j] = null ;
					}
				}
			}
			cleanArray(withDeads) ;
		}

		
		if (withZombieKills.length > 1) {
			for(i in 0...withZombieKills.length - 1) {
				var z = withZombieKills[i] ;
				if (z == null)
					continue ;
				
				for (j in (i + 1)...withZombieKills.length) {
					var z2 = withZombieKills[j] ;
					if (z2 == null)
						continue ;
					
					var l = Zone.getZoneLevel(cast z, cast z2) ;
					if (l <= 2) { //concat kills
						z.zombieKills += Std.int(z2.zombieKills / l) ;
						z2.zombieKills = 0 ;
						withZombieKills[j] = null ;
					}
				}
			}
			cleanArray(withZombieKills) ;
		}
		
		
		//make leaders "player noisy" zones 
		var cDead = 0 ;
		var cZombieKill = 0 ;
		while (leaders.length < nbLeader - 2 && withDeads.length > 0 && withZombieKills.length > 0) {
			if (withDeads.length > 0) {
				var z = withDeads.shift() ;
				var r = Std.random(100) ;
				
				if (r < z.deads * 10) {
					setLeader(z, Deads(z.deads)) ; 
					cDead++ ;
				} else { 
					if (Std.random(100) < cDead * 20) //no more deads leaders
						withDeads = new Array() ;
				}
			}
			
			if (withZombieKills.length > 0) {
				var z = withZombieKills.shift() ;
				var r = Std.random(100) ;
				
				if (r < z.zombieKills * 10) {
					setLeader(z, ZombieKills(z.zombieKills)) ; 
					cZombieKill++ ;
				} else { 
					if (Std.random(100) < cZombieKill * 20) //no more zombieKills leaders
						withZombieKills = new Array() ;
				}
				
			}
			
		}
		
		
		for (z in baseZones) {
			if (z.building && z.zombies <= 3)
				z.addZombie(Std.random(4) + 1) ;
		}
		
		
		
		if (leaders.length > 0 && nbLeader >= leaders.length)
			return ;
		
		var n = (nbLeader - leaders.length) ;
		for(n in 0...n) {
			var z = null ;
			while (z == null) {
				z = orderedZombies[Std.random(orderedZombies.length)] ;
				
				if (z.isSafe())
					z = null ;
			}
			setLeader(z) ;
		}
		
		var i = 0 ;
		while(i < orderedZombies.length && i < 10) {
			var z = orderedZombies[i] ;
			trace(z.zombies) ;
			if (z.zombies > 20)
				leaders.push({behaviour : Move(true, z.x, z.y, 3, z.zombies * 2), zone : z}) ;
			else 
				break ;
			i++ ;
		}
		
		/*if (emptyZones.length == 0)
			return ;
		
		for (n in leaders.length...nbLeader) {
			var z = null ;
			while (z == null) {
				z = emptyZones[Std.random(emptyZones.length)] ;
				
				if (z.isSafe())
					z = null ;
			}
			trace(z.x + ", " + z.y) ;
			leaders.push({behaviour : Move(false, z.x, z.y, 1, 10 + z.zombies * 2), zone : z}) ;
			
		}*/
		
		
		
		
		
	}
	
	
	static function setLeader(z : Zone, ?from : LeadStimulus) {
		if (from == null)
			from = OwnWay ;
		/*
		Deads ; //players deads on zone
		ZombiKills ; //zombies friends killed by players on zone
		OwnWay ; //no external stimulus, just a will of the zombie crowd to do something tonight
		*/
		
		switch(from) {
			case Deads(d) : 
				var l = {behaviour : Move(false, z.x, z.y, Std.int(Math.min(d + Std.random(3) / 3, 3)), d * 10), zone : z} ;
				leaders.push(l) ;
				if(Std.random(Std.int(Math.max(1, 10 - d))) == 0) { //grow 
					l = {behaviour : Grow(Std.random(d - Std.int(d / 2)) + Std.int(d / 2)), zone : z} ;
					leaders.push(l) ;
				}
					
			case ZombieKills(k) : 
				var d = 25 + k * 2 ;
				var l = {behaviour : Move(true, z.x, z.y, Std.random(3) + 1, d), zone : z} ;
				leaders.push(l) ;
				l = {behaviour : Move(false, z.x, z.y, Std.random(3) + 1, 100 - d), zone : z} ;
				leaders.push(l) ;
				
			case OwnWay : 
				var probs = [{b : Move(false, Std.int(Math.max(0, Math.min(z.x + getSide() * (Std.random(5) + 1), Map.SIZE - 1))), Std.int(Math.max(0, Math.min(z.y + getSide() * (Std.random(5) + 1), Map.SIZE - 1))), Std.random(2), 20 + z.zombies * 2), weight : 50 - (if (z.building) 25 else 0) + z.zombies * 5},
							{b : Grow(Std.int(Math.max(1, Std.random(Std.int(Math.min(10, Std.int(z.zombies / 2 + 1)) + 1))))), weight : /* 20 + z.zombies * 10*/ 50 - z.zombies },
							{ b: Eat(Std.random(2) + 1), weight : -5 + z.zombies * 2}] ;
							
				//trace(probs)  ;

				var b = randomProbs(cast probs) ;
				leaders.push({behaviour : b.b, zone : z}) ;
				
				
		}
	}
	
	
	static function diffuseLeads() {
		for (l in leaders) {
			var b = l.behaviour ;
			
			//trace(b) ;
			
			switch(b) {
				case Grow(power) : 
					var d = 15 + power * 10 ;
					l.zone.addLead(l, d) ;
					var max = if (power < 4) 1 else Std.random(2) + 1 ;
						
					for(x in (l.zone.x - max)...(l.zone.x + max)) {
						for(y in (l.zone.y - max)...(l.zone.y + max)) {
							var z = map.grid[x][y] ;
							if (z == null || z.isTown())
								continue ;
							var dist = Zone.getZoneLevel(cast l.zone, {x : x, y : y}) ;
							z.addLead(l, Std.int(d * DIST_ATTENUATION[dist])) ;
						}
					}
					
					
				
				case Eat(power) : 
					l.zone.addLead(l, 15) ;
				case Move(out, tx, ty, max, power) : 
					if (max <= 0)
						continue ;
					
					for(x in (l.zone.x - max)...(l.zone.x + max)) {
						for(y in (l.zone.y - max)...(l.zone.y + max)) {
							var z = map.grid[x][y] ;
							if (z == null || z.isTown())
								continue ;
							
							var dist = Zone.getZoneLevel(cast l.zone, {x : x, y : y}) ;
							z.addLead(l, Std.int(power * DIST_ATTENUATION[dist])) ;
						}
					}
			}
			
		}
		
	}
	
	
	
	static function prepare() {
		zones = new Array() ;
		baseZones = new Array() ;
		withDeads = new Array() ;
		withZombieKills = new Array() ;
		orderedZombies = new Array() ;
		emptyZones = new Array() ;
		
		var tzones = new Array() ;
		for(x in 0...Map.SIZE) {
			for(y in 0...Map.SIZE) {
				var z = map.grid[x][y] ;
				
				z.done = false ;
				z.modZombie = 0 ;
				
				baseZones.push(z) ;
				
				if (z.deads > 0)
					withDeads.push(z) ;
				if (z.zombieKills > 0)
					withZombieKills.push(z) ;
				
				if (z.zombies > 0)
					orderedZombies.push(z) ;
				
				if (z.isTown())
					continue ;
				if (z.zombies == 0)
					emptyZones.push(z) ; 
				else
					tzones.push(z) ;
			}
		}
		
		if (withDeads.length > 1) {
			withDeads.sort(function(a, b) {
				if (a.deads > b.deads)
					return -1 ;
				else 
					return 1 ;
			}) ;
		}
		
		if (withZombieKills.length > 1) {
			withZombieKills.sort(function(a, b) {
				if (a.zombieKills > b.zombieKills)
					return -1 ;
				else 
					return 1 ;
			}) ;
		}
		
		if (orderedZombies.length > 1) {
			orderedZombies.sort(function(a, b) {
				if (a.zombies > b.zombies)
					return -1 ;
				else
					return 1 ;
			}) ;
		}
		
		while (tzones.length > 0) {
			var e = tzones[Std.random(tzones.length)] ;
			tzones.remove(e) ;
			zones.push(e) ;
		}
	}
	
	
	
	static function clean() {
		for(x in 0...Map.SIZE) {
			for(y in 0...Map.SIZE) {
				var z = map.grid[x][y] ;
				
				z.deads = 0 ;
				z.zombieKills = 0 ;
				//z.leadBehaviour = null ;
				z.leads = null ;
			}
		}
	}
	
	
	static function cleanArray(t : Array<Dynamic>) : Array<Dynamic> {
		var res = new Array() ;
		for (z in t) {
			if (z == null)
				continue ;
			res.push(z) ;
		}
		return res ;
	}
	
	
	static public function randomProbs(tt : Array<{weight : Int}>) : Dynamic {
		var n = 0 ;
		var t = tt.copy() ;
		
		for(e in t) {			
			if (e.weight <= 0)
				t.remove(e) ;
			else
				n += e.weight ;
		}
		
		n = Std.random(n) ;
		var i = 0 ;
		while( n >= t[i].weight) {
			n -= t[i].weight ;
			i++ ;
		}
		return t[i] ;
	}
	
	
	static public function getSide() : Int {
		return Std.random(2) * 2 - 1 ;
	}
	
	
}