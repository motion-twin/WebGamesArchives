package data;
import handler.ClanManaWar;

typedef Reward = {
	@:optional var collections : List<Collection>;
	@:optional var objects : List<{o:Object, count:Int}>;
	@:optional var ingredients : List<{i:Ingredient, count:Int}>;
	@:optional var gold : Null<Int>;
}

typedef MHItem = {
	var id : Int;
	var icon : String;
	var name : String;
	var monsters : List<data.Monster>;
	var proba : Int;
	var points : Int;
	var unique : Bool;
	var places : Null<List<data.Map>>;
}

typedef MHConfig = {
	var items : Array<MHItem>;
	var allMonsters : List<data.Monster>;
	var rewards : List<{ points : Int, reward :Reward }>;	
	var rankingRewards:Null<Array<{range:{start:Int, end:Int}, reward:Reward}>>;
}

typedef WarConfig = {
	var defenderTotal : Int;
	var attackTime : Int;//used in castle.hx
	var enableHeroicActions : Bool;
	var rewards:Null<Array<{range:{start:Int, end:Int}, reward:Reward}>>;
	//
	var clanWar : {
		var defenderLevels : Int;
		var categoryBattleTimeCoef:Null<Array<Float>>;
		var clanCategories:Null<Array<Int>>;
		var categoryAttackLimit:Null<Array<Int>>;
		var enableMana : Bool;
		var cantAttackIfCastleDestroyed : Bool;
		var cumulativeReputLoss : Bool;
		var minimumDamagesToWinWar : Null<Int>;
		var minimumAttacksOrDamagesToWinWar : Int;
		var enableBuildings : Bool;
		var moreWarsPossibleWithReput : Bool;
		var defenderAutoLevels : Null<Float>;
		var defenderMax : Int;
	};
	
	var manaWar : {
		var enableSpells : Bool;
		var enableAlly : Bool;
		var repairerTotal : Int;
		var beginMana : Int;
		var beginReput : Int;
		var warPerDay : Int;
		
		var counterAttackManaCoef:Float;//useless
		var counterAttackStolenManaCoef:Float;
		var allyStolenManaCoef:Float;
		
		var canJoinDuringWar:Bool;
		var canJoinNoCastle:Bool;
		var canJoinDuringEvent:Bool;
		var cantJoinDaysBeforeEnd:Int;
		var cantJoinDaysAfterStart:Int;
		var maxClanChange : Int;
		var maxAllianceAsk : Int;
		var maxDayDurationAllianceAsk : Int;//days
		
		var warSubscribeCost : Int;
		var defaultCastleLife : Int;
		var stolenManaPercent : Float;
		var maxDefenderPerUser : Int;
		var castleAttackDamages : Int;
		var maxClanReputation : Int;
		var castleRepairCost : Int;
		var honorBonusAfterTax : Int;
		
		var fightXpFactor : Float;
		var minUsersToBuildCastle : Int;
		
		var warTime : Float;//ms
		var castleRepairDuration:Float;//ms
		var castleProtectionTime:Float;//ms
		var castleBuildProtectionTime:Float;//ms
		var minDurationBeforeFirstAttack:Float;//ms
		
		var defenderMinRecoveryTime : Float;//ms
		var attackerCooldown: Float;//ms
		var escapedCooldown : Float;//ms
		var defenderWaitAfterQuit:Float;//ms
		var defenderCumulativeAttacksAbility:Int;
		
		var castleManaGeneration:Int;
		var castleManaGenerationTime:Float;//ms
		
		var warManaGeneration:Float;// % 
		
		var honnorForWonToday:Int;
		var honnorForAttackedToday:Int;
		var honnorForRecentlyAttacked:Int;
		var honnorForCurrentlyAttacked:Int;
		
		var locations:Array<Map>;
	};
}

