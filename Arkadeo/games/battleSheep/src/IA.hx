import Game.Race ;
import Game.Coord ;
import Spot.Building ;

import api.AKApi ;
import api.AKProtocol ;
import api.AKConst ;



enum TargetType {
	@prio(10)	TakePlayer ; 
	@prio(0) 	WeakenPlayer ; 
	@prio(6)	TakeNeutral ; 
	@prio(0)	WeakenNeutral ;
	@prio(3)	ReInforce ;
	@prio(10)	SaveField ;
}


class IA {

	public static var DELTA_TAKE_NEUTRAL = [5,
											10, 10,
											15, 15, 15, 
											20, 20] ;
	public static var DELTA_TAKE_PLAYER = [	5,
											10, 10,
											15, 15, 15, 
											20, 20] ;

	public static var SLEEPPROBS = [4, 2, 1] ;
	public static var PLAYER 	= 0 ;
	public static var ENNEMY 	= 1 ;
	public static var NEUTRAL 	= 2 ;

	public static var REACT_CD = 2 * 40 ;

	var level : mt.flash.Volatile<Int> ;
	var coolDown : mt.flash.Volatile<Int> ;

	var minDeltaPlayer : mt.flash.Volatile<Int> ;
	var minDeltaNeutral : mt.flash.Volatile<Int> ;
	var multiByDist : Bool ;

	var avBuildings : Array<Int> ;

	var spots : Array<Array<Spot>> ;
	var side : Coord ; //x side => 0 or WIDTH

	var lastAction : {type : TargetType, spot : Spot } ;
	var lastReactionSpot : Null<Spot> ;
	var reactionCooldown : Int ;

	var pause : Bool ;

	//###PARAMS	
	var maxOnNewSwarm : mt.flash.Volatile<Int> ; // 1 -> 3
	var swReinforcement : mt.flash.Volatile<Int> ; // %
	var swCounterAttack : mt.flash.Volatile<Int> ; // %


	public function new(s : Int, lvl : Int, counterAttackLevel : Int) {
		spots = [[], [], []] ;
		level = lvl ;
		coolDown = 2 * 40 ;
		side = {x : s, y : Game.HEIGHT / 2} ;
		avBuildings = [] ;

		minDeltaNeutral = 0 ;
		minDeltaPlayer = 0 ;

		reactionCooldown = 10 * 40 ; //
		lastAction = null ;

		pause = false ;

		#if debug
		//pause = true ;
		#end


		switch(counterAttackLevel) {
			case 0 : 
				maxOnNewSwarm = 1 ;
				swReinforcement = 15 ;
				swCounterAttack = 15 ;

			case 1 : 
				maxOnNewSwarm = 1 ;
				swReinforcement = 25 ;
				swCounterAttack = 25 ;

			case 2 : 
				maxOnNewSwarm = 1 ;
				swReinforcement = 35 ;
				swCounterAttack = 35 ;

			case 3 : 
				maxOnNewSwarm = 2 ;
				swReinforcement = 25 ;
				swCounterAttack = 25 ;

			case 4 : 
				maxOnNewSwarm = 2 ;
				swReinforcement = 35 ;
				swCounterAttack = 35 ;

			case 5 : 
				maxOnNewSwarm = 3 ;
				swReinforcement = 35 ;
				swCounterAttack = 35 ;

			default : 
				maxOnNewSwarm = 3 ;
				swReinforcement = 35 ;
				swCounterAttack = 35 ;
		}


		if (level == 0) {
			maxOnNewSwarm = 1 ;
			swCounterAttack = Std.int(Math.round(swCounterAttack / 3)) ;
		} else if (level == 1) {
			maxOnNewSwarm = Std.int(Math.min(maxOnNewSwarm, 2)) ;
			swCounterAttack = Std.int(Math.round(swCounterAttack / 1.5)) ;
		}

		var blds = [0, 2, 3, 4, 5, 6] ;

		if (Game.me.isProgression() && Game.me.curPool > 0) {
			for (i in 0...Game.me.curPool)
				avBuildings.push(blds[Game.me.random(6)]) ;
		}


		minDeltaNeutral = DELTA_TAKE_NEUTRAL[Game.me.random(DELTA_TAKE_NEUTRAL.length)] ;
		minDeltaPlayer = DELTA_TAKE_PLAYER[Game.me.random(DELTA_TAKE_PLAYER.length)] ;
		multiByDist = Game.me.random(2) == 0 ;
	}


	public function setPause(p : Bool) {
		pause = p ;
	}


