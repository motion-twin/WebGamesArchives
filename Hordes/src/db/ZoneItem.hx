package db;

import Common;
import mt.db.Types;
import tools.Utils;

class ZoneItem extends neko.db.Object {

	static var TABLE_IDS = ["zoneId","toolId","isBroken","visible"];
	static var INDEXES = [ ["zoneId","toolId"],["toolId","isBroken"] ];
	static var RELATIONS = function() {
		return [ { key : "zoneId",    prop : "zone",    manager : Zone.manager, lock : false } ];
	}

	public static var manager = new ZoneItemManager();
	
	public var zoneId(default, null)	: SInt;
	public var toolId	: SInt;
	public var visible	: SBool;
	public var isBroken	: SBool;
	public var count	: SInt;
	public var zone(dynamic, dynamic)	: Zone;
	
	public var life: SInt;
	
	public static function create(zone:Zone, tid:Int, ?count=1, ?fl_br=false, ?fl_vis=true) {
		var o = manager._getByToolId( zone, tid, fl_br, fl_vis );
		if( o != null ) {
			o.count += count;
			o.update();
			return o;
		}
		var o = new ZoneItem();
		o.count = count;
		o.zone = zone;
		o.toolId = tid;
		o.isBroken = fl_br;
		o.visible = fl_vis;
		o.insert();
		return o;
	}
	
	// méthode spécifique pour les ajouts en banque
	public static function addToCity( map : Map, tool : Tool, ?fl_vis = true ) {
		var zone = map._getCity();
		var tid = tool.toolId;
		var o = manager._getByToolId( zone, tid, tool.isBroken, true );
		if( o!= null ) {
			o.count ++;
			o.update();
			return o;
		}
		
		var o = new ZoneItem();
		o.zone = zone;
		o.toolId = tid;
		o.isBroken = tool.isBroken;
		o.visible = fl_vis;
		o.insert();
		return o;
	}
	
	public function new() {
		super();
		visible = true;
		isBroken = false;
		count = 1;
		life = 0;
	}
	
	public static function categorizeItemList(list:List<ZoneItem>) {
		var hash = new Hash();
		for (zitem in list) {
			var tool = XmlData.getTool(zitem.toolId);
			var key = Tool.getCategoryName(tool);
			if ( hash.get(key)==null )
				hash.set(key,new List());
			hash.get(key).add(zitem);
		}
		var clist = new Array();
		for (key in hash.keys()) {
			clist.push({
				key		: key,
				list	: hash.get(key),
			});
		}
		clist.sort(function(a,b) {
			if (a.key==Text.get.BankCat_Rsc) return -1;
			if (b.key==Text.get.BankCat_Rsc) return 1;
			if (a.key==Text.get.BankCat_None) return 1;
			if (b.key==Text.get.BankCat_None) return -1;
			if (a.key<b.key) return -1;
			if (a.key>b.key) return 1;
			return 0;
		});
		return clist;
	}

	override public function delete() {
		if( count <= 1 )
			super.delete();
		else {
			count--;
			update();
		}
	}
	
	#if tid_appli
	public function getGraph( viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields ) : Dynamic {
		if( fields == null ) fields = [];
		//
		var tinfo = XmlData.getTool(toolId);
		var cat = db.Tool.getCategory(tinfo);
		var graph:Dynamic = {
			id:tinfo.toolId,
			name:tinfo.name,
			count:this.count,
			broken:this.isBroken,
			img:tinfo.icon,
			cat: if(cat==null) Text.get.BankCat_None else Text.getByKey("BankCat_"+Std.string(cat)),
			deco: if( tinfo.deco != null ) tinfo.deco else 0,
			heavy: tinfo.isHeavy,
		}
		
		for ( f in fields ) {
			switch (f.name) {
				case "id", "name", "count", "broken", "img", "cat", "deco", "heavy":
				case "guard": graph.guard = (viewer.map != null) ? tinfo.getGuard(viewer.map) : null;
				case "desc": graph.desc = tinfo.description;
				default:
					throw "Unknown field: "+f.name;
			}
		}
		return graph;
	}
	#end
}

class ZoneItemManager extends neko.db.Manager<ZoneItem> {
	public function new(){
		super(ZoneItem);
	}
	
	override function make(it : ZoneItem ) {
		//it.encodeKey = it.toolId + it.count;
		//it.makeUniqueId();
		if ( it.life == null ) it.life = 0;
	}
	
	private function addOptionalReq( fl_br:Bool, fl_vis:Bool ) {
		var req = "";
		if ( fl_br != null )
			req += " AND isBroken="+fl_br;
		if ( fl_vis != null )
			req += " AND visible="+fl_vis;
		return req;
	}
	
	public function _getByToolId( zone: Zone, tid : Int, fl_br:Bool, fl_vis:Bool ) {
		var query = select( "zoneId="+zone.id+" AND toolId="+tid + addOptionalReq(fl_br,fl_vis) );
		return object(query,true);
	}
	