typedef BattleConfig = {
	var leagues : Array < { name : String, desc : String, places : Int,
							minLevel : Int, maxLevel : Int, points : Null<Int>,
							maxPools:Int, poolQualif:Int, poolBattles:Int,
							moveTime : Float, maxMoveCumul : Int,
							allowFightEnter : Bool, allowOddClans : Bool,
							joinCost : Int, minTeamSize:Int, maxTeamSize:Int, teamPowerBase:Int,
							minTeamPower : Null<Int>, maxTeamPower:Null<Int>,
							rewards:Null<Array<Reward>>,
							enterMoves:Int, startTimeDecal:Float
						}>;//cdc specifics
	var prepareTime : Float;//temps entre début de l'event en lui meme et le début des combats
	var battleTime : Float;
	var pauseTime : Float;
	var scoreTime : Float;
	var dinozPerUser : Int;
	var dinozPerClan : Int;
	var battleTimeout : Int;
	var width : Int;
	var height : Int;
}

typedef MonsterEventConfig = {
	var monsters : List<data.Monster>;
}

typedef FilmFestivalEventConfig = {
	var zones : Array<Bool>;
	var shops : List<Shop>;
	var monsters : List<Monster>;
	var finalistCount : Int;
	var finalistMinVotes : Int;
}

enum BattleMode {
	Old;
	New;
}

enum WarMode {
	Old;
	Mana;
}

enum Event {
	Nothing;
	XMas;
	MonsterHunter( cfg : MHConfig );
	ClanWar( cfg : WarConfig, mode : WarMode );
	ClanBattle( cfg : BattleConfig, mode : BattleMode );
	Anniversary;
	MonsterSpecial( cfg : MonsterEventConfig );
	Easter;
	FilmFestival(cfg : FilmFestivalEventConfig );
	Independence;
EMPTY;//XMasAvent;
	XMasGoblin;
	XStPatrick;
	GoldPromo( mult : Float );
}

class EventXML {

	public static function parseConfig( x : haxe.xml.Fast ) {
		return switch( x.name ) {
		case "xmas": XMas;
		case "xmasgoblin": XMasGoblin;
		case "xstpatrick": XStPatrick;
		case "anniversary" : Anniversary;
		case "independence" : Independence;
		case "mhunter": MonsterHunter( parseMHConfig(x) );
		case "war", "manawar": ClanWar( parseWarConfig(x), parseWarMode(x) );
		case "battle", "cdc": ClanBattle( parseBattleConfig(x), parseBattleMode(x) );
		case "mspecial" : MonsterSpecial( parseMonsterEventConfig(x) );
		case "easter" : Easter;
		case "filmfestival" : FilmFestival( parseFilmFestivalConfig(x) );
		case "goldpromo" : GoldPromo( x.has.mult ? Std.parseFloat( x.att.mult ) : 1.0 );
		default: throw "Unknown event '"+x.name+"'";
		};
	}

	static function parseBattleMode( x : haxe.xml.Fast ) : BattleMode {
		return switch( x.name ) {
			case "battle" : BattleMode.Old;
			case "cdc" : BattleMode.New;
			default : throw "Unknown battle mode " + x.name;
		}
	}
	
	static function parseWarMode( x : haxe.xml.Fast ) : WarMode {
		return switch( x.name ) {
			case "war" : WarMode.Old;
			case "manawar" : WarMode.Mana;
			default : throw "Unknown war mode " + x.name;
		}
	}
	
	static function parseFilmFestivalConfig( x : haxe.xml.Fast ) : FilmFestivalEventConfig {
		return {
			zones : Lambda.array(Lambda.map( x.node.zones.innerData.split(":"), function(s) return s=="1")) ,
			shops : Lambda.map( x.node.shops.innerData.split(":"), function(s) return Data.SHOPS.getId(Tools.makeId(s))),
			monsters : Lambda.map( x.node.monsters.innerData.split(":"), function(m) return Data.MONSTERS.getId( Tools.makeId(m) ) ),
			
			finalistCount : if( x.has.finalistCount ) Std.parseInt(x.att.finalistCount) else 20,
			finalistMinVotes : if( x.has.finalistMinVotes ) Std.parseInt(x.att.finalistMinVotes) else 50,
		}
	}
	