	public function initSpot(sp : Spot) {
		spots[getSpotIdx(sp)].push(sp) ;
	}


	function getSpotIdx(sp : Spot) : Int {
		return if (sp.isNeutral())
						NEUTRAL
				else if (sp.ennemy)
						ENNEMY
				else 
					PLAYER ;
	}


	public function onNewOwner(sp : Spot, nRace : Race) {
		spots[getSpotIdx(sp)].remove(sp) ;
		var nIdx = (Game.me.isEnnemy(nRace)) ? ENNEMY : PLAYER ;

		spots[nIdx].push(sp) ;

		if (Game.me.isEnnemy(nRace) && avBuildings.length > 0 && sp.canBeBuilded(true))
			sp.revealBuilding( Type.createEnumIndex(Building, avBuildings.shift()) ) ;

		if (reactionCooldown > 0 || (sp == lastReactionSpot && Game.me.random(3) > 0) )
			return ;

		if (pause)
			return ;

		if (sp.isNeutral() && !Game.me.isEnnemy(nRace)) {
			//check for counter attack
			var done = false ;

			var swInfos = getSwarmInfo(sp) ;
			var fPop = sp.curPop + swInfos.pPop ;
			var ePop = swInfos.ePop ;


			if (fPop >= ePop) {
				for (f in [getByDist, getByPop]) {
					fPop = sp.curPop + swInfos.pPop ;
					ePop = swInfos.ePop ;

					var ctSpots = f(sp) ;
					var attackers = [] ;

					for (i in 0...maxOnNewSwarm) {
						if (ctSpots.length <= i)
							break ;
						attackers.push(ctSpots[i]) ;

						ePop += attackers[i].getSendPop() ;

						if (fPop < ePop && Game.me.random(2) == 0)
							break ;
					}

					if (fPop + minDeltaPlayer < ePop && Game.me.random(100) < swCounterAttack) {
						done = true ;
						for (s in attackers)
							Game.me.sendSwarm(s, sp) ;
					}

					if (done)
						break ;
				}
			}

			if (done)
				setReactionCooldown(sp) ;
		}
	}


	public function onNewSwarm(sw : Swarm) {

		if (reactionCooldown > 0)
			return ;

		if (pause)
			return ;

		var NOTHING = 0 ;
		var REINFORCE = 1 ;
		var ATTACK_FROM = 2 ;

		var action = NOTHING ;
		var target = null ;

		if (!Game.me.isEnnemy(sw.owner)) {
			if (Game.me.isEnnemy(sw.to.owner)) {
				var swInfos = getSwarmInfo(sw.to) ;
				var ePop = sw.to.curPop + swInfos.ePop ;
				var pPop = swInfos.pPop ;

				if (ePop <= pPop && !(sw.to == lastReactionSpot && Game.me.random(4) > 0)) { //player is taking it 
					var reinforcers = [] ;

					var distSpots = getByDist(sw.to) ;

					for (i in 0...maxOnNewSwarm) {
						if (distSpots.length <= i)
							break ;
						reinforcers.push(distSpots[i]) ;

						ePop += distSpots[i].getSendPop() ;

						if (ePop > pPop && Game.me.random(2) == 0)
							break ;
					}

					if (ePop > pPop && Game.me.random(100) < swReinforcement) {
						action = REINFORCE ;
						target = sw.to ;
						for (s in reinforcers)
							Game.me.sendSwarm(s, sw.to) ;
					}

					
				} 

				if (action != NOTHING) { //DONE
					setReactionCooldown(target) ;
					return ; 
				}


				if (sw.from == lastReactionSpot && Game.me.random(4) > 0)
					return ;

				for (f in [getByDist, getByPop]) {
					var fPop = sw.from.curPop ;

					var ctSpots = f(sw.from) ;
					var attackers = [] ;

					for (i in 0...maxOnNewSwarm) {
						if (ctSpots.length <= i)
							break ;
						attackers.push(ctSpots[i]) ;

						fPop -= attackers[i].getSendPop() ;

						if (fPop < -minDeltaPlayer && Game.me.random(2) == 0)
							break ;
					}

					if (fPop < -minDeltaPlayer && Game.me.random(100) < swCounterAttack) {
						action = ATTACK_FROM ;
						target = sw.from ;
						for (s in attackers)
							Game.me.sendSwarm(s, sw.from) ;
					}

					if (action != NOTHING) {
						setReactionCooldown(target) ;
						break ;
					}
				}


			}

		}
	}


	function setReactionCooldown(target : Spot) {
		reactionCooldown = REACT_CD ;
		lastReactionSpot = target ;
	}


