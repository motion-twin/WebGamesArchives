package db;
import mt.db.Types;

class City extends neko.db.Object {

	static var PRIVATE_FIELDS = ["buildingsCache","tag","dist","trade","tradeUp"];
	static function RELATIONS() : Array<Relation> {
		return [
			{ prop : "map", key : "mid", manager : Map.manager, lock : false },
			{ prop : "user", key : "uid", manager : User.manager, lock : false },
			{ prop : "king", key : "kid", manager : User.manager, lock : false },
			{ prop : "defense", key : "defenseId", manager : Units.manager },
			{ prop : "defenseRO", key : "defenseId", manager : Units.manager, lock : false },
			{ prop : "garnison", key : "garnisonId", manager : Units.manager },
			{ prop : "garnisonRO", key : "garnisonId", manager : Units.manager, lock : false },
			{ prop : "link1", key : "lid1", manager : City.manager, lock : false },
			{ prop : "link2", key : "lid2", manager : City.manager, lock : false },
			{ prop : "link3", key : "lid3", manager : City.manager, lock : false },
			{ prop : "link4", key : "lid4", manager : City.manager, lock : false },
		];
	}
	public static var manager = new CityManager(City);

	public var id : SId;

	// position
	public var mid : SInt;
	public var map(dynamic,dynamic) : Map;
	public var name : STinyText;
	public var x : SInt;
	public var y : SInt;

	// control
	public var user(dynamic,dynamic) : SNull<User>;
	public var king(dynamic,dynamic) : SNull<User>;
	var defenseId : SNull<SInt>;
	var garnisonId : SNull<SInt>;
	public var defense(dynamic,dynamic) : SNull<Units>;
	public var garnison(dynamic,dynamic) : SNull<Units>;
	public var defenseRO(dynamic,dynamic) : SNull<Units>;
	public var garnisonRO(dynamic,dynamic) : SNull<Units>;

	// other
	public var isCity : SBool;
	public var placeId : SNull<SEncoded>;
	public var placeValue : SInt;
	public var cumulativeLoss : SInt;
	public var isConnected : SBool;
	public var distanceToKing : SInt;

	// ressources
	public var food : SInt;
	public var gold : SInt;
	public var wood : SInt;
	public var metal : SInt;
	public var lin : SInt;
	public var horse : SInt;

	// population
	public var pending : SInt;
	public var farmers : SInt;
	public var wooders : SInt;
	public var workers : SInt;
	public var merchants : SInt;
	public var recruiters : SInt;

	// links
	public var link1(dynamic,dynamic) : SNull<City>;
	public var link2(dynamic,dynamic) : SNull<City>;
	public var link3(dynamic,dynamic) : SNull<City>;
	public var link4(dynamic,dynamic) : SNull<City>;
	public var lid1 : SNull<SInt>;
	public var lid2 : SNull<SInt>;
	public var lid3 : SNull<SInt>;
	public var lid4 : SNull<SInt>;

	var buildingsCache : IntHash<Int>;
	public var tag : Int;
	public var dist : Int;
	public var trade : Int;
	public var tradeUp : Bool;

	public function initDefense() {
		var d = defense;
		if( d != null ) return d;
		d = new db.Units();
		d.user = user;
		d.battle = db.Battle.manager.getCurrent(this,true);
		d.insert();
		defense = d;
		return d;
	}

	public function clearBuildingCache() {
		buildingsCache = null;
	}

	public function getBuildingLevel( b : data.Building ) {
		if( buildingsCache == null ) {
			buildingsCache = new IntHash();
			for( b in this.getBuildings() )
				buildingsCache.set(b.b.bid,b.level);
		}
		var level = buildingsCache.get(b.bid);
		return if( level == null ) 0 else level;
	}

	public function getCurrentBuilding() {
		var b = isCity && placeId != null ? Data.BUILDINGS.getId(placeId) : null;
		if( b == null )
			return null;
		var cur = db.Building.manager.search({ cid : id, bid : b.bid }).first();
		var level = (cur == null) ? 1 : cur.level + 1;
		return {
			b : b,
			level : level,
			progress : placeValue,
			max : b.levels[level].turns,
		};
	}

	public function hasUnits() {
		return defenseId != null || garnisonId != null;
	}

	public function resourcesCount() {
		return food + gold + wood + metal + lin + horse;
	}

	public function getResources() {
		var r = Data.RESOURCES.list;
		var rl = [
			{ r : r.food, n : food, max : 0 },
			{ r : r.gold, n : gold, max : 0 },
			{ r : r.wood, n : wood, max : 0 },
			{ r : r.metal, n : metal, max : 0 },
			{ r : r.lin, n : lin, max : 0 },
			{ r : r.horse, n : horse, max : 0 },
		];
		for( r in rl )
			r.max = Rules.getMaxStock(this,r.r);
		return rl;
	}

