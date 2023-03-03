package db;
import mt.db.Types;
import Common;
import tools.Utils;

class Zone extends neko.db.Object
{

	static var INDEXES = [ ["type"],["x","y"],["mapId","y","x"],["mapId"] ];

	static var RELATIONS = function() {
		return [ { key : "mapId", prop : "map", manager : Map.manager, lock : false } ];
	}

	static var PRIVATE_FIELDS	= [ "building", "infoTagEnum", "explo" ];
	public var building	: OutsideBuilding;


	public static var manager = new ZoneManager();
	public static var TYPE_CITY		= 1;		// Ville

	public var map(dynamic, dynamic) : Map;   // la Carte de référence
	public var id			: SId;
	public var mapId(default, null)		: SInt;

	public var type			: SInt;		// type de zone
	public var diggers		: SInt;		// extraction du bâtiment
	public var dropCount	: SInt;		// Nombre d'objets récupérable dans la zone
	public var bdropCount	: SInt;		// Nombre d'objets récupérable dans un building de la zone

	public var x			: SInt;		// Coordonnée sur la carte
	public var y			: SInt;		// Coordonnée sur la carte
	public var level		: SInt;		// level sur la carte

	public var zombies		: SInt;		// Nombre de zombies présents dans la zone
	public var humans		: SInt;		// Compteur contrôle humain
	public var kills		: SInt;
	public var checked		: SBool;	// Zone balisée ?
	public var tempChecked	: SBool;	// Zone balisée pour la journée ?
	public var infoTag		: SInt;
	public var infoTagEnum	: InfoTags;
	public var endFeist		: SNull<SDateTime>;	//  En cas de perte de contrôle : timer festin
	public var scout		: SInt;
	public var direction	: SInt;

	// CAMPING
	public var defense		: SInt;		// Défense de la zone
	public var camped		: SBool;	// Est-ce que la zone a déjà servi de camping

	public var explo(getExplo, null) : Null<db.Explo>;   // la Carte de référence
	
	public function new() {
		super();
		type = 0;
		zombies = 0;
		humans = 0;
		scout = 0;
		kills = 0;
		defense = 0;
		camped = false;
	}
	
	dynamic public function getExplo() {
		var e = db.Explo.manager.get( id, false );
		getExplo = function() { return e; };
		return e;
	}
	
	public function canDropPlan(map:Map) {
		return diggers <= 0 && isBuilding() && !MapVar.getBool(map, "campPlanDropped_"+this.id);
	}

	public function getDefense() {
		return
			defense +
			if( isBuilding() ) {
				if( hasBuildingExtracted() )
					building.baseDefense // bâtiment révélé
				else
					0; // non révélé
			}
			else
				-25; // rase campagne
	}

	public function fillWithItems(?rnd:Int->Int) {
		if( map == null ) return;
		if( rnd == null ) rnd = Std.random;
		//
		var dc 	= Math.ceil(Const.get.DropCount  * 0.7);
		var bdc = Math.ceil(Const.get.BDropCount * 0.7);
		dropCount = dc + rnd( dc );
		bdropCount = bdc + rnd( bdc );
	}

	public function regen(chance:Int) {
		var fl_regen = false;
		var dcChance = if( dropCount < Const.get.MapRegenSaturate ) chance else chance * 0.33;
		if( Std.random(100) < dcChance ) {
			dropCount += Const.get.MapRegenDropCount + Std.random(Const.get.MapRegenDropCount);
			fl_regen = true;
		}

		var bdcChance = if( bdropCount < Const.get.MapRegenSaturate ) chance else chance * 0.33;
		if( Std.random(100) < bdcChance ) {
			bdropCount += Const.get.MapRegenBDropCount + Std.random(Const.get.MapRegenBDropCount);
			fl_regen = true;
		}
		update();
		return fl_regen;
	}


	public function getTplBuilding(?includeExplorable = false) {
		if( type != null ) {
			if( building != null ) {
				var b = XmlData.getOutsideBuilding( type, includeExplorable );
				if( b != null )
					building = b;
			}
		}
		return building;
	}

	public inline function isBuilding(?includeExplorable = false) {
		return type > TYPE_CITY && (!includeExplorable && !XmlData.getOutsideBuilding(type, true).isExplorable);
	}

