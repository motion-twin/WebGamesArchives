import data.PuzzleData.PuzzlePiece;
import data.Message;
import data.Battle;

private enum EUnit {
	Soldier;
	Archer;
	Cavalier;
	Paladin;
	Piquier;
	Chevalier;
	ArcherMonte;
	Balist;
	Catapult;
}

/*

	TIME = 1 minute ~= 1 "day"

	generals : updated every minute (and async)
	user : 1 turn = 30 minutes ~= 1 month age
	map : 1 map turn = 5 minutes ~= 5 days age
	resources : spawn 1 every map turn (produce : 6/user-turn)

*/

class Rules {

	static inline var SPRIO = 5; // soldiers probability priority over other units
	static var TRADE_PROTECT_FACTOR = 0.5;
	public static inline var HEALTH_PROTECT = 50;

	// maximum number of minutes that we can update in one batch (consider server crash if more)
	static inline var MAX_DELAY = 90;

	public static var PIECES = {
		var p = new Array<PuzzlePiece>();
		for( c in Type.getEnumConstructs(PuzzlePiece) )
			p.push(Reflect.field(PuzzlePiece,c));
		p;
	}

	public static function randomProbas( a : Array<Int> ) {
		var tot = 0;
		for( x in a )
			tot += x;
		tot = Std.random(tot);
		for( i in 0...a.length ) {
			tot -= a[i];
			if( tot < 0 ) return i;
		}
		return -1;
	}

	public static function getPuzzleProbas( c : db.City, t : Array<Array<Int>> ) {
		var p = [
			30,	// PFood
			30,	// PGold
			30,	// PWood
			30,	// PBuild
			1,	// PSoldier
			1,	// PPeople
			0,	// PGather
			20,	// PAgain
		];
		var people = c.getPeopleCount();
		var k = Math.ceil(Math.pow(people,2));
		// add soldier if enough gold
		if( c.gold >= (k>>1) )
			p[4] = 15;
		// add people if enough food
		if( c.food >= k )
			p[5] = 25 - (people >> 2);
		if( people >= 100 )
			p[5] = 0;
		return p;
	}

	public static function getLevelCost( level : Int, r : data.Resource ) {
		if( r == null ) // turns
			return [2,4,9,20,40][level];
		return switch( r.k ) {
		case RFood: [10,25,50,200,500][level];
		case RWood: [20,50,100,400,950][level];
		case RGold: [20,40,80,300,650][level];
		case RHorse,RLin,RMetal: [5,20,40,70,100][level];
		};
	}

	static var COMBOS = [0,0,0,1,1.25,1.5,2,3,4];

	public static function getMaxStock( c : db.City, r : data.Resource ) {
		if( !c.isCity )
			return 9999;
		return switch( r.k ) {
		case RFood:
			[100,250,600,1500,3500,9999][c.getBuildingLevel(Data.BUILDINGS.list.store)];
		case RWood:
			[100,300,500,2000,5000,9999][c.getBuildingLevel(Data.BUILDINGS.list.hut)];
		case RGold:
			9999;
		case RHorse:
			[10,50,100,150,200,500][c.getBuildingLevel(Data.BUILDINGS.list.stable)];
		case RLin:
			[10,50,100,150,200,500][c.getBuildingLevel(Data.BUILDINGS.list.factry)];
		case RMetal:
			[10,50,100,150,200,500][c.getBuildingLevel(Data.BUILDINGS.list.forge)];
		};
	}

	public static function getMaxTaxes( u : db.User, r : data.Resource ) {
		return switch(r.k) {
		case RFood, RGold, RWood:
			[0,10,15,20,25,30][u.city.getBuildingLevel(Data.BUILDINGS.list.palace)];
		case RHorse, RLin, RMetal:
			[0,0,20,40,60,80][u.city.getBuildingLevel(Data.BUILDINGS.list.palace)];
		};
	}

	static function lostResources( u : db.User, r : data.Resource, count : Int ) {
		if( u == null || count <= 0 )
			return;
		switch( r.k ) {
		case RGold, RFood, RWood:
		default: return;
		}
		var goal = App.GOALS.resolve(r.id);
		if( goal != null )
			App.api.incrementGoal(goal,u,count);
	}

	public static function produce( c : db.City, p : PuzzlePiece, combo : Int ) {
		var v : Int = 0;
		var f = COMBOS[combo];
		var R = Data.RESOURCES.list;
		var maximize = function(cur,r) {
			var max = getMaxStock(c,r);
			var lost = (v + cur) - max;
			if( lost > 0 ) {
				v -= lost;
				if( v < 0 ) v = 0;
			}
			db.Log.city(c,MCityProduce(r.id,v));
			if( lost > 0 ) {
				db.Log.city(c,MCityLost(r.id,lost));
				lostResources(c.user,r,lost);
			}
		};
		switch( p ) {
		case PFood:
			f *= [1,1.3,1.55,1.75,1.9,2][c.getBuildingLevel(Data.BUILDINGS.list.farm)];
			v = Std.int(f * c.farmers * 6);
			if( v == 0 ) v = 1;
			maximize(c.food,R.food);
			c.food += v;
		case PGold:
			f *= [1,1.3,1.55,1.75,1.9,2][c.getBuildingLevel(Data.BUILDINGS.list.market)];
			v = Std.int(f * c.merchants * 6);
			if( v == 0 ) v = 1;
			maximize(c.gold,R.gold);
			c.gold += v;
		case PWood:
			f *= [1,1.3,1.55,1.75,1.9,2][c.getBuildingLevel(Data.BUILDINGS.list.hut)];
			v = Std.int(f * c.wooders * 5);
			if( v == 0 ) v = 1;
			maximize(c.wood,R.wood);
			c.wood += v;
		case PBuild:
			f *= [1,1.3,1.55,1.75,1.9,2][c.getBuildingLevel(Data.BUILDINGS.list.wshop)];
			v = Std.int(f * c.workers);
			if( c.placeId != null )	{
				c.placeValue += v;
				db.Log.city(c,MCityBuildProgress(v));
			} else {
				v *= [0,1,2,3,4,5][c.getBuildingLevel(Data.BUILDINGS.list.yard)];
				if( v == 0 )
					db.Log.city(c,MCityBuildWasted);
				else {
					var old = v;
					maximize(c.food,R.food);
					c.food += v;
					v = old;
					maximize(c.gold,R.gold);
					c.gold += v;
					v = old;
				}
			}
		case PSoldier:
			if( c.getBuildingLevel(Data.BUILDINGS.list.casern) == 0 ) {
				v = 0;
				db.Log.city(c,MCityNoCasern);
			} else if( !c.user.recruit ) {
				v = 0;
				db.Log.city(c,MCityNoRecruit);
			} else {
				v = c.recruiters + (combo - 2);
				var u = c.initDefense();
				u.soldiers += v;
				u.update();
				db.Log.city(c,MCityNewSoldiers(v));
			}
		case PPeople:
			v = 1;
			c.pending += v;
			for( i in 0...v )
				db.Log.city(c,MCityNewPeople);
		case PGather:
			throw "Not used";
		case PAgain:
			v = combo - 2;
			var p = c.getPuzzle();
			p.actions += v;
			if( p.actions > db.Puzzle.MAX_ACTIONS ) {
				v -= p.actions - db.Puzzle.MAX_ACTIONS;
				p.actions = db.Puzzle.MAX_ACTIONS;
			}
			p.turns -= v;
			db.Log.city(c,MCityMoreActions(v));
		}
		return v;
	}

