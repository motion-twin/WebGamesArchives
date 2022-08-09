package db;
import mt.db.Types;
import data.Battle;

class Battle extends neko.db.Object {

	static var PRIVATE_FIELDS = ["data"];
	static var INDEXES = [["mid", "finished"]];
	static function RELATIONS() : Array<Relation> {
		return [
			{ prop : "map", key : "mid", manager : Map.manager, lock : false },
			{ prop : "city", key : "cid", manager : City.manager },
		];
	}
	public static var manager = new BattleManager(Battle);

	public var id : SId;
	public var mid : SInt;
	public var cid : SInt;
	public var started : SDateTime;
	public var lastUpdate : SDateTime;
	public var ended : SNull<SDateTime>;
	public var finished : SBool;
	public var map(dynamic,dynamic) : Map;
	public var city(dynamic,dynamic) : City;
	public var data : data.Battle;
	var sdata : SBinary;

	public function new(c) {
		super();
		city = c;
		map = c.map;
		lastUpdate = started = Date.now();
		data = {
			ids : new IntHash(),
			history : [],
			camps : [],
			pairs : new List(),
			provoke : false,
		};
	}

	public function isPartOf( u : User ) {
		if( u == null )
			return false;
		for( c in data.ids )
			if( c.u == u.id )
				return true;
		return false;
	}

	public function getCurrentCamp( u : User ) {
		if( u == null )
			return null;
		for( cid in data.ids.keys() ) {
			var c = data.ids.get(cid);
			if( c.u == u.id ) {
				for( c in data.camps )
					if( c.id == cid )
						return !c.def;
			}
		}
		return null;
	}

	public function getUnitsCount( def ) {
		var total = 0;
		for( c in data.camps ) {
			if( c.def != def ) continue;
			for( u in c.units )
				total += u.f + u.l.length;
		}
		return total;
	}

	public function history(h) {
		data.history.unshift({ h : h, t : Date.now().getTime() });
	}

	public function add( u : db.Units, def ) {
		if( u == null )
			return null;
		if( u.battle != this ) {
			if( u.battle != null ) throw "assert "+u.id+" "+Std.string({ b1 : { id : u.battle.id, p : u.battle.cid, started : u.battle.started }, cur : { id : this.id, p : cid, started : started } });
			u.battle = this;
			u.update();
		}
		var c = { id : u.id, def : def, gid : null, units : null, kill : 0 };
		data.camps.push(c);
		data.ids.set(u.id,{
			u : u.uid,
			g : null,
			k : if( u == city.defense ) true else null,
		});
		return c;
	}

	function getCamp(cid) {
		var c = data.ids.get(cid);
		return { u : db.User.manager.get(c.u,false), g : c.g, k : c.k };
	}

	public function getLog() {
		var log = new List();
		var units = new db.Units().getInfos();
		for( h in data.history ) {
			var l : Dynamic = { id : Type.enumIndex(h.h), date : Date.fromTime(h.t) };
			log.add(l);
			switch( h.h ) {
			case BKill(cid,kind):
				l.c = getCamp(cid);
				l.u = units[kind].u;
			case BJoin(cid,count,def):
				l.c = getCamp(cid);
				l.count = count;
				l.def = def;
			case BQuit(cid,count), BFlee(cid,count), BUnitsLeave(cid,count), BUnitsAdd(cid,count):
				l.c = getCamp(cid);
				l.count = count;
			case BDie(cid):
				l.c = getCamp(cid);
			case BWin(def):
				l.def = def;
			}
		}
		return log;
	}

}

class BattleManager extends neko.db.Manager<Battle> {

	override function make( b : Battle ) {
		var bd : { private var sdata : String; } = b;
		var data = neko.Lib.stringReference(neko.zip.Uncompress.run(neko.Lib.bytesReference(bd.sdata)));
		b.data = haxe.Unserializer.run(data);
	}

	override function unmake( b : Battle ) {
		var bd : { private var sdata : String; } = b;
		var s = new haxe.Serializer();
		s.useEnumIndex = true;
		s.serialize(b.data);
		var data = s.toString();
		bd.sdata = neko.Lib.stringReference(neko.zip.Compress.run(neko.Lib.bytesReference(data),9));
	}

	public function getCurrent( c : City, lock ) {
		return object("SELECT * FROM Battle WHERE cid = "+c.id+" AND finished = 0",lock);
	}

	public function getCurrentId( c : City ) : Null<Int> {
		var r = result("SELECT id FROM Battle WHERE cid = "+c.id+" AND finished = 0 LIMIT 1");
		return (r == null) ? null : r.id;
	}

}