	public function getLogs( ?keys: Array<CityLogKey>, ?user: User, ?limit:Int) {
		var m = db.Map.manager.get( mapId, false );
		if( limit!=null ) {
			if( limit > 0 )
				return CityLog.manager.getZoneLogs( m, this, user, keys, limit );
			else
				return CityLog.manager.getZoneLogs( m, this, user, keys );
		}
		else
			return CityLog.manager.getZoneLogs( m, this, user, keys, Const.get.MaxLogsDefault );
	}

/* ----------------------------- ITEMS ----------------------------*/

	public function getItems( ?lock=false, ?fl_vis:Bool ) {
		return ZoneItem.manager._getZoneItems( this, lock, fl_vis );
	}

	// [!!] en cas de modification de cette méthode, modifier l'algo dans Cron.hx > gather()
	public function getRandomRessource(chance:Int) : Tool {
		if( Std.random(100) >= chance )
			return null;

		var list = XmlData.getDropList();
		var dropList = new Array();
		for( tool in list )
			for( i in 0...tool.proba )
				dropList.push(tool.key);

		var tool = XmlData.getToolByKey( dropList[Std.random(dropList.length)] );
		if( tool != null && tool.key == "bplan_drop" && db.MapVar.manager.fastInc(mapId, "plansDroppedToday") > Const.get.MaxDailyPlanDrop )
			tool = XmlData.getToolByKey("wood");
		return tool;
	}

	public function hasTimeBeforeFeist() {
		return endFeist != null && endFeist.getTime() > Date.now().getTime();
	}

	public function getFeistTime() {
		if( endFeist == null )
			return -1;

		return Math.floor( endFeist.getTime() - Date.now().getTime()  );
	}

	public function getRandomItem(?chanceBonus:Int) : Tool {
		if( chanceBonus == null ) chanceBonus = 0;
		//
		var b = XmlData.getOutsideBuilding( type );
		var tools = b.tools;
		if( tools == null )
			return null;
		// On teste déjà s'il est possible de trouver qqch
		if( Std.random( 100 ) < b.probaEmpty-chanceBonus )
			return null;
		// on ajoute les objets référence dans la liste des probas à hauteur de leur attribut de proba
		var tProba = new Array();
		for( t in tools ) {
			for( i in 0...t.p ) {
				tProba.push( t.t );
			}
		}
		var foundTool = XmlData.getToolByKey( tProba[Std.random(tProba.length-1)] );
		return foundTool;
	}

	
	/**
	 * On récupère un objet appartement à une liste spéciale de drop
	 * @param	dlid  ID du bâtiment spécial
	 * @param	?chance  chance d'obtention d'un objet
	 * @return l'objet
	 */
	public function getSpecialDropListItem(dlid,?chance:Int) : Tool {
		var dlist = XmlData.getOutsideBuilding( dlid );
		var toolList = dlist.tools;
		if( toolList == null ) {
			return null;
		}
		if( chance == null ) chance = 100 - dlist.probaEmpty;
		// On teste déjà s'il est possible de trouver qqch
		if( Std.random(100) >= chance ) {
			return null;
		} else {
			// on ajoute les objets référence dans la liste des probas à hauteur de leur attribut de proba
			var tProba = new Array();
			for( t in toolList )
				for( i in 0...t.p )
					tProba.push( t.t );
			var foundTool = XmlData.getToolByKey( tProba[Std.random(tProba.length-1)] );
			return foundTool;
		}
	}

/* ----------------------------- FESTIN ----------------------------*/

	public function getHumanScore(?ulist : List<{id:Int,spentHeroDays:Int,hero:Bool}>) {
		return 1.0 * humans; // humans contient le score de zone calculé
	}

	public function changeHumanScore(delta:Int, ?fl_doUpdate=true) {
		if( type == 1 || delta == 0 || delta == null ) 
			return; // ville
		humans += delta;
		if( humans < 0 )
			humans = 0;
		if( fl_doUpdate )
			update();
	}

	public function isInFeist() {
		return zombies > humans && !hasTimeBeforeFeist();
	}

	public function isBeforeFeist() {
		return zombies>humans && hasTimeBeforeFeist();
	}

	public function getScoutReduction() {
		return getScoutLevel() * Const.get.ReductionByScoutLevel;
	}

