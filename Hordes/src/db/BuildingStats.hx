package db;
import mt.db.Types;
import Common;
import tools.Utils;

class BuildingStats extends neko.db.Object {

	public var id : SId;
	public var mapId : SNull<SInt>;
	public var days : SInt;
	public var bid : SInt;

	public static var manager = new BuildingStatsManager();

	public static function create( map : Map, bid : Int ) {
		var bs = new BuildingStats();
		bs.mapId = map.id;
		bs.days = map.days;
		bs.bid = bid;
		bs.insert();
		return bs;
	}

	public function new() {
		super();
		mapId = null;
		days = 0;
		bid = 0;
	}

	function dbRights() {
		return {
			can : {
				insert : true,
				delete : true,
				modify : true,
				truncate : true,
			},
			invisible : [],
			readOnly : [],
		};
	}
}

class BuildingStatsManager extends neko.db.Manager<BuildingStats> {
	public function new() {
		super(BuildingStats);
	}

	public function inc(map:Map,bid:Int) {
		var bcount = execute( "SELECT count(*) FROM BuildingStats WHERE mapId="+map.id+" AND bid="+bid ).getIntResult(0);
		if ( bcount<=0 ) {
			BuildingStats.create(map,bid);
		}
	}

	public function getByMap(map:Map) {
		return objects( selectReadOnly("mapId="+map.id), false );
	}

	public function getDayDistrib(bid:Int) {
		return results("SELECT days, count(*) AS n FROM BuildingStats WHERE bid="+bid+" GROUP BY days");
	}

	public function countBuildings() {
		return results( "SELECT bid AS bid, count(*) AS n FROM BuildingStats GROUP BY bid");
	}
}