	public static function getUnitCostFactor( c : db.City, b : data.Building ) {
		var B = Data.BUILDINGS.list;
		return switch( b ) {
		case B.cat, B.bal: [1.0,1.0,0.8,0.7,0.6,0.5][c.getBuildingLevel(B.wshop)];
		default: throw "assert";
		}
	}

	public static function calculateFood( c : db.City ) {
		return c.getPeopleCount();
	}

	public static function calculateTrade( c : db.City ) {
		var neg = (c.cumulativeLoss < 0) ? -1 : 1;
		// reverse n(k) = n(k-1) + k
		var k = (Math.sqrt(1 + 8 * neg * c.cumulativeLoss / 10) - 1) * 0.5;
		return Math.floor( neg * k );
	}

	public static function inverseTrade( v : Int ) {
		if( v < 0 ) return -inverseTrade(-v);
		return v * (v + 1) * 5; // n(k) = n(k-1) + k
	}

	public static function calculateTaxesPercent( c : db.City ) {
		return if( !c.isConnected || c.king == null ) 0 else 20;
	}

	public static function calculateSpent( c : db.City ) {
		var unitCount = 0;
		var units = db.Units.manager.search({ uid : c.user.id },false);
		for( u in units ) {
			u.free = 0;
			unitCount += u.count();
		}
		var freeUnits = 0;
		var def = c.defenseRO;
		if( def != null ) {
			var max = [0,5,10,20,50,100][c.getBuildingLevel(Data.BUILDINGS.list.casern)];
			def.free = def.count();
			if( def.free > max ) def.free = max;
			freeUnits += def.free;
		}
		for( g in db.General.manager.search({ uid : c.user.id },false) ) {
			var u = g.unitsRO;
			var n = u.count();
			u.free = (n >= g.reputation) ? g.reputation : n;
			freeUnits += u.free;
		}
		var trade = 0;
		c.trade = 0;
		for( c in db.City.manager.search({ kid : c.user.id },false) ) {
			if( c.isCity ) {
				c.trade = 0;
				continue;
			}
			c.trade = calculateTrade(c);
			if( c.garnisonRO == null )
				c.tradeUp = false;
			else {
				var dt = c.garnisonRO.count() - Math.ceil(c.trade*TRADE_PROTECT_FACTOR);
				if( dt != 0 )
					c.tradeUp = dt > 0;
			}
			if( c.isConnected || c.trade < 0 )
				trade += c.trade;
		}
		var tpercent = Rules.calculateTaxesPercent(c);
		var taxes = if( trade <= 0 ) 0 else Math.ceil(trade*tpercent/100);
		return {
			food : calculateFood(c),
			units : units,
			unitCount : unitCount,
			freeUnits : freeUnits,
			unitGold : unitCount - freeUnits,
			tradeGold : trade,
			taxesGold : taxes,
			taxesPercent : tpercent,
			gold : (unitCount - freeUnits) - trade + taxes,
		};
	}

