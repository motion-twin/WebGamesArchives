package db;
import Common;
import mt.db.Types;

class CityBuildingVote extends neko.db.Object {

	static var INDEXES = [ ["buildingType"], ["mapId","buildingType", true] ];

	static var RELATIONS = function(){
		return [
			{ key : "mapId",	prop : "map",	manager : Map.manager }
		];
	}

	public static var manager = new CityBuildingVoteManager();

	public var id: SId;
	public var mapId(default,null) : SInt;
	public var buildingType : SInt;
	public var buildVote : SInt;
	public var destroyVote : SInt;
	public var done : SBool;

	public var map( dynamic, dynamic ) : Map;

	public function new() {
		super();
	}

	public static function create( building:Building, map:Map ) {
		var v = new CityBuildingVote();
		v.map = map;
		v.buildingType = building.id;
		v.buildVote = 0;
		v.insert();
		return v;
	}
}

class CityBuildingVoteManager extends neko.db.Manager<CityBuildingVote> {

	public function new() {
		super( CityBuildingVote );
	}

	public function getBuildingsVotes( map : Map ) {
		return objects( select("mapId="+ map.id+" AND buildVote>0 AND done=0"),true);
	}

	public function _getBuildVote( build :Building, map : Map) {
		return object( select( "buildingType=" + build.id + " AND mapId=" + map.id ), true);
	}

	public function getTotalVotes( map : Map) {
		var res = results("SELECT SUM(buildVote) AS sum FROM CityBuildingVote WHERE mapId=" + map.id).first();
		return if(res!=null) res.sum else 0;
	}

	public function getBuildVoteCount( build :Building, map : Map) {
		var res = results("SELECT buildVote FROM CityBuildingVote WHERE buildingType=" + build.id + " AND mapId=" + map.id).first();
		return if(res!=null) res.buildVote else 0;
	}

	public function getLocked( build:Building, map:Map ) {
		return object( select( "buildingType="+build.id+" AND mapId="+map.id), true );
	}

	public function clearVotes(map:Map, b:Building) {
		execute("DELETE FROM CityBuildingVote WHERE mapId="+map.id+" AND buildingType="+b.id);
	}

	public function getMapVotes( map:Map ) {
		return results("SELECT buildVote AS n, buildingType AS bid FROM CityBuildingVote WHERE mapId="+map.id);
	}

	public function getMapVotesHash( map:Map, ?buildingIds:List<Int> ){
		var h = new IntHash();
		var res =
			if (buildingIds==null)
				Db.results("SELECT buildVote, buildingType FROM CityBuildingVote WHERE mapId=" + map.id);
			else
				Db.results("SELECT buildVote, buildingType FROM CityBuildingVote WHERE buildingType IN(" + buildingIds.join(",") + ") AND mapId=" + map.id);
		for( r in res )
			h.set( r.buildingType, r.buildVote );
		return h;
	}

}
