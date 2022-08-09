import game.Resolver;
import db.Game;
using StringFormat;

// 3pts per victory
// 1pts per draw
typedef SingleLeagueGame = {
	teamIdA:Int,
	teamIdB:Int,
	scoreA:Int,
	scoreB:Int,
	board:ScoreBoard
};

typedef SingleLeagueTeam = {
	teamId:Int,
	won:Int,
	lost:Int,
	draw:Int,
	ptf:Int,
	pta:Int,
	pts:Int,
	pos:Int,
	ppos:Int
};

typedef SingleLeague = {
	var division : Int;
	var gameOver : Bool;
	var round : Int; // X/14
	var roundDone : Bool;
	var pgames : Array<Array<SingleLeagueGame>>;
	var games : Array<Array<SingleLeagueGame>>;
	var table : Array<Array<SingleLeagueTeam>>;
	var actions : Int;
	var marketSeeds : Array<Int>;
};

class SingleLeagueManager {
	public static var PROMOTED_TEAMS = 3;
	public static var MATCH_TABLE = [
		[ [0,1], [2,3], [4,5], [6,7] ],
		[ [0,2], [1,3], [4,6], [5,7] ],
		[ [0,3], [1,2], [4,7], [5,6] ],
		[ [0,4], [1,5], [2,6], [3,7] ],
		[ [0,5], [1,4], [2,7], [3,6] ],
		[ [0,6], [1,7], [2,5], [3,4] ],
		[ [0,7], [1,6], [2,4], [3,5] ]
	];

	public static function create( t:db.Team ) : SingleLeague {
		var result = {
			gameOver : false,
			division : 0,
			round : 0,
			roundDone : false,
			table : [ [], [] ],
			games : null,
			pgames : null,
			actions : 2,
			marketSeeds : null,
		};
		result.table[0].push({ teamId:t.id, won:0, lost:0, draw:0, ptf:0, pta:0, pts:0, pos:0, ppos:0 });
		for (i in 0...7)
			result.table[0].push({ teamId:(i+1), won:0, lost:0, draw:0, ptf:0, pta:0, pts:0, pos:0, ppos:0 });
		for (i in 0...8)
			result.table[1].push({ teamId:(i+8), won:0, lost:0, draw:0, ptf:0, pta:0, pts:0, pos:0, ppos:0 });
		initMatches(result, t);
		return result;
	}

	public static function endRound( d:SingleLeague, t:db.Team, teamResult:db.Game ){
		if (d.roundDone)
			throw "EndRound() called twice";
		d.roundDone = true;
		var divId = 0;
		var gameWinner = function(winner:SingleLeagueTeam, winnerScore, loser:SingleLeagueTeam, loserScore){
			winner.won++; winner.pts += 3; winner.ptf += (winnerScore - loserScore);
			loser.lost++; loser.pta += (winnerScore - loserScore);
		}
		var gameDraw = function(t1:SingleLeagueTeam, t2:SingleLeagueTeam){
			t1.draw++; t1.pts += 1;
			t2.draw++; t2.pts += 1;
		}
		for (division in d.games){
			for (g in division){
				if (g.teamIdA == t.id || g.teamIdB == t.id){
					g.scoreA = (g.teamIdA == teamResult.teamIdA) ? teamResult.scoreA : teamResult.scoreB;
					g.scoreB = (g.teamIdB == teamResult.teamIdB) ? teamResult.scoreB : teamResult.scoreA;
				}
				else {
					var randomGame = db.Game.manager.object("SELECT * FROM Game WHERE teamIdA IN ({0},{1}) AND teamIdB IN ({0},{1}) ORDER BY RAND() LIMIT 1".format([g.teamIdA, g.teamIdB]), false);
					if (randomGame == null)
						throw "No match precomputed for bots !\nYou must run 'neko index.n /admin/oposeBots' to create many possible games.";
					g.scoreA = (g.teamIdA == randomGame.teamIdA ? randomGame.scoreA : randomGame.scoreB);
					g.scoreB = (g.teamIdA == randomGame.teamIdA ? randomGame.scoreB : randomGame.scoreA);
					if (divId == 0){
						var a = g.scoreA;
						var b = g.scoreB;
						g.scoreA = Math.round(g.scoreA * 3/5);
						g.scoreB = Math.round(g.scoreB * 3/5);
						if (a != b && g.scoreA == g.scoreB){
							if (a > b) g.scoreA++ else g.scoreB++;
						}
					}
				}
				var t1 = Lambda.filter(d.table[divId], function(t) return t.teamId == g.teamIdA).first();
				var t2 = Lambda.filter(d.table[divId], function(t) return t.teamId == g.teamIdB).first();
				if (g.scoreA > g.scoreB)
					gameWinner(t1, g.scoreA, t2, g.scoreB);
				else if (g.scoreA < g.scoreB)
					gameWinner(t2, g.scoreB, t1, g.scoreA);
				else
					gameDraw(t1, t2);
			}
			divId++;
		}
		var ranking = getRanking(d, d.division);
		var pos = 0;
		for (t in ranking){
			t.ppos = t.pos;
			t.pos = ++pos;
		}
		d.pgames = d.games;
		d.games = [];
		d.marketSeeds = null;
	}

	public static function getRanking( d:SingleLeague, division:Int ){
		var result = d.table[division].copy();
		result.sort(GConfig.leagueCompare);
		return result;
	}

	public static function nextRound( d:SingleLeague, t:db.Team ){
		if (d.gameOver){
			return;
		}
		d.games = [];
		if (d.round == 6){
			// END OF DIVISION
			var ranking = getRanking(d, d.division);
			switch (d.division){
				case 1:
					d.gameOver = true;
					d.games = [];

				case 0:
					var div1Ranking = getRanking(d, 1);
					var promoted = ranking.splice(0,PROMOTED_TEAMS);
					var demoted = div1Ranking.splice(-PROMOTED_TEAMS,PROMOTED_TEAMS);
					for (p in promoted){
						d.table[1].push(p);
						d.table[0].remove(p);
					}
					for (p in demoted){
						d.table[0].push(p);
						d.table[1].remove(p);
					}
					if (Lambda.exists(promoted, function(p) return p.teamId == t.id)){
						d.pgames = [];
						d.division++;
						d.round = 0;
						for (div in d.table)
							for (team in div){
								team.won = 0;
								team.lost = 0;
								team.draw = 0;
								team.ptf = 0;
								team.pta = 0;
								team.pts = 0;
								team.ppos = 0;
								team.pos = 0;
							}
						initMatches(d, t);
					}
					else {
						d.gameOver = true;
						d.games = [];
					}
			}
		}
		else {
			d.round++;
			initMatches(d, t);
		}
	}

	static function initMatches( d:SingleLeague, t:db.Team ){
		d.roundDone = false;
		d.games = [ [], [] ];
		for (division in 0...2){
			if (MATCH_TABLE[d.round] == null)
				throw "No match table for round "+d.round;
			for (m in MATCH_TABLE[d.round]){
				var match = {
					teamIdA:d.table[division][m[0]].teamId,
					teamIdB:d.table[division][m[1]].teamId,
					scoreA:null,
					scoreB:null,
					board:null
			    };
				d.games[division].push(match);
				if (match.teamIdA == t.id || match.teamIdB == t.id){
					var g = new db.Game();
					g.kind = GameKind.SINGLE_LEAGUE;
					g.teamIdA = match.teamIdA;
					g.teamIdB = match.teamIdB;
					g.referee = db.Referee.random();
					g.insert();
				}
			}
		}
	}
}