	public function exists( zone: Zone, tid : Int, ?fl_br:Bool, ?fl_vis:Bool ) {
		var req = "SELECT count(*) FROM ZoneItem WHERE zoneId="+zone.id+" AND toolId =" + tid + addOptionalReq(fl_br,fl_vis);
		return execute(req).getIntResult(0) > 0;
	}
	
	public function _getZoneItems( zone: Zone, ?lock=false, ?fl_vis:Bool ) {
		return 	if ( lock ) objects(select("zoneId=" + zone.id + addOptionalReq(null, fl_vis) + " ORDER BY toolId ASC" ), true);
				else objects(selectReadOnly("zoneId=" + zone.id + addOptionalReq(null, fl_vis) + " ORDER BY toolId ASC" ), false);
	}
	
	public function countItemsInZone( zid:Int, tids:List<Int> ) {
		var sql = "SELECT count(*) FROM ZoneItem WHERE zoneId="+zid+" AND isBroken=0 AND visible=1 AND toolId IN ("+tids.join(",")+")";
		return execute(sql).getIntResult(0);
	}
	
	public function sumAllItemsInZone( zid:Int ) {
		return execute("SELECT SUM(count) FROM ZoneItem WHERE zoneId="+zid+" AND isBroken=0 AND visible=1").getIntResult(0);
	}
	
	public function deleteAllItemsInZone( zid:Int ) {
		var sql = "DELETE FROM ZoneItem WHERE zoneId="+zid+"";
		execute(sql);
	}
	
	public function countItemList( ids : List<Int>, zone: Zone) : List<{amount:Int, id: Int}> {
		var sql = "SELECT `count` as amount, toolId as id FROM ZoneItem WHERE zoneId="+zone.id+" AND isBroken=0 AND visible=1 AND toolId IN (" + ids.join(",") + ")";
		return results( sql );
	}
	
	public function countZoneItemList( zid : Int ) : List<{amount:Int, id: Int}> {
		var sql = "SELECT `count` as amount, toolId as id FROM ZoneItem WHERE zoneId="+zid+" AND isBroken=0 AND visible=1";
		return results( sql );
	}
	
	public function getByToolId(tid:Int, zone:Zone, fl_broken:Bool, fl_vis:Bool) {
		return object(select( "toolId="+tid+" AND zoneId="+zone.id+" AND isBroken="+(fl_broken?1:0)+" AND "+(fl_vis?1:0) ), true);
	}
	
	public function getLockedList(ziIds:List<Int>) {
		return objects( select ("id IN ("+ziIds.join(",")+")"), true );
	}
	
	public function getItemList( ids : List<Int>, zone: Zone, ?fl_br:Bool, ?fl_vis:Bool) {
		return objects(
			select("zoneId="+zone.id+" AND toolId IN (" + ids.join(",") + ") "+addOptionalReq(fl_br,fl_vis)+" ORDER BY ToolId"),
			true );
	}
	
	public function dropCadaverTools( cadaver : Cadaver, zone: Zone) {
		execute("INSERT INTO ZoneItem (zoneId, toolId, isbroken, visible,`count`) (SELECT "+zone.id+",toolId,0,1,1 FROM CadaverRemains WHERE cadaverId="+cadaver.id+") ON DUPLICATE KEY UPDATE `count` = `count` + 1");
	}
	
	public function dropUserTools( user : User, zone: Zone) {
		var sql = "INSERT INTO ZoneItem (zoneId, toolId, isbroken, visible,`count`) (SELECT "+zone.id+",toolId,isbroken,1,1 FROM Tool WHERE inBag=1 AND soulLocked = 0 AND userId="+user.id+") ON DUPLICATE KEY UPDATE `count` = `count` + 1";
		execute(sql);
	}
	
	public function getZonesWithHiddenTools( map:Map ) {
		var mapZoneIds = db.Zone.manager._getZoneIds(map);
		var req = "SELECT DISTINCT(zoneId) as zoneId FROM ZoneItem WHERE zoneId!="+map.cityId+" AND visible=0 AND zoneId IN("+mapZoneIds.join(",")+")";
		var list = Lambda.map( results(req), function(r) {return r.zoneId;} );
		return list;
	}
	
	// MOD_SHAMAN_SOULS
	
	public function getZonesWithTool( map:Map, toolId:Int ) {
		var mapZoneIds = db.Zone.manager._getZoneIds(map);
		mapZoneIds.remove(map.cityId);
		var req = "SELECT DISTINCT(zoneId) as zoneId FROM ZoneItem WHERE toolId="+toolId+" AND visible=1 AND zoneId IN("+mapZoneIds.join(",")+")";
		var list = Lambda.map( results(req), function(r) {return r.zoneId;} );
		return list;
	}
	
	public function getAllToolsInMap(map:Map, toolId:Int, ?pIncludeCity:Bool=false):List<db.ZoneItem> {
		var mapZoneIds = db.Zone.manager._getZoneIds(map);
		if( !pIncludeCity ) mapZoneIds.remove(map.cityId);	
		return objects(select("toolId=" + toolId + " AND visible=1 AND zoneId IN(" + mapZoneIds.join(",") + ")"), false);
	}
	
}
