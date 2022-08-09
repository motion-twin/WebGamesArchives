import flash.display.Bitmap ;
import flash.display.BitmapData ;
import flash.display.MovieClip ;
import flash.display.Sprite ;
import flash.display.BlendMode ;
import flash.ui.Keyboard ;

import mt.bumdum9.Lib ;

import mt.deepnight.SpriteLib ;

import Game.Race ;
import Game.Coord ;
import Spot.Building ;

typedef ByPassInfo = {
	var side : Int ; //0 > 4 : north to west
	var s : Spot ;
	var x : Float ;
	var y : Float ;
}

typedef Animal = {
	var sp : DSprite ;
	var sh : DSprite ; 
	var c : Coord ;
	var n : Int ;
	var d : Float ; 
	var curByPass : ByPassInfo ;
	var plague : Array<Spot> ;
}


class Swarm {


	public var from : Spot ;
	public var to : Spot ;
	public var owner : Race ;
	public var pop : mt.flash.Volatile<Int> ;
	public var animals : Array<Array<Animal>> ;

	public var buildingEffect : Building ;

	public var spotFound : Bool ;
	public var byPassed : Bool ;

	public function new(f : Spot, t : Spot, p : Int, ?forceRace : Race, ?forceBldEffect : Building) {
		from = f ;
		to = t ;
		pop = p ;
		owner = (forceRace != null) ? forceRace : from.owner ;
		spotFound = false ;
		byPassed = false ;

		if (forceBldEffect != null)
			buildingEffect = forceBldEffect ;
		else {
			if (f.building != null) {
				switch(f.building) {
					case Fast, Rage : buildingEffect = f.building ;
					default : //nothing to do 
				}
			}
		}

		init() ;
		Game.me.swarms.push(this) ;
		Game.me.ia.onNewSwarm(this) ;

		var count = 0 ;
		for (ta in animals)
			count += ta.length ;

		/*trace("### NEW SWARM : " + pop + " [" + count + "]") ;

		for (ta in animals) {
			for(a in ta)
				trace(a.n + " # " + Std.string(a.sp != null)) ;
		}

		trace("###############################") ;*/

	}



	public function stopAnims() {
		for (ta in animals) {
			for (a in ta) {
				if (a.sp == null)
					continue ;
				a.sp.stopAnim(a.sp.getFrame()) ;
			}
		}
	}


	public function killFromPlague(s : Spot) {
		var av = [] ;
		for (i in 0...animals.length) {
			var avLine = {idx : i, a : []} ;
			for (a in animals[i]) {
				if (!Lambda.exists(a.plague, function(x) { return x.id == s.id ; }))
					continue ;
				avLine.a.push(a) ;
			}

			if (avLine.a.length > 0)
				av.push(avLine) ;
		}

		if (av.length == 0)
			return ; //fail

		var cLine = av[Game.me.random(av.length)] ;
		var cA = cLine.a[Game.me.random(cLine.a.length)] ;

		
		//### part
		var expl = Game.me.tiles.getSpriteAnimated(Game.getSpriteName(owner) + "_explode", "race_explode", 1) ;
		expl.fl_killOnEndPlay = true ;
		Game.me.dm.add(expl, Game.DP_FX) ;
		expl.x = cA.sp.x ;
		expl.y = cA.sp.y ;
		new mt.fx.Rotate(expl, -8 + Std.random(17)) ;
		//###

		cA.n-- ;
		pop-- ;
		if (cA.n <= 0) {
			animals[cLine.idx].remove(cA) ;
			removeAnimal(cA) ;
		}

		if (pop <= 0)
			kill() ;
	}


	function getHitTest(c : Coord, ?dist = 100, ?withTo = false) {
		var toHitTest = [] ;
		for (s in Game.me.spots) {
			if (s == from || (s == to && !withTo))
				continue ;
			if (Game.dist(c, s.getCoord()) < dist)
				toHitTest.push(s) ;
		}

		return toHitTest ;
	}