	public function getDetectionChance(ignored:Int) : Int {
		var delta = Math.max( 0, zombies-getHumanScore() );
		delta -= Const.get.UserControl;
		delta += ignored*Const.get.UserControl;
		delta = Math.floor(delta*1.3);
		if( map.hasMod("NIGHTMODS") && App.isNight() )
			delta -= 5;
		if( delta <= 6 ) delta *= 0.5;
		return Math.floor( Math.max(0, delta-getScoutReduction() ) );
	}

	public function hasBuildingExtracted() {
		return diggers <= 0;
	}

	public function countPlayers() : Int {
		return manager.countPlayers( this );
	}

	public function getPlayers( ?user : User, ?lock:Bool) {
		return User.manager.getPlayersByZoneAndPriority( this, user, lock );
	}

	override public function toString() {
		return Utils.toString( this );
	}

	public function getScoutLevel() {
		return Math.min( Const.get.MaxScoutLevel, Math.floor(scout/Const.get.ScoutLevels) );
	}

	public static function getStaticScoutLevel( scout : Int ) {
		return Math.min( Const.get.MaxScoutLevel, Math.floor(scout/Const.get.ScoutLevels) );
	}

	public function print() {
		var str = "ZONE #"+this.id+" (@"+x+","+y+") | MAP #"+mapId+" | ";
		str += "isInFeist="+isInFeist()+" | endFeist="+endFeist+" | ";
		str += "h="+getHumanScore()+" | z="+zombies;
		return str;
	}

	public function logError(code:String, ?delta=0) {
		try {
			var txt = print()+"\n-------\n";
			var pList = getPlayers(null,false);
			for( u in pList ) txt+=u.name+" (#"+u.id+") job="+u.jobId+" control="+u.getControlScore()+" terror="+u.isTerrorized+"\n";
			txt += "-------------\n";
			txt += "humans(before)="+(humans-delta)+"\n";
			txt += "humans(after)="+humans+"\n";
			txt += "delta="+delta+"\n";
			txt += "App.user="+App.user.name+" job="+App.user.jobId+"\n";
			txt += "TOOLS :\n";
			for( t in App.user.getInBagTools() ) txt += "  name="+t.name+" isBroken="+t.isBroken+"\n";
			txt += "-------------\n";
			var logs = db.CityLog.manager.getZoneLogs(
				App.user.getMapForDisplay(),
				this,
				[CL_OutsideTempEvent, CL_OutsideEvent, CL_OutsideMessage]
			);
			for( l in logs ) txt += l.dateLog+" - "+tools.Utils.removeHtmlTags(l.ctext)+"\n";
			return db.Error.create("ZERR : "+code, txt, App.user);
		} catch(e:Dynamic) {
			return null;
		}
	}

	public function recalcHumanScore(?excludedUsers:Iterable<db.User>, ?fl_update=true) {
		var users = db.User.manager.getOutsidePlayers(this.id, false);
		if( excludedUsers != null ) {
			users = Lambda.filter( users, function(u) {
				return !Lambda.has(excludedUsers, u);
			});
		}
		var newScore = 0;
		for( u in users ) {
			var score = u.getControlScore();
			newScore += score;
		}
		
		if( humans != newScore ) {
			var delta = newScore - humans;
			humans = newScore;
			if( fl_update )
				update();
			return delta;
		} else {
			return 0;
		}
	}
	
	public function coord(city:Zone) {
		return MapCommon.coords(city.x, city.y, x, y);
	}
	
	#if tid_appli
	
	public function getItemsGraph(viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields)
	{
		var oItems = [];
		var itemsList = getItems(false, true);
		var itemsMap = new Hash();
		// premier parcours pour compter en aggrégeant les items camouflés (empoisonnés)
		for(zitem in itemsList) {
			var tinfo = XmlData.getTool(zitem.toolId);
			var toolId =	if( tinfo.hasType(Fake) ) {
								var rep = tinfo.getReplacement();
								if( rep!=null ) rep.toolId;
								else null;
							} else tinfo.toolId;
			// stockage
			if( toolId != null ) {
				var hkey = toolId+"_"+zitem.isBroken;
				var data = 	if(itemsMap.exists(hkey)) itemsMap.get(hkey) 
							else { n: 0, zitem: zitem };
				data.n += zitem.count;
				itemsMap.set(hkey, data);
			}
		}
		
		for (data in itemsMap) {
			var itemNode = data.zitem.getGraph(viewer, scopes, fields);
			itemNode.count = data.n;
			oItems.push(itemNode);
		}
		
		return oItems;
	}
	