	public static function nextTurn( c : db.City ) {
		var badHealth = false;
		for( c in db.City.manager.search({ kid : c.user.id, isCity : false },false) ) {
			var c = db.City.manager.get(c.id);
			var g = c.garnisonRO;
			var dt = if( g == null ) -c.distanceToKing else g.count();
			if( c.cumulativeLoss > 0 )
				dt -= Math.ceil(calculateTrade(c)*TRADE_PROTECT_FACTOR);
			c.cumulativeLoss += (dt < 0) ? -dt * dt : dt;
			if( c.cumulativeLoss < 0 ) {
				var maxLoss = -inverseTrade(c.distanceToKing * c.distanceToKing * 2);
				if( c.cumulativeLoss < maxLoss )
					c.cumulativeLoss = maxLoss;
			}
			c.update();
		}
		var spent = calculateSpent(c);
		var u = db.User.manager.get(c.user.id);
		u.trade = spent.tradeGold;
		if( u.trade > u.maxTrade )
			u.maxTrade = u.trade;
		c.food -= spent.food;
		c.gold -= spent.gold;
		db.Log.city(c,MCityConsume(spent.food,if( c.gold < 0 ) spent.gold + c.gold else spent.gold));
		if( spent.taxesGold > 0 ) {
			var rel = db.Relation.manager.getWithKeys({ uid : c.king.id, tid : u.id },true);
			if( rel == null ) {
				rel = new db.Relation();
				rel.user = c.king;
				rel.target = u;
				rel.insert();
			}
			rel.pendingGold += spent.taxesGold;
			rel.update();
		}
		if( c.gold < 0 ) {
			var deficit = -c.gold;
			c.cumulativeLoss += 1 + Std.random(Math.ceil(deficit/3));
			c.gold = 0;
			var uprobas = new Array(), units = new Array();
			for( u in spent.units ) {
				var special = u.count() - u.soldiers;
				var p = special + u.soldiers * SPRIO - ((special >= u.free) ? u.free : special + (u.free - special) * SPRIO);
				if( p <= 0 ) continue;
				uprobas.push(p);
				units.push(db.Units.manager.get(u.id));
			}
			var ulost = Std.random(c.cumulativeLoss);
			var umax = spent.unitCount - spent.freeUnits;
			if( ulost > umax ) ulost = umax;
			for( i in 0...ulost ) {
				// select unit group
				var gid = randomProbas(uprobas);
				var g = units[gid];
				// select unit
				var u = g.get();
				var probas = u.copy();
				probas[0] *= SPRIO;
				var uid = randomProbas(probas);
				u[uid]--;
				if( uid == 0 )
					uprobas[gid] -= SPRIO;
				else
					uprobas[gid]--;
				g.set(u);
			}
			for( p in 0...units.length ) {
				var u = units[p];
				if( u.count() == 0 ) {
					u.delete();
					// fix in case we just inserted defense
					if( u == c.defense ) c.defense = null;
				} else
					u.update();
			}
			if( umax > 0 ) {
				db.Log.city(c,MCityDesert(ulost));
				if( App.user == u ) {
					switch( ulost ) {
					case 0: App.api.addSessionMessage(Text.get.event_soldier_angry,null);
					case 1: App.api.addSessionMessage(Text.get.event_soldier_leave_one,null);
					default: App.api.addSessionMessage(Text.get.event_soldier_leave,{ count : ulost });
					}
				}
			} else if( deficit > 0 )
				db.Log.city(c,MCityDeficit(deficit));
			// if too much loss, lose one territory
			if( (umax == 0 && deficit > 0) || c.cumulativeLoss > 10 + u.curTerritory * 3 ) {
				var targets = Lambda.array(db.City.manager.search({ kid : u.id, isCity : false },false));
				for( c in targets )
					c.trade = calculateTrade(c);
				targets.sort(function(c1,c2) return (c1.trade == c2.trade) ? c2.distanceToKing - c1.distanceToKing : c1.trade - c2.trade);
				var target = targets[0];
				if( target != null ) {
					target = db.City.manager.get(target.id);
					target.king = null;
					var g = target.garnison;
					if( g != null ) {
						g.prevUser = g.user;
						g.user = null;
						g.update();
						if( target.isCity )
							g.delete();
					}
					target.update();
					db.Log.user(u,MUserLostDeficit(target.id));
					updateTerritory(u);
					c.cumulativeLoss = 0;
					if( App.user == u )
						App.api.addSessionMessage(Text.get.event_crisis_lost,{ name : target.name, id : target.id });
				}
			}
		} else {
			var rgold = Data.RESOURCES.list.gold;
			var lost = c.gold - getMaxStock(c,rgold);
			if( lost > 0 ) {
				c.gold -= lost;
				db.Log.city(c,MCityLost(rgold.id,lost));
				lostResources(c.user,Data.RESOURCES.list.gold,lost);
			}
			c.cumulativeLoss -= Math.ceil(c.gold/3);
			if( c.cumulativeLoss < 0 )
				c.cumulativeLoss = 0;
		}
		if( c.food < 0 ) {
			c.food = 0;
			// kill one at random
			var r = c.getPeople();
			r[0].n--; // always save one farmer
			var tot = 0;
			for( p in r ) tot += p.n;
			tot = Std.random(tot);
			for( i in 0...r.length ) {
				tot -= r[i].n;
				if( tot < 0 ) {
					r[i].n--;
					r[0].n++;
					c.setPeople(r);
					c.food = c.getPeopleCount();
					if( App.user == u ) App.api.addSessionMessage(Text.get.event_people_die,r[i].p);
					db.Log.city(c,MCityStarve(r[i].p.id));
					break;
				}
			}
		}
		// age = 30-150 ans
		if( u.age > age(30) && u.age > u.lastHealthIssue + HEALTH_PROTECT && Std.random((age(150) - u.age) >> 4) == 0 )
			badHealth = true;
		if( badHealth ) {
			u.health++;
			u.lastHealthIssue = u.age;
			if( u.health >= 3 ) {
				gameOver(u);
				db.Log.map(c.map,MMapKingDied(u.getTitle().id,u.id,c.id,u.age));
			}
			db.Log.user(u,MUserHealth(u.health));
		}
		// update user
		u.update();
	}

	public static inline function age( years ) {
		return (years - 20) * 12 << 2;
	}

	public static function recruitGeneralCost( c : db.City ) {
		if( c.user == null ) return null;
		var gcount = db.General.manager.count({ uid : c.user.id });
		if( gcount >= c.getBuildingLevel(Data.BUILDINGS.list.hq) )
			return null;
		return Std.int(50 * Math.pow(2,gcount));
	}

	public static function canHaveRecruiter( c : db.City ) {
		return c.getBuildingLevel(Data.BUILDINGS.list.casern) > 1;
	}

	public static function getFearTime( m : db.Map, units : Int ) {
		return DateTools.hours(units * 3) / m.getSpeed();
	}

	public static function updateTime( v : { lastUpdate : Date }, k : Float, ?max = MAX_DELAY ) {
		var now = Date.now().getTime();
		var last = v.lastUpdate.getTime();
		var min = Std.int((now - last)/DateTools.minutes(1));
		if( min > max && max > 0 ) {
			last += DateTools.minutes(min - max);
			v.lastUpdate = Date.fromTime(last);
			min = max;
			if( k > max ) throw "assert";
		}
		min = Std.int(min/k);
		if( min <= 0 ) return 0;
		v.lastUpdate = Date.fromTime(last + DateTools.minutes(min*k));
		return min;
	}

	static function generalSpeed( g : db.General, from : db.City, to : db.City ) {
		return 0.15 * g.map.getSpeed() * (to.canPass(g.user) && from.canPass(g.user) ? 3 : 1);
	}

