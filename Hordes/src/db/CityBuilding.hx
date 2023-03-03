package db;
import mt.db.Types;
import Common;

using Lambda;
class CityBuilding extends neko.db.Object {

	static var INDEXES = [ ["zoneId","type"] ];

	static var RELATIONS = function() {
		return [{ key : "zoneId", prop : "zone", manager : Zone.manager } ];
	}

	public static var manager = new CityBuildingManager();

	public var id		: SId;
	public var zoneId(default,null)	: SInt;
	public var type		: SInt;
	public var pa		: SInt;
	//public var suggest	: SInt;
	public var isDone	: SBool;
	public var life		: SInt;
	public var maxLife	: SInt;
	public var heroVotes : SInt;//votes from hero users to make city building appears as recommanded

	public var zone(dynamic,dynamic)		: Zone;

	public function new() {
		super();
		maxLife = 1;
		life = maxLife;
		isDone = false;
		pa = 0;
		//suggest = 0;
		heroVotes = 0;
	}
	
	public static function getDef(def:Int, life:Int, max:Int) {
		return Math.floor(def * life/max);
	}

	public static function unlock( map:Map, binfos:Building, ?fl_stat=true ) {
		var b = manager.getByKey(map, binfos.key, true);
		if( b == null ) {
			b = new CityBuilding();
			b.zoneId = map.cityId;
			b.type = binfos.id;
			b.maxLife = binfos.paCost;
			if( binfos.key == "reactor" )
				b.maxLife = 250;
			b.life = b.maxLife;
			b.insert();
			if( fl_stat )
				BuildingStats.manager.inc(map, binfos.id);
		}
		return b;
	}
	
	public static function giveBuilding( map:Map, binfos:Building ) {
		var b = unlock(map, binfos, false);
		b.isDone = true;
		b.pa = binfos.paCost;
		b.update();
		return b;
	}
	
	public function isActive( ?l:List<db.CityBuilding>) {
		var out = true;
		var binfos = getInfos();
		for ( p in binfos.getParents() ) {
			var b = db.CityBuilding.manager.getCityInternal(zoneId, p.id);
			if ( b.life == 0 || b.isDone == false ) {
				out = false;
				if( l != null ) l.add(b);
				break;
			}
		}
		return out;
	}
	
	public function isVisible(bhash:Hash<CityBuilding>) {
		var binfos = getInfos();
		if( binfos.parent == "" )
			return true;
		else
			return bhash.exists(binfos.parent) && bhash.get(binfos.parent).isDone;
	}
	
	public inline function getInfos():Building {
		return XmlData.getBuildingById(type);
	}
	
