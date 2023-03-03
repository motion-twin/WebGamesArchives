package db;
import  Common;
import mt.db.Types;

class GameStat extends neko.db.Object {

	static var RELATIONS = function(){
		return [
			{ key : "mapId",	prop : "map",	manager : Map.manager },
		];
	}

	public static var manager  = new GameStatManager();

	public var id : SId;
	public var date : SNull<SDate>;
	public var mapId : SNull<SInt>;
	public var day : SInt;
	public var deathCount : SInt;
	public var attackCount : SInt;
	public var defense : SInt;
	public var water : SInt;
	public var buildingCount : SInt;
	public var temporaryBuildingCount : SInt;

	public var map(dynamic,dynamic ) : Map;

	public static function addStat( m : Map ) {

		var s = new GameStat();
		s.date = Date.now();
		s.mapId = m.id;
		s.day = m.days;
		s.defense = -2; // updaté plus tard dans HordeAttack.resolve()
		s.water = m.water;
		s.water = m.water;
		s.insert();
		return s;
	}

	public function new() {
		super();
	}
}

private class GameStatManager extends neko.db.Manager<GameStat> {
	public function new() {
		super(GameStat);
	}

	public function _getGameStats( mapId : Int, ?lock) {
		if( lock ) {
			return Lambda.map( objects( select ( "mapId="+mapId ), true) ,
				function( g: GameStat ) {
					return GameStat.manager.get( g.id );
				});
		}
		return Lambda.list( objects( select ( "mapId="+mapId ), false) );
	}

	public function getLastGameStats( mapId : Int, ?lock) {
		if( lock ){
			return object( select( "mapId="+mapId + " ORDER BY id DESC LIMIT 0,1"), true );
		}
		return object( selectReadOnly( "mapId="+mapId + " ORDER BY id DESC LIMIT 0,1"), false);
	}

	public function getMapDeathCount( mapId : Int) {
		return execute("SELECT sum(deathCount) FROM GameStat WHERE mapId="+mapId).getIntResult(0);
	}

}