	public function setResources( res : Array<{ r : data.Resource, n : Int }> ) {
		for( r in res )
			switch( r.r.k ) {
			case RFood: food = r.n;
			case RGold: gold = r.n;
			case RWood: wood = r.n;
			case RMetal: metal = r.n;
			case RLin: lin = r.n;
			case RHorse: horse = r.n;
			}
	}

	public function hasResource( r : data.Resource, n : Int ) {
		return switch( r.k ) {
		case RFood: food >= n;
		case RWood: wood >= n;
		case RGold: gold >= n;
		case RHorse: horse >= n;
		case RLin: lin >= n;
		case RMetal: metal >= n;
		};
	}

	public function useResources( cost : Array<{ r : data.Resource, n : Int }> ) {
		for( g in cost )
			if( !useResource(g.r,g.n) )
				return g.r;
		return null;
	}

	public function useResource( r : data.Resource, n : Int ) {
		switch( r.k ) {
		case RFood: if( food < n ) return false; food -= n;
		case RWood: if( wood < n ) return false; wood -= n;
		case RGold: if( gold < n ) return false; gold -= n;
		case RHorse: if( horse < n ) return false; horse -= n;
		case RLin: if( lin < n ) return false; lin -= n;
		case RMetal: if( metal < n ) return false; metal -= n;
		}
		return true;
	}

	public function giveResource( r : data.Resource, v : Int ) {
		var max = Rules.getMaxStock(this,r);
		var d = 0;
		switch( r.k ) {
		case RFood: food += v; if( food > max ) { d = food - max; food = max; }
		case RWood: wood += v; if( wood > max ) { d = wood - max; wood = max; }
		case RGold: gold += v; if( gold > max ) { d = gold - max; gold = max; }
		case RHorse: horse += v; if( horse > max ) { d = horse - max; horse = max; }
		case RLin: lin += v; if( lin > max ) { d = lin - max; lin = max; }
		case RMetal: metal += v; if( metal > max ) { d = metal - max; metal = max; }
		}
		return d;
	}

	public function giveResources( cost : Array<{ r : data.Resource, n : Int }> ) {
		var maxed = false;
		for( g in cost )
			if( giveResource(g.r,g.n) > 0 )
				maxed = true;
		return !maxed;
	}

	public function getPeople() {
		var p = Data.PEOPLE.list;
		var pop = [
			{ p : p.farmer, n : farmers },
			{ p : p.wooder, n : wooders },
			{ p : p.worker, n : workers },
			{ p : p.mercht, n : merchants },
			{ p : p.recrut, n : recruiters },
		];
		if( pending > 0 )
			pop.push({ p : p.pend, n : pending });
		return pop;
	}

	public function setPeople( pop : Array<{ p : data.People, n : Int }> ) {
		var P = Data.PEOPLE.list;
		for( p in pop )
			switch( p.p ) {
			case P.farmer: farmers = p.n;
			case P.wooder: wooders = p.n;
			case P.mercht: merchants = p.n;
			case P.worker: workers = p.n;
			case P.recrut: recruiters = p.n;
			case P.pend: pending = p.n;
			default: throw p.p.id;
			}
	}

	public function getPeopleCount() {
		return farmers + wooders + workers + merchants + recruiters + pending;
	}

	public function getPuzzle() {
		return db.Puzzle.manager.get(id);
	}

	function getBuildings() {
		return db.Building.manager.search({ cid : id },false).map(function(b) return b.get());
	}

	public function getBuildingsOrder() {
		var bl = Lambda.array(db.Building.manager.search({ cid : id },false));
		bl.sort(function(b1,b2) return b1.id - b2.id);
		return Lambda.map(bl,function(b) return b.get());
	}

	public function getLog() {
		var l = db.Log.manager.search({ cid : id },false).first();
		if( l == null ) {
			l = new db.Log();
			l.lcity = this;
		}
		return l;
	}

	public function getPlaceResource() {
		return (isCity || placeId == null) ? null : Data.RESOURCES.getId(placeId);
	}

	public function canViewInfos( u : User ) {
		if( u == null )
			return false;
		if( user == u || king == u )
			return true;
		if( user != null )
			return u.isKingOf(user) || db.Relation.get(user,u).friendly;
		if( king != null )
			return u.isKingOf(king) || db.Relation.get(king,u).friendly;
		return false;
	}

	public function getBattle() {
		return db.Battle.manager.getCurrentId(this);
	}

	public function canViewDefense(view) {
		if( defense == null )
			return false;
		// we can view city
		return view;
	}

	public function canViewGarnison(view) {
		if( garnison == null )
			return false;
		// our garnison
		if( king == App.user )
			return true;
		// we can view city
		return view;
	}

	public function canPass( u : User ) {
		return (user != null) ? user.allowPassage(u) : ((king == null) ? false : king.allowPassage(u));
	}

