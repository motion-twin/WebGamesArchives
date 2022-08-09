package db;
import mt.db.Types;

class Relation extends neko.db.Object {

	static var TABLE_IDS = ["uid","tid"];
	static var PRIVATE_FIELDS = ["data"];
	static function RELATIONS() {
		return [
			{ prop : "user", key : "uid", manager : User.manager, lock : false },
			{ prop : "target", key : "tid", manager : User.manager, lock : false },
		];
	}
	public static var manager = new RelationManager(Relation);

	public var uid : SInt;
	public var tid : SInt;
	public var user(dynamic,dynamic) : User;
	public var target(dynamic,dynamic) : User;

	public var canCross : SBool;
	public var canRecolt : SBool;
	public var friendly : SNull<SBool>;
	public var pendingGold : SInt;

	public function new() {
		super();
		canCross = false;
		canRecolt = false;
		pendingGold = 0;
	}

	public function isMeaningful() {
		return canCross || canRecolt || friendly != null || pendingGold > 0 || target.city.king == user;
	}

	public static function get( u : User, t : User ) {
		var r = manager.getWithKeys({ uid : u.id, tid : t.id },false);
		if( r == null ) {
			r = new db.Relation();
			r.user = u;
			r.target = t;
		}
		return r;
	}

	public function getTaxesPercent() {
		return Rules.calculateTaxesPercent(target.city);
	}

	public function getTaxesValue() {
		if( target.trade <= 0 ) return 0;
		return Math.ceil(target.trade * getTaxesPercent() / 100);
	}

}

class RelationManager extends neko.db.Manager<Relation> {

	public function searchDisplay( u : User, inv : Bool ) {
		var conds = [
			"canCross = 1",
			"canRecolt = 1",
			"friendly IS NOT NULL",
		];
		return objects("SELECT * FROM Relation WHERE "+(inv?"tid":"uid")+" = "+u.id+" AND ("+conds.join(" OR ")+")",false);
	}
}