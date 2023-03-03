package db;
import mt.db.Types;
import Common;

typedef CityLogOption = {
	userId : Int,
	toolId : Int
}

class CityLog extends neko.db.Object {

	static var RELATIONS = function() {
		return [
			{ key : "mapId", prop : "map", manager : Map.manager, lock : false },
			{ key : "zoneId", prop : "zone", manager : Zone.manager, lock : false },
			{ key : "userId",    prop : "user",    manager : User.manager, lock : false }
		];
	}

	static var INDEXES = [ ["ckey"], ["mapId","userId","id"], ["zoneId"], ["ckey","date"], ["mapId","date","zoneId","id"] ];
	static var PRIVATE_FIELDS	= [ "options" ];

    public static var manager  = new CityLogManager();

    public var id(default,null)			: SId;

	public var mapId(default,null)	: SInt;
	public var zoneId(default,null)	: SNull<SInt>;
	public var userId(default,null)	: SNull<SInt>;
	public var ckey		: SString<32>;
	public var ctext	: SText;
	public var coption	: SNull<SBinary>;
	public var dateLog	: SDateTime;
	public var date 	: SDate; // Champs pour optimiser les requêtes
	public var day		: SInt;
	public var hidden	: SBool;

	public var options : CityLogOption;
	public var map( dynamic, dynamic ) : Map;
	public var user( dynamic, dynamic ) : User;
	public var zone( dynamic, dynamic ) : Zone;

	public function new() {
		super();
		dateLog = Date.now();
		date = Date.now();
	}

	public static function add( key : CityLogKey, text : String, map : Map, ?user:User, ?options : CityLogOption, ?zone: Zone ) {
		var c = new CityLog();
		c.ctext = text;
		c.map = map;
		c.day = map.days;
		c.ckey = Std.string(key);
		c.user = user;
		c.zone = zone;
		if( options != null ) {
			c.options = options;
		}
		c.insert();
		return c;
	}

	public function hasKey(k:CityLogKey) {
		return ckey==Std.string(k);
	}

	public static function addToZone(key,text,map,zoneId) {
		add(key,text,map,null,null,zoneId);
	}
}

class CityLogManager extends neko.db.Manager<CityLog>{

	public function new() {
		super(CityLog);
	}

	override function make( cl : CityLog ) {
		if( cl.coption != null && cl.coption != "") {
			var z = neko.Lib.localUnserialize( neko.Lib.bytesReference(cl.coption));
			cl.options = z;
		}
	}

	override function unmake( cl : CityLog ) {
		cl.coption = neko.Lib.stringReference(neko.Lib.serialize( cl.options ));
	}

	public function getLogs( map : Map, ?user:User, ?keys : Array<CityLogKey>, ?limit:Int ) {
		return getZoneLogs( map, user, keys, limit );
	}

	public function getZoneLogs( map : Map, ?zone: Zone, ?user: User, ?keys : Array<CityLogKey>, ?limit:Int ) {
		var reqZone = if( zone == null) " AND zoneId IS NULL" else " AND zoneId="+ zone.id;

		// new system
		var day = if(App.request.exists("logDay")) Std.parseInt( App.request.get("logDay") ) else map.days;

		if (limit==null ) {
			var sql = objects( selectReadOnly( "mapid=" +map.id +" AND hidden=0 "+ getKeys( keys ) + getUser( user ) +reqZone + " AND day="+day ), false );
			var rs = Lambda.array(sql);
			rs.sort(function(o1,o2){if( o1.id > o2.id ) return -1; if( o2.id > o1.id ) return 1; return 0;});
			return Lambda.list( rs );
		}
		else {
			return objects( selectReadOnly( "mapid=" +map.id +" AND hidden=0 "+ getKeys( keys ) + getUser( user ) +reqZone + " AND day="+day+" ORDER BY id DESC LIMIT "+limit ), false );
		}
	}