	public function update() {

		var defaultDist = 0.9 ;
		var distDone = Std.int(Math.round( to.getSize() / 2 * 1.3 )) ;

		var delta = null ;

		var toHitTest = null ;

		
 
		for (r in animals.copy()) {
			//var byPass = null ;
			for (a in r.copy()) {

				a.plague = [] ;

				var next = null ;

				var byPass = null ;

				if (a.d <= 0.0)
					a.d = defaultDist + (defaultDist * Game.me.random(7) / 100) * (Game.me.random(2) * 2 - 1) ;

				var	dist = a.d ;

				//### FAST EFFECT
				if (buildingEffect != null && Type.enumEq(buildingEffect, Fast))
					dist *= 2 ;
				//### 

				//### SLOW AND PLAGUE EFFECT
				var slowDone = false ;
				var cc = {x : a.c.x, y : a.c.y } ;
				for (s in getHitTest(cc, Spot.BUILDING_RADIUS, true)) {
					if (!slowDone && s.hasActiveBuilding(Slow, owner)) {
						dist = dist / 2 ;
						slowDone = true ;
					}

					if (s.hasActiveBuilding(Plague, owner) && s.waitPlague < 0) {
						a.plague.push(s) ;
						s.addToPlague(this, a.n) ;
					}

				}
				//###

				if (spotFound || byPassed)
					delta = null ;

				if (delta == null) {
					next = getNextPoint(a.c, to.getCoord(), dist) ;
					delta = {x : next.x - a.c.x, y : next.y - a.c.y, d : dist} ;
				} else 
					next = {x : a.c.x + delta.x / delta.d * dist, y : a.c.y + delta.y / delta.d * dist} ;

				if (Game.dist(next, to.getCoord()) < distDone) {
					spotFound = true ;
					var tPop = Std.int(Math.min(a.n, pop)) ;
					pop -= tPop ;


					//### RAGE EFFECT

					var fPop = 0 ;
					var backPop = 0 ;
					for (i in 0...tPop) {
						if (to.hasBuilding(Bunker) && !to.isNeutral() && !Type.enumEq(owner, to.owner) && Game.me.random(100) < Spot.BUNKER_PC)
							backPop++ ;
						else if (buildingEffect != null && !to.isNeutral() && !Type.enumEq(owner, to.owner) && Type.enumEq(buildingEffect, Rage) && Game.me.random(100) < Spot.RAGE_PC)
							fPop += 2 ;
						else
							fPop++ ;
					}

					//trace("ADD ### pop : " + pop + ", a.n : " + a.n + ", tPop : " + tPop + ", fPop : " + fPop) ;

					if (backPop > 0)
						new Swarm(to, from, backPop, owner, buildingEffect) ;

					if (fPop > 0)  {
						//trace("       pre : " + to.curPop) ;
						to.addPop(fPop, owner, next) ;
						//trace("       ppost : " + to.curPop) ;
					}

					removeAnimal(a) ;
					r.remove(a) ; 

				} else {
					var old = {x : a.c.x, y : a.c.y} ;

					if (byPass == null) {
						a.c.x = next.x ;
						a.c.y = next.y ;
						if (toHitTest == null)
							toHitTest = getHitTest(a.c) ;

						for (s in toHitTest) {
							if (a.sp.hitTestObject(s.hitBox)) {
								byPass = getByPass(old, s, to.getCoord(), delta, dist, a.curByPass) ;

								if (byPass != null) {
									byPassed = true ;
									break ;
								}
							}
						}
					}

					if (byPass != null) {
						if (a.curByPass != null) {
							if (a.curByPass.s == byPass.s && a.curByPass.side == byPass.side)
								byPass = a.curByPass ;
							else
								a.curByPass = byPass ;
						} else
							a.curByPass = byPass ;

						next = { x : old.x + byPass.x / delta.d * dist, y : old.y + byPass.y / delta.d * dist } ;
					}
					if (next.x - old.x < 0)
						a.sp.scaleX = -1 ;
					else if (next.x - old.x > 0)
						a.sp.scaleX = 1 ;

					a.c.x = next.x ;
					a.c.y = next.y ;

					a.sp.x = Std.int(Math.round(next.x)) ;
					a.sp.y = Std.int(Math.round(next.y)) ;
					a.sh.x = a.sp.x ;
					a.sh.y = a.sp.y + 1 ;


					if (!Game.me.isEnnemy(owner)) {
						for (pk in Game.me.curKPoints) {
							if (a.sp.hitTestObject(pk.sp))
								pk.grab() ;
						}
					}
				}
			}

			if (r.length == 0)
				animals.remove(r) ;
		}

		if (animals.length == 0)
			kill() ;
	}