	public function canCross( u : User ) {
		var owner = (user == null) ? king : user;
		var right = true;
		if( owner != null ) {
			// if the owner have a wall, don't allow passage
			if( owner.city.getBuildingLevel(Data.BUILDINGS.list.wall) > 0 )
				right = false;
		} else {
			// if there are barbarians units, don't allow passage
			right = !hasUnits();
		}
		// if the city is not defended, we can pass
		if( !right && !hasUnits() && db.General.manager.enemiesFortified(this,u) == 0 )
			right = true;
		// if we have the passage rights pass for this kingdom then it's also fine
		if( !right && user != null && user.allowPassage(u) )
			right = true;
		if( !right && king != null && king.allowPassage(u) )
			right = true;
		return right;
	}

	public function buildDistMap(tag,dist) {
		if( this.tag == tag && this.dist <= dist )
			return;
		this.tag = tag;
		this.dist = dist;
		dist++;
		var c;
		c = link1; if( c != null ) c.buildDistMap(tag,dist);
		c = link2; if( c != null ) c.buildDistMap(tag,dist);
		c = link3; if( c != null ) c.buildDistMap(tag,dist);
		c = link4; if( c != null ) c.buildDistMap(tag,dist);
	}

	function get_trade() {
		return Rules.calculateTrade(this);
	}

	public function reset() {
		// res
		food = 0;
		gold = 0;
		wood = 0;
		metal = 0;
		lin = 0;
		horse = 0;
		// people
		pending = 0;
		farmers = 0;
		wooders = 0;
		workers = 0;
		merchants = 0;
		recruiters = 0;
		// place
		placeId = null;
		placeValue = 0;
		cumulativeLoss = 0;
		// units
		if( defense != null ) {
			defense.delete();
			defense = null;
		}
		// --- keep garnison ---
		// puzzle
		var p = getPuzzle();
		if( p != null ) p.delete();
		// buildings
		for( b in db.Building.manager.search({ cid : id },false) )
			b.delete();
		// log
		var g = getLog();
		if( g.id != null ) g.delete();
		// city
		if( isCity ) {
			food = 30;
			farmers = 1;
		}
	}

	override function toString() {
		return id+"#"+name;
	}
}

class CityManager extends neko.db.Manager<City> {

	public function getCenter( m : db.Map ) {
		return object("SELECT City.* FROM User,City WHERE City.mid = "+m.id+" AND uid = User.id ORDER BY User.maxTerritory DESC LIMIT 1",false);
	}

	public function getVassals( u : User ) {
		return objects("SELECT * FROM City WHERE kid = "+u.id+" AND uid IS NOT NULL",false);
	}

	public function getVassalsTerritory( u : User ) {
		var uids : List<{ uid : Int }> = results("SELECT uid FROM City WHERE kid = "+u.id+" AND uid IS NOT NULL");
		if( uids.isEmpty() )
			return new List();
		return objects("SELECT * FROM City WHERE kid IN ("+uids.map(function(r) return r.uid).join(",")+")",false);
	}

	public function getConnectedTerritory( u : User ) {
		// canCross
		var users : List<{ uid : Int }> = results("SELECT uid FROM Relation WHERE tid = "+u.id+" AND canCross = 1");
		// king
		var king = u.city == null ? null : u.city.king;
		if( king != null )
			users.add({ uid : king.id });
		// vassals
		for( u in results("SELECT uid FROM City WHERE kid = "+u.id+" AND uid IS NOT NULL") )
			users.add(u);
		if( users.isEmpty() )
			return new List();
		var uids = users.map(function(u) return u.uid).join(",");
		return objects("SELECT * FROM City WHERE uid IN ("+uids+") UNION SELECT * FROM City WHERE kid IN ("+uids+")",false);
	}

	public function getTerritoryChangeImpact( u : User ) {
		var users = User.manager.objects("SELECT User.* FROM User, Relation WHERE uid = "+u.id+" AND tid = User.id AND canCross = 1",false);
		var king = u.city.king;
		if( king != null ) {
			users.remove(king);
			users.add(king);
		}
		for( u in User.manager.objects("SELECT User.* FROM User, City WHERE kid = "+u.id+" AND uid = User.id",false) ) {
			users.remove(u);
			users.add(u);
		}
		return users;
	}

	public function getResourcePlaces( m : Map ) {
		return objects("SELECT * FROM City WHERE mid = "+m.id+" AND isCity = 0 AND placeId IS NOT NULL",true);
	}

	public function getDecadent( m : Map ) {
		var time = Math.ceil(Puzzle.ACTION_MINUTES / m.getSpeed());
		return objects("SELECT City.* FROM City, Puzzle WHERE mid = "+m.id+" AND Puzzle.id = City.id AND Puzzle.lastUpdate < NOW() - INTERVAL (("+(Puzzle.MAX_ACTIONS+1)+" - actions) * "+time+") MINUTE",false);
	}

	public function getMostFar( u : User ) {
		return object("SELECT * FROM City WHERE kid = "+u.id+" AND uid IS NULL ORDER BY distanceToKing DESC LIMIT 1",false);
	}

}