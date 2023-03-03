package db;
import Common;
import mt.db.Types;
import tools.Utils;

class Cadaver extends neko.db.Object {

	static var INDEXES = [ ["deathType"],["mapId","survivalDays"],["deathType","mapDay"],["createDate"],["oldMapId"],["userId","survivalDays"], ["userId","id"], ["season"] ];

	static var PRIVATE_FIELDS = ["name"];

	static var RELATIONS = function(){
		return [
			{ key : "userId",	prop : "user",	manager : User.manager, lock : false },
			{ key : "mapId",	prop : "map",	manager : Map.manager, lock : false }, // à delocker
		];
	}

	public static var manager  = new CadaverManager();

	public var id : SId;
	public var zoneId : SNull<SInt>;
	public var userId(default,null) : SInt;

	public var mapId(default,null) : SNull<SInt>;		// Quand on supprime la map on ne supprime surtout pas le cadaver
	public var mapName : SString<50>;	// D'où ce stockage du nom de la map...
	public var oldMapId : SInt;			// Et d'où ce stockage du mapId...
	public var deathType : SInt;
	public var mapDay : SInt;
	public var survivalDays : SInt;
	public var homeRecycle : SInt;
	public var homeLevel : SInt;
	public var deathMessage : SNull<SString<120>>;
	public var comment : SString<100>;
	public var watered : SNull<SString<32>>;
	public var garbaged : SNull<SString<32>>;
	public var diedInTown : SBool;
	public var attackedCity : SBool;
	public var isGhoul : SBool;
	public var hardcore : SBool;
	public var banned : SBool; // exclusion du classement
	public var custom : SBool; // issu d'une ville privée
	public var season : SInt;

	public var createDate : SNull<SDateTime>; // spécifique cron

	public var user(dynamic, dynamic) : User;
	public var map(dynamic, dynamic) : Map;

	public var name : String;

	public static function create( map : Map , user : User, name, death, day, survivalDays, diedInTown ) {
		var uc =  manager._getUserCadaver( user, map, true );
		if( uc != null )
			return uc;

		var c = new Cadaver();
		c.map = map;
		c.oldMapId = map.id;
		c.user = user;
		c.deathType = death;
		c.mapDay = day;
		c.diedInTown = diedInTown;
		c.survivalDays = survivalDays;
		c.comment = "";
		c.homeLevel = user.homeLevel;
		c.isGhoul = user.isGhoul;
		c.hardcore = map.isHardcore();
		c.season = map.season;
		c.banned = map.isBannedFromRanking();
		c.custom = map.isCustom();
		c.insert();
		return c;
	}
	
	public function mapFlag(n:String) : Bool {
		return db.MapVar.manager.getBoolFromId(oldMapId, n);
	}
	
	public function new() {
		super();
		mapDay = 1;
		survivalDays = 1;
		homeRecycle = 0;
		season = 0;
	}
	
	public function isMapOpen() {
		if( mapId == null ) return false;
		var map = Map.manager.get(mapId, false);
		if( map == null ) return false;
		if( map.status == Type.enumIndex(EndGame) ) return false;
		return true;
	}
	
	public function getSurvivalPoints() {
		var score = 0;
		for( i in 1...survivalDays + 1)
			score += i;
		
		var hasRestriction = custom && !mapFlag("fullXP");
		var ratio = if ( season <= 10 ) 3 else 2; //50% instead of 33%  after season  10
		return	if(hasRestriction) 	Std.int(score / ratio);
				else 				score;
	}
	
	public static function getSurvivalPointsStatic(survivalDays) {
		var score = 0;
		for(i in 1...survivalDays + 1)
			score += i;
		return score;
	}
	
	public function getDeathReason() {
		return getDeathReasonStatic(deathType);
	}

	public static function getDeathReasonStatic(deathType:Int) {
		var e = Type.getEnumConstructs(DeathType);
		var k = Std.string(e[deathType]);
		return Text.getByKey(k);
	}

	public function getShortDeathReason() {
		return getShortDeathReasonStatic(deathType);
	}