	static function parseMHConfig( x : haxe.xml.Fast ) : MHConfig {
		var items = new Array();
		var allMonsters = new List();
		for( i in x.nodes.i ) {
			var item = {
				id : items.length,
				icon : i.has.icon ? i.att.icon : null,
				name : i.att.name,
				monsters : Lambda.map(i.att.m.split(":"), Data.MONSTERS.getName),
				proba : Std.parseInt(i.att.proba),
				points : Std.parseInt(i.att.points),
				unique : i.has.unique,
				places : new List(),
			};
			
			if( i.has.zones )
				for( z in Tools.intArray(i.att.zones) )
					for( m in Data.MAP )
						if( m != null && m.zone == z )
							item.places.add( m );
			if( i.has.places )
				for( p in i.att.places.split(":") )
					item.places.add( Data.MAP.getName(p) );
			
			items.push(item);
			for( m in item.monsters )
				if(  !Lambda.has( allMonsters, m ) )
					allMonsters.add(m);
		}
		var rewards = new List<{points:Int, reward:Reward}>();
		if( x.hasNode.rewards ) {
			for( r in x.node.rewards.nodes.r ) {
				var points = Std.parseInt(r.att.points);
				var reward : Reward = cast { };
				if(  r.hasNode.object ) {
					reward.objects = new List();
					for ( node in r.nodes.object )
						reward.objects.add( { o: Data.OBJECTS.getName(node.att.name), count: node.has.count ? Std.parseInt(node.att.count) : 1 } );
				}
				if( r.hasNode.ingredient ) {
					reward.ingredients = new List();
					for ( node in r.nodes.ingredient )
						reward.ingredients.add( { i: Data.INGREDIENTS.getName(node.att.name), count: node.has.count ? Std.parseInt(node.att.count) : 1 } );
				}
				if( r.hasNode.collection ) {
					reward.collections = new List();
					for ( node in r.nodes.collection )
						reward.collections.add( Data.COLLECTION.getName(node.att.name) );
				}
				rewards.add( { points:points, reward:reward } );
			}
		}
		
		var rankingRewards = if ( x.hasNode.rankingRewards ) parseWarRewards(x.node.rankingRewards) else null;
		
		return {
			items : items,
			allMonsters : allMonsters,
			rewards : rewards,
			rankingRewards : rankingRewards,
		};
	}

	static function iopt(x : haxe.xml.Fast,?l,name,def) {
		if( l != null ) l.remove(name);
		return x.has.resolve(name) ? Std.parseInt(x.att.resolve(name)) : def;
	}
	
	static function timeopt(x : haxe.xml.Fast, ?l, name, def) {
		if( l != null ) l.remove(name);
		return x.has.resolve(name) ? data.Tools.parseTime(x.att.resolve(name)) : def;
	}
	
	static function iaopt(x : haxe.xml.Fast,?l,name,def) {
		if( l != null ) l.remove(name);
		return x.has.resolve(name) ? Lambda.array(Lambda.map( x.att.resolve(name).split(":"), function(c) return Std.parseInt(c))) : def;
	}

	static function fopt(x : haxe.xml.Fast,?l,name,def) {
		if( l != null ) l.remove(name);
		return x.has.resolve(name) ? Std.parseFloat(x.att.resolve(name)) : def;
	}

	static function faopt(x : haxe.xml.Fast,?l,name,def) {
		if( l != null ) l.remove(name);
		return x.has.resolve(name) ? Lambda.array(Lambda.map( x.att.resolve(name).split(":"), function(c) return Std.parseFloat(c))) : def;
	}
	
	static inline function b(x : haxe.xml.Fast,?l,name) {
		if( l != null ) l.remove(name);
		return x.has.resolve(name) ? x.att.resolve(name) == "1" : false;
	}
	
	static inline function bopt(x : haxe.xml.Fast,?l,name, def) {
		if( l != null ) l.remove(name);
		return x.has.resolve(name) ? x.att.resolve(name) == "1" : def;
	}
	
	static function baopt(x : haxe.xml.Fast,?l,name,def) {
		if( l != null ) l.remove(name);
		return x.has.resolve(name) ? Lambda.array(Lambda.map( x.att.resolve(name).split(":"), function(c) return c == "1")) : def;
	}

	static function parseMonsterEventConfig( x : haxe.xml.Fast ) : MonsterEventConfig {
		var cfg : MonsterEventConfig = {
			monsters: Lambda.map(x.att.monsters.split(":"), Data.MONSTERS.getName),
		};
		return cfg;
	}
	