	public static function updateGeneral( g : db.General, ?minutes ) {
		if( minutes == null )
			minutes = updateTime(g,1); // don't use map speed, since it's calculated in generalSpeed already
		if( minutes <= 0 )
			return;
		var dx = g.cityTo.x - g.cityFrom.x;
		var dy = g.cityTo.y - g.cityFrom.y;
		var d = Math.sqrt(dx*dx+dy*dy);
		var ratio = d / db.General.PROGRESS_MAX;
		var speed = generalSpeed(g,g.cityFrom,g.cityTo);
		var cur = g.progress * ratio + minutes * speed;
		if( cur < d )
			g.progress = Std.int(cur / ratio);
		else {
			// arrived
			var old = g.cityFrom;
			var c = g.cityTo;
			g.cityFrom = c;
			g.cityTo = old;
			g.progress = 0;
			g.moving = false;
			// next move
			var n = g.getNextMoves().first();
			if( n != null ) {
				if( c.canCross(g.user) ) {
					g.cityTo = n;
					g.moving = true;
					g.updateNextMove();
					var minutes = Std.int((cur - d) / speed);
					updateGeneral(g,minutes);
					return;
				}
				g.resetNextMoves();
			}
			// auto-attack
			var king = if( c.user != null ) c.user else c.king;
			if( king != null && db.Relation.get(g.user,king).friendly == false ) {
				try {
					new handler.General().startAttack(g,false);
				} catch( e : handler.Action ) {
					// ok
				}
			}
		}
	}

	public static function generalETA( g : db.General ) {
		var dx = g.cityTo.x - g.cityFrom.x;
		var dy = g.cityTo.y - g.cityFrom.y;
		var d = Math.sqrt(dx*dx+dy*dy);
		var cur = d * g.progress / db.General.PROGRESS_MAX;
		var next = g.lastUpdate.getTime() + DateTools.minutes(Math.ceil((d - cur) / generalSpeed(g,g.cityFrom,g.cityTo)));
		if( next < Date.now().getTime() ) {
			var g = db.General.manager.get(g.id);
			updateGeneral(g);
			g.update();
			if( g.moving )
				return generalETA(g);
			return Date.now();
		}
		var cur = g.cityTo;
		for( p in g.getNextMoves() ) {
			var dx = p.x - cur.x;
			var dy = p.y - cur.y;
			var d = Math.sqrt(dx*dx+dy*dy);
			next += DateTools.minutes(Math.ceil(d) / generalSpeed(g,cur,p));
			cur = p;
		}
		return Date.fromTime(next);
	}

	public static function setMapTime( map : db.Map, delta : Float ) {
		var date = function(d:Date) return Date.fromTime(d.getTime() + delta);
		for( g in db.General.manager.search({ mid : map.id, moving : true },true) ) {
			g.lastUpdate = date(g.lastUpdate);
			g.update();
		}
		for( b in db.Battle.manager.search({ mid : map.id, ended : null },true) ) {
			b.lastUpdate = date(b.lastUpdate);
			b.update();
		}
		for( c in db.City.manager.search({ mid : map.id, isCity : true },true) ) {
			var p = c.getPuzzle();
			if( p == null ) continue;
			p.lastUpdate = date(p.lastUpdate);
			p.update();
		}
		map.lastUpdate = date(map.lastUpdate);
		map.update();
	}

	public static function updateMap( map : db.Map ) {
		// map turns
		var turns = updateTime(map,30 / map.getSpeed());
		// move all generals
		for( g in db.General.manager.search({ mid : map.id, moving : true },true) ) {
			updateGeneral(g);
			g.update();
		}
		// update battles
		for( b in db.Battle.manager.search({ mid : map.id, ended : null },true) ) {
			updateBattle(b);
			b.update();
		}
		// distribute place ressources
		var places = null;
		if( turns > 0 ) {
			places = db.City.manager.getResourcePlaces(map);
			for( c in places ) {
				var max = 50 - c.resourcesCount();
				if( max <= 0 ) continue;
				if( c.placeValue <= 0 ) {
					if( c.resourcesCount() == 0 ) {
						c.placeId = null;
						c.update();
					}
					continue;
				}
				var k = (turns > c.placeValue) ? c.placeValue : turns;
				if( k >= max ) k = max;
				c.giveResources([{ r : c.getPlaceResource(), n : k }]);
				c.placeValue -= k;
				c.update();
			}
		}
		// create new place ?
		for( i in 0...turns )
			if( places.length < Std.random(map.totalCities) && Std.random(5) == 0 ) {
				var R = Data.RESOURCES.list;
				var possible = db.City.manager.search({ mid : map.id, isCity : false, placeId : null },true);
				// only allow ressources if not already a ressource around
				for( c in possible )
					if(
						(c.link1 != null && !c.link1.isCity && c.link1.placeId != null) ||
						(c.link2 != null && !c.link2.isCity && c.link2.placeId != null) ||
						(c.link3 != null && !c.link3.isCity && c.link3.placeId != null) ||
						(c.link4 != null && !c.link4.isCity && c.link4.placeId != null)
					)
						possible.remove(c);
				var possible = Lambda.array(possible);
				var possibleRessources = [R.horse,R.lin,R.metal];
				var p = possible[Std.random(possible.length)];
				var r = possibleRessources[Std.random(possibleRessources.length)];
				if( p != null ) {
					p.placeId = r.rid;
					p.placeValue = ( 20 + Std.random(20) ) * 10;
					p.update();
					db.Log.map(map,MMapNewPlace(p.id,r.id));
				}
			}
		// decadent cities
		for( c in db.City.manager.getDecadent(map) ) {
			var c = db.City.manager.get(c.id);
			if( c.user == null ) {
				// can occur only if user deleted (tests)
				c.reset();
				c.update();
				continue;
			}
			// play unused turns with around the same speed as a normal user
			var p = c.getPuzzle();
			p.updateActions();
			{
				for( i in freeLostTurns(p)...p.lostActions ) {
					nextTurn(c);
					p.lostActions--;
					if( c.user == null )
						break;
				}
			}
			p.update();
			// if the city is back to empty, reset it
			if( c.user != null && c.getPeopleCount() <= 1 ) {
				var u = c.user;
				gameOver(u);
				db.Log.user(u,MUserDecadent);
				db.Log.map(map,MMapKingdomDecadent(u.getTitle().id,u.id,c.id));
			}
			c.update();
		}
		// mark map as updated
		map.turns += turns;
		map.update();
	}