	public function getGraph( viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields ) : Dynamic {
		if ( fields == null ) fields = [];
		var o:Dynamic = {
			id:id,
			x: x,
			y: y,
			nvt: !tempChecked,
			tag: if (infoTag > 0) infoTag else null,
		}
		
		if ( map.getVarValue("noAPI") == 1 ) 	return o;
		if ( viewer.mapId != this.mapId ) 	return o;
		
		var userOnZone = viewer.zoneId == this.id;
		for( f in fields ) {
			switch( f.name ) {
				case "id", "x", "y", "nvt", "tag":
				case "details":
					if ( userOnZone ) {
						o.z = this.zombies;
						o.h = this.humans;
						o.dried = this.dropCount <= 0;
					}
				
				case "items":
					if ( userOnZone )
						o.items = getItemsGraph(viewer, scopes, f.fields);					
				
				case "building":
					if ( checked ) {
						if( type > 1 ) {
							if( diggers > 0 ) {
								var building = {
									type: -1,
									name: Text.get.UndiggedBuilding,
									dig: diggers,
									camped : camped,
								}
								o.building = building;
							} else {
								var bdata = XmlData.getOutsideBuilding(type, true);
								if ( bdata != null ) {
									var building = {
										type: type,
										name: bdata.name,
										dig: diggers,
										desc: bdata.description,
										camped : camped,
									}
									o.building = building;
								}
							}
						} else {
							o.building = null;
						}
					}
				default:
					throw "Unknown field: "+f.name;
			}
		}
		
		return o;
	}
	#end

}

private class ZoneManager extends neko.db.Manager<Zone>
{
	public function new() {
		super(Zone);
	}

	override function make( z : Zone ) {
		var b = XmlData.getOutsideBuilding( z.type );
		if( b != null )
			z.building = b;
		var tConstr = Type.getEnumConstructs(InfoTags)[z.infoTag];
		if( tConstr != null )
			z.infoTagEnum = Reflect.field(InfoTags, tConstr);
	}

	override function unmake( z : Zone ) {
		if( z.infoTagEnum != null )
			z.infoTag = Type.enumIndex(z.infoTagEnum);
	}

	public function _getZonesForZombiesDispatch( map : Map ) {
		return objects(select("mapId="+map.id+" AND zombies > 0 AND type!="+Zone.TYPE_CITY), true);
	}

	public function countZombies( map : Map ) {
		return execute("SELECT SUM(zombies) FROM Zone WHERE type!=1 AND mapid="+map.id).getIntResult(0);
	}

	public function _getZonesForSWFMap( map : Map ) {
		var r = results("SELECT id, scout, zombies, x, y, type, diggers, checked, tempChecked, infoTag, dropCount, bdropCount FROM Zone WHERE mapId="+map.id);
		var arr = Lambda.array(r);
		arr.sort(function (za:Zone, zb:Zone) {
			if( za.y < zb.y )
				return -1;
			if( za.y > zb.y )
				return 1;
			if( za.x < zb.x )
				return -1;
			if( za.x > zb.x )
				return 1;
			return 0;
		});
		return Lambda.list(arr);
	}

	public function _getZonesForCatapult( map : Map ) {
		return results("SELECT id, x, y, level, zombies, direction FROM Zone WHERE mapId="+map.id+" ORDER BY y ASC ,x ASC");
	}

	public function _getZoneIds( map : Map ) {
		return Lambda.map( results("SELECT id FROM Zone WHERE mapId="+map.id), function(r) { return r.id; } );
	}

	public function _getDirectionForCatapult( zoneId:Int ) {
		return execute("SELECT direction FROM Zone WHERE id="+zoneId).getIntResult(0);
	}
	
	public function _getZonesForMap( map : Map, ?lock=false ) {
		if( lock )
			return objects(select("mapId="+map.id+" ORDER BY y ASC ,x ASC"), true);
		else
			return objects(selectReadOnly("mapId="+map.id+" ORDER BY y ASC ,x ASC"), false);
	}
	