	static function getByPass(from : Coord, hitSpot : Spot, to : Coord, delta : {x : Float, y : Float, d : Float}, dist : Float, cur : ByPassInfo) : ByPassInfo {
		var bBox = hitSpot.getBoundingBox() ;
		var res = {x : 0.0, y : 0.0, side : 0, s : hitSpot} ;

		if (from.y >= bBox.yMin && from.y <= bBox.yMax)
			res.side = (from.x < hitSpot.x) ? 3 : 1 ;
		else
			res.side = (from.y < hitSpot.y) ? 0 : 2 ;


		var distTo = {	x : Game.dist({x : from.x, y : 0}, {x : to.x, y : 0}),
						y : Game.dist({x : 0, y : from.y}, {x : 0, y : to.y})
					} ;

		switch(res.side) {
			case 0, 2: //top, bottom

				if (res.side == 0 && to.y < from.y)
					return null ;
				if (res.side == 2 && to.y > from.y)
					return null ;

				res.y = 0.0 ;
				var quarter = (bBox.xMax - bBox.xMin) / 4 ;
				var dir = 0 ;

				if (from.x < hitSpot.x - quarter) {
					dir = -1 ;
					if (cur != null && cur.side == 3) //force 1 cause of prev byPass
						dir = 1 ;
					else if (distTo.x > Math.abs(to.x - (from.x + hitSpot.getSize()) )) //force 1 cause of logical way
						dir = 1 ;
				} else if (from.x > hitSpot.x + quarter) {
					dir = 1 ;
					if (cur != null && cur.side == 1) { //force -1
						dir = -1 ;
					} else if (distTo.x > Math.abs(to.x - (from.x - hitSpot.getSize()) )) //force 1 cause of logical way
						dir = -1 ;
				} else 
					dir = (delta.x >= 0) ? 1 : -1 ;

				//res.x = dir * (Math.abs(delta.x) + Math.abs(delta.y)) ;
				res.x = dir * Math.abs(dist) ;

			case 1, 3 : //right, left

				if (res.side == 1 && to.x > from.x)
					return null ;
				if (res.side == 3 && to.x < from.x)
					return null ;

				res.x = 0.0 ;
				var quarter = (bBox.yMax - bBox.yMin) / 4 ;
				var dir = 0 ;

				if (from.y < hitSpot.y - quarter) {
					//if (res.side == 1) trace("hop") ;
					dir = -1 ;
					if (cur != null && cur.side == 0) //force 1
						dir = 1 ;
					else if (distTo.y > Math.abs(to.y - (from.y + hitSpot.getSize()) )) //force 1 cause of logical way
						dir = 1 ;
				} else if (from.y > hitSpot.y + quarter) {
					//if (res.side == 1) trace("paf") ;
					dir = 1 ;
					if (cur != null && cur.side == 2) //force -1
						dir = -1 ;
					else if (distTo.y > Math.abs(to.y - (from.y - hitSpot.getSize()) )) //force 1 cause of logical way
						dir = -1 ;
				} else 
					dir = (delta.y >= 0) ? 1 : -1 ;

				//trace(res.side + " => " + dir + " # " + Std.string(distTo) + " # " + cur) ;

				res.y = dir * Math.abs(dist) ;		
		}

		return res ;
	}


