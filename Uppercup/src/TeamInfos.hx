import Const;
import mt.MLib;

enum Perk {
	_PCornerCage;
	_PRandomCage;
	_PSmallCage;
	_PLargeCage;
	_PPlayerLargeCage;
	_PSideWarp;

	_PWeak;
	@prio(5) _PSuperStrong;
	@prio(5) _PKamikaze;
	_PStatic;
	_PSlow;
	_PFast;
	@prio(1) _PSuperFast;
	_PMediumRange;
	_PHighRange;
	_PEasyPowerControl;
	_PSlowIaKick;
	_PNoFaults;
	_PNoTimeBonus;

	@prio(1) _PNoGoal;
	_PBadGoal;
	_PAverageGoal;
	_PSuperGoal;

	@prio(1) _PTeleports;
	@prio(1) _PCornerTeleports;
	@prio(1) _PBumpers;
	@prio(1) _PRocks;
	@prio(1) _PPumpkins;
	@prio(1) _PLifeBelts;
	@prio(1) _PAnvils;

	@prio(2) _PMines;
	@prio(2) _PSnow;
	@prio(2) _PWet;
	@prio(2) _PSuperWet;
	@prio(2) _PGlue;
	@prio(2) _PLeather;

	@prio(1) _PWindLight;
	@prio(1) _PWindMedium;
	@prio(1) _PWindStrong;

	_PWindBottom;
	_PWindTop;
	_PWindFront;
	_PWindBack;

	@prio(3) _PRugby;
	@prio(3) _PBowling;
	@prio(3) _PElectric;

	@prio(1) _PAttackWall;
	@prio(1) _PDefenseWall;
	@prio(1) _PMiddleWall;
	@prio(1) _PGoalWall;

	_PTuto1;
	_PTuto2;
	_PTuto3;
	_PTutoMatch;
	_PTutoElectric;
}