	public function _getZonesByLevel( map : Map, minLevel : Int, maxLevel:Int, ?lock ) {
		if( !lock )
			return objects(selectReadOnly("mapId="+map.id+" AND level>=" + minLevel + " AND level<="+maxLevel+" ORDER BY y ASC ,x ASC"), false);
		else
			return objects(select("mapId="+map.id+" AND level>=" + minLevel + " AND level<="+maxLevel+" ORDER BY y ASC ,x ASC"), true);
	}
	
	public function getRescueZones( map:Map, maxLevel:Int) {
		return objects(selectReadOnly("mapId="+map.id+" AND level<="+maxLevel+" ORDER BY y ASC ,x ASC"), false);
	}
	
	public function countPlayers( zone : Zone ) : Int {
		return execute("SELECT count(distinct(id)) FROM User WHERE dead=0 AND zoneId="+zone.id).getIntResult(0);
	}

	public function countCampingPlayers( zone : Zone ) : Int {
		return execute("SELECT count(distinct(id)) FROM User WHERE dead=0 AND campStatus IS NOT NULL AND zoneId="+zone.id).getIntResult(0);
	}

	public function countUnbannedPlayers( zone : Zone ) : Int {
		return execute("SELECT count(distinct(id)) FROM User WHERE dead=0 AND isCityBanned=0 AND zoneId="+zone.id).getIntResult(0);
	}

	public function _getZone( map:Map, x:Int, y:Int, ?fl_lock=true ) {
		if (fl_lock)
			return object(select( "mapId="+map.id+" AND x="+x+" AND y="+y), true );
		else
			return object(selectReadOnly( "mapId="+map.id+" AND x="+x+" AND y="+y), false );
	}

	public function getKnownZones( map:Map, ?lock) {
		if( lock )
			return objects(select( "mapId="+ map.id + " AND (tempChecked=1 OR checked=1)" ), lock );
		return objects(selectReadOnly( "mapId="+ map.id + " AND (tempChecked=1 OR checked=1)" ), lock );
	}

	public function _getZonesFromIds( ids : List<Int>, lock=true ) {
		if( ids.length <= 0 )
			return new List();

		if( lock )
			return objects(select("id IN("+ids.join(",")+")"), true);

		return objects(selectReadOnly("id IN("+ids.join(",")+")"), false);
	}

	public function globalCheck( ids : List<Int>, map : Map ) {
		execute("UPDATE Zone SET checked=1, tempChecked=1 WHERE mapId="+map.id+" AND id IN("+ids.join(",")+")");
	}
	
	//for rockets building
	public function crossKillZombies(map:Map, x:Int, y:Int ) {
		execute("UPDATE Zone SET zombies=0 WHERE mapId="+map.id+" AND (x="+x+" OR y="+y+")");
		var zoneIdsWithHumans = Lambda.map(
			results("SELECT id FROM Zone WHERE mapId="+map.id+" AND (x="+x+" OR y="+y+") AND humans>0"),
			function(r) { return r.id; }
		);
		if( zoneIdsWithHumans.length > 0 ) {
			// recalcul du contrôle là où c'est utile
			var zoneWithHumans = objects(select("id IN ("+zoneIdsWithHumans.join(",")+")"), true);
			for( z in zoneWithHumans )
				z.recalcHumanScore(true);
		}
	}
	
	public function syncZonesScores(map:db.Map) {
		var zoneIds = Lambda.map( results("SELECT id FROM Zone WHERE mapId="+map.id), function(r) { return r.id; } );
		if( zoneIds.length > 0 ) {
			// recalcul du contrôle là où c'est utile
			var zoneWithHumans = objects(select("id IN ("+zoneIds.join(",")+")"), true);
			for( z in zoneWithHumans )
				z.recalcHumanScore(true);
		}
	}
	
	public function getExtractedBuildings(map: Map) {
		return results("SELECT type FROM Zone WHERE type >1 AND diggers = 0 AND mapId="+map.id+" ORDER BY type");
	}

