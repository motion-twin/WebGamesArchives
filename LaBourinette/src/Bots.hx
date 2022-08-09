import GameParameters;
import Competence;
import db.Game.GameKind;
using StringFormat;

typedef BotTeam = {
	id:Int,
	division:Int,
	team:db.Team,
	players:Array<BotPlayer>,
	addPlayer:BotPlayer->BotTeam
};

typedef BotPlayer = {
	id:Int,
	name:String,
	player:db.Player,
	attPos:AttPos,
	defPos:DefPos,
	items:Array<Item>,
	secondThrower:Bool,
};

class Bots {
	static var DIV2 = 2;
	static var DIV1 = 1;
	static var PID = 0;
	static var UID = 0;
	static var TEAMS = null;
	static function init(){
		PID = 0;
		UID = 0;
		TEAMS = [];
		var v = Vice.get;
		var c = Competence.get;
		// Help me to define things below
		var t = {
			Thrower:Competence.get.Thrower,
			CurveThrow:Competence.get.CurveThrow,
			PowerThrow:Competence.get.PowerThrow,
			SpeedThrow:Competence.get.SpeedThrow,
			StomachAim:Competence.get.StomachAim,
			RotoThrow:Competence.get.RotoThrow,
			WhirlThrow:Competence.get.WhirlThrow,
			PerfectThrow:Competence.get.PerfectThrow
		};
		var b = {
			Batter:Competence.get.Batter,
			Lynx:Competence.get.Lynx,
			Empale:Competence.get.Empale,
			FlexyArms:Competence.get.FlexyArms,
			PicoRun:Competence.get.PicoRun,
			WhirlSwing:Competence.get.WhirlThrow,
			AbsorbSwing:Competence.get.AbsorbSwing,
			BellSwing:Competence.get.BellSwing,
			StrongArm:Competence.get.StrongArm,
			SureSwing:Competence.get.SureSwing
		};
		var a = {
			Crusher:Competence.get.Crusher,
			Juggler:Competence.get.Juggler,
			MoveAway:Competence.get.MoveAway,
			Sniper:Competence.get.Sniper,
			HammerThrow:Competence.get.HammerThrow,
		};
		var d = {
			Passer:Competence.get.Passer,
			LargeHands:Competence.get.LargeHands,
			Pitify:Competence.get.Pitify,
			AngelJump:Competence.get.AngelJump,
			PicoTackle:Competence.get.PicoTackle,
			Slide:Competence.get.Slide,
			BangBang:Competence.get.BangBang,
			BigBang:Competence.get.BigBang,
			Fork:Competence.get.Fork,
			Reflex:Competence.get.Reflex,
			FootPlay:Competence.get.FootPlay,
		};

		// -------------------------------------------------------
		// First Division
		// -------------------------------------------------------
		botTeam(DIV1, "Destructeurs")
			.addPlayer(botPlayer(-1, ASub, Thro, [c.NoPain, c.Manager], [v.ALCOOLIC]))
			.addPlayer(botPlayer(-1, AttR, DefL, [c.Innocent], []))
			.addPlayer(botPlayer(-1, Bat1, DefM, [c.QuickPunch], [v.DEPRESSIVE]))
			.addPlayer(botPlayer(-1, Bat2, DefR, [c.Vitality], []))
			.addPlayer(botPlayer(-1, Bat3, DefF, [c.RefereeFriend], [v.SELFISH]))
			.addPlayer(botPlayer(-1, AttL, DSub, [c.Melody], [], true))
			;
		botTeam(DIV1, "Apitoyeurs")
			.addPlayer(botPlayer(-1, ASub, Thro, [t.PowerThrow], [v.DEPRESSIVE]))
			.addPlayer(botPlayer(-1, AttR, DefL, [], []))
			.addPlayer(botPlayer(-1, Bat1, DefM, [b.PicoRun], [v.FRAGILE]))
			.addPlayer(botPlayer(-1, Bat2, DefR, [], []))
			.addPlayer(botPlayer(0, Bat3, DefF, [b.BellSwing], []))
			.addPlayer(botPlayer(0, AttL, DSub, [], [], true))
			;
		botTeam(DIV1, "Ombres saignantes")
			.addPlayer(botPlayer(0, ASub, Thro, [t.RotoThrow], [v.ALCOOLIC]))
			.addPlayer(botPlayer(-1, AttR, DefL, [], []))
			.addPlayer(botPlayer(-1, Bat1, DefM, [], []))
			.addPlayer(botPlayer(0, Bat2, DefR, [], []))
			.addPlayer(botPlayer(0, Bat3, DefF, [b.AbsorbSwing], []))
			.addPlayer(botPlayer(0, AttL, DSub, [], [], true))
			;
		botTeam(DIV1, "Fous de Paul")
			.addPlayer(botPlayer(0, ASub, Thro, [t.CurveThrow,t.SpeedThrow], []))
			.addPlayer(botPlayer(-1, AttR, DefL, [], []))
			.addPlayer(botPlayer(0, Bat1, DefM, [b.Batter], []))
			.addPlayer(botPlayer(0, Bat2, DefR, [b.Batter], []))
			.addPlayer(botPlayer(0, Bat3, DefF, [b.Batter], []))
			.addPlayer(botPlayer(0, AttL, DSub, [], [], true))
			;
		botTeam(DIV1, "Mega-carreleurs")
			.addPlayer(botPlayer(0, ASub, Thro, [t.PowerThrow,t.SpeedThrow,t.Thrower], []))
			.addPlayer(botPlayer(0, AttR, DefL, [], []))
			.addPlayer(botPlayer(-1, Bat1, DefM, [b.Batter], []))
			.addPlayer(botPlayer(0, Bat2, DefR, [], []))
			.addPlayer(botPlayer(0, Bat3, DefF, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(0, AttL, DSub, [], [], true))
			;
		botTeam(DIV1, "Rage de luxe")
			.addPlayer(botPlayer(0, ASub, Thro, [t.CurveThrow,t.SpeedThrow,t.RotoThrow], []))
			.addPlayer(botPlayer(0, AttR, DefL, [], []))
			.addPlayer(botPlayer(0, Bat1, DefM, [b.Batter], []))
			.addPlayer(botPlayer(-1, Bat2, DefR, [], []))
			.addPlayer(botPlayer(0, Bat3, DefF, [b.AbsorbSwing], []))
			.addPlayer(botPlayer(0, AttL, DSub, [], [], true))
			;
		botTeam(DIV1, "Maillets dansants")
			.addPlayer(botPlayer(-1, ASub, Thro, [t.PowerThrow,t.Thrower,t.WhirlThrow], []))
			.addPlayer(botPlayer(0, AttR, DefL, [], []))
			.addPlayer(botPlayer(-1, Bat1, DefM, [b.Batter], []))
			.addPlayer(botPlayer(0, Bat2, DefR, [b.WhirlSwing], []))
			.addPlayer(botPlayer(0, Bat3, DefF, [b.PicoRun], []))
			.addPlayer(botPlayer(0, AttL, DSub, [], [], true))
			;
		// -------------------------------------------------------
		// Second division
		// -------------------------------------------------------
		botTeam(DIV2, "Diables roses")
			.addPlayer(botPlayer(0, ASub, Thro, [t.CurveThrow,t.PowerThrow,t.SpeedThrow,t.Thrower], []))
			.addPlayer(botPlayer(0, AttR, DefL, [], []))
			.addPlayer(botPlayer(0, Bat1, DefM, [b.Lynx], []))
			.addPlayer(botPlayer(0, Bat2, DefR, [b.BellSwing], []))
			.addPlayer(botPlayer(0, Bat3, DefF, [b.Empale], []))
			.addPlayer(botPlayer(0, AttL, DSub, [], [], true))
			;
		botTeam(DIV2, "Brutes agiles")
			.addPlayer(botPlayer(1, ASub, Thro, [t.CurveThrow,t.PowerThrow,t.SpeedThrow,t.Thrower], []))
			.addPlayer(botPlayer(1, AttR, DefL, [], []))
			.addPlayer(botPlayer(-1, Bat1, DefM, [b.Batter,b.Lynx], []))
			.addPlayer(botPlayer(1, Bat2, DefR, [b.Batter,b.Lynx], []))
			.addPlayer(botPlayer(1, Bat3, DefF, [b.Batter,b.Lynx], []))
			.addPlayer(botPlayer(-1, AttL, DSub, [], [], true))
			;
		botTeam(DIV2, "Fatal Bastos")
			.addPlayer(botPlayer(2, ASub, Thro, [t.CurveThrow,t.PowerThrow,t.SpeedThrow,t.Thrower], []))
			.addPlayer(botPlayer(2, AttR, DefL, [], []))
			.addPlayer(botPlayer(-1, Bat1, DefM, [b.Batter,b.Lynx], []))
			.addPlayer(botPlayer(2, Bat2, DefR, [b.Batter,b.Empale], []))
			.addPlayer(botPlayer(1, Bat3, DefF, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(-1, AttL, DSub, [], [], true))
			;
		botTeam(DIV2, "Picorons lovers")
			.addPlayer(botPlayer(1, ASub, Thro, [t.CurveThrow,t.PowerThrow,t.SpeedThrow,t.Thrower], []))
			.addPlayer(botPlayer(2, AttR, DefL, [], []))
			.addPlayer(botPlayer(1, Bat1, DefM, [b.Batter,b.AbsorbSwing], []))
			.addPlayer(botPlayer(1, Bat2, DefR, [b.Batter,b.BellSwing], []))
			.addPlayer(botPlayer(1, Bat3, DefF, [b.Batter,b.Lynx], []))
			.addPlayer(botPlayer(0, AttL, DSub, [], [], true))
			;
		botTeam(DIV2, "Amanites putrides")
			.addPlayer(botPlayer(2, ASub, Thro, [t.CurveThrow,t.PowerThrow,t.SpeedThrow,t.Thrower], []))
			.addPlayer(botPlayer(-1, AttR, DefL, [], []))
			.addPlayer(botPlayer(2, Bat1, DefM, [b.Batter,b.AbsorbSwing], []))
			.addPlayer(botPlayer(2, Bat2, DefR, [b.Batter,b.BellSwing], []))
			.addPlayer(botPlayer(1, Bat3, DefF, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(1, AttL, DSub, [], [], true))
			;
		botTeam(DIV2, "Destestables")
			.addPlayer(botPlayer(1, ASub, Thro, [t.CurveThrow,t.PowerThrow,t.SpeedThrow,t.Thrower,t.PerfectThrow,t.StomachAim], []))
			.addPlayer(botPlayer(2, AttR, DefL, [], []))
			.addPlayer(botPlayer(2, Bat1, DefM, [b.Batter,b.BellSwing], []))
			.addPlayer(botPlayer(2, Bat2, DefR, [b.Batter], []))
			.addPlayer(botPlayer(1, Bat3, DefF, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(1, AttL, DSub, [], [], true))
			;
		botTeam(DIV2, "Empoisonneurs")
			.addPlayer(botPlayer(2, ASub, Thro, [t.CurveThrow,t.PowerThrow,t.SpeedThrow,t.Thrower,t.PerfectThrow,t.RotoThrow], []))
			.addPlayer(botPlayer(1, AttR, DefL, [], []))
			.addPlayer(botPlayer(1, Bat1, DefM, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(1, Bat2, DefR, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(1, Bat3, DefF, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(1, AttL, DSub, [], [], true))
			;
		botTeam(DIV2, "Carnassiers")
			.addPlayer(botPlayer(2, ASub, Thro, [t.CurveThrow,t.PowerThrow,t.SpeedThrow,t.Thrower,t.PerfectThrow,t.WhirlThrow], []))
			.addPlayer(botPlayer(1, AttR, DefL, [], []))
			.addPlayer(botPlayer(0, Bat1, DefM, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(1, Bat2, DefR, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(1, Bat3, DefF, [b.Batter,b.PicoRun], []))
			.addPlayer(botPlayer(1, AttL, DSub, [], [], true))
			;
	}

	static function botTeam(division:Int, name:String){
		var t = new db.Team();
		t.id = TEAMS.length+1;
		t.name = name;
		var botTeam : BotTeam = { id:t.id, team:t, division:division, players:[], addPlayer:null };
		TEAMS[TEAMS.length] = botTeam;
		botTeam.addPlayer = callback(_addPlayer, botTeam);
		return botTeam;
	}

	static function _addPlayer(botTeam:BotTeam, botPlayer:BotPlayer) : BotTeam {
		botPlayer.player.teamId = botTeam.id;
		botTeam.players.push(botPlayer);
		return botTeam;
	}

	static function generateBot( seed:mt.Rand, level:Int=0, comps:Array<Competence>, vices:Array<Vice> ){
		var p = new db.Player(seed);
		p.id = ++PID;
		p.age = 0;
		p.maxAge = 14;
		var cRoll = game.Dice.D100.roll(1, seed);
		var nbrCompetences : Int = 2 + (level <= 0 ? level : Math.round((level * 0.8) + (cRoll/99 * level * 0.2)));
		var vices : Array<Vice> = if (vices == null || vices.length == 0)
			(level < 0 ? [] : Lambda.array(Vice.random(1+seed.random(Std.int(Math.min(5, 2+level))), seed)))
		else
			vices;
		p.vices = Lambda.map(vices, function(v) return v.skey).join(",") + ",";
		nbrCompetences += vices.length;
		nbrCompetences = Std.int(Math.min(nbrCompetences, 15));
		var maxValue = 6;
		var competences = tools.ArrayTools.randomize(Lambda.array(Competence.ALL), seed);
		for (c in comps)
			competences.remove(c);
		competences = comps.concat(competences);
		var found = 0;
		while (found < nbrCompetences && competences.length > 0){
			var c = competences.shift();
			if (p.power    + c.power     > maxValue
			|| p.agility   + c.agility   > maxValue
			|| p.endurance + c.endurance > maxValue
			|| p.accuracy  + c.accuracy  > maxValue
			|| p.charisma  + c.charisma  > maxValue)
				continue;
			p.power += c.power;
			p.agility += c.agility;
			p.endurance += c.endurance;
			p.charisma += c.charisma;
			p.accuracy += c.accuracy;
			p.addCompetence(c);
			found ++;
		}
		p.basePrice = 1000 + nbrCompetences * 250;
		return p;
	}

	static function botPlayer(lvl:Int, attPos:AttPos, defPos:DefPos, comps:Array<Competence>, ?vices:Array<Vice>, ?items:Array<Item>, ?secondThrower:Bool=false ){
		var seed = new mt.Rand(1235 * PID + 127);
		var p = generateBot(seed, lvl, comps, vices);
		p.label = Std.string(attPos)+"-"+Std.string(defPos);
		if (items == null)
			items = [];
		return { id:p.id, name:p.name, player:p, attPos:attPos, defPos:defPos, items:items, secondThrower:secondThrower };
	}

	public static function initializeDatabase(){
		init();
		for (team in TEAMS){
			if (db.Team.manager.count({id:team.id}) == 0)
				team.team.insert();
			else
				team.team.update();
			for (p in team.players){
				if (db.Player.manager.count({id:p.player.id}) == 0)
					p.player.insert();
				else
					p.player.update();
				db.Inventory.manager.delete({ teamId:team.id, playerId:p.player.id });
				for (item in p.items){
					var inv = new db.Inventory(item, team.team, p.player);
					inv.teamId = team.team.id;
					inv.playerId = p.player.id;
					inv.itemId = item.dbid;
					inv.life = item.maxLife;
					inv.insert();
				}
			}
			db.TeamConfig.manager.delete({ teamId:team.id });
			var params = new Parameters(new List(), cast team.players);
			var config = new db.TeamConfig();
			config.teamId = team.id;
			config.name = "Default";
			config.setParams(params);
			config.insert();
		}
		db.Referee.initializeDatabase();
	}

	public static function oposeBots(){
		Db.execute("DELETE FROM Game WHERE teamIdA < 30 AND teamIdB < 30");
		var teams = db.Team.manager.objects("SELECT * FROM Team WHERE id < 30", false);
		var done = new Hash();
		var matchTable = [];
		for (a in teams){
			for (b in teams){
				if (a == b)
					continue;
				if (done.exists(a.id+"-"+b.id) || done.exists(b.id+"-"+a.id))
					continue;
				done.set(a.id+"-"+b.id, true);
				matchTable.push({ a:a, b:b });
			}
		}
		Db.execute("COMMIT");
		for (m in matchTable){
			neko.Lib.println(m.a.name+" VS "+m.b.name);
			for (i in 0...30){
				var g = new db.Game();
				g.setKind(SINGLE_LEAGUE);
				g.teamA = m.a;
				g.teamB = m.b;
				g.insert();
				neko.Lib.print("db.Game #"+g.id+" --- ");
				g.resolve();
				g.update();
				neko.Lib.println(g.scoreA+" / "+g.scoreB);
				neko.db.Manager.cleanup();
			}
		}
		Db.execute("START TRANSACTION");
	}

	public static function botsStats(){
		var teamsList = Lambda.array(db.Team.manager.objects("SELECT * FROM Team WHERE id < 30", false));
		var table = new Array();
		for (t in teamsList)
			table.push(new Array<Float>());
		var done = new Hash();
		var idxA = -1;
		for (a in teamsList){
			++idxA;
			var idxB = -1;
			for (b in teamsList){
				idxB++;
				if (a == b){
					table[idxA][idxB] = null;
					table[idxB][idxA] = null;
					continue;
				}
				if (done.exists(a.id+"-"+b.id) || done.exists(b.id+"-"+a.id))
					continue;
				done.set(a.id+"-"+b.id, true);
				var games = db.Game.manager.objects("SELECT * FROM Game WHERE teamIdA In ({0},{1}) AND teamIdB IN ({0},{1})".format([a.id, b.id]), false);
				var stats = { aWins:0, bWins:0, draws:0 };
				for (g in games){
					var scoreA = g.teamIdA == a.id ? g.scoreA : g.scoreB;
					var scoreB = g.teamIdA == b.id ? g.scoreA : g.scoreB;
					if (scoreA > scoreB)
						stats.aWins++;
					else if (scoreA < scoreB)
						stats.bWins++;
					else
						stats.draws++;
				}
				var value = 0.0;
				if (stats.aWins - 10 > stats.bWins)
					value = 2;
				else if (stats.aWins - 3 > stats.bWins)
					value = 1;
				else if (stats.aWins > stats.bWins)
					value = 0.5;
				else if (stats.bWins - 10 > stats.aWins)
					value = -2;
				else if (stats.bWins - 3 > stats.aWins)
					value = -1;
				else if (stats.bWins > stats.aWins)
					value = -0.5;
				table[idxA][idxB] = value;
				table[idxB][idxA] = -value;
			}
		}

		neko.Lib.println("||"+Lambda.map(teamsList, function(t) return t.id).join("|")+"|");
		var i = 0;
		for (row in table){
			neko.Lib.print("|");
			neko.Lib.print(teamsList[i].id);
			neko.Lib.print("|");
			neko.Lib.print(row.join("|"));
			neko.Lib.println("|");
			++i;
		}
	}
}