	public static function updateTerritory( u : db.User, ?rec = true ) {
		u = db.User.manager.get(u.id);
		if( u.city == null ) return; // already dead
		var kingdom = db.City.manager.search({ kid : u.id },true);
		for( c in kingdom )
			c.isConnected = false;
		var vassals = db.City.manager.getVassalsTerritory(u);
		// update territory size and give title
		u.curTerritory = kingdom.length + 1 + vassals.length;
		if( u.curTerritory > u.maxTerritory ) {
			var oldT = u.getTitle();
			u.maxTerritory = u.curTerritory;
			var newT = u.getTitle();
			if( newT != oldT ) {
				db.Log.map(u.map,MMapUserPromote(u.id,newT.id));
				db.Log.user(u,MUserPromote(newT.id));
				u.updateGameInfos();
				App.api.addUserHistory(Text.format(Text.get.got_title,{ name : u.getTitle().name }),u);
				if( newT.goal != null && u.map.group == null )
					App.api.incrementGoal(newT.goal,u);
				if( newT == Data.TITLES.list.emper ) {
					var m = db.Map.manager.get(u.map.id);
					m.lastEmperor = u;
					m.update();
				}
			}
		}
		u.update();
		// mark territory as connected
		var cl = new List();
		var walk = db.City.manager.getConnectedTerritory(u);
		cl.add(u.city);
		while( cl.length > 0 ) {
			var c = cl.pop();
			for( c2 in kingdom ) {
				if( c2.isConnected )
					continue;
				if( c2.id == c.lid1 || c2.id == c.lid2 || c2.id == c.lid3 || c2.id == c.lid4 ) {
					c2.isConnected = true;
					cl.add(c2);
				}
			}
			for( c2 in walk )
				if( c2.id == c.lid1 || c2.id == c.lid2 || c2.id == c.lid3 || c2.id == c.lid4 ) {
					cl.add(c2);
					walk.remove(c2);
				}
		}
		// commit
		for( c in kingdom )
			c.update();
		// our territory change might impact other users
		if( rec ) {
			for( u in db.City.manager.getTerritoryChangeImpact(u) )
				updateTerritory(u,false);
		}
	}

	public static function setKing( c : db.City, k : db.User, g : db.General, battle : db.Battle ) {
		// update city
		var oldKing = c.king;
		k.city.buildDistMap(TAG++,0);
		c.king = k;
		c.distanceToKing = c.dist;
		c.update();
		// tell the world about it
		if( battle == null ) {
			if( c.isCity ) db.Log.map(c.map,MMapControlNoFight(k.id,c.id,g.name));
		} else if( g == null )
			db.Log.map(c.map,MMapRevoltStopped(k.id,c.id));
		else
			db.Log.map(c.map,MMapBattleWon(k.id,c.id,g.name));
		// clear previous user kingdom
		if( c.user != null ) {
			var kingdom = db.City.manager.search({ kid : c.user.id },true);
			for( c in kingdom ) {
				if( c.user != null )
					db.Log.user(c.user,MUserKingDefeat(c.king.id,k.id));
				c.king = null;
				var g = c.garnison;
				if( g != null ) {
					if( c.isCity )
						g.delete();
					else {
						g.prevUser = g.user;
						g.user = null;
						g.update();
					}
				}
				c.update();
			}
			for( g in db.General.manager.search({ uid : c.user.id },true) ) {
				g.fortify = false;
				var b = g.units.battle;
				// remove general from battle if fighting against new king
				if( b != null && b.getCurrentCamp(k) != null ) {
					var b = db.Battle.manager.get(b.id);
					Rules.updateBattle(b);
					g.units.battle = null;
					g.units.update();
					Rules.updateBattle(b);
					b.update();
				}
				g.update();
			}
			if( kingdom.isEmpty() )
				db.Log.user(c.user,MUserNewKing(k.id));
			else {
				db.Log.map(c.map,MMapKingdomDestroy(k.id,c.user.id,c.id));
				db.Log.user(c.user,MUserLostKingdom(k.id));
			}
			updateTerritory(c.user);
			var ucount = if( battle != null ) battle.getUnitsCount(false) else g.units.count();
			c.user.kingFear = Date.fromTime(Date.now().getTime() + getFearTime(c.map,ucount));
			c.user.update();
		}
		// notice previous king
		if( oldKing != null )
			db.Log.user(oldKing,MUserLostPlace(c.id,k.id));
		// notice new king
		db.Log.user(k,MUserWinPlace(c.id,oldKing == null ? null : oldKing.id));
		// notice new king king
		if( k.city.king != null && k.city.king != oldKing )
			db.Log.user(k.city.king,MUserVassalNewPlace(c.id,k.id));
		// unfortify all generals
		for( g in db.General.manager.search({ cid1 : c.id, fortify : true },false) )
			if( g.user != k && g.user.city.king != k ) {
				var g = db.General.manager.get(g.id);
				g.fortify = false;
				g.update();
			}
		// update city connect status
		if( oldKing != null ) updateTerritory(oldKing);
		updateTerritory(k);
		if( !c.isCity ) {
			var trade = -c.distanceToKing * c.distanceToKing;
			c.cumulativeLoss = inverseTrade(trade);
			c.update();
			var k = db.User.manager.get(k.id);
			k.trade += trade;
			k.update();
		}
	}