	public function _getZonesByDirection( map:Map, dir:Int, ?minLevel:Int, lock:Bool ) {
		var reqLevel = if(minLevel != null) " AND level>="+minLevel+" " else "";
		if( lock ) {
			return objects( select("mapId="+map.id+" AND direction="+dir+reqLevel), true );
		} else {
			return objects( selectReadOnly("mapId="+map.id+" AND direction="+dir+reqLevel), false );
		}
	}

	public function getZoneIds(map:Map, minLevel:Int, maxLevel:Int) {
		var res = results("SELECT id FROM Zone WHERE mapId="+map.id+" AND level>="+minLevel+" AND level<="+maxLevel);
		var arr : Array<Int> = new Array();
		for(r in res)
			arr.push(r.id);
		return arr;
	}

	public function updateHumanScores(?map:Map) {
		var start = Date.now().getTime();
		var res = Db.results("SELECT DISTINCT(zoneId) AS id FROM User WHERE zoneId IS NOT null AND dead=0 AND isDeleted=0");
		var zoneIds = Lambda.map(res, function(r) { return r.id; });
		var mapReq = if(map!=null) " AND mapId="+map.id else "";
		// raz
		Db.execute("UPDATE Zone SET humans = 0 WHERE humans!=0 "+mapReq);
		
		if ( zoneIds.length<=0 )
			return Date.now().getTime()-start;
		
		// citoyens standards
		Db.execute("UPDATE Zone SET humans = humans + (SELECT 2*count(*) FROM User WHERE dead=0 AND isDeleted=0 AND isTerrorized=0 AND zoneId=Zone.id) WHERE type!=1 AND id IN ("+zoneIds.join(",")+") "+mapReq);
		
		// gardiens
		Db.execute("UPDATE Zone SET humans = humans + (SELECT 2*count(*) FROM User WHERE dead=0 AND isDeleted=0 AND isTerrorized=0 AND zoneId=Zone.id AND jobId=4) WHERE type!=1 AND id IN ("+zoneIds.join(",")+") "+mapReq);
		
		// héros avec upgrade de contrôle
		var up = XmlData.getHeroUpgrade("control");
		Db.execute("UPDATE Zone SET humans= humans + (SELECT count(*) FROM User WHERE dead=0 AND isDeleted=0 AND isTerrorized=0 AND zoneId=Zone.id AND hero=1 AND spentHeroDays>="+up.days+") WHERE type!=1 AND id IN ("+zoneIds.join(",")+") "+mapReq);
		
		// héros non-drogués ET avec upgrade "Corps sain"
		var up = XmlData.getHeroUpgrade("drugclean");
		Db.execute("UPDATE Zone SET humans = humans + (SELECT count(*) FROM User WHERE dead=0 AND isDeleted=0 AND isTerrorized=0 AND zoneId=Zone.id AND hero=1 AND spentHeroDays>="+up.days+" AND isClean=1) WHERE type!=1 AND id IN ("+zoneIds.join(",")+") "+mapReq);
		
		// porteurs d'objets de def (portière, ...)
		var list = XmlData.getToolsByType(Control);
		var idList = new List();
		for (t in list) 
			if ( !t.hasType(SoulLocked) ) 
				idList.add(t.toolId);
		var uids = Lambda.map( Db.results("SELECT userId FROM Tool WHERE toolId IN ("+idList.join(",")+")"), function(r) {return r.userId;} );
		if ( uids.length>0 )
			Db.execute("UPDATE Zone SET humans = humans + (SELECT count(*) FROM User WHERE zoneId=Zone.id AND isTerrorized=0 AND id IN ("+uids.join(",")+")) WHERE type!=1 AND id IN ("+zoneIds.join(",")+") "+mapReq);
		return Date.now().getTime()-start;
	}
	
	public function getZonesWithDiggedBuildingById(zids:List<Int>) { // concours pour le nom de fonction le plus pourri
		return objects(select("id IN ("+zids.join(",")+") AND diggers <= 0 AND type > "+Zone.TYPE_CITY), true);
	}
	
	public function getZonesWithBuilding(map:Map) {
		return objects(select("mapId="+map.id+" AND type > "+Zone.TYPE_CITY),true);
	}
	
	public function revealMap(map:Map) {
		execute("UPDATE Zone SET tempChecked=1, checked=1 WHERE mapId="+map.id);
	}
}
