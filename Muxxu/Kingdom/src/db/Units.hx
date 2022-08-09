package db;
import mt.db.Types;
import data.Battle.BattleCamp;

class Units extends neko.db.Object {

	static var PRIVATE_FIELDS = ["free","camp"];
	static function RELATIONS() : Array<Relation> {
		return [
			{ prop : "user", key : "uid", manager : User.manager, lock : false, cascade : true },
			{ prop : "prevUser", key : "puid", manager : User.manager, lock : false },
			{ prop : "battle", key : "bid", manager : Battle.manager, lock : false },
		];
	}
	public static var manager = new neko.db.Manager<Units>(Units);

	public var id : SId;
	public var user(dynamic,dynamic) : SNull<User>; // null = barbarians
	public var uid : SNull<SInt>;
	public var battle(dynamic,dynamic) : SNull<Battle>;
	public var bid : SNull<SInt>;
	public var prevUser(dynamic,dynamic) : SNull<User>;

	public var soldiers : SInt;
	public var archers : SInt;
	public var cavaliers : SInt;
	public var paladins : SInt;
	public var piquiers : SInt;
	public var chevaliers : SInt;
	public var cavarchers : SInt;
	public var balists : SInt;
	public var catapults : SInt;

	 // used temporary by Rules
	public var free : Int;
	public var camp : BattleCamp;

	public function new() {
		super();
		soldiers = 0;
		archers = 0;
		cavaliers = 0;
		paladins = 0;
		piquiers = 0;
		chevaliers = 0;
		cavarchers = 0;
		balists = 0;
		catapults = 0;
	}

	public function count() {
		return soldiers + archers + cavaliers + paladins + piquiers + chevaliers + cavarchers + balists + catapults;
	}

	public function cost() {
		var cost = count() - ((free == null) ? 0 : free);
		if( cost < 0 ) return 0;
		return cost;
	}

	public function get() {
		return [
			soldiers,
			archers,
			cavaliers,
			paladins,
			piquiers,
			chevaliers,
			cavarchers,
			balists,
			catapults,
		];
	}

	public function getInfos() {
		var u = Data.UNITS.list;
		return [
			{ u : u.sold, n : soldiers },
			{ u : u.arch, n : archers },
			{ u : u.cav, n : cavaliers },
			{ u : u.pal, n : paladins },
			{ u : u.piq, n : piquiers },
			{ u : u.chev, n : chevaliers },
			{ u : u.caa, n : cavarchers },
			{ u : u.bal, n : balists },
			{ u : u.cat, n : catapults },
		];
	}

	public function set(units) {
		var p = 0;
		soldiers = units[p++];
		archers = units[p++];
		cavaliers = units[p++];
		paladins = units[p++];
		piquiers = units[p++];
		chevaliers = units[p++];
		cavarchers = units[p++];
		balists = units[p++];
		catapults = units[p++];
	}

	public function setInfos(units:Array<{ u : data.Unit, n : Int }>) {
		var p = 0;
		soldiers = units[p++].n;
		archers = units[p++].n;
		cavaliers = units[p++].n;
		paladins = units[p++].n;
		piquiers = units[p++].n;
		chevaliers = units[p++].n;
		cavarchers = units[p++].n;
		balists = units[p++].n;
		catapults = units[p++].n;
	}

	function hide( k : Int ) {
		if( k < 10 ) return "?";
		if( k < 100 ) return "??";
		if( k < 1000 ) return "???";
		return "????";
	}

}