	public static function getShortDeathReasonStatic(deathType:Int) {
		var e = Type.getEnumConstructs(DeathType);
		var k = "DTS_"+Std.string(e[deathType]).substr(3);
		return Text.getByKey(k);
	}
	
	public function canLeaveMessage() {
		return
			deathType != Type.enumIndex(DT_Poison) &&
			deathType != Type.enumIndex(DT_GhoulAttack);
	}

	public function getDeathEnumName() {
		return Std.string(Type.getEnumConstructs(DeathType)[deathType]);
	}

	public function recycle() {
		if( mapId == null )
			return null;
		var map = db.Map.manager.get( mapId, false );
		if( map == null )
			return null;

		// on ne drope que les items en bon état
		db.ZoneItem.manager.dropCadaverTools( this, map._getCity() );
		db.CadaverRemains.manager.deleteCadaverTools( id );

		var rsc = new Array();
		for (level in 0...homeLevel+1) {
			var up = XmlData.homeUpgrades[level];
			for (req in up.reqs) {
				var treq = XmlData.getToolByKey(req.key);
				for (i in 0...req.n) {
					rsc.push(treq);
				}
			}
		}
		var recup = new Array();
		if ( rsc.length>0 ) {
			var max = Math.min( Const.get.MaxRecycledRsc, Std.random( rsc.length )+1 );
			while (max>0) {
				var i = Std.random(rsc.length);
				recup.push( rsc[i].print() );
				db.ZoneItem.addToCity( map, rsc[i] );
				rsc.splice(i,1);
				max--;
			}
			recup.sort( function(a,b) {
				if ( a>b ) return 1;
				if ( a<b ) return -1;
				return 0;
			});
		}
		return recup;
	}

	public function hasHomeRecycled() {
		return hasHomeRecycledStatic(homeRecycle);
	}

	public static function hasHomeRecycledStatic(homeRecycle) {
		return homeRecycle>=Const.get.HomeRecycling;
	}

	public function getHome() {
		return XmlData.homeUpgrades[homeLevel];
	}

	public function getTools() {
		return CadaverRemains.manager.getByCadaver( this );
	}

	public function getDispTools() {
		var tools = CadaverRemains.manager.getByCadaver( this );
		if( tools.length <= 0 ) {
			return new List();
		}
		return Lambda.map( tools, function( ct: CadaverRemains ) {
			var t = new db.Tool();
			t.id = ct.id;
			t.toolId = ct.toolId;
			t.makeInfos();
			t.isBroken = ct.isBroken;
			return t;
		});
	}

	override public function toString() {
		return Utils.toString( this );
	}

	public static function formatName(name) {
		return ;
	}

	public function print() {
		return "<strong>&dagger;&nbsp;"+user.name+"</strong>";
	}

	public function isV1() {
		var startDate = DateTools.delta( createDate, -DateTools.days(mapDay) );
		return startDate.getTime() <= Date.fromString("2008-11-26 15:25:00").getTime();
	}

	public function isHardcore() {
		return /*Version.hasMod("HARDCORE") && */hardcore;
	}
	
	
	#if tid_appli
	public function getGraph( viewer : db.User, scopes: Array<String>, fields : mt.net.GraphFields ) : Dynamic {
		if( fields == null ) fields = [];
		var oGraph:Dynamic = {
			id: userId,
			twinId : user.twinId,
			day: mapDay,
			msg: deathMessage,
			name: name,
			avatar : user.avatar,
			dtype: deathType,
			season: season,
		}
		
		for( f in fields ) {
			switch( f.name ) {
				case "id", "twinId", "day", "msg", "name", "avatar", "dtype", "season":
				case "v1": oGraph.v1 = isV1();
				case "score": oGraph.score = Math.max(0, getSurvivalPoints());
				case "survival": oGraph.survival = Math.max(0, survivalDays);
				case "mapName": oGraph.mapName = this.mapName;
				case "comment": oGraph.comment = this.comment;
				case "mapId": oGraph.mapId = this.oldMapId;
				case "cleanup":
					var cleanGraph:Dynamic = { };
					if( garbaged != null ) {
						cleanGraph.user = garbaged;
						if( garbaged == "" ) cleanGraph.type = "ghoul";
						else cleanGraph.type = "garbage";
					} else if( watered != null ) {
						cleanGraph.user = watered;
						cleanGraph.type = "water";
					} else {
						cleanGraph.user = null;
						cleanGraph.type = "cook";
					}
					oGraph.cleanup = cleanGraph;
				default:
					throw "Unknown field: "+f.name;
			}
		}
		
		return oGraph;
	}
	#end	
}

