#if js
JS SHOULD NOT REACH THIS FILE
#end

using Lambda;
using StringTools;
using Std;

class GConfig {
	public static var MAX_LEAGUE_LEVEL = 10;

	public static var MAX_TEAM_SIZE = 7;
	public static var MIN_TEAM_SIZE = 5;
	public static var MIN_GAME_TEAM_SIZE = 5;
	public static var MAX_GAME_TEAM_SIZE = 6;
	public static var DAILY_ACTIONS = 24;
	public static var START_ACTIONS = 12;
	public static var HEAL_COST = 8;
	public static var SURGERY_COST = 16;

	public static var USER_CHANGE_FACE_COST = 2;
	public static var USER_CHANGE_LAIUS_COST = 1;
	public static var USER_CHANGE_WALL_COST = 2;
	public static var MAX_LAIUS_LENGTH = 500;
	public static var EXTRA_PLAYER_PAS = 1;

	public static var DEFY_COST = 4;
	public static var DEFY_REWARD = 400;

	public static var START_TIME = " 00:00:00";
	public static var SHOUT_COST = 10;
	public static var SHOUT_MAX = 140;

	#if neko
	public static var MARAVEUX_FULL_VER = 1;
	public static var MARAVEUX_BOUILLE_VER = 1;
	public static var MARAVEUX_BOUILLE_MAX = [64,64,64,64,64,64,64,64,64,64];
	public static var MANAGER_BOUILLE_VER     = 1;
	public static var MANAGER_BOUILLE_MAX     = [64,64,64,64,64,64,64,64,64,64];
	#end

	static var __init : Bool = {
		haxe.Serializer.USE_ENUM_INDEX = true;
		#if neko
		MARAVEUX_FULL_VER = Text.get.maraveux_full_ver.parseInt();
		MARAVEUX_BOUILLE_VER = Text.get.maraveux_bouille_ver.parseInt();
		MARAVEUX_BOUILLE_MAX  = Text.get.maraveux_bouille_max.trim().split(",").map(Std.parseInt).array();
		MANAGER_BOUILLE_VER = Text.get.manager_bouille_ver.parseInt();
		MANAGER_BOUILLE_MAX = Text.get.manager_bouille_max.trim().split(",").map(Std.parseInt).array();
		#end
		true;
	};

	#if neko

	public static function getDefyRisk(userA, userB) : { prize:Int, risk:Int }{
		if (userA.level == userB.level)
			return {
				prize:1,
				risk:Std.int(Math.min(userA.defyScore(), 1))
		   	};
		if (userA.level > userB.level)
			return {
				prize:1,
				risk:Std.int(Math.min(userA.defyScore(), Math.min(10, userA.level - userB.level)))
		   	};
		return {
			prize:Std.int(Math.min(userB.defyScore(), Math.min(10, userB.level - userA.level))),
			risk:Std.int(Math.min(userA.defyScore(), 1))
		};
	}

	public static function generateFace(?r:mt.Rand, version:Int, maxParams:Array<Int>){
		var n = [ version ];
		for (m in maxParams)
			n.push(r == null ? Std.random(m) : r.random(m));
		return encodeSkinArray(n);
	}

	public static function getComputerFace(t:db.Team){
		var version = MANAGER_BOUILLE_VER;
		var maxParams = MANAGER_BOUILLE_MAX;
		var n = [ version ];
		for (m in maxParams)
			n.push(1);
		return encodeSkinArray(n) + ":" + MANAGER_BOUILLE_VER;
	}

	public static function encodeSkinArray( n:Array<Int> ) : String {
		var chk = 0;
		for (i in n)
			chk += i;
		var chkk = (chk & 0xFF) ^ (n[n.length-1] & n[1] ^ (n[2] & n[0]));
		var bytes = new haxe.io.BytesBuffer();
		for (i in 0...n.length){
			n[i] = n[i] ^ chkk;
			bytes.addByte(n[i]);
		}
		bytes.addByte(chkk);
		var bytes = bytes.getBytes();
		return tools.Base64.encodeBytes(bytes);
	}

	public static function nextStartTime(?now:Date) : Date {
		var now = now == null ? Date.now().getTime() : now.getTime();
		var tomorrow = now + DateTools.days(1);
		var midnight = Date.fromString(Date.fromTime(tomorrow).toString().substr(0,10)+GConfig.START_TIME).getTime();
		if (midnight - now < DateTools.hours(8)){
			midnight = midnight + DateTools.days(1);
		}
		return Date.fromTime(midnight);
	}

	public static function leagueCompare( a, b ){
		var scoreC = -1 * Reflect.compare(a.pts, b.pts);
		if (scoreC != 0)
			return scoreC;
		var gaC = -1 * Reflect.compare(a.ptf - a.pta, b.ptf - b.pta);
		if (gaC != 0)
			return gaC;
		var ptfC = -1 * Reflect.compare(a.ptf, b.ptf);
		if (ptfC != 0)
			return ptfC;
		var ptaC = Reflect.compare(a.pta, b.pta);
		if (ptaC != 0)
			return ptaC;
		return -1 * Reflect.compare(a.teamId, b.teamId);
	}

	public static function getHooligansBonus( level ){
		return 20 + (level*10);
	}

	public static function getLeagueGameWinnerBonus( level ){
		return 100 * (level+1);
	}

	public static function getLeaguePrize( level ){
		return 700 + level * 100;
	}

	public static function getSingleLeaguePrize( l:{division:Int} ){
		return 700 + l.division * 100;
	}
	#end
}