	public static function getSoldierUpgrades( c : db.City ) {
		var l = new List();
		var B = Data.BUILDINGS.list;
		var U = Data.UNITS.list;
		var R = Data.RESOURCES.list;
		var level;
		level = c.getBuildingLevel(B.forge);
		if( level > 0 ) l.add({ u : U.piq, r : R.metal, r2 : null, n : 7 - level });
		level = c.getBuildingLevel(B.stable);
		if( level > 0 ) l.add({ u : U.cav, r : R.horse, r2 : null, n : 7 - level });
		level = c.getBuildingLevel(B.archer);
		if( level > 0 ) l.add({ u : U.arch, r : R.lin, r2 : null, n : 7 - level });
		level = c.getBuildingLevel(B.academ);
		if( level > 0 ) {
			l.add({ u : U.chev, r : R.horse, r2 : R.metal, n : 7 - level });
			l.add({ u : U.caa, r : R.horse, r2 : R.lin, n : 7 - level });
		}
		level = c.getBuildingLevel(B.tour);
		if( level > 0 ) l.add({ u : U.pal, r : R.metal, r2 : null, n : (7 - level) * 2 });
		return l;
	}

	public static function getResourcesConverts( c : db.City ) {
		var l = new List();
		var B = Data.BUILDINGS.list;
		var R = Data.RESOURCES.list;
		var PROD = [0,5,7,10,15,20];
		var COST = [0,100,80,70,60,50];
		var level;
		level = c.getBuildingLevel(B.cauldr);
		if( level > 0 ) l.add({ b : B.cauldr, r : R.wood, r2 : R.metal, n : COST[level], n2 : 1 });
		level = c.getBuildingLevel(B.factry);
		if( level > 0 ) l.add({ b : B.factry, r : R.lin, r2 : R.gold, n : 1, n2 : PROD[level] });
		level = c.getBuildingLevel(B.butch);
		if( level > 0 ) l.add({ b : B.butch, r : R.horse, r2 : R.food, n : 1, n2 : PROD[level] });
		return l;
	}

	public static function gameOver( u : db.User ) {
		var u = db.User.manager.get(u.id);

		if( u.maxTerritory > 2 ) {
			var p = new db.Pantheon();
			p.user = u;
			p.map = u.map;
			p.city = u.city;
			p.start = u.lastJoin;
			p.end = Date.now();
			p.age = u.age;
			p.curTerritory = u.curTerritory;
			p.maxTerritory = u.maxTerritory;
			p.maxPower = u.maxPower;
			p.maxReputation = u.maxReputation;
			p.maxTrade = u.maxTrade;
			p.global = (u.map.group == null);
			p.calculateScore();
			p.insert();
			App.api.addUserHistory(Text.format(Text.get.is_dead,{ age : Std.int((u.age>>2)/12) + 20 }),u);
		}

		var c = db.City.manager.get(u.city.id);
		c.user = null;
		c.reset();
		c.update();
		if( c.king != null )
			db.Log.user(c.king,MUserVassalDie(u.id,u.curTerritory));

		for( c in db.City.manager.search({ kid : u.id },true) ) {
			c.king = null;
			c.update();
		}
		for( g in db.General.manager.search({ uid : u.id },true) )
			g.delete();
		for( u in db.Units.manager.search({ uid : u.id },true) ) {
			u.delete();
			if( u.bid != null ) {
				var b = db.Battle.manager.get(u.bid);
				syncBattle(b);
				b.update();
			}
		}
		for( r in db.Relation.manager.search({ uid : u.id },true) )
			r.delete();
		for( r in db.Relation.manager.search({ tid : u.id },true) )
			r.delete();
		u.city = null;
		if( u.map.difficulty == u.difficulty && u.getTitle().difficulty > u.difficulty )
			u.difficulty++;
		u.update();
		var map = db.Map.manager.get(u.map.id);
		map.availableCities++;
		if( map.lastEmperor == u )
			map.lastEmperor = null;
		map.update();
	}

	public static function syncBattle( b : db.Battle ) {
		if( b.ended != null )
			return new List();
		// synchronize units sets
		var camps = b.data.camps.copy();
		var units = db.Units.manager.search({ bid : b.id },true);
		for( u in units ) {
			var c = null;
			for( cc in camps )
				if( cc.id == u.id ) {
					c = cc;
					camps.remove(c);
					break;
				}
			if( c == null )
				c = b.add(u,true); // new camp is always a defender
			u.camp = c;
			if( c.units == null ) {
				// create units
				c.units = new Array();
				for( u in u.getInfos() ) {
					var life = new Array();
					for( i in 0...u.n )
						life.push(u.u.life);
					c.units.push({ f : 0, l : life, k : 0 });
				}
				// are they units from a given general ?
				var g = db.General.manager.search({ unid : u.id },false).first();
				var inf = b.data.ids.get(c.id);
				if( g != null ) {
					c.gid = g.id;
					inf.g = g.name;
					inf.k = false;
				}
				// log the new camp
				b.history(BJoin(c.id,u.count(),c.def));
			} else {
				// synchronize units
				var infos = u.getInfos();
				for( idx in 0...infos.length ) {
					var u = infos[idx];
					var bu = c.units[idx];
					var delta = u.n - (bu.f + bu.l.length);
					if( delta == 0 )
						continue;
					if( delta > 0 ) {
						// complete missing units
						for( i in 0...delta )
							bu.l.push(u.u.life);
						b.history(BUnitsAdd(c.id,delta));
						continue;
					}
					// remove units that are the most healthy
					var l = bu.l.copy();
					l.sort(function(l1,l2) return l2 - l1);
					for( i in 0...-delta ) {
						var v = l.shift();
						if( v != null ) {
							bu.l.remove(v);
							continue;
						}
						// automatically kill an alive unit inside the pair
						bu.f--;
						for( p in b.data.pairs ) {
							if( p.u1.cid == c.id && p.u1.kind == idx ) {
								p.u1.life = 0;
								p.u1.cid = null;
								break;
							}
							if( p.u2.cid == c.id && p.u2.kind == idx ) {
								p.u2.life = 0;
								p.u2.cid = null;
								break;
							}
						}
					}
					b.history(BUnitsLeave(c.id,-delta));
				}
			}
		}
		// remove destroyed camps
		for( c in camps )
			removeBattleCamp(b,c,units);
		// update pairs
		if( updateBattlePairs(b,units) )
			for( u in units )
				u.update();
		checkBattleEnd(b,units);
		return units;
	}

