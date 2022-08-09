package db;
import mt.db.Types;

class Map extends neko.db.Object {

	static function RELATIONS() {
		return [
			{ prop : "lastEmperor", key : "lastuid", manager : User.manager, lock : false },
			{ prop : "group", key : "gid", manager : Group.manager, lock : false },
		];
	}
	public static var manager = new MapManager(Map);

	public var id : SId;
	public var name : STinyText;
	public var width : SInt;
	public var height : SInt;
	public var turns : SInt;
	public var lastUpdate : SDateTime;
	public var totalCities : SInt;
	public var availableCities : SInt;
	public var rawData : SText;
	public var cityData : SText;
	public var difficulty : SInt;
	public var lastEmperor(dynamic,dynamic) : SNull<User>;

	public var speedCoef : SInt;
	public var group(dynamic,dynamic) : SNull<db.Group>;

	override function toString() {
		return id+"#"+name;
	}

	public function getSpeed() : Float {
		return switch( speedCoef ) {
		case -1: 1;
		case 0: 1;
		case 1: 2;
		case 2: 0.5;
		default: 1;
		}
	}
	
	public function canEdit() {
		return group != null && App.api.isGroupAdmin(group);
	}

	public function getLog() {
		var l = db.Log.manager.search({ mid : id },false).first();
		if( l == null ) {
			l = new db.Log();
			l.lmap = this;
		}
		return l;
	}

}

class MapManager extends neko.db.Manager<Map> {
	
	public function getForGroup( g : Group ) {
		return object("SELECT * FROM Map WHERE gid = " + g.id + " AND speedCoef >= 0 LIMIT 1", false);
	}

	public function listFree( dif : Int, count : Int ) {
		return objects("SELECT * FROM Map WHERE gid IS NULL AND availableCities > 1 AND difficulty <= "+dif+" ORDER BY difficulty DESC, availableCities LIMIT "+count,false);
	}
	
	public function active() {
		return objects("SELECT * FROM Map WHERE speedCoef >= 0 AND availableCities < totalCities", false);
	}

}