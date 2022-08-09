package db;
import mt.db.Types;
import data.Message;

class Log<M:EnumValue> extends neko.db.Object {

	static var MAXLOG = 200;
	static var PRIVATE_FIELDS = ["log"];
	static var INDEXES : Array<Dynamic> = [["mid",true],["cid",true],["uid",true]];
	static function RELATIONS() {
		return [
			{ prop : "lmap", key : "mid", manager : Map.manager, lock : false, cascade : true },
			{ prop : "lcity", key : "cid", manager : City.manager, lock : false, cascade : true },
			{ prop : "luser", key : "uid", manager : User.manager, lock : false, cascade : true },
		];
	}
	public static var manager = new LogManager(Log);

	public var id : SId;
	public var lmap(dynamic,dynamic) : SNull<Map>;
	public var lcity(dynamic,dynamic) : SNull<City>;
	public var luser(dynamic,dynamic) : SNull<User>;
	var slog : SBinary;
	public var lastRead : SInt;

	public var log : Array<{ d : Date, msg : M }>;

	public function new() {
		super();
		this.log = new Array();
		lastRead = 0;
	}

	function getUser(uid) {
		return db.User.manager.get(uid,false);
	}

	function getCity(cid) {
		return db.City.manager.get(cid,false);
	}

	function getBattle(bid) {
		return bid;
	}

	function compactUser( m : UserMessage ) {
		switch( m ) {
		case MDiploFriend(_), MDiploEnemy(_), MDiploNeutral(_), MDiploTaxChange(_), MDiploCross(_), MDiploNoCross(_):
		default: return false;
		}
		for( i in 0...log.length - lastRead ) {
			var msg2 : UserMessage = cast log[i].msg;
			var found = switch( m ) {
			case MDiploFriend(uid),MDiploEnemy(uid),MDiploNeutral(uid):
				switch( msg2 ) {
				case MDiploFriend(uid2),MDiploEnemy(uid2),MDiploNeutral(uid2): uid == uid2;
				default: false;
				}
			case MDiploCross(uid), MDiploNoCross(uid):
				switch( msg2 ) {
				case MDiploCross(uid2),MDiploNoCross(uid2): uid == uid2;
				default: false;
				}
			case MDiploTaxChange(uid):
				switch( msg2 ) {
				case MDiploTaxChange(uid2): uid == uid2;
				default: false;
				}
			default:
				false;
			}
			if( found ) {
				// update old message
				log[i].msg = cast m;
				return true;
			}
		}
		return false;
	}

	function add( msg : M ) {
		// compact log
		if( luser != null && compactUser(cast msg) ) {
			update();
			return;
		}
		log.unshift({ d : Date.now(), msg : msg });
		while( log.length >= MAXLOG ) {
			log.pop();
			lastRead--;
		}
		update();
	}

	function prepareCity( p : Dynamic, m : CityMessage ) {
		switch( m ) {
		case MCityConsume(food,gold):
			p.food = food;
			p.gold = gold;
		case MCityProduce(rid,qty), MCityLost(rid,qty):
			p.r = Data.RESOURCES.getName(rid);
			p.n = qty;
		case MCityRecruit(pid), MCityStarve(pid):
			p.p = Data.PEOPLE.getName(pid);
		case MCityMoreActions(n), MCityBuildProgress(n), MCityNewSoldiers(n), MCityDesert(n), MCityDeficit(n):
			p.n = n;
		case MCityStartBuild(bid,level),MCityCancelBuild(bid,level),MCityTerminateBuild(bid,level):
			p.b = Data.BUILDINGS.getName(bid);
			p.level = level;
		case MCityGather(name,cid,rid,n,taxes):
			p.general = name;
			p.c = getCity(cid);
			p.r = Data.RESOURCES.getName(rid);
			p.n = n;
			p.taxes = taxes;
		case MCityConvert(rid1,rid2,n):
			p.r = Data.RESOURCES.getName(rid1);
			p.r2 = Data.RESOURCES.getName(rid2);
			p.n = n;
		case MCityConvert2(rid1,n,rid2,n2):
			p.r = Data.RESOURCES.getName(rid1);
			p.n = n;
			p.r2 = Data.RESOURCES.getName(rid2);
			p.n2 = n2;
		case MCityBuildWasted,MCityGridReset,MCityNewPeople,MCityNoCasern,MCityNoRecruit:
		}
	}

	function prepareMap( p : Dynamic, m : MapMessage ) {
		switch( m ) {
		case MMapControlNoFight(uid,cid,name),MMapBattleWon(uid,cid,name):
			p.u = getUser(uid);
			p.c = getCity(cid);
			p.general = name;
		case MMapRevoltStopped(uid,cid):
			p.u = getUser(uid);
			p.c = getCity(cid);
		case MMapKingdomDestroy(kid,uid,cid):
			p.k = getUser(kid);
			p.u = getUser(uid);
			p.c = getCity(cid);
		case MMapUserPromote(uid,tid):
			p.u = getUser(uid);
			p.t = Data.TITLES.getName(tid);
		case MMapNewPlace(cid,rid):
			p.c = getCity(cid);
			p.r = Data.RESOURCES.getName(rid);
		case MMapKingdomDecadent(tid,uid,cid):
			p.c = getCity(cid);
			p.t = Data.TITLES.getName(tid);
			p.u = getUser(uid);
		case MMapKingDied(tid,uid,cid,age):
			p.c = getCity(cid);
			p.t = Data.TITLES.getName(tid);
			p.u = getUser(uid);
			p.age = age;
		case MMapNewUser(uid,cid):
			p.c = getCity(cid);
			p.u = getUser(uid);
		case MMapRevolt(uid,kid):
			p.u = getUser(uid);
			p.k = getUser(kid);
		case MMapCityName(uid,cid,old,name):
			p.u = getUser(uid);
			p.c = getCity(cid);
			p.old = old;
			p.name = name;
		}
	}

