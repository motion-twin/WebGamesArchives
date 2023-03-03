package db;
import Common;
import mt.db.Types;
import neko.Lib;

class CityUpgrade extends neko.db.Object {

	static var INDEXES:Array<Dynamic> = [ ["bid"], ["mapId","bid", true] ];

	static var RELATIONS = function(){
		return [
			{ key : "mapId",	prop : "map",	manager : Map.manager }
		];
	}

	public static var manager = new CityUpgradeManager();

	public var id: SId;
	public var mapId(default,null) : SInt;
	public var bid: SInt;
	public var votes : SInt;
	public var level : SInt;

	public var map( dynamic, dynamic ) : Map;

	public function new() {
		super();
		votes = 0;
		level = 0;
	}

	public static function addVote( building:Building, map:Map, n:Int ) {
		var up = manager._getUpgrade( building, map, true );
		if( up!=null ) {
			if ( up.level >= Const.get.MaxUpgradeLevel )
				return null; // level max atteint
			up.votes+= n;
			up.update();
		}
		else {
			up = new CityUpgrade();
			up.map = map;
			up.bid = building.id;
			up.votes = n;
			up.insert();
		}
		return up.votes;
	}


	public function getBuilding() {
		return XmlData.getBuildingById(bid);
	}


	function dbRights() {
		return {
			can : {
				insert : true,
				delete : true,
				modify : true,
				truncate : false,
			},
			invisible : [],
			readOnly : [],
		};
	}

	public static function getValueIfAvailableByKey( bkey:String, ?branch:Int, map:Map, defaultValue:Float ) : Float {
		var b = XmlData.getBuildingByKey(bkey);
		return	if ( b == null )
					defaultValue;
				else
					getValueIfAvailable( b, branch, map, defaultValue );
	}

	public static function getValueIfAvailable( b:Building, ?branch:Int, map:Map, defaultValue:Float, ?upgrades  ) : Float {
		var up = if ( upgrades != null ) upgrades.get(b.key) else manager._getUpgrade(b, map, false);
		// upgrade disponible ?
		if ( up == null  || up.level == 0 ) {
			return defaultValue;
		} else {
			// si oui, on renvoie sa "valeur"
			var value = getUpgradeValue( XmlData.getCityUpgradeByParent(b), up.level, branch );
			if ( value == null ) value = defaultValue;
			return value;
		}
	}

	public static function getUpgradeDesc(upData:CityUpgradeData, level:Int) {
		if ( upData.levels[level]==null ) return null;
		var desc = upData.levels[level].desc;
		desc = desc.split("::v::").join(""+getUpgradeValue(upData, level, 1));
		desc = desc.split("::v2::").join(""+getUpgradeValue(upData, level, 2));
		desc = desc.split("::v3::").join(""+getUpgradeValue(upData, level, 3));
		return desc;
	}

	public function getDesc() {
		return getUpgradeDesc( XmlData.getCityUpgradeByParent(getBuilding()), level );
	}
	
	#if tid_appli
	public function getGraph( viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields ) : Dynamic {
		if ( fields == null ) fields = [];
		var b = getBuilding();
		return {
			name:b.name,
			level:this.level,
			update:this.getDesc(),
			buildingId:b.id,	
		}
	}
	#end
	
	public static function getUpgradeValue( upData:CityUpgradeData, level:Int, ?branch:Int ) : Float {
		if (level == 0 || level == null ) {
			return null;
		} else {
			if( level > upData.levels.length - 1 )
				level = upData.levels.length - 1;
			
			switch(branch) {
				case 3 : return upData.levels[level].value3;
				case 2 : return upData.levels[level].value2;
				default : return upData.levels[level].value;
			}
		}
	}
}

class CityUpgradeManager extends neko.db.Manager<CityUpgrade> {

	public function new() {
		super( CityUpgrade );
	}

	public function destroy(map:Map, bid:Int) {
		execute("DELETE FROM CityUpgrade WHERE mapId="+map.id+" AND bid="+bid);
	}

	public function getBestVote( map : Map ) {
		return object( select("mapId="+map.id+" AND votes > 0 ORDER BY votes DESC LIMIT 1"), true );
	}

	public function getVotes(map:Map) {
		return objects( selectReadOnly("mapId="+map.id), false );
	}

	public function getUpgrades(map:Map) {
		return objects( selectReadOnly("mapId="+map.id+" AND level>0"), false );
	}

	public function getUpgradesHash(map:Map) {
		var h = new Hash();
		var rs = objects( selectReadOnly("mapId="+map.id+" AND level>0"), false );
		for( r in rs ) {
			var b = XmlData.getBuildingById( r.bid );
			h.set( b.key, r );
		}
		return h;
	}

	public function _getUpgrade( b:Building, map:Map, ?lock=false ) {
		if (lock) {
			return object( select("bid="+b.id+" AND mapId="+map.id), true );
		}
		else {
			return object( selectReadOnly("bid="+b.id+" AND mapId="+map.id), false );
		}
	}

}