	public function applyEffects() {
		var map = Map.manager.get(zone.mapId, true); // lockée
		var binfos = getInfos();
		
		// distinction "fondations"
		for (p in binfos.getParents())
			if (p.key == "fondations") {
				db.GhostReward.manager.gainForAll(map, GR.get.wondrs);
				break;
			}
			
		// distinctions spéciales
		if (binfos.key == "wonder_pmv")		GhostReward.manager.gainForAll(map, GR.get.ebpmv);
		if (binfos.key == "wonder_crow")	GhostReward.manager.gainForAll(map, GR.get.ebcrow);
		if (binfos.key == "wonder_wheel")	GhostReward.manager.gainForAll(map, GR.get.ebgros);
		if (binfos.key == "wonder_castle")	GhostReward.manager.gainForAll(map, GR.get.ebcstl);
		
		// bâtiments apportant de l'eau au puits
		var waterBuildings = [
			{ b:XmlData.getBuildingByKey("megaPump"),		w:50 },
			{ b:XmlData.getBuildingByKey("betterPump"),		w:150 },
			{ b:XmlData.getBuildingByKey("pump"),			w:5 },
			{ b:XmlData.getBuildingByKey("breakthrough"),	w:2 },
			{ b:XmlData.getBuildingByKey("wellBoost"),		w:40 },
			{ b:XmlData.getBuildingByKey("eden"),			w:70 },
			{ b:XmlData.getBuildingByKey("waterNetwork"),	w:15 },
			{ b:XmlData.getBuildingByKey("deepRocket"),		w:60 },
			{ b:XmlData.getBuildingByKey("waterDetector"),	w:100 },
		];
		for( wb in waterBuildings )
			if (wb.b.key == binfos.key) {
				map.water += wb.w;
				map.update();
				CityLog.add( CL_GiveWater, Text.fmt.CL_BuildingsSuppliedWater( { building:wb.b.name, n:wb.w } ), map  );
				break;
			}
		
		var city = map._getCity();
		if( binfos.key == "regen" && map.days > 1 ) {
			var ni = NewsInfo.manager.getLast(map.id,true);
			if( ni!=null ) {
				ni.regenDir = -1;
				ni.update();
			}
		}
		
		switch(binfos.key) {
			//Thomas wonder_castle, wonder_wheel, wonder_crow, wonder_pmv Implementation
			case "wonder_castle", "wonder_wheel", "wonder_crow", "wonder_pmv" :
				db.GhostReward.manager.gainForAll(App.user.map, GR.get.ebuild);
			//Thomas woodCafet Implementation
			case "woodCafet" :
				var b = XmlData.getBuildingByKey("woodCafet");
				var meat = XmlData.getToolByKey("woodMeat");
				var n = 2;
				ZoneItem.create(city, meat.toolId, n);
				CityLog.add(CL_GiveInventory, Text.fmt.CL_BuildingToInventory( {building:b.print(), name:meat.print(), n:n } ), map);
			//Thomas fortified Implementation
			case "fortified":
				for( u in map.getUsers(true) ) {
					u.homeDefense += 4;
					u.update();
				}
			//Thomas altar Implementation
			case "altar":
				for( u in map.getUsers(true) ) {
					u.isCityBanned = false;
					db.Complaint.manager.clear(u);
					u.update();
				}
		/* REWRITE
			//Thomas fireworks Implementation
			case "fireworks":
				for( z in db.Zone.manager._getZonesForMap(map, true) ) {
					if( z.building != null || z.explo != null )
						z.checked = z.tempChecked = true;
					z.update();
				}
		*/
			//Thomas lastchance Implementation
			case "lastchance":
				var def = 1 * ZoneItem.manager.sumAllItemsInZone(map.cityId);
				map.tempDef += def;
				map.update();
				db.ZoneItem.manager.deleteAllItemsInZone( map.cityId );
				CityLog.add(CL_NewBuilding, Text.fmt.LastChance( { name:binfos.print(), n:def } ), map);
			//Thomas balooning Implementation
			case "balooning":
				Zone.manager.revealMap(map);
				CityLog.add(CL_OpenDoor, Text.fmt.Baloon({name:binfos.print()}), map);
			//Thomas rockets Implementation
			case "rockets":
				var city = map._getCity();
				Zone.manager.crossKillZombies( map, city.x, city.y );
				CityLog.add(CL_OpenDoor, Text.fmt.RocketKill({name:binfos.print()}), map);
		}
	}
	
	public static function hasHanger(map:Map) {
		return	map.hasMod("FRAGILE_HANGER") && manager.hasBuilding(map, "hanger") ||
				map.hasMod("SOLID_HANGER") && manager.hasBuilding(map, "hanger_solid");
	}
	
	public static function hasMeatCage(map:Map) {
		return manager.hasBuilding(map, "meatCage");
	}

	public function destroy(map:Map) {
		db.CityUpgrade.manager.destroy(map, type);
		isDone = false;
		pa = 0;
		life = maxLife;
		heroVotes = 0;
		update();
	}

	public static function destroyHanger(map:Map) {
		if(!map.hasMod("FRAGILE_HANGER"))
			return;
		var b = manager.getByKey(map, "hanger", true);
		b.destroy(map);
	}
	