	static function checkBattleEnd( b : db.Battle, units : List<db.Units> ) {
		// check end of battle
		if( b.ended != null || b.data.pairs.length > 0 )
			return;
		b.ended = Date.now();
		b.finished = true;
		// choose the king as the first surviving attacking camp
		var newKing = null;
		for( c in b.data.camps ) {
			if( c.def ) continue;
			newKing = c;
			break;
		}
		var defWin = (newKing == null);
		var futureKing = null;
		if( newKing == null ) {
			var u = (b.city.user == null) ? b.city.king : b.city.user;
			if( u != null ) futureKing = u.id;
		} else if( !b.data.provoke ) {
			var c = b.data.ids.get(newKing.id);
			futureKing = c.u;
		}
		// remove battle mode an all units and fortify winning generals
		var umap = new IntHash();
		for( u in units ) {
			u.battle = null;
			u.update();
			umap.set(u.id,u);
			if( u.camp.gid != null && u.camp.def == defWin ) {
				var g = db.General.manager.get(u.camp.gid);
				if( g.user != null && g.user.id == futureKing ) g.fortify = true;
				updateReputation(g,u.camp.kill);
				g.update();
			}
		}
		// notice all users of the battle result (only once per user)
		var uwin = new IntHash();
		for( cid in b.data.ids.keys() ) {
			var inf = b.data.ids.get(cid);
			var unit = umap.get(cid);
			var won = uwin.get(inf.u) || (unit != null && unit.camp.def == defWin);
			uwin.set(inf.u,won);
		}
		for( uid in uwin.keys() ) {
			var user = db.User.manager.get(uid,false);
			if( user == null ) continue;
			db.Log.user(user,MUserBattleReport(b.id,b.cid,uwin.get(uid)));
		}
		b.history(BWin(defWin));
		// eventually change the king of the new city
		if( newKing != null && !b.data.provoke )
			setKing(b.city,umap.get(newKing.id).user,db.General.manager.get(newKing.gid),b);
	}

	static function removeBattleCamp( b : db.Battle, c : BattleCamp, units : List<db.Units> ) {
		if( c.units == null )
			throw b.id+" => "+Std.string(c)+" CAMPS=##"+Std.string(b.data.camps)+"## UNITS=["+units.map(function(u) return u.id).join(",")+"]";
		b.data.camps.remove(c);
		var count = 0;
		for( u in c.units )
			count += u.f + u.l.length;
		// kill units in pairs
		for( p in b.data.pairs ) {
			if( p.u1.cid == c.id ) {
				p.u1.life = 0;
				p.u1.cid = null;
			}
			if( p.u2.cid == c.id ) {
				p.u2.life = 0;
				p.u2.cid = null;
			}
		}
		if( count > 0 )
			b.history(BQuit(c.id,count));
	}

	public static function updateBattlePairs( b : db.Battle, units : List<db.Units> ) {
		var attCount = 0, defCount = 0;
		var umap = new IntHash();
		for( u in units ) {
			if( u.camp.def ) defCount += u.count() else attCount += u.count();
			umap.set(u.id,u);
		}
		// remove broken pairs and process killed units
		var kill = false;
		var killUnit = function(u:BattleUnit,c:db.Units,cadv:db.Units) {
			var bu = c.camp.units[u.kind];
			bu.f--;
			// if alive put back into unit stock
			if( u.life > 0 ) {
				bu.l.push(u.life);
				return;
			}
			// update corresponding db.Units
			kill = true;
			if( c.camp.def ) defCount-- else attCount--;
			var tmp = c.get();
			tmp[u.kind]--;
			c.set(tmp);
			b.history(BKill(c.camp.id,u.kind));
			bu.k++;
			if( cadv != null )
				cadv.camp.kill++;
			if( c.count() > 0 )
				return;
			// if all units are killed, do some cleanup
			var g = db.General.manager.get(c.camp.gid);
			if( g != null )
				db.Log.user(g.user,MUserLostGeneral(b.id,b.cid,g.name));
			b.history(BDie(c.camp.id));
			removeBattleCamp(b,c.camp,units);
			c.delete();
			units.remove(c);
		};
		for( p in b.data.pairs ) {
			var c1 = umap.get(p.u1.cid);
			var c2 = umap.get(p.u2.cid);
			var end = p.u1.life == 0 || p.u2.life == 0 || c1 == null || c2 == null;
			if( !end ) continue;
			if( c1 != null ) killUnit(p.u1,c1,c2);
			if( c2 != null ) killUnit(p.u2,c2,c1);
			b.data.pairs.remove(p);
		}
		// create missing pairs
		var attPairs = Math.ceil(attCount/3);
		var defPairs = Math.ceil(defCount/3);
		var npairs = (attPairs > defPairs) ? attPairs : defPairs;
		if( npairs > 7 ) npairs = 7;
		if( npairs > attCount ) npairs = attCount;
		if( npairs > defCount ) npairs = defCount;
		npairs -= b.city.getBuildingLevel(Data.BUILDINGS.list.wall);
		if( npairs <= 0 ) npairs = 1;
		while( b.data.pairs.length < npairs ) {
			// choose camps and units
			var catt = new Array(), cdef = new Array(), probAtt = new Array(), probDef = new Array();
			for( u in units ) {
				var c = u.camp.def ? cdef : catt;
				var p = u.camp.def ? probDef : probAtt;
				var uid = 0;
				for( un in u.camp.units ) {
					if( un.l.length > 0 ) {
						p.push(un.l.length);
						c.push({ id : uid, camp : u.camp, u : un });
					}
					uid++;
				}
			}
			// choose a given non-fighting unit
			var uatt = catt[randomProbas(probAtt)];
			var udef = cdef[randomProbas(probDef)];
			if( uatt == null || udef == null )
				break;
			var katt = Std.random(uatt.u.l.length), kdef = Std.random(udef.u.l.length);
			// create pair
			var u1 = { cid : uatt.camp.id, life : uatt.u.l[katt], kind : uatt.id };
			var u2 = { cid : udef.camp.id, life : udef.u.l[kdef], kind : udef.id };
			b.data.pairs.add({ u1 : u1, u2 : u2 });
			uatt.u.l.splice(katt,1);
			udef.u.l.splice(kdef,1);
			uatt.u.f++;
			udef.u.f++;
		}
		return kill;
	}