	public function counts(map:Map, key:String, ?day:Int) {
		if ( day!=null ) {
			return results("SELECT userId AS uid, count(*) AS n FROM CityLog WHERE mapId="+map.id+" AND hidden=0 AND day="+day+" AND userId IS NOT null AND ckey='"+key+"' GROUP BY userId");
		} else {
			return results("SELECT userId AS uid, count(*) AS n FROM CityLog WHERE mapId="+map.id+" AND hidden=0 AND day<"+map.days+" AND userId IS NOT null AND ckey='"+key+"' GROUP BY userId");
		}
	}

	public function countByZone(zone:db.Zone) {
		return execute("SELECT count(*) FROM CityLog WHERE zoneId="+zone.id+" AND hidden=0").getIntResult(0);
	}

	public function getCountsByMap(map:Map ) {
		return results("SELECT userId AS uid, count(*) AS n, ckey, day FROM CityLog WHERE mapId="+map.id+" AND userId IS NOT null GROUP BY userId");
	}

	public function clearLogs(zid:Int) {
		execute("DELETE FROM CityLog WHERE zoneId="+zid+" AND ( ckey IN ('CL_OutsideTempEvent','CL_OutsideMessage','CL_OutsideChat') )");
	}

	function getUser( user : User ) {
		var reqUser = "";
		if ( user!=null ) {
			reqUser=" AND userId="+user.id;
		}
		return reqUser;
	}

	function getKeys( keys : Array<CityLogKey>) {
		var reqKey = "";
 		if ( keys!=null && keys.length > 0 ) {
			reqKey+=" AND ckey IN (";
			var a = new Array();
			for (key in keys) {
				a.push( quote(Std.string(key)) );
			}
			reqKey+=a.join(",") + ")";
		}
		return reqKey;
	}

	function getDateSQL( off : Int ) {

		var hours = App.CRON_HOUR;
		var hour = hours[0];
		var min = hours[1];
		var sec = hours[2] ;

		var now = Date.now();
		var cronHour = new Date( now.getFullYear(), now.getMonth(), now.getDate(), App.CRON_HOUR[0], App.CRON_HOUR[1], App.CRON_HOUR[2]);

		// si l'heure de l'attaque n'est pas à minuit
		// on a forcément un décallage des news qui commencent du coup la veille
		if( now.getTime() <= cronHour.getTime() ) {
			off += 1;
		}

		var mmm = now.getMonth() + 1;
		var dday = now.getDate() - off;

		var today = new Date( now.getFullYear(), mmm, dday, hour,min,sec );
		var month = if( mmm > 9 ) Std.string( mmm ) else "0" + Std.string( mmm );
		var day = if( dday > 9 ) Std.string( dday ) else "0" + Std.string( dday );
		var reqDate = " AND `dateLog` >='"+today.getFullYear()+"-"+month+"-"+day+" "+App.getCronHourForSQL()+"'";
		var tomorrow = DateTools.delta( today, 1000 * 60 * 60 * 24);
		mmm = tomorrow.getMonth();
		dday = tomorrow.getDate();
		month = if( mmm > 9 ) Std.string( mmm ) else "0" + Std.string( mmm );
		day = if( dday > 9 ) Std.string( dday ) else "0" + Std.string( dday );
		reqDate += " AND `dateLog` <'"+tomorrow.getFullYear()+"-"+month+"-"+day+" " + App.getCronHourForSQL() +"'";
		return reqDate;
	}

	public function getLastActivity(u:User) {
		var res = execute("SELECT dateLog FROM CityLog WHERE userId="+u.id+" ORDER BY id DESC LIMIT 1");
		if ( res.length==0 )
			return null;
		else
			return Date.fromString(res.getResult(0));
	}

	public function getLast(zoneId:Int, msg:String) {
		return object( "SELECT * FROM CityLog WHERE zoneId="+zoneId+" AND ctext="+quote(msg)+" ORDER BY id DESC LIMIT 1", false );
	}

	public function replaceRecent(zone:Zone, date:Date, msg:String) {
		execute("UPDATE CityLog SET ctext="+quote(msg)+" WHERE zoneId="+zone.id+" AND dateLog>="+quote(date.toString()));
	}
}