	function prepareUser( p : Dynamic, m : UserMessage ) {
		switch( m ) {
		case MUserWelcome(cid), MUserLostDeficit(cid):
			p.c = getCity(cid);
		case MUserKingDefeat(kid,uid):
			p.k = getUser(kid);
			p.u = getUser(uid);
		case MUserNewKing(uid),MUserLostKingdom(uid):
			p.u = getUser(uid);
		case MUserLostPlace(cid,uid), MUserWinPlace(cid,uid), MUserVassalNewPlace(cid,uid):
			p.c = getCity(cid);
			p.u = if( uid == null ) null else getUser(uid);
		case MUserPromote(tid):
			p.t = Data.TITLES.getName(tid);
		case MUserLostGeneral(bid,cid,g):
			p.b = getBattle(bid);
			p.c = getCity(cid);
			p.general = g;
		case MUserBattleReport(bid,cid,won):
			p.b = getBattle(bid);
			p.c = getCity(cid);
			p.won = won;
		case MDiploCross(uid),MDiploNoCross(uid),MDiploFriend(uid),MDiploEnemy(uid),MDiploNeutral(uid),MDiploTaxChange(uid),
			MDiploRecolt(uid),MDiploNoRecolt(uid):
			p.u = getUser(uid);
		case MDiploTaxCollect(uid,tl),MDiploTaxCollected(uid,tl):
			p.u = getUser(uid);
			p.taxes = Lambda.map(tl,function(t) return { r : Data.RESOURCES.getName(t.r), n : t.n, w : t.w });
		case MUserHealth(h):
			p.h = h;
		case MUserDecadent:
		case MUserRevolt(uid,cid,bid), MUserStartRevolt(uid,cid,bid):
			p.u = getUser(uid);
			p.c = getCity(cid);
			p.b = getBattle(bid);
			p.hasBattle = bid != null;
		case MUserAttack(bid,cid,g,uid),MUserAttacked(bid,cid,g,uid),MUserAttackedAt(bid,cid,g,uid):
			p.b = getBattle(bid);
			p.c = getCity(cid);
			p.general = g;
			p.u = getUser(uid);
		case MUserGeneralReput(g,d):
			p.general = g;
			p.delta = (d < 0) ? -d : d;
			p.neg = (d < 0);
		case MUserProvoked(bid,cid,g,g2,uid):
			p.general = g;
			p.general2 = g2;
			p.b = getBattle(bid);
			p.c = getCity(cid);
			p.u = getUser(uid);
		case MUserProvoke(bid,cid,g,count):
			p.b = getBattle(bid);
			p.c = getCity(cid);
			p.general = g;
			p.count = count;
		case MUserRevoltCancel(uid,cid),MUserNewVassal(uid,cid):
			p.u = getUser(uid);
			p.c = getCity(cid);
		case MUserVassalDie(uid,count):
			p.u = getUser(uid);
			p.count = count;
		}
	}

	public function prepare() {
		var params = new List();
		for( l in log ) {
			var p = { date : l.d, id : Type.enumIndex(l.msg) };
			params.add(p);
			if( luser != null )
				prepareUser(p,cast l.msg);
			else if( lcity != null )
				prepareCity(p,cast l.msg);
			else
				prepareMap(p,cast l.msg);
		}
		return params;
	}

	public static function map( m : Map, msg : MapMessage ) {
		var l = manager.search({ mid : m.id },true).first();
		if( l == null ) {
			l = new Log();
			l.lmap = m;
			l.insert();
		}
		l.add(msg);
	}

	public static function city( c : City, msg : CityMessage ) {
		var l = manager.search({ cid : c.id },true).first();
		if( l == null ) {
			l = new Log();
			l.lcity = c;
			l.insert();
		}
		l.add(msg);
	}

	public static function user( u : User, msg : UserMessage ) {
		var l = manager.search({ uid : u.id },true).first();
		if( l == null ) {
			l = new Log();
			l.luser = u;
			l.insert();
		}
		l.add(msg);
	}

}

class LogManager extends neko.db.Manager<Log<Dynamic>> {

	override function make( l : Log<Dynamic> ) {
		var ldata : { private var slog : String; } = l;
		var data = neko.Lib.stringReference(neko.zip.Uncompress.run(neko.Lib.bytesReference(ldata.slog)));
		l.log = haxe.Unserializer.run(data);
	}

	override function unmake( l : Log<Dynamic> ) {
		var ldata : { private var slog : String; } = l;
		var s = new haxe.Serializer();
		s.useEnumIndex = true;
		s.serialize(l.log);
		var data = s.toString();
		ldata.slog = neko.Lib.stringReference(neko.zip.Compress.run(neko.Lib.bytesReference(data),9));
	}

}
