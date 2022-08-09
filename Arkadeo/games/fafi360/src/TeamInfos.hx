import mt.flash.Volatile;
import api.AKApi;

enum Perk {
	_PPreciseGoal;
	_PStrongGoal;
	_PReachGoal;

	_PPreciseDefense;
	_PStrongDefense;
	_PReachDefense;
	_PFastDefense;

	_PReachAll;
	_PMagneticBall;

	_PPreciseAttack;
	_PReachAttack;
	_PFastAttack;

	_PExtraTime1;
	_PExtraTime2;
	_PBonusGrab;
	_PGoalJump;
	_PDefenseJump;
	_PDoubleAttack;

	@ai _PWeak;
	@ai _PSuperStrong;
	@ai _PNoGoal;
	@ai _PCornerCage;
	@ai _PRandomCage;
	@ai _PSmallCage;
	@ai _PLargeCage;
	@ai _PPlayerLargeCage;
	@ai _PMineField;
	@ai _PLowRange;
	@ai _PKamikaze;
	@ai _PSlow;

	@ai _PRocks;
	@ai _PPumpkins;
	@ai _PMissiles;

	@ai _PSnowTerrain;
	@ai _PWetTerrain;
	@ai _PExtraWater;
	@ai _PGlueTerrain;
	@ai _PLeatherTerrain;
}

@:publicFields class TeamInfos {
	var side		: Int;

	var name		: String;
	var color		: Int;
	var playerCount	: api.AKConst;
	var hairFrame	: Int;
	var perkCache	: Map<Int,Bool>;
	var skill		: api.AKConst;

	var players		: Array<en.Player>;

	public function new() {
		var game = Game.ME;

		skill = AKApi.const(0);
		name = "Unknown";
		color = 0xDF2046;
		hairFrame = 17;
		perkCache = new Map();
		players = new Array();
		playerCount = game.isLeague() ? api.AKApi.const(9) : api.AKApi.const(11);

		if( game.isLeague() ) {
			var rseed = new mt.Rand(0);
			rseed.initSeed(game.seed);
			var hairs = [13,14,15, 36,37,38];
			hairFrame = hairs[rseed.random(hairs.length)];
		}
	}

	public function setProgressionLevel(level:Int) {
		var game = Game.ME;
		var raw = haxe.Resource.getString("teams");
		var xml = new haxe.xml.Fast( Xml.parse(raw).firstChild() );
		var i = 1;
		for(node in xml.nodes.t) {
			if( i==level ) {
				name = node.att.name;
				color = mt.deepnight.Color.hexToInt(node.att.color);
				hairFrame = Std.parseInt(node.att.hair);
				playerCount = AKApi.const(Std.parseInt(node.att.size));
				skill = AKApi.const(Std.parseInt(node.att.skill));
				#if debug
				game.scoreTarget = AKApi.const(1);
				#else
				game.scoreTarget = AKApi.const(Std.parseInt(node.att.score));
				#end
				if( StringTools.trim(node.att.perks).length>0 )
					for(k in node.att.perks.split(",")) {
						var p = Type.createEnum(Perk, "_P"+StringTools.trim(k));
						addPerk(p);
					}

				break;
			}
			i++;
		}
	}

	public inline function getSkill() {
		return skill.get();
	}

	public static function getPerkText(p:Perk) {
		try {
			var d = Lang.ALL.get(Std.string(p)).split("|");
			return { name:d[0], desc:d[1] }
		}
		catch(e:Dynamic) {
			return { name:"ERR:"+p, desc:"ERROR : missing text" }
		}
	}

	public function savePerks() {
		var a = new Array();
		for(pid in perkCache.keys())
			a.push(pid);
		return a;
	}

	public function loadPerks(a:Array<Int>) {
		if( a!=null ) {
			// Mode LEVEL UP
			for( pid in a )
				addPerk( Type.createEnumIndex(Perk, pid) );
		}
		else if( Game.ME.isProgression() ) {
			// Mode MISSION
			var rseed = new mt.Rand(0);
			rseed.initSeed( AKApi.getSeed() );
			for( l in 1...AKApi.getLevel()+1 )
				if( Game.ME.isPerkLevel(l) ) {
					var perks = getUnusedPlayerPerks();
					addPerk( perks[rseed.random(perks.length)] );
				}
		}
	}


	public function addPerk(p:Perk) {
		perkCache.set(Type.enumIndex(p), true);
	}

	public function getPerks() {
		var a = [];
		for( id in perkCache.keys() )
			a.push(Type.createEnumIndex(Perk, id));
		return a;
	}

	public function getUnusedPlayerPerks() {
		var allPerks = [];
		var meta = haxe.rtti.Meta.getFields(Perk);
		for(k in Type.getEnumConstructs(Perk)) {
			var p = Type.createEnum(Perk, k);
			if( !hasPerk(p) )
				if( Reflect.field(meta,k)==null || !Reflect.hasField(Reflect.field(meta,k), __unprotect__("ai")) )
					allPerks.push(p);
		}
		return allPerks;
	}

	public inline function hasPerk(p:Perk) {
		return perkCache.exists(Type.enumIndex(p));
	}
}