	static inline function isCheval( u : EUnit ) {
		return switch( u ) {
			case Cavalier, Chevalier, ArcherMonte: true;
			default: false;
		};
	}

	static function pow( u1 : EUnit, u : EUnit, attack ) {
		if( u == ArcherMonte ) return 0;
		return switch( u1 ) {
			case Soldier: 0;
			case Cavalier: if( u == Archer ) 2 else 0;
			case Archer: if( u == Piquier || u == Paladin ) 2 else 0;
			case Piquier: if( isCheval(u) ) 3 else 0;
			case Paladin: 0;
			case Chevalier: if( u == Soldier ) 2 else 0;
			case ArcherMonte: 0;
			case Balist: if( attack ) 0 else 4;
			case Catapult: if( attack ) 4 else 0;
		};
	}

	static var U : Array<EUnit> = Lambda.array(Lambda.map(Type.getEnumConstructs(EUnit),callback(Reflect.field,EUnit)));

	public static function updateBattle( b : db.Battle ) {
		if( b.ended != null )
			return;
		var units = syncBattle(b);
		var turns = updateTime(b,2 / b.map.getSpeed());
		var killed = false;
		for( i in 0...turns ) {
			var die = false;
			for( b in b.data.pairs ) {
				var u1 = b.u1;
				var u2 = b.u2;
				u1.life -= 1 + Std.random(2) + pow(U[u2.kind],U[u1.kind],false);
				u2.life -= 1 + Std.random(2) + pow(U[u1.kind],U[u2.kind],true);
				if( u1.life <= 0 ) {
					u1.life = 0;
					die = true;
				}
				if( u2.life <= 0 ) {
					u2.life = 0;
					die = true;
				}
			}
			if( die ) {
				updateBattlePairs(b,units);
				killed = true;
			}
		}
		checkBattleEnd(b,units);
		if( killed )
			for( u in units )
				u.update();
	}

	public static function estimateBattleEnd( b : db.Battle ) {
		if( b.ended != null )
			return null;
		var attLife = 0, defLife = 0;
		for( c in b.data.camps )
			for( u in c.units )
				for( l in u.l )
					if( c.def ) defLife += l else attLife += l;
		for( p in b.data.pairs ) {
			attLife += p.u1.life;
			defLife += p.u2.life;
		}
		var life = (attLife > defLife) ? defLife : attLife;
		var time = DateTools.minutes( life / (0.75 * b.map.getSpeed() * b.data.pairs.length) );
		return Date.fromTime(Date.now().getTime() + time);
	}

	public static function killBattleUnits( b : db.Battle, units : db.Units, remove ) {
		var c = null;
		for( cc in b.data.camps )
			if( cc.id == units.id ) {
				c = cc;
				break;
			}
		if( c == null )
			return null;
		var ul = units.getInfos();
		var count = 0;
		for( idx in 0...ul.length ) {
			var life = ul[idx].u.life;
			var u = c.units[idx];
			var killed = u.f;
			for( l in u.l )
				if( l < life )
					killed++;
			ul[idx].n -= killed;
			count += killed;
		}
		if( remove ) {
			units.setInfos(ul);
			units.battle = null;
			units.update();
			b.data.camps.remove(c);
			b.history(BFlee(c.id,count));
		}
		return count;
	}

	public static function updateReputation( g : db.General, count : Int ) {
		var old = g.reputation;
		if( count < 0 )
			g.points -= Math.ceil((g.reputation * -count) / 2); // units lost while fleeing
		else
			g.points += count; // units killed
		if( g.points < 0 ) g.points = 0;
		// 1 + 2 + 3 + 4 + 5 = 15 points => reput 5
		// R(R + 1)/2 == P
		g.reputation = Math.floor((Math.sqrt(1 + 8 * g.points) - 1) / 2);
		if( g.reputation < 1 )
			g.reputation = 1;
		if( g.reputation != old && g.name != null )
			db.Log.user(g.user,MUserGeneralReput(g.name,g.reputation - old));
	}

	static var TAG = 0;

	public static function checkConnection( c0 : db.City, target : db.City, users : List<db.User> ) {
		var tag = TAG++;
		var l = new List();
		l.add(c0);
		while( true ) {
			var c = l.pop();
			if( c == null ) break;
			for( cn in [c.link1,c.link2,c.link3,c.link4] )
				if( cn != null && cn.tag != tag ) {
					cn.tag = tag;
					var cuser = cn.user;
					var cking = cn.king;
					for( u in users )
						if( cking == u || cuser == u ) {
							if( cn == target ) return true;
							l.add(cn);
							break;
						}
				}
		}
		return false;
	}

	public static function canReach( u : db.User, c : db.City ) {
		// the list of users are the vassals + us + our king + the users that gave us cross rights
		var ul = db.User.manager.getVassals(u);
		ul.add(u);
		var king = u.city.king;
		if( king != null ) {
			ul.remove(king);
			ul.add(king);
		}
		for( r in db.Relation.manager.search({ tid : u.id, canCross : true }) ) {
			ul.remove(r.user);
			ul.add(r.user);
		}
		return Rules.checkConnection(c,u.city,ul);
	}

	public static function potionPrice( u : db.User ) {
		if( u.health <= 0 ) return null;
		return (u.usedPotions + 2) * 50;
	}

	public static function poisonPrice( u : db.User ) {
		if( u.health < 2 ) return null;
		return 30;
	}

	public static function turnsPrice( u : db.User ) {
		return 50;
	}

	public static function extraTurns( u : db.User ) {
		return 50;
	}

	public static function extraTurnsHours( u : db.User ) {
		return Math.ceil(App.fullApi.getPromo(48,"thours") / u.map.getSpeed());
	}

	public static function freeLostTurns( p : db.Puzzle ) {
		var t = 20 + Std.int(p.turns/20); // allow 5% lost actions "for free"
		if( t < 0 )
			t = 0;
		return t;
	}

}