	function removeAnimal(a : Animal, ?anim = false ) {

		var fKill = function(aa : DSprite, ash : DSprite) {
						aa.destroy() ;
						ash.destroy() ;
					} ;

		if (anim) {
			var s = new mt.fx.Spawn(a.sp, 0.06, true) ;
			var s2 = new mt.fx.Spawn(a.sh, 0.06, true) ;
			s.reverse() ;
			s2.reverse() ;
			s2.onFinish = callback(fKill, a.sp, a.sh) ;
		} else
			fKill(a.sp, a.sh) ;


		


	}

/*
0 > 45
1 > 44
2 > 42
3 > 39
4 > 35
5 > 30
6 > 24
7 > 17
8 > 9

last.idx = 7
*/




	function init() {

		var spn = Game.getSpriteName(owner) ;

		animals = new Array() ;
		var n = pop ;
		var last = {n : 0, idx : -1 } ;
		var cMax = 6 + ( (pop > 50 ) ? 2 : 0)  + Game.me.random(2) ;

		try {
		
		while (n > 0) {
			if (last.idx == -1) {
				if (n > last.n) {
					last.n++ ;
					var l = new Array() ;
					for (i in 0...last.n) {
						var sp = Game.me.tiles.getSpriteAnimated(spn + "_run", spn + "_run_anim") ;
						sp.offsetAnimFrame() ;

						l.push({sp : sp, sh : Game.me.tiles.getSprite("shadow_" + spn), c : {x : 0.0, y : 0.0}, n : 1, d : 0.0, curByPass : null, plague : []}) ;
					}

					animals.push(l) ;
					n -= last.n ;

					if (animals.length == cMax)
						last.idx = animals.length - 1 ;
				} else 
					last.idx = animals.length - 1 ;

			} else {
				var sp = Game.me.tiles.getSpriteAnimated(spn + "_run", spn + "_run_anim") ;
				sp.offsetAnimFrame() ;
				animals[last.idx].push({sp : sp, sh : Game.me.tiles.getSprite("shadow_" + spn), c : {x : 0.0, y : 0.0}, n : 1, d : 0.0, curByPass : null, plague : []}) ;
				n-- ;
				last.idx-- ;

				if (last.idx < 0)
					break ;
			}
		}


		if (n > 0) {
			for (t in animals) {
				for (a in t) {
					//var d = Std.int(Math.min(more, n)) ;
					var d = 1 ;
					a.n += d ;
					n -= d ;

					if (n <= 0) break ;
				}
				if (n <= 0) break ;
			}
		}



		} catch(e : Dynamic) {
			throw "#2 " + Std.string(e) ;
		}


		//POSITION 
		var dx = to.x - from.x ;
		var side = (dx > 0) ? 1 : ( (dx < 0) ? -1 : ( (from.ennemy) ? -1 : 1 )) ;

		var n = Std.int(Math.round( from.getSize() / 2 * 1.3 )) ;
		var lastPoint = from.getCoord() ;



		var fc = from.getCoord() ;
		var tc = to.getCoord() ;

		var point = getNextPoint(fc, tc, n) ;
		/*trace("point : " + Std.string(from.getCoord()) + " # " + Std.string(to.getCoord()) + "," + n + " ==> " + Std.string(point)) ;
		trace("eqValues : " + Std.string(getEqValues(from.getCoord(), to.getCoord()))) ;*/

		var dPerp = getNextPoint(fc, {x : fc.x - (tc.y - fc.y), y : fc.y + tc.x - fc.x}, 11) ;
		dPerp = {x : dPerp.x - fc.x, y : dPerp.y - fc.y} ;


		try {

		for (i in 0...animals.length) {
			var r = animals[animals.length - 1 - i] ;

			var pp = {	x : point.x - (r.length - 1 ) / 2 * dPerp.x,
						y : point.y - (r.length - 1) / 2 * dPerp.y
					}

			for (a in r) {
				a.c.x = pp.x + Game.me.random(3) * (Game.me.random(2) * 2 - 1) ;
				a.c.y = pp.y + Game.me.random(3) * (Game.me.random(2) * 2 - 1) ;
				a.sp.scaleX = side ;
				Game.me.dm.add(a.sp, Game.DP_WARFIELD) ;

				a.sp.x = Std.int(Math.round( a.c.x )) ;
				a.sp.y = Std.int(Math.round( a.c.y )) ;

				a.sh.x = a.sp.x ;
				a.sh.y = a.sp.y + 1 ;
				Game.me.dm.add(a.sh, Game.DP_WAR_SHADOWS) ;

				pp.x += dPerp.x ;
				pp.y += dPerp.y ;
			}

			n += 12 ;

			var nPoint = getNextPoint(fc, tc, n) ;
			//trace("point : " + Std.string(from.getCoord()) + " # " + Std.string(to.getCoord()) + "," + n + " ==> " + Std.string(nPoint)) ;
			lastPoint = nPoint ;
			point = nPoint ;
		}


		} catch(e : Dynamic) {
			throw "#3 " + Std.string(e) ;
		}

		try {

		//recal
		for (i in 0...animals.length) {
			for (a in animals[i].copy()) {
				var toRemove = a.sp.y < 47 ;

				if (!toRemove) {
					var toHitTest = getHitTest({x : a.sp.x, y : a.sp.y}, 100 ) ;

					for (s in toHitTest) {
						if (a.sp.hitTestObject(s.hitBox)) {
							toRemove = true ;
							break ;		
						}
					}
				}

				if (toRemove) {
					var n = a.n ;

					var others = [] ;
					for (la in animals) {
						for (o in la) {
							if (o == a)
								continue ;
							others.push(o) ;
						}
					}

					if (others.length == 0) { 
							//can't remove the only one animal. let it go through spot
					} else  {
						animals[i].remove(a) ;
						removeAnimal(a) ;
						others[Game.me.random(others.length)].n += n ;
					}
				}
			}
		}


		} catch(e : Dynamic) {
			var s = owner + " #pop : " + pop + " animals : " + Std.string(animals) ;
			throw s + " ####### " + Std.string(e) ;
		}

		try {


		if (buildingEffect != null && Type.enumEq(buildingEffect, Fast)) {
			for (ta in animals) {
				for (a in ta) {
					new mt.fx.Radiate(a.sp) ;
				}
			}
		}

		if (buildingEffect != null && Type.enumEq(buildingEffect, Rage)) {
			for (ta in animals) {
				for (a in ta) {
					new mt.fx.Sleep(new mt.fx.Radiate(a.sp, 0.1, /*0xef1717*/ 0x86fffe), Std.random(5)) ;
				}
			}

		}


		} catch(e : Dynamic) {
			throw "#5 " + Std.string(e) ;
		}

	}


	public static function getNextPoint(f : Coord, t : Coord, dist : Float) : Coord {
		var d = Game.dist(f, t) ;
		var div = d / dist ;

		return { 	x :  f.x + (t.x - f.x) / div ,
					y :  f.y + (t.y - f.y) / div ,
		} ;
	}


	public function kill(?force = false) {
		for (r in animals) {
			for (a in r)
				removeAnimal(a, force) ;
		}

		if (to != null && !force) {
			if (Type.enumEq(Game.me.mode, GM_LEAGUE))
				to.updateBonusLeague(Game.me.isEnnemy(this.owner)) ;

			to.setSwarmed(false) ;
			to.unGrowPop() ;
		}


		Game.me.swarms.remove(this) ;
	}

}