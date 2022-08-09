package data;
import data.Fight.FightStat;

typedef ChallengeInfo = {
	var id		: String;
	var inv		: Bool;
	var enemy 	: Bool;
	var percent : Bool;
	var poison 	: Bool;
	var dead 	: Bool;
	var assaults 	: Int;
	var lostLife	: Int;
	var attacks 	: Int;
	var counters 	: Int;
	var esquives	: Int;
	var groupAttacks: Int;
	var text	: String;
 }

typedef Challenge = {
	var id		: String;
	var enemy 	: Bool;
	var percent : Bool;
	var poison 	: Bool;
	var dead 	: Bool;
	var inv		: Bool;
	var assaults 	: Array<Int>;
	var lostLife	: Array<Int>;
	var attacks 	: Array<Int>;
	var counters 	: Array<Int>;
	var esquives	: Array<Int>;
	var groupAttacks: Array<Int>;
	var text	: String;
 }

 class ChallengeXML extends haxe.xml.Proxy<"challenges.xml",Challenge> {
	
	 public static function parse() {
		
		 return new data.Container<Challenge,ChallengeXML>(true, true).parse("challenges.xml", function(id,cid,c) {
			
			var challenge = {
				id 			: id,
				enemy 		: (c.has.enemy && c.att.enemy == "1") 		? true : false,
				percent 	: (c.has.percent && c.att.percent == "1") 	? true : false,
				poison 		: (c.has.poison && c.att.poison == "1") 	? true : false,
				dead 		: (c.has.dead && c.att.dead == "1") 		? true : false,
				inv			: (c.has.inv && c.att.inv == "1") 			? true : false,
				assaults 	: c.has.assaults ? Lambda.array(Lambda.map(c.att.assaults.split(":"), Std.parseInt)) 	: [0],
				lostLife	: c.has.lostLife ? Lambda.array(Lambda.map(c.att.lostLife.split(":"), Std.parseInt)) 	: [0],
				attacks 	: c.has.attacks  ? Lambda.array(Lambda.map(c.att.attacks.split(":"), Std.parseInt)) 	: [0],
				counters 	: c.has.counters ? Lambda.array(Lambda.map(c.att.counters.split(":"), Std.parseInt)) 	: [0],
				esquives 	: c.has.esquives ? Lambda.array(Lambda.map(c.att.esquives.split(":"), Std.parseInt)) 	: [0],
				groupAttacks: c.has.groupAttacks ? Lambda.array(Lambda.map(c.att.groupAttacks.split(":"), Std.parseInt)) : [0],
				text		: c.node.text.innerHTML,
			};
			for ( chk in c.nodes.check ) {
				var user = parseCheck(chk);
				var opp = randomStat();
				if(  challenge.enemy ) {
					var tmp = user; user = opp; opp = tmp;
				}
				if(  !check( chk.att.result == "1" ? true : false, challenge, user, opp ) ) {
					throw "Challenge : "+challenge.id+" do not pass a test : "+chk.att.result+" => "+user+" / "+opp;
				}
			}
			return challenge;
			
		});
	}
	
	static function parseCheck( n : haxe.xml.Fast ) {
		var s : FightStat = cast {
			user			: 0,
			attacks 		: n.has.attacks  ? Std.parseInt(n.att.attacks) 				: 0,
			groupAttacks 	: n.has.groupAttacks  ? Std.parseInt(n.att.groupAttacks) 	: 0,
			counters 		: n.has.counters  ? Std.parseInt(n.att.counters) 			: 0,
			assaults 		: n.has.assaults  ? Std.parseInt(n.att.assaults) 			: 0,
			lostLife 		: n.has.lostLife  ? Std.parseInt(n.att.lostLife)			: 0,
			startLife		: n.has.startLife  ? Std.parseInt(n.att.startLife) 			: 0,
			esquives 		: n.has.esquives  ? Std.parseInt(n.att.esquives) 			: 0,
			poison 			: (n.has.poison && n.att.poison	==  "1") ? 1: 0,
			dead 			: (n.has.dead   && n.att.dead   ==  "1") ? 1: 0,
		};
		return s;
	}
	
	static function randomStat() {
		var s : FightStat = cast {
			user			: 0,
			attacks 		: 0,
			groupAttacks 	: 0,
			counters 		: 0,
			assaults 		: 0,
			lostLife 		: 0,
			startLife		: 0,
			esquives 		: 0,
			poison 			: 0,
			dead 			: false,
		};
		return s;
	}
	
	public static function check( res, challenge, user, opp ) {
		//var c = handler.Dojo.generateChallenge(challenge);
		var l = handler.Dojo.generateChallenges(challenge);
		for( c in l )
			if(  res != handler.Dojo.isChallengeValided(user, opp, c) )
				return false;
		return true;
	}
}