	static function parseWarConfig( x : haxe.xml.Fast) : WarConfig {
		var cfg : WarConfig = null;
		var M = Data.MAP.list;
		try {
			var MW = ClanManaWar;
			var a = Lambda.list({ iterator : x.x.attributes });
			var b = callback(b, x, a);
			var iopt = callback(iopt, x, a);
			var fopt = callback(fopt, x, a);
			var iaopt = callback(iaopt, x, a);
			var timeopt = callback(timeopt, x, a);
			var faopt = callback(faopt, x, a);
			
			
			cfg  = {
				
				attackTime : iopt("attackTime",80),
				defenderTotal : iopt("defenderTotal", 15),
				enableHeroicActions : b("enableHeroicActions"),
				rewards : if( x.hasNode.rewards ) parseWarRewards(x.node.rewards) else null,
				
				clanWar : {
					defenderMax : iopt("defenderMax", 5),
					defenderLevels : iopt("defenderLevels",1000), // no limit
					defenderAutoLevels : fopt("defenderAutoLevels",null),
					moreWarsPossibleWithReput : b("moreWarsPossibleWithReput"),
					enableBuildings : b("enableBuildings"),
					minimumAttacksOrDamagesToWinWar : iopt("minimumAttacksOrDamagesToWinWar",0),
					minimumDamagesToWinWar : iopt("minimumDamagesToWinWar",null),
					cumulativeReputLoss : b("cumulativeReputLoss"),
					cantAttackIfCastleDestroyed : b("cantAttackIfCastleDestroyed"),
					enableMana : b("enableMana"),
					categoryBattleTimeCoef : faopt("categoryBattleTimeCoef", null),
					clanCategories : iaopt("clanCategories", null),
					categoryAttackLimit : iaopt("categoryAttackLimit", null),
				},
				
				manaWar : {
					enableSpells : b("enableSpells"),
					enableAlly : b("enableAlly"),
					repairerTotal : iopt("repairerTotal", 50),
					beginMana : iopt("beginMana", MW.WAR_BEGIN_MANA),
					beginReput : iopt("beginReput", MW.WAR_BEGIN_REPUT),
					warPerDay : iopt("warPerDay", MW.MAX_WAR_PER_DAY),
					
					counterAttackManaCoef : fopt("counterAttackManaCoef", 0.65),
					
					counterAttackStolenManaCoef : fopt("counterAttackStolenManaCoef", 0.5),
					allyStolenManaCoef : fopt("allyStolenManaCoef", 0.5),
					
					canJoinDuringWar : b("canJoinDuringWar"),
					canJoinDuringEvent : b("canJoinDuringEvent"),
					canJoinNoCastle : b("canJoinNoCastle"),
					cantJoinDaysBeforeEnd : iopt("cantJoinDaysBeforeEnd", 0),
					cantJoinDaysAfterStart : iopt("cantJoinDaysAfterStart", 10),
					
					maxClanChange : iopt("maxClanChange", 0),
					
					maxAllianceAsk :  iopt("maxAllianceAsk", MW.MAX_ALLIANCE_ASK),
					maxDayDurationAllianceAsk : iopt("maxDayDurationAllianceAsk", MW.MAX_DURATION_ALLIANCE_ASK),//ms
					
					warSubscribeCost : iopt("warSubscribeCost", MW.WAR_SUBSCRIBE_FEE),
					defaultCastleLife : iopt("defaultCastleLife", MW.CASTLE_DEFAULT_LIFE),
					stolenManaPercent : fopt("stolenManaPercent", MW.STOLEN_MANA_PERCENT),
					maxDefenderPerUser : iopt("maxDefenderPerUser", MW.MAX_DEFENDER_PER_USER),
					castleAttackDamages : iopt("castleAttackDamages", MW.CASTLE_ATTACK_DAMAGES),
					maxClanReputation : iopt("maxClanReputation", MW.MAX_CLAN_REPUTATION),
					castleRepairCost : iopt("castleRepairCost", MW.CASTLE_REPAIR_COST),
					honorBonusAfterTax : iopt("honorBonusAfterTax", MW.HONNOR_BONUS_AFTER_TAX),
					
					fightXpFactor : fopt("fightXpFactor", MW.FIGHT_XP_FACTOR),
					minUsersToBuildCastle : iopt("minUsersToBuildCastle", MW.WAR_MIN_USERS_TO_BUILD_CASTLE),
					
					warTime : timeopt("warTime", MW.WAR_TIME),//ms
					castleRepairDuration : timeopt("castleRepairDuration", MW.CASTLE_REPAIR_DURATION),//ms
					castleProtectionTime : timeopt("castleProtectionTime", MW.CASTLE_PROTECTION_TIME),//ms
					castleBuildProtectionTime : timeopt("castleBuildProtectionTime", 0),//ms
					minDurationBeforeFirstAttack : timeopt("minDurationBeforeFirstAttack", MW.MIN_DURATION_BEFORE_FIRST_ATTACK),//ms
					
					defenderMinRecoveryTime : timeopt("defenderMinRecoveryTime", MW.MINIMUM_DEFENDER_RECOVERY_TIME),//ms
					attackerCooldown : timeopt("attackerCooldown", MW.COOLDOWN_DURATION),//ms
					escapedCooldown : timeopt("escapedCooldown", MW.ESCAPED_COOLDOWN_DURATION),//ms
					defenderWaitAfterQuit : timeopt("defenderWaitAfterQuit", MW.DEFENDER_WAIT_AFTER_QUIT),//ms
					defenderCumulativeAttacksAbility : iopt("defenderCumulativeAttacksAbility", MW.DEFENDER_CUMULATIVE_ATTACKS_ABILITY),
					
					castleManaGeneration : iopt("castleManaGeneration", 10),
					castleManaGenerationTime : timeopt("castleManaGenerationTime", DateTools.hours(1)),//ms
					
					warManaGeneration : fopt("warManaGeneration", 0.1),// % 
					
					honnorForWonToday : iopt("honnorForWonToday", 25),
					honnorForAttackedToday : iopt("honnorForAttackedToday", 10),
					honnorForRecentlyAttacked : iopt("honnorForRecentlyAttacked", 10),
					honnorForCurrentlyAttacked : iopt("honnorForCurrentlyAttacked", 10),
					
					locations : if ( x.has.locations ) { a.remove("locations");  Lambda.array(Lambda.map(x.att.locations.split(":"), function(mname:String) return M.resolve(mname)));  }
								else [M.dnv, M.univ, M.fountj, M.papy, M.frcbrt, M.colesc, M.port, M.marche],
				}
			};
			
			if( !a.isEmpty() )
				throw "Unknown attribute '" + a.pop() + "'";
		} catch( e:Dynamic) {
			throw "Parse WarConfig Error : " + e + " / " + haxe.Stack.exceptionStack().join(',');
		}
		return cfg;
	}

	static function parseBattleConfig( x : haxe.xml.Fast) : BattleConfig {
		var ll = new Array();
		for ( l in x.nodes.league )
		{
			ll.push({
				name : l.att.name,
				desc : l.x.firstChild().nodeValue,
				places : if( l.has.places || !l.has.mult ) Std.parseInt(l.att.places) else Std.parseInt(l.att.mult),
				minLevel : if(  l.has.minlevel ) Std.parseInt(l.att.minlevel) else 1,
				maxLevel : if(  l.has.maxlevel ) Std.parseInt(l.att.maxlevel) else 50,
				points : if(  l.has.points ) Std.parseInt(l.att.points) else null,
				maxPools : if(  l.has.maxPools ) Std.parseInt( l.att.maxPools ) else Std.parseInt( x.att.maxPools ),
				poolQualif : if(  l.has.poolQualif ) Std.parseInt( l.att.poolQualif ) else Std.parseInt( x.att.poolQualif ),
				poolBattles : if(  l.has.poolBattles ) Std.parseInt( l.att.poolBattles ) else Std.parseInt( x.att.poolBattles ),
				moveTime : if(  l.has.moveTime ) Std.parseFloat( l.att.moveTime ) else Std.parseFloat( x.att.moveTime ),
				maxMoveCumul : if(  l.has.maxMoveCumul ) Std.parseInt( l.att.maxMoveCumul ) else if( x.has.maxMoveCumul) Std.parseInt( x.att.maxMoveCumul ) else 0,
				allowFightEnter : ( l.has.allowFightEnter ) ? l.att.allowFightEnter == "1" : (x.has.allowFightEnter)? x.att.allowFightEnter == "1"  : true,
				joinCost : (l.has.joinCost) ? Std.parseInt(l.att.joinCost) : 0,
				minTeamSize : (l.has.minTeamSize) ? Std.parseInt(l.att.minTeamSize) : 30,
				maxTeamSize : (l.has.maxTeamSize) ? Std.parseInt(l.att.maxTeamSize) : 300,
				maxTeamPower : (l.has.maxTeamPower) ? Std.parseInt(l.att.maxTeamPower) : null,
				minTeamPower : (l.has.minTeamPower) ? Std.parseInt(l.att.minTeamPower) : null,
				teamPowerBase : (l.has.teamPowerBase) ? Std.parseInt(l.att.teamPowerBase) : 200,
				allowOddClans : if( l.has.allowOddClans ) l.att.allowOddClans == "1" else false,
				startTimeDecal: if( l.has.startTimeDecal ) Std.parseFloat(l.att.startTimeDecal) else 0.0,
				
				rewards : if ( l.hasNode.rewards ) parseBattleRewards(l.node.rewards) else null,
				enterMoves : if( l.has.enterMoves ) Std.parseInt(l.att.enterMoves) else 0,
			});
		}
			
		if( ll.length == 0 )
			throw "Missing ligue";
		
		return {
			leagues : ll,
			prepareTime : fopt(x,"x.att.prepareTime",0),
			battleTime : Std.parseFloat(x.att.battleTime),
			pauseTime : Std.parseFloat(x.att.pauseTime),
			dinozPerUser : iopt(x,"dinozPerUser",3),
			dinozPerClan : iopt(x,"dinozPerClan",45),
			battleTimeout : iopt(x,"battleTimeout",null),
			width : iopt(x,"width",20),
			height : iopt(x,"height",20),
			scoreTime : if( x.has.scoreTime ) Std.parseFloat(x.att.scoreTime) else 1.0,
		};
	}
	
