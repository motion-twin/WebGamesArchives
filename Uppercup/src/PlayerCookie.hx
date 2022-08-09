import mt.SecureSO;
import mt.deepnight.Lib;
import mt.deepnight.HaxeJson;
import Const;

typedef PlayerData = {
	var lastLevelNormal	: Int;
	var lastLevelHard	: Int;
	var lastLevelEpic	: Int;
	var shirtColor		: Int;
	var pantColor		: Int;
	var stripeColor		: Int;
	var music			: Bool;
	var sfx				: Bool;
	var crowdSfx		: Bool;
	var lowq			: Bool;
	var forcedQuality	: Bool;
	var unlocked		: String;
	var lang			: String;
	var leftHanded		: Null<Bool>;
	var ratedUs			: Bool;
	var tutoFlags		: Map<String,Bool>;
	var wonNormal		: Bool;
	var wonHard			: Bool;
	var wonEpic			: Bool;
	var unlockedHard	: Bool;
	var normalStars		: Map<Int,Int>;
	var hardStars		: Map<Int,Int>;
	var epicStars		: Map<Int,Int>;

	var nbLaunch 		: Int;
}

class PlayerCookie {
	static var VERSION = 20;
	static var PRE_RELEASE_DATA_VERSION = 15;

	#if !webDemo
	var sso				: SecureSO;
	#end
	public var data		: PlayerData;

	public function new() {
		#if !webDemo
		sso = new SecureSO({ name:"save", aesKey:"C0ACE17B954C6037454FC6FF100A2205", aesIv:"F93F111655192668BF70BE2CA2B92454" });
		#end
		data = makeNewData();
		load();
		data.nbLaunch++;
	}

	public inline function deviceId() {
		#if webDemo
		return "webDemo";
		#else
		return Lib.isAir() ? sso.deviceId() : "notAir";
		#end
	}

	public function save() {
		var hj = new HaxeJson(VERSION);
		hj.serialize(data);

		#if webDemo
		Lib.setCookie("uppercup", "data", hj.getSerialized());
		#else
		sso.set("data", hj.getSerialized());
		#end
	}

	public function load() {
		#if webDemo
		var raw = Lib.getCookie("uppercup", "data");
		#else
		var raw = sso.get("data");
		#end
		if( data==null )
			resetAndSave();
		else {

			var hj = new HaxeJson(VERSION);
			if( raw==null )
				return;

			hj.unserialize(raw);
			if( hj.getCurrentUnserializedDataVersion()<PRE_RELEASE_DATA_VERSION ) {
				// Old pre-release data
				resetAndSave();
			}
			else {
				// Recent data
				hj.patch(15,16, function(o:PlayerData) {
					var def = makeNewData();
					o.lastLevelEpic = def.lastLevelEpic;
				});
				hj.patch(16,17, function(o:PlayerData) {
					var def = makeNewData();
					o.wonEpic = o.wonNormal = o.wonHard = false;
				});
				hj.patch(17,18, function(o:PlayerData) {
					var def = makeNewData();
					o.forcedQuality = def.forcedQuality;
				});
				hj.patch(18,19, function(o:PlayerData) {
					o.unlockedHard = true; // existing players had this mode for "free"
				});
				hj.patch(19,20, function(o:PlayerData) {
					o.normalStars = new Map();
					o.hardStars = new Map();
					o.epicStars = new Map();
				});
				data = hj.getUnserialized();
				#if webDemo
				data.normalStars = new Map();
				data.hardStars = new Map();
				data.epicStars = new Map();
				data.lastLevelNormal = data.lastLevelHard = data.lastLevelEpic = 1;
				#end
				save();
			}
		}
	}

	function getDefaultLang() {
		var lang = flash.system.Capabilities.language;
		return switch( lang ) {
			case "fr", "hu", "es", "de", "pt", "it", "ru", "tr" : lang;
			default : "en";
		}
	}

	public inline function getLastLevel(v:GameVariant) {
		return switch( v ) {
			case Normal : data.lastLevelNormal;
			case Hard : data.lastLevelHard;
			case Epic : data.lastLevelEpic;
		}
	}


	public inline function setTutoFlag(id) {
		data.tutoFlags.set(id, true);
		save();
	}

	public inline function hasTutoFlag(id) {
		return data.tutoFlags.exists(id);
	}


	public function getStars(v:GameVariant, lid:Int) {
		var map = switch( v ) {
			case Normal : data.normalStars;
			case Hard : data.hardStars;
			case Epic : data.epicStars;
		}
		return map.exists(lid) ? map.get(lid) : 0;
	}

	public function setStars(v:GameVariant, lid:Int, n:Int) {
		if( getStars(v,lid) < n ) {
			var map = switch( v ) {
				case Normal : data.normalStars;
				case Hard : data.hardStars;
				case Epic : data.epicStars;
			}
			map.set(lid, n);
			save();
		}
	}


	function makeNewData() : PlayerData {
		return {
			unlocked	: "",
			lastLevelNormal	: 1,
			lastLevelHard	: 4,
			lastLevelEpic	: 4,
			shirtColor	: 0,
			pantColor	: 0,
			stripeColor	: 0,
			music		: true,
			sfx			: true,
			crowdSfx	: true,
			lowq		: false,
			forcedQuality: false,
			lang		: getDefaultLang(),
			nbLaunch	: 0,
			leftHanded	: null,
			ratedUs		: false,
			tutoFlags	: new Map(),
			wonNormal	: false,
			wonHard		: false,
			wonEpic		: false,
			unlockedHard: false,
			normalStars	: new Map(),
			hardStars	: new Map(),
			epicStars	: new Map(),
		}
	}

	public function toString() {
		var a = [];
		for(k in Reflect.fields(data))
			a.push(k+" => "+Reflect.field(data, k));
		return a.join("\n");
	}


	public function resetAndSave() {
		data = makeNewData();
		save();
	}

}