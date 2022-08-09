package db;
import mt.db.Types;

class General extends neko.db.Object {

	public static inline var PROGRESS_MAX = 1000000;
	static function RELATIONS() : Array<Relation> {
		return [
			{ prop : "user", key : "uid", manager : User.manager, lock : false },
			{ prop : "map", key : "mid", manager : Map.manager, lock : false },
			{ prop : "units", key : "unid", manager : Units.manager },
			{ prop : "unitsRO", key : "unid", manager : Units.manager, lock : false },
			{ prop : "cityFrom", key : "cid1", manager : City.manager, lock : false },
			{ prop : "cityTo", key : "cid2", manager : City.manager, lock : false },
		];
	}
	public static var manager = new GeneralManager(General);

	public var id : SId;
	public var map(dynamic,dynamic) : Map;
	public var name : SNull<SString<30>>;
	public var user(dynamic,dynamic) : User;
	public var units(dynamic,dynamic) : Units;
	public var unitsRO(dynamic,dynamic) : Units;
	public var cid1 : Int;
	public var cid2 : Int;
	public var cityFrom(dynamic,dynamic) : City;
	public var cityTo(dynamic,dynamic) : City;
	public var moving : SBool;
	public var lastUpdate : SDateTime;
	public var progress : SInt;
	public var reputation : SInt;
	public var points : SInt;
	public var fortify : SBool;
	public var nextMoves : STinyText;

	public function get_name() {
		return (name == null) ? Text.get.general_unknown_name : name;
	}

	public function canAct() {
		return !moving && !fortify && units.bid == null;
	}

	public function canMove() {
		return canAct();
	}

	public function canFortify() {
		if( fortify ) return true;
		if( moving || units.bid != null || units.count() == 0 )
			return false;
		if( cityFrom.user == user || cityFrom.king == user )
			return true;
		var p = (cityFrom.user == null) ? cityFrom.king : cityFrom.user;
		if( p != null && p.city.king == user )
			return true;
		return false;
	}

	public function canTransfer() {
		return canAct() && (cityFrom.user == user || cityFrom.king == user);
	}

	public function canTransferOthers() {
		return !transferOthers().isEmpty();
	}

	public function transferOthers() {
		var gl = new List();
		if( !canAct() )
			return gl;
		for( g in db.General.manager.search({ uid : user.id, cid1 : cid1, moving : false, fortify : false },false) )
			if( g != this && g.canAct() )
				gl.add(g);
		return gl;
	}

	public function canAttack() {
		return canAct() && cityFrom.user != user && cityFrom.king != user;
	}

	public function canRecolt() {
		if( moving || cityFrom.isCity || cityFrom.resourcesCount() == 0 || units.bid != null)
			return false;
		var plu = cityFrom.king;
		if( plu == null )
			return false;
		return plu == user || plu.city.king == user || db.Relation.get(plu,user).canRecolt;
	}

	public function canProvoke() {
		return canAct() && (cityFrom.user == user || (cityFrom.user == null && cityFrom.king == user)) && cityFrom.getBattle() == null && !manager.provokeEnemies(this).isEmpty();
	}

	public function canViewInfos(u) {
		return u != null && (u == user || u.isKingOf(user) || db.Relation.get(user,u).friendly);
	}

	public function canViewBattle() {
		return moving ? false : cityFrom.getBattle() != null;
	}

	public function eta() {
		return this.moving ? Rules.generalETA(this) : null;
	}

	public function getNextMoves() {
		if( nextMoves == "" )
			return new List();
		return Lambda.map(nextMoves.split(":"),function(id) return db.City.manager.get(Std.parseInt(id),false));
	}

	public function updateNextMove() {
		var n = nextMoves.split(":");
		n.shift();
		nextMoves = n.join(":");
	}

	public function resetNextMoves() {
		nextMoves = "";
	}

}

class GeneralManager extends neko.db.Manager<General> {

	public function enemiesFortified( c : City, u : User ) {
		return execute("SELECT COUNT(*) FROM General WHERE cid1 = "+c.id+" AND fortify = 1 AND uid != "+u.id).getIntResult(0);
	}

	public function provokeEnemies( g : General ) {
		return objects("SELECT * FROM General WHERE moving = 0 AND cid1 = "+g.cid1+" AND uid != "+g.user.id,false);
	}

}