	function getByDist(sp : Spot) : Array<Spot> {
		var res = spots[ENNEMY].copy() ;
		res.remove(sp) ;

		res.sort(function(a, b) {
			if (Game.dist(a.getCoord(), sp.getCoord()) >= Game.dist(b.getCoord(), sp.getCoord()))
				return -1 ;
			else 
				return 1 ;
		}) ;

		return res ;
	}


	function getByPop(sp : Spot) : Array<Spot> {
		var res = spots[ENNEMY].copy() ;
		res.remove(sp) ;

		res.sort(function(a, b) {
			if (a.curPop > b.curPop)
				return -1 ;
			else 
				return 1 ;
		}) ;

		return res ;
	}


	public function update() {

		if (pause)
			return ;

		if (reactionCooldown > 0.0)
			reactionCooldown-- ;


		coolDown-- ;
		if (coolDown > 0 || (Game.me.swarms.length > 6 || Game.me.random(10) > 0) )
			return ;

		coolDown = Std.int(Math.round(SLEEPPROBS[level] * (0.8 + Game.me.random(5)) )) * 40 ;

		var count = 0 ;
		var replay = 1 ;

		while(replay == 1) {
			var canDo = getTargetsBySpot() ;

			if (canDo.length == 0) //no more IA spots available
				return ;

			switch(Std.int(level)) {
				case 0 : //DUMB
					replay = Game.randomProbs([4 + count * 3, 1]) ;

					var choice = canDo[Game.me.random(canDo.length)] ;
					var spc = choice.to[Game.me.random(choice.to.length)] ;

					for (f in spc.with)
						Game.me.sendSwarm(f, spc.sp) ;

					lastAction = {type : spc.type, spot : spc.sp} ;

				case 1 : //STANDARD
					replay = Game.randomProbs([3 + count * 3, 1]) ;

					var choice = canDo[Game.me.random( Std.int(Math.min(3, canDo.length)) )] ;
					var spc = choice.to[Game.me.random(Std.int(Math.min(3, choice.to.length)) )] ;

					for (f in spc.with)
						Game.me.sendSwarm(f, spc.sp) ;

					lastAction = {type : spc.type, spot : spc.sp} ;

				case 2 : //NO MERCY
					if (canDo[0].prio <= 0) {
						return ;
					}

					if (canDo[0].prio <= 5) {
						if (Game.me.random(8) < 8 - canDo[0].prio) //nothing very interesting. Wait for pop
							return ;
					}

					replay = Game.randomProbs([3 + count * 2, 1]) ;

					var choice = canDo[0] ;

					if (lastAction != null && lastAction.spot == choice.to[0].sp) {
						var prob = 1 ; //fizzle 40% 
						if (Type.enumEq(lastAction.type, choice.to[0].type))
							prob = 3 ; //fizzle 80% 

						if (Game.me.random(5) <= prob)
							return ;
					}

					for (f in choice.to[0].with)
						Game.me.sendSwarm(f, choice.to[0].sp) ;

					lastAction = {type : choice.to[0].type, spot : choice.to[0].sp} ;

				case 3 : 
					throw "invalid ia level" ;
			}
			count++ ;
		}
	}


	function getSwarmInfo(to : Spot) : {ePop : Int, pPop : Int, curPlayerSwarms : Int} {

		var res = {ePop : 0, pPop : 0, curPlayerSwarms : 0} ;

		for (sw in Game.me.swarms.copy()) {
			if (sw.to.id != to.id)
				continue ;

			var aiSwarm = Game.me.isEnnemy(sw.owner) ;
			if (!aiSwarm)
				res.curPlayerSwarms++ ;
			
			if (aiSwarm)
				res.ePop += sw.pop ;
			else 
				res.pPop += sw.pop ;
		}
		return res ;
	}


	function getTargetsBySpot() : Array<{prio : Int, from : Spot, to : Array<{ type : TargetType, sp : Spot, with : Array<Spot>}>}> {
		var res = new Array() ;

		//#####################################
		var eval = function(i : Int, from : Array<Spot>, t : Spot, ?lastBest : TargetType) {

			for (f in from) {
				if (f == t)
					return null ;
			}

			var pop = 0 ;
			for (f in from)
				pop += f.getSendPop() ;

			var info : {type : TargetType, sp : Spot, with : Array<Spot> } = {type : null,
							sp : t, with : from.copy()} ;

			var swInfos = getSwarmInfo(t) ;

			switch(i) {
				case PLAYER : 
					var ePop = swInfos.ePop ;
					var pPop = t.curPop + swInfos.pPop ;

					if (ePop > pPop)
						info.type = ReInforce ;
					else {
						ePop += pop ;
						info.type = (ePop >= pPop + minDeltaPlayer + Std.int(Game.dist(from[0].getCoord(), t.getCoord()) / 10 )) ? TakePlayer : WeakenPlayer ; //prend la distance en compte pour évaluer le besoin en pop
					}

				case NEUTRAL : 

					//if (swInfos.curPlayerSwarms == 0) {
						var ePop = swInfos.ePop + pop ;
						/*var pPop = if (t.curPop < swInfos.pPop) 
										swInfos.pPop - t.curPop ;
									else 
										t.curPop - swInfos.pPop ;*/
						var pPop = t.curPop + swInfos.pPop ; //on maximise la taille sans prendre en compte la distance. On considère que tout appartient au joueur (swarms + neutres) 

						info.type = (ePop >= pPop + minDeltaNeutral) ? TakeNeutral : WeakenNeutral ;
					//}

				case ENNEMY : 
					var ePop = swInfos.ePop + t.curPop ;
					var pPop = swInfos.pPop ;
					
					if (swInfos.curPlayerSwarms > 0) {
						if (ePop <= pPop) { //player is taking it 
							ePop += pop ;
							if (ePop > pPop)
								info.type = SaveField ;
						} else 
							info.type = ReInforce ;

					} else if (info.sp.building != null && ePop < 20 )
						info.type = ReInforce ;
			}

			if (info.type == null)
				return null ;

			if (lastBest != null && getPrio(lastBest, t) >= getPrio(info.type, t))
				return null ;

			return info ;
		} ;
		//############################

		var withOtherSpots = level >= 2 && Game.me.random(Std.int(Math.max(1, 4 - maxOnNewSwarm))) == 0 ; 


		for (f in spots[ENNEMY].copy()) {
			var r = { prio : 0, from : f, to : [] } ;

			for (i in 0...3) {
				for (t in spots[i].copy()) {
					var info = eval(i, [f], t) ;
					
					if (info == null)
						continue ;

					if (withOtherSpots && (i != NEUTRAL || t.curPop <= 28)) { //on ne force pas à prendre les plus gros enclos neutres avec du multi enclos => on laisse le joueur se planter dessus et récupérer ses points
							var others = getOtherSpots(f) ;
							var froms = [f] ;
							for (o in others) {
								froms.push(o) ;
								var alter = eval(i, froms, t, info.type) ;
								if (alter == null)
									continue ;

								if (getPrio(alter.type, t) > getPrio(info.type, t)) 
									info = alter ;
							}
					}

					var prio = getPrio(info.type, info.sp) ;
					if (prio > r.prio)
						r.prio = prio ;
					r.to.push(info) ;
				}

				r.to.sort(function(a, b) {

					var ap = 0 ;
					var bp = 0 ;

					ap = getPrio(a.type, a.sp) ;
					bp = getPrio(b.type, b.sp) ;

					if (ap > bp)
						return -1 ;
					else if (ap < bp)
						return 1 ;
					else {
						if (!Type.enumEq(a.type, b.type)) {
							if (a.with.length != b.with.length)
								return (a.with.length <= b.with.length) ? -1 : 1 ;
							else
								return (Game.me.random(2) == 0) ? -1 : 1 ;
						} else {
							/*if (a.with.length != b.with.length)
								return (a.with.length <= b.with.length) ? -1 : 1 ;*/

							switch(a.type) {
								case TakePlayer :

									var dista = Game.dist(f.getCoord(), a.sp.getCoord()) ;
									var distb = Game.dist(f.getCoord(), b.sp.getCoord()) ;

									var va = a.sp.curPop - a.sp.size * 3 + Std.int(dista / 10) ;
									var vb = b.sp.curPop - b.sp.size * 3 + Std.int(distb / 10);

									return (va <= vb) ? -1 : 1 ;

								case WeakenPlayer : 
									var dista = Game.dist(f.getCoord(), a.sp.getCoord()) ;
									var distb = Game.dist(f.getCoord(), b.sp.getCoord()) ;

									var va = a.sp.curPop - a.sp.size * 3 + Std.int(dista / 10) ;
									var vb = b.sp.curPop - b.sp.size * 3 + Std.int(distb / 10);

									return (va <= vb) ? -1 : 1 ;

								case TakeNeutral : 
									var dista = Game.dist(f.getCoord(), a.sp.getCoord()) ;
									var distb = Game.dist(f.getCoord(), b.sp.getCoord()) ;

									var va = a.sp.curPop - a.sp.size * 3 + Std.int(dista / 10) ;
									var vb = b.sp.curPop - b.sp.size * 3 + Std.int(distb / 10);

									return (va <= vb) ? -1 : 1 ;

								case WeakenNeutral : 
									return (a.sp.size >= b.sp.size) ? -1 : 1 ; //big spots first 				

									//### TODO : minor pop cost 

								case ReInforce : 
									var dista = Game.dist(f.getCoord(), a.sp.getCoord()) ;
									var distb = Game.dist(f.getCoord(), b.sp.getCoord()) ;

									return (dista <= distb) ? -1 : 1 ; //nearest spots first


								case SaveField : 
									var dista = Game.dist(f.getCoord(), a.sp.getCoord()) ;
									var distb = Game.dist(f.getCoord(), b.sp.getCoord()) ;

									return (dista <= distb) ? -1 : 1 ; //nearest spots first
							}
						}
					}

					
				} ) ;
			}
			if (r.to.length > 0)
				res.push(r) ;		
		}

		res.sort(function(a, b) { 
				if (a.prio > b.prio)
					return -1 ;
				else if (a.prio < b.prio)
					return  1 ;
				else {
					if (a.to[0].with.length < b.to[0].with.length)
						return -1 ;
					else if (a.to[0].with.length > b.to[0].with.length)
						return 1 ;
					else 
						return (Game.me.random(2) == 0) ? -1 : 1 ;
				}
		}) ;

		return res ;
	}


	function getOtherSpots(f : Spot) : Array<Spot> {
		var avSpots = spots[ENNEMY].copy() ;
		avSpots.remove(f) ;
		var max = Std.int(Math.min(avSpots.length, 2)) ;
		if (multiByDist)
			max-- ;

		if (max <= 0)
			return [] ;

		var res = [] ;
		
		while (max > res.length && avSpots.length > 0) {
			var dMin : {d : Float, s : Spot} = { d : 90000.0, s : null } ;
			for (s in avSpots) {
				var d = Game.dist(f.getCoord(), s.getCoord()) ;
				if (dMin.d > d)
					dMin = {d : d, s : s} ;
			}

			if (dMin.s != null) {
				res.push(dMin.s) ;
				avSpots.remove(dMin.s) ;
			}
		}


		if (multiByDist) {
			var sMax = f ;
			for (s in avSpots) {
				if (s.curPop >= sMax.curPop)
					sMax = s ;
			}
			if (sMax != f) {
				res.push(sMax) ;
				avSpots.remove(sMax) ;
			}
		}

		return res ; 
	}


	public function getPrio(t : TargetType, sp : Spot) {
		var a = haxe.rtti.Meta.getFields(TargetType) ;
		var p =  Reflect.field(a, Std.string(t)).prio[0] ;

		switch(t) {
			case TakePlayer : 
				if (sp.building != null) {
					switch(sp.building) {
						case MoreSex, Rage : p += 3 ;
						case Fast, Slow : p += 2 ;
						case Watch, Bonus : p += 1 ;
						case Plague, Bunker : p += 0 ;
						case Box, TinyBox : p += (avBuildings != null && avBuildings.length > 0) ? 2 : 1 ;
					}
				}

			case WeakenPlayer :
				if (spots[ENNEMY].length > Std.int(Math.round(spots[PLAYER].length * 5 / 4)))
					p += 1 ;

			case TakeNeutral : 
				if (spots[ENNEMY].length == 1) 
					p += 30 ;
				else if (spots[ENNEMY].length < Std.int(Math.round(spots[PLAYER].length * 3 / 4)) )
					p += 5 ;
				else if (spots[ENNEMY].length < Std.int(Math.round(spots[PLAYER].length * 4 / 3)) )
					p += 3 ;

				//if (AKApi.getGameMode() == GM_LEAGUE)
					p += 8 ;

				/*if (sp.building != null)
					p += 1 ;*/

			case WeakenNeutral :

				/*if (spots[ENNEMY].length >= spots[PLAYER].length)
					p += 3 ;*/
				

			case ReInforce : 

				if (sp.building != null) {
					switch(sp.building) {
						case Plague : p += 4 ;
						case Rage : p += 3 ;
						case Slow : p += 2 ;
						default : //nothing to do 
					}

				}
				

			case SaveField : 
				//nothing to do

		}


		/*if (sp.curPop < 25)
			p -= 1 ;*/

		return p ;

	}




}