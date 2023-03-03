package db;
import Common;
import mt.db.Types;

class MapVar extends neko.db.Object {

	static var PRIVATE_FIELDS = ["map"];
	static var INDEXES = [["mapId"], ["mapId", "name"]];

	public static var manager = new Manager();

	public var id					: SId;
	public var mapId(default, null)	: SInt;
	public var name					: SString<32>;
	public var value				: SInt;
	public var map(getMap, null) 	: Map;

	public function new(map:Map, name, value) {
		super();
		this.mapId = map.id;
		this.name = name.toLowerCase();
		this.value = value;
	}
	
	public static function getValue(map:Map, n:String, ?defValue=0) {
		var v = manager.getVar(map, n);
		return if( v == null ) defValue else v.value;
	}
	
	public static function getBool(map:Map, n:String) {
		var v = manager.getVar(map, n);
		return v != null && v.value == 1;
	}
	
	public static function setValue(map:Map, n:String, val:Int) {
		var v = manager.getVar(map, n, true);
		if( v == null ) {
			v = new MapVar(map, n, val);
			v.insert();
		} else {
			v.value = val;
			v.update();
		}
	}
	
	static public function removeValue(map:Map, n:String) 
	{
		var v = manager.getVar(map, n, true);
		if( v != null ) {
			v.delete();
		}
	}
	
	function getMap() {
		return Map.manager.get(mapId, false);
	}
}

private class Manager extends neko.db.Manager<MapVar> {
	public function new() {
		super(MapVar);
	}
	
	public function getVar(map:Map, n:String, fl_lock=false) {
		return	if( fl_lock )
					object(select("mapId="+map.id+" AND name="+quote(n.toLowerCase())), true);
				else
					object(selectReadOnly("mapId="+map.id+" AND name="+quote(n.toLowerCase())), false);
	}
	
	public function getAllVars(map:Map, fl_lock=false):List<MapVar> {
		return	if( fl_lock )
					objects(select("mapId="+map.id), true);
				else
					objects(selectReadOnly("mapId="+map.id), false);
	}
	
	public function hasVar(map:Map, n:String) {
		return count( {mapId:map.id, name:n.toLowerCase()} ) > 0;
	}
	
	public function getFromId(mapId:Int, n:String ) {
		return object(selectReadOnly("mapId="+mapId+" AND name="+quote(n.toLowerCase())), false);
	}
	
	public function getBoolFromId(mapId:Int, n:String ) {
		var v = object(selectReadOnly("mapId="+mapId+" AND name="+quote(n.toLowerCase())), false);
		return v != null && v.value == 1;
	}
	
	public function getMapIds(k:String, n:Int) {
		return Lambda.map( results("SELECT mapId FROM MapVar WHERE name="+quote(k)+" AND value="+n), function(r) return r.mapId );
	}
	
	public function fastInc(mapId:Int, n:String, ?inc=1) {
		// création de valeur sans l'objet Map
		var v = object( select("mapId="+mapId+" AND name="+quote(n.toLowerCase())), true);
		if( v != null ) {
			v.value += inc;
			v.update();
			return v.value;
		} else {
			execute("INSERT INTO MapVar(mapId,name,value) VALUES ("+mapId+", "+quote(n.toLowerCase())+", "+inc+")");
			return inc;
		}
	}
}
