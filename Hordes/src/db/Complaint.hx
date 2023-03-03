package db;
import mt.db.Types;
import Common;

class Complaint extends neko.db.Object{

	static var RELATIONS = function(){
		return [
			{ key : "mapId",	prop : "map",	manager : Map.manager, lock : false },
			{ key : "plaintiff",	prop : "p",	manager : User.manager, lock : false },
			{ key : "suspect",	prop : "s",	manager : User.manager, lock : false },
		];
	}

	static var TABLE_IDS = [
		"mapId","plaintiff","suspect",
	];

	public static var manager  = new ComplaintManager();

	public var mapId(default,null)				: SInt;
	public var plaintiff(default,null)			: SInt;
	public var suspect(default,null)				: SInt;
	public var reason				: SString<100>;
	public var cpt					: SInt;

	public var map(dynamic,dynamic)	: Map;
	public var p(dynamic,dynamic)	: User;
	public var s(dynamic,dynamic)	: User;

	public function new() {
		super();
		cpt = 1;
	}

	public static function add(map:Map, plaintiff:User, suspect:User, reason:String, value:Int) {
		var c = new Complaint();
		c.map = map;
		c.p = plaintiff;
		c.s = suspect;
		c.cpt = value;
		c.reason = reason;
		c.insert();
		return c;
	}
}

private class ComplaintManager extends neko.db.Manager<Complaint> {

	public function new() {
		super( Complaint );
	}

	public function countComplaints(s:User) {
		return execute("SELECT sum(cpt) FROM Complaint WHERE mapId="+s.mapId+" AND suspect="+s.id).getIntResult(0);
	}

	public function getAllForUser(user:User) {
		return objects( selectReadOnly( "suspect="+user.id+" OR plaintiff="+user.id ),false);
	}

	public function getComplaints(s:User) {
		return objects( selectReadOnly( "mapId="+s.mapId+" AND suspect="+s.id ),false);
	}

	public function clear(user:User) {
		execute("DELETE FROM Complaint WHERE suspect="+user.id);
	}

}