@:publicFields class TeamInfos {
	static var ALL : Map<Int,TeamInfos> = new Map();

	var side			: Int;
	var lid				: Int;
	private var variant	: GameVariant;

	var name			: String;
	var shirtColor		: UInt;
	var pantColor		: UInt;
	var stripeColor		: UInt;
	var playerCount		: Int;
	var hairFrame		: Int;
	var perkCache		: Map<Int,Bool>;
	private var skill	: Float;
	var townX			: Int;
	var townY			: Int;
	private var scoreTarget	: Int;
	var forcedStars		: Int;
	var isCustom		: Bool;

	public function new(side:Int, ?lid=-1) {
		var game = m.Game.ME;

		variant = Normal;
		this.side = side;
		this.lid = lid;
		isCustom = false;
		skill = 0;
		forcedStars = 0;
		scoreTarget = 0;
		name = "No name";
		shirtColor = pantColor = stripeColor = 0x4F4F4F;
		hairFrame = 17;
		perkCache = new Map();
		playerCount = 11;
		townX = townY = 0;

		if( side==1 )
			addPerk(_PAverageGoal);
	}

	public function getScoreTarget() {
		return switch( variant ) {
			case Normal	: scoreTarget;
			case Hard	: scoreTarget;
			case Epic	: scoreTarget+1;
		}
	}

	public function getTimeSeconds() : Float {
		if( isTutorial() )
			return 60*4;

		switch( variant ) {
			case Normal :
				if( lid<15 )
					return 60*4;
				else if( lid<50 )
					return 60*2.5;
				else
					return 60*2;

			case Hard :
				return 60*1.5;

			case Epic :
				return 60;
		}
	}

	public static function countLevels() {
		return Lambda.count(ALL);
	}

	public function initFromLevel(lid:Int) {
		if( lid<=10 )
			addPerk(_PNoGoal);
	}

	public static function getUnlockedHairs() {
		var all = [];
		var max = 1;
		max = MLib.max(max, m.Global.ME.playerCookie.data.lastLevelNormal);
		max = MLib.max(max, m.Global.ME.playerCookie.data.lastLevelHard);
		max = MLib.max(max, m.Global.ME.playerCookie.data.lastLevelEpic);
		for(lid in 1...max)
			all.push( ALL.get(lid).hairFrame );
		return all;
	}

	public static function makeMultiplayer() {
		var t = new TeamInfos(1, 1);
		t.scoreTarget = 3;
		t.playerCount = 10;
		t.skill = 1;
		t.pantColor = t.shirtColor = t.stripeColor = 0xFF0000;
		t.name = "Player 2"; // HACK multi
		t.hairFrame = 74;
		t.variant = Normal;
		return t;
	}

	public static function generate(diff:Float, v:GameVariant, ?name:String) {
		var t = new TeamInfos(1, 1);
		var seed = Std.random(999999);
		var rseed = new mt.Rand(seed);
		t.scoreTarget = 3;
		t.playerCount = MLib.round(7 + diff*5);
		t.skill = diff;
		t.pantColor = t.shirtColor = t.stripeColor = 0xFF0000;
		t.forcedStars = MLib.round( t.playerCount * diff );
		t.name = name!=null ? name : Lang.QuickMatch;
		t.isCustom = true;
		t.variant = v;

		// Hair
		var all = getUnlockedHairs();
		t.hairFrame = all[rseed.random(all.length)];

		// Obstacles
		var all = [_PRocks, _PPumpkins, _PLifeBelts, _PAnvils];
		t.addPerk( all.splice(rseed.random(all.length), 1)[0] );
		if( diff>=0.5 )
			t.addPerk( all.splice(rseed.random(all.length), 1)[0] );

		// Special obstacles
		var all = [ _PMines, _PBumpers, _PTeleports, _PCornerTeleports ];
		if( diff>=0.3 && rseed.random(100)<30+diff*60 )
			t.addPerk( all.splice(rseed.random(all.length), 1)[0] );
		//if( diff>=0.7 )
			//t.addPerk( all.splice(rseed.random(all.length), 1)[0] );

		// Terrain
		var all = [ _PSnow, _PLeather ];
		if( diff>=0.6 )
			all.push(_PSuperWet);
		else
			all.push(_PWet);
		if( diff>=0.7 )
			all.push(_PGlue);
		if( t.hasPerk(_PBumpers) || t.hasPerk(_PCornerTeleports) || t.hasPerk(_PTeleports) )
			all.remove(_PSnow);
		if( diff>=0.4 && rseed.random(100)<diff*90 )
			t.addPerk( all.splice(rseed.random(all.length), 1)[0] );

		// Balls
		var all = [ _PElectric, _PBowling, _PRugby ];
		if( diff>=0.3 )
			t.addPerk( all.splice(rseed.random(all.length), 1)[0] );

		// Goal cage
		var all = [ _PCornerCage, _PPlayerLargeCage];
		if( diff<=0.3 )
			all.push(_PLargeCage);
		if( diff>=0.6 )
			all.push(_PSmallCage);
		if( rseed.random(100)<30 || diff>=0.4 )
			t.addPerk( all.splice(rseed.random(all.length), 1)[0] );

		// Goal
		var all = [];
		if( diff<=0.5 )
			all.push(_PBadGoal);
		if( diff>=0.7 && rseed.random(100)<25 && !t.hasPerk(_PSmallCage) )
			all.push(_PSuperGoal);
		if( all.length>0 )
			t.addPerk( all.splice(rseed.random(all.length), 1)[0] );

		// Generic
		var all = [];
		if( diff<=0.3 )
			all.push(_PWeak);
		if( diff>=0.7 && rseed.random(100)<25 )
			all.push(_PSuperStrong);
		if( all.length>0 )
			t.addPerk( all.splice(rseed.random(all.length), 1)[0] );

		return t;
	}

	public static inline function getByLevel(lid, v:GameVariant) {
		var t = !ALL.exists(lid) ? new TeamInfos(1, lid) : ALL.get(lid);
		t.variant = v;
		return t;
	}

	public static function readXml() {
		ALL = new Map();
		var raw = haxe.Resource.getString("teams");
		var xml = new haxe.xml.Fast( Xml.parse(raw).firstChild() );
		var lid = 1;

		var errors = [];
		var failedLevels = [];
		var perkKeys = Type.getEnumConstructs(Perk);

		for( node in xml.nodes.t ) {
			var t = new TeamInfos(1);
			ALL.set(lid, t);
			try {
				t.lid = lid;
				t.name = StringTools.trim(node.att.name);
				t.hairFrame = Std.parseInt(node.att.hair);
				if( !node.has.colors ) {
					// Random colors
					var rseed = new mt.Rand(lid);
					var c = mt.deepnight.Color.randomColor(rseed.rand(), rseed.range(0.7,1), rseed.range(0.7,1));
					t.shirtColor = t.stripeColor = c;
					t.pantColor = mt.deepnight.Color.brightnessInt(c, -0.4);
				}
				else {
					// Fixed colors
					var colors = node.att.colors.split(",");
					var colors = colors.map( function(c) return Std.parseInt(c) );
					t.shirtColor = colors[0];
					t.pantColor = colors.length>=2 ? colors[1] : colors[0];
					t.stripeColor = colors.length>=3 ? colors[2] : colors[0];
				}
				t.scoreTarget = Std.parseInt(node.att.score);
				t.playerCount = Std.parseInt(node.att.players);
				t.skill = Std.parseFloat(node.att.skill);

				// Coord
				var pt = node.att.town.split(",");
				t.townX = Std.parseInt(pt[0]);
				t.townY = Std.parseInt(pt[1]);

				// Perks
				var raw = StringTools.replace(node.innerHTML, "\n", " ");
				raw = StringTools.replace(raw, "\r", " ");
				raw = StringTools.replace(raw, "\t", " ");
				raw = StringTools.replace(raw, ",", " ");
				raw = StringTools.replace(raw, ";", " ");
				raw = StringTools.replace(raw, "-", " ");
				if( StringTools.trim(raw).length>0 )
					for( k in raw.split(" ") ) {
						k = StringTools.trim(k);
						if( k.length==0 )
							continue;

						var found = false;
						for( realK in perkKeys )
							if( k.toLowerCase()==realK.substr(2).toLowerCase() ) {
								found = true;
								t.addPerk( Type.createEnum(Perk, realK) );
								break;
							}
						if( !found ) {
							var codes = [];
							failedLevels.push(lid);
							for(i in 0...k.length)
								codes.push(k.charCodeAt(i));
							errors.push(lid+":["+k+";"+k.length+";"+codes.join(",")+"]");
							var keys = perkKeys.map(function(realK) return realK.substr(2).toLowerCase() );
							errors.push("["+keys.join("/")+"]");
						}
					}
			} catch( e:Dynamic ) {
				trace("XML error for team "+lid+" ("+t.name+"): "+e);
			}
			lid++;
		}

		if( errors.length>0 ) {
			trace(errors.join(", "));
			var all = Type.getEnumConstructs(Perk).join("\n");
			trace(all);
			trace(failedLevels.join(","));
		}
	}

	public inline function getSkillLevel() : Float {
		return switch( variant ) {
			case Normal : skill;
			case Hard : 0.6 + 0.4*skill;
			case Epic : 1;
		}
	}

	public function isTutorial() {
		return hasPerk(_PTuto1) || hasPerk(_PTuto2) || hasPerk(_PTuto3);
	}

	public function getCupId() {
		return Std.int( (lid-1)/Const.MATCHES_BY_CUP );
	}

	public inline function isFinal() {
		return lid%Const.MATCHES_BY_CUP==0;
	}

	public static inline function isFinalStatic(lid) {
		return lid%Const.MATCHES_BY_CUP==0;
	}

	//public static function getPerkText(p:Perk) {
		//try {
			//var d = Lang.ALL.get(Std.string(p)).split("|");
			//return { name:d[0], desc:d[1] }
		//}
		//catch(e:Dynamic) {
			//return { name:"ERR:"+p, desc:"ERROR : missing text" }
		//}
	//}

	public function addPerk(p:Perk) {
		perkCache.set(Type.enumIndex(p), true);
		switch( p ) {
			case _PBadGoal : removePerk(_PSuperGoal); removePerk(_PAverageGoal);
			case _PAverageGoal : removePerk(_PSuperGoal); removePerk(_PBadGoal);
			case _PSuperGoal : removePerk(_PBadGoal); removePerk(_PAverageGoal);
			default :
		}
	}
	public inline function removePerk(p:Perk) {
		perkCache.remove(Type.enumIndex(p));
	}

	public function getPerks() {
		var a = [];
		for( id in perkCache.keys() )
			a.push(Type.createEnumIndex(Perk, id));
		return a;
	}

	public function hasPerkAmong(pa:Array<Perk>) {
		for(p in pa)
			if( hasPerk(p) )
				return true;
		return false;
	}

	public function hasPerk(p:Perk) {
		// Special forced perks
		if( side==1 ) {
			switch( variant ) {
				case Normal :

				case Hard :
					switch( p ) {
						case _PNoGoal : return false;
						case _PFast : return true;
						default :
					}

				case Epic :
					switch( p ) {
						case _PNoGoal : return false;
						case _PBadGoal : return false;
						case _PSuperFast : return true;
						case _PMediumRange : return true;
						default :
					}
			}
		}

		// Normal perks
		return perkCache.exists(Type.enumIndex(p));
	}
}
