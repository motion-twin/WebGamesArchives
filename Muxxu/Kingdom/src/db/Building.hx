package db;
import mt.db.Types;

class Building extends neko.db.Object {

	static var INDEXES : Array<Dynamic> = [["cid","bid",true]];
	static function RELATIONS() {
		return [
			{ prop : "city", key : "cid", manager : City.manager, lock : false },
		];
	}
	public static var manager = new neko.db.Manager<Building>(Building);

	public var id : SId;
	public var city(dynamic,dynamic) : City;
	public var bid : SEncoded;
	public var level : SInt;

	public function get() {
		return { b : Data.BUILDINGS.getId(bid), level : level };
	}

}