class CadaverManager extends neko.db.Manager<Cadaver> {

	public function new() {
		super(Cadaver);
	}

	private override function make( c: Cadaver ) {
		c.name = c.user.name;
	}

	public function getMapCount( map : Map ) {
		return execute("SELECT COUNT(*) FROM Cadaver WHERE mapId="+map.id).getIntResult(0);
	}

	public function _getUserCadaver( user : User, map : Map, lock:Bool ) {
		if( map == null )
			return null;
		if( lock )
			return object(select( "userId="+user.id + " AND mapId=" + map.id ), true);
		else
			return object(selectReadOnly( "userId="+user.id + " AND mapId=" + map.id ), false);
	}

	public function getUserCadavers( user : User ) {
		return objects(select( "userId="+user.id ), true);
	}

	public function getLastUserCadaver( user : User, ?lock) {
		if( lock )
			return object("SELECT * FROM Cadaver FORCE INDEX (Cadaver_userId_id) WHERE userId="+user.id + " ORDER BY id DESC LIMIT 0,1 FOR UPDATE", true);
		else
			return object("SELECT * FROM Cadaver FORCE INDEX (Cadaver_userId_id) WHERE userId="+user.id + " ORDER BY id DESC LIMIT 0,1", false);
	}

	public function getList(map : Map) {
		var rs = objects( selectReadOnly( "mapId="+map.id),false);
		return sortedResults( rs );
	}

	public function getHistoryList(mapId : Int) {
		var rs = Lambda.array( results( "SELECT c.id, u.twinId, c.comment, c.survivalDays, c.userId, c.deathMessage, c.deathType, c.diedInTown, u.name, u.customTitle FROM Cadaver c, User u WHERE c.oldMapId=" + mapId + " AND u.id = c.userId ORDER by c.survivalDays DESC") );
		rs.sort( function( o1,o2 ) { if( o1>o2 ) return 1; if( o2>o1) return -1; return 0;} );
		return Lambda.list( rs );
	}

	public function getUserIds(mapId:Int) : List<Int> {
		var raw = results("SELECT userId FROM Cadaver WHERE oldMapId="+mapId);
		return Lambda.map(raw, function(r) { return r.userId; });
	}
	
	public function getRewardableUserIds(mapId:Int) : List<Int> {
		var season = db.Version.getVar("season");
		var maxUsers = db.Version.getVar("usersRank_season_" + season, 40);
		var raw:List<{userId:Int, survivalDays:Int}> = results("SELECT userId, survivalDays FROM Cadaver WHERE oldMapId=" + mapId + " ORDER BY survivalDays DESC");
		var index = -1;
		//make sure to avoid cheater users
		var raw = Lambda.filter(raw, function(c) {
			return db.UserVar.manager.count( {userId:c.userId, name:"cheater".toLowerCase()} ) == 0;
		});
		
		var raw = Lambda.filter(raw, function(c) {
			index++;
			if ( index >= maxUsers && c.survivalDays < 5 ) return false;
			return true;
		});
		return Lambda.map(raw, function(r) { return r.userId; });
	}

	public function getOrderedList(map : Map) {
		return objects( selectReadOnly( "mapId="+map.id+" ORDER BY mapDay ASC"),false);
	}

	public function getFilteredList( map : Map, reason : DeathType, day : Int )  {
		var sql =  selectReadOnly( "mapId="+map.id+" AND deathType=" + Type.enumIndex( reason ) +" AND mapDay="+day );
		var rs = objects( sql ,false);
		return sortedResults( rs );
	}

	public function getAtDay( map : Map, day : Int )  {
		var sql =  selectReadOnly( "mapId="+map.id+" AND mapDay="+day );
		var rs = objects( sql ,false);
		return rs;
	}
	
	public function getFilteredExcludeList( map : Map, exclude : DeathType, day : Int )  {
		var rs = objects( selectReadOnly( "mapId="+map.id+" AND deathType !=" + Type.enumIndex( exclude ) +" AND mapDay="+day),false) ;
		return sortedResults( rs );
	}

	private function sortedResults( rs ) : List<Cadaver>{
		if( rs == null ) return null;
		var a =  Lambda.array( rs );
		a.sort( function( c1 : Cadaver, c2 : Cadaver ) {
			return tools.Utils.compareStrings( c1.name, c2.name );
		});
		return Lambda.list(a);
	}

	public function hasPlayedAMap( user : User, map : Map ) {
		return execute("SELECT count(*) from Cadaver where mapId="+map.id+" AND userId="+user.id).getIntResult(0) > 0;
	}

	public function countPlayedMaps( user : User ) {
		return execute("SELECT count(*) from Cadaver where userId="+user.id).getIntResult(0);
	}

	public function getPlayedMapsIds( user : User ) {
		return results("SELECT mapId FROM Cadaver WHERE mapId IS NOT NULL AND userId="+user.id);
	}

	public function getSeasonMapIds( user:User, season:Int ) {
		var res = results("SELECT oldMapId FROM Cadaver WHERE userId="+user.id+" AND oldMapId IS NOT null AND season="+season);
		var hash = new IntHash();
		for(r in res)
			hash.set(r.oldMapId, true);
		return hash;
	}

	public function getPlayedMaps( user:User, ?minDaysFilter:Int ) {
		var reqDays = if ( minDaysFilter!=null ) " AND survivalDays>="+minDaysFilter else "";
		return objects( selectReadOnly( "userId="+user.id+" "+reqDays+" ORDER BY id DESC"), false);
	}
	
	public function getBestMaps( user:User, seasonFilter:Int, minDaysFilter:Int, limit:Int ) {
		return
			objects( selectReadOnly(
				"userId="+user.id+" "+((seasonFilter>=0)?"AND season="+seasonFilter:"")+" AND survivalDays>="+minDaysFilter+" ORDER BY survivalDays DESC LIMIT "+limit
			), false);
	}

	public function getBest() {
		return object( selectReadOnly("mapId IS null AND survivalDays>2 AND createDate > '2008-12-01' ORDER BY survivalDays DESC LIMIT 1"), false );
	}

	public function getUncleanedDeads(map:Map) {
		// retourne tous les zombies des jours précédents qui n'ont toujours pas attaqué...
		var midnight = Date.fromString( DateTools.format( Date.now(), "%Y-%m-%d 00:00:00" ) );
		return objects( select("mapId="+map.id+" AND attackedCity=0 AND watered IS NULL AND garbaged IS NULL AND mapDay <"+map.days+" AND createDate<"+quote(midnight.toString()) ), true );
	}

	public function getByMap( map : Map ) {
		var rs = Lambda.array( results("SELECT c.deathType, c.mapDay, c.id, c.userId, u.name FROM Cadaver as c, User as u WHERE c.mapId=" + map.id+ " AND u.id = c.userId") );
		// *** Ajouté : c.userId à la fonction de compare et à la requête SQL...
		rs.sort( function( o1 : { deathType:Int, mapDay:Int, id:Int,name:String, userId:Int},o2: { deathType:Int, mapDay:Int, id:Int,name:String, userId:Int}) {
			return tools.Utils.compareStrings( o1.name, o2.name );
		} );
		return Lambda.list( rs );
	}
	
	public function getFromUids(uids:List<Int>) {
		return objects( select("userId IN("+uids.join(",")+")"), true );
	}

}