	#if tid_appli
	public function getGraph( viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields ) : Dynamic {
		var infos = getInfos();
		if ( infos.mod != null && infos.mod.length > 0 && !db.GameMod.hasMod(infos.mod) )
			return null;
		
		if( fields == null ) fields = [];
		var graph:Dynamic = {
			id: this.type,
		}
		
		for ( f in fields )
		{
			switch (f.name)
			{
				case "id":
				case "parent": graph.parent = if( infos.parent != "" ) XmlData.getBuildingByKey(infos.parent).id else null;
				case "temporary": graph.temporary = infos.temporary;
				case "icon": graph.icon = infos.icon;
				case "pa": graph.pa = this.pa;
				case "name": graph.name = infos.name;
				case "life": graph.life = this.life;
				case "maxLife": graph.maxLife = this.maxLife;
				case "votes": graph.heroVotes = this.heroVotes;
				case "desc": graph.desc = infos.description;
				case "breakable": graph.breakable = !infos.unbreakable;
				case "def": graph.def = infos.def;
				case "hasUpgrade": graph.hasUpgrades = infos.hasLevels;
				case "rarity": graph.rarity = Std.string(infos.drop);
				case "resources":
					graph.resources = [];
					for ( t in infos.needList )
					{
						graph.resources.push( {
							rsc : t.t.getGraph(viewer, scopes, f.fields),
							amount : t.amount,
						} );
					}
				
				default:
					throw "Unknown field: "+f.name;
			}
		}
		
		return graph;
	}
	#end
}

private class CityBuildingManager extends neko.db.Manager<CityBuilding> {
	
	public function new() {
		super(CityBuilding);
	}

	public function getByKey(map:Map, k:String, ?fl_lock=false) {
		var binfos = XmlData.getBuildingByKey(k);
		return 	if(binfos == null ) {
					null;
				} else {
					if(fl_lock)
						object(select("zoneId="+map.cityId+" AND type="+binfos.id), true);
					else
						object(selectReadOnly("zoneId="+map.cityId+" AND type="+binfos.id), false);
				}
	}
	
	public function getCityInternal(zoneId:Int, bid:Int, ?fl_lock=false) {
		return	if(fl_lock)
					object(select("zoneId="+zoneId+" AND type="+bid), true);
				else
					object(selectReadOnly("zoneId="+zoneId+" AND type="+bid), false);
	}
	
	public function getKnownBuildings(map:Map, ?fl_lock=false) {
		return	if(fl_lock)
					objects(select("zoneId="+map.cityId),true);
				else
					objects(selectReadOnly("zoneId="+map.cityId),false);
	}
	
	public function getDoneBuildings(map:Map, ?fl_lock=false) {
		return	if(fl_lock)
					objects(select("zoneId="+map.cityId+" AND isDone=1"), true);
				else
					objects(selectReadOnly("zoneId="+map.cityId+" AND isDone=1"), false);
	}

	public function getUndoneBuildings(map:Map, ?fl_lock=false) {
		return	if(fl_lock)
					objects(select("zoneId="+map.cityId+" AND isDone=0"), true);
				else
					objects(selectReadOnly("zoneId="+map.cityId+" AND isDone=0"), false);
	}

	public function getDoneBuildingsHash(map:Map, ?fl_lock=false) {
		var h = new Hash();
		for( b in getDoneBuildings(map, fl_lock) )
			if( b.getInfos() != null )
				h.set(b.getInfos().key, b);
		return h;
	}
	
	public function getKnownBuildingsHash(map:Map, ?fl_lock=false) {
		var h = new Hash();
		for( b in getKnownBuildings(map, fl_lock) )
			if( b.getInfos() != null )
				h.set(b.getInfos().key, b);
		return h;
	}
	
	public function getTemporaryBuildings(map:Map) {
		var temporaryIds =	Lambda.map( Lambda.filter( XmlData.buildings, function( b : Building ) { return b.temporary; } ), function( b: Building ) {return b.id;});
		return objects(select("zoneId="+map.cityId+" AND isDone=1 AND type IN ("+temporaryIds.join(",")+")"),true);
	}

	public function hasBuilding(map:Map, key:String){
		var b = XmlData.getBuildingByKey(key);
		return	if( b == null ) false;
				else execute("SELECT count(*) FROM CityBuilding WHERE zoneId="+map.cityId+" AND isDone=1 AND type="+b.id).getIntResult(0) > 0;
	}
	
	
	public function resetMap(map:Map) {
		execute("DELETE FROM CityBuilding WHERE zoneId="+map.cityId);
	}
}