	static function parseBattleRewards( p_rewardsNode:haxe.xml.Fast ):Array<Reward>
	{
		var rewards = [];
		for( o in p_rewardsNode.nodes.reward )
		{
			if( !o.has.progress ) throw "Battle node reward doesn't have attribute progress "+p_rewardsNode;
			var progress = Std.parseInt( o.att.progress );
			if( rewards[progress] != null ) throw "Multiple rewards are set for the same progress ("+progress+")";
			var reward : Reward = parseRewardNode(o);
			rewards[progress] = reward;
		}
		return rewards;
	}
	
	static function parseWarRewards( p_rewardsNode:haxe.xml.Fast ):Array<{range:{start:Int, end:Int}, reward:Reward}>
	{
		var rewarded : Array<Bool> = [];
		var rewards = [];
		for( o in p_rewardsNode.nodes.reward )
		{
			if( !o.has.range ) throw "War node reward doesn't have attribute range "+p_rewardsNode;
			var range = Lambda.array(Lambda.map(o.att.range.split(":"), Std.parseInt ));
			if( range[0] > range[1] || range[0] < 1 || range[1] < 1 ) throw "War reward has invalid range value : " + o.att.range;
			for( i in range[0]...range[1]+1 ) {
				if( rewarded[i] ) throw "Le clan classé " + i + " reçoit déjà des récompenses - problème de range";
				rewarded[i] = true;
			}
			rewards.push( { range:{ start:range[0], end:range[1] }, reward: parseRewardNode(o) } );
		}
		return rewards;
	}
	
	static function parseRewardNode( o:haxe.xml.Fast ):Reward
	{
		var reward : Reward = { };
		
		if( o.hasNode.object ) {
			reward.objects = new List();
			for ( node in o.nodes.object )
				reward.objects.add( { o: Data.OBJECTS.getName(node.att.name), count: node.has.count ? Std.parseInt(node.att.count) : 1 } );
		}
		if( o.hasNode.ingredient ) {
			reward.ingredients = new List();
			for ( node in o.nodes.ingredient )
				reward.ingredients.add( { i: Data.INGREDIENTS.getName(node.att.name), count: node.has.count ? Std.parseInt(node.att.count) : 1 } );
		}
		if( o.hasNode.collection ) {
			reward.collections = new List();
			for ( node in o.nodes.collection )
				reward.collections.add( Data.COLLECTION.getName(node.att.name) );
		}
		if( o.hasNode.gold )
			reward.gold = if( o.node.gold.has.count ) Std.parseInt( o.node.gold.att.count ) else null;
	
		return reward;
	}

}
