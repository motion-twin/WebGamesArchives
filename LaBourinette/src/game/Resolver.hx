#if js
JS MUST NOT CONTAIN THIS
#end

package game;

import GameParameters;
import game.GameState;
import game.InitialData;
import game.Event;
import game.Dice;
import game.Geom;
import game.Team;
import geom.Pt;
import Stat;

typedef TeamScores = Array<Int>;
typedef ScoreBoard = Array<TeamScores>;

class Resolver {
	// If you alter the results, you must increase the version number then call 'make maraversion'
	public static var VERSION = 12;

	public static var LIFE_PER_ATTEMPT = 0;
	public static var LIFE_PER_BATTLER = 0;
	public static var LIFE_PER_PHASE = 5;  // +5 each phase
	public static var LIFE_PER_ROUND = 5;  // +5 => 10 every new round (every two phase)
	public static var LIFE_HALF_TIME = 40; // +45 => 50 at half time
	static var THROW_LIFE_COST = -1;
	static var BATTLER_LIFE_COST = -4;
	public static var FORFAIT_POINTS = 5;
	// The optimum Z angle depends of different engine parameters,
	// it is pre-computed using neko index.n /admin/balance-ball
	static var OPTIMUM_Z_ANGLE = 0.594;
	public var beforeEvents : List<Event>;
	public var afterEvents : List<Event>;
	public var teamA : Team;
	public var teamB : Team;
	public var board : ScoreBoard;
	public var totalRounds(default,null) : Int;
	var seed : Int;
	var listeners : List<GameListener>;
	public var randomizer : mt.Rand;
	public var referee : IReferee;
	public var state : GameState;
	public var time : Int;
	var prevState : GameState;
	var stateTime : Int;
	public var round : Int;
	public var phase : Int;
	public var fault : { team:Int, player:Int };
	public var throwerMoved : Bool;
	public var playersHash : IntHash<PlayerData>;
	public var players : List<PlayerData>;
	public var field : Field;
	public var ball : Ball;
	public var ballDest: Point;
	public var attTeam : Team;
	public var defTeam : Team;
	public var winner : Team;
	public var thrower : PlayerData;
	public var battler : PlayerData;
	public var totalAttemptsCounter : Int;
	var attempt : Int;
	var strikes : Int;
	var throwFaults : Int;
	var batAttempt : DiceRoll;
	public var batNumber : Int;
	var throwDifficulty : Float;
	var throwPower : DiceRoll;
	var throwKind : ThrowKind;
	var specialThrow : Competence;
	var specialSwing : Competence;
	var ballPower : DiceRoll;
	var optimizationsRequired : Bool;
	public var prevAttemptDominators : Team;
	var tstart : Null<Int>;
	var tend : Null<Int>;
	var hooliganRound : Int;

	public function new(data:InitialData){
		if (data == null)
			throw "InitialData must not be null";
		this.board = new ScoreBoard();
		this.field = new Field(this);
		this.playersHash = new IntHash();
		this.players = new List();
		this.board[0] = [];
		this.board[1] = [];
		this.time = 0; // ticks
		this.totalAttemptsCounter = 0; // attempts
		this.totalRounds = data.totalRounds == null ? 5 : data.totalRounds;
		this.round = 0;
		this.phase = 0;
		this.attempt = 0;
		this.teamA = new Team(0, data.teamNameA, data.teamA, data.paramA, data.corruptA, data.hooligansA);
		this.attTeam = teamA;
		this.teamB = new Team(1, data.teamNameB, data.teamB, data.paramB, data.corruptB, data.hooligansB);
		this.defTeam = teamB;
		this.listeners = new List();
		this.ball = new Ball(this);
		this.ball.alive = false;
		this.prevState = null;
		this.state = INIT;
		this.seed = data.seed;
		this.randomizer = new mt.Rand(seed);
		this.referee = data.referee;
		this.optimizationsRequired = false;
		this.beforeEvents = new List();
		this.afterEvents = new List();
		this.hooliganRound = 0;
		#if neko
		var args = neko.Sys.args();
		if (args.length == 4){
			tstart = Std.parseInt(args[2]);
			tend = Std.parseInt(args[3]);
		}
		#elseif flash
		var fparams = flash.Lib.current.loaderInfo.parameters;
		if (Reflect.field(fparams, "tstart") != null){
			tstart = Std.parseInt(Reflect.field(fparams, "tstart"));
			tend = Std.parseInt(Reflect.field(fparams, "tend"));
		}
		#end
	}

	public function addEventListener( l:GameListener ){
		listeners.push(l);
	}

	public function event( evt:Event ){
		for (l in listeners)
			l.onEvent(evt);
		switch (evt){
			case Bobo(_,_):
				optimizationsRequired = true;
			case Injure(p,_):
				optimizationsRequired = true;
				p.team.updateSpirit(-1, 100);
			case Ko(p):
				optimizationsRequired = true;
				p.team.updateSpirit(-1, 100);
			case Recovered(pId):
				optimizationsRequired = true;
			case PlayerDisabled(pId):
				optimizationsRequired = true;
			case PhaseStart(_):
				// encouragement du public
				teamA.publicSpirit(roll());
				teamB.publicSpirit(roll());
			case NextAttempt(_,_,_,_):
			case RoundStart:
				teamA.updateSpirit(Reflect.compare(teamA.score,teamB.score)/5, Std.int(40+Math.abs(teamA.score-teamB.score)*10));
				teamB.updateSpirit(Reflect.compare(teamB.score,teamA.score)/5, Std.int(40+Math.abs(teamB.score-teamA.score)*10));
			case PicoStar:
				attTeam.updateSpirit(0.5, 100);
			case AttScore:
				attTeam.updateSpirit(0.1, 20);
				defTeam.updateSpirit(-0.1, 20);
			case ViceActive(pid, vid):
				if (state == INIT)
					beforeEvents.push(evt);
				else if (state == GAME_OVER)
					afterEvents.push(evt);
			case PicoPafAttempt(p):
				p.stats.count(AttPaf);
			case PicoPaf(p):
				p.stats.count(AttPaf);
				p.stats.success(AttPaf);
			case PicoSafe(p):
				p.stats.success(DefSave);
			default:
		}
	}

	function initialize(){
		if (!teamA.isParamReady())
			teamB.score = 1;
		if (!teamB.isParamReady())
			teamA.score = 1;
		teamA.initialize(this);
		teamB.initialize(this);
	}

	public function getDef( pos:DefPos ) : PlayerData {
		return defTeam.getDef(pos);
	}

	public function getAtt( pos:AttPos ) : PlayerData {
		return attTeam.getAtt(pos);
	}

	public function getBallPos() : Point {
		return (state == FLY) ? new Point(ball.middleCourse.x, ball.middleCourse.y) : ball.getPoint();
	}

	public function isOutField( p:Pt ){
		if (p.x * p.x + p.y * p.y >= 100*100)
			return true;
		if (isOutFieldAngle(p))
			return true;
		return false;
	}

	public function isOutFieldAngle( p:Pt ){
		var angle = Math.atan2(p.y, p.x);
		if (angle < -Math.PI/4 || angle > Math.PI/4)
			return true;
		return false;
	}

	public inline function debug() : Bool {
		return (tstart != null && tend != null && time >= tstart && time <= tend);
	}

	public function next() : Bool {
		time++;
		if (prevState != state){
			prevState = state;
			stateTime = 0;
		}
		else {
			stateTime++;
		}
		if (debug()){
			// trace("["+time+"] state="+state+" RandTime="+(untyped randomizer.times)+" RandSeed="+(untyped randomizer.seed));
			for (p in field.players){
				trace("#"+p.id+" "+p.name+" "+p.pos+" "+p.getState());
			}
		}
		switch (state){
			case INIT:
				event(DefStart);
				initialize();
				event(DefEnd);
				if (teamA.score + teamB.score > 0){
					board[teamA.id][0] = teamA.score;
					board[teamB.id][0] = teamB.score;
					// both teams where not ready
					if (teamA.score == teamB.score){
						event(GiveUp(teamA));
						event(GiveUp(teamB));
					}
					// team A was not ready
					else if (teamA.score == 0){
						event(GiveUp(teamA));
					}
					// team B is not ready
					else if (teamB.score == 0){
						event(GiveUp(teamB));
					}
					state = GAME_OVER;
				}
				else {
					state = NEW_ROUND;
					round = 0;
				}

			case HALF_TIME:
				event(HalfTime);
				state = NEW_PHASE;
				attTeam.updateLife(LIFE_HALF_TIME);
				defTeam.updateLife(LIFE_HALF_TIME);
				for (p in attTeam.players)
					if (p.canPlay())
						p.onHalfTime();
				for (p in defTeam.players)
					if (p.canPlay())
						p.onHalfTime();
				for (p in teamA.players) p.setPos(null);
				for (p in teamB.players) p.setPos(null);

			case NEW_ROUND:
				phase = 0;
				event(RoundStart);
				state = NEW_PHASE;
				board[0][round] = 0;
				board[1][round] = 0;
				attTeam.updateLife(LIFE_PER_ROUND);
				defTeam.updateLife(LIFE_PER_ROUND);

			case NEW_PHASE:
				var tmp = defTeam;
				defTeam = attTeam;
				attTeam = tmp;
				attTeam.setMode(ATTACK);
				defTeam.setMode(DEFENSE);
				event(PhaseStart(attTeam, round, phase));
				board[attTeam.id][round] = 0;
				batNumber = 0;
				thrower = defTeam.getDef(Thro);
				state = NEW_BATTER;
				attTeam.updateLife(LIFE_PER_PHASE);
				defTeam.updateLife(LIFE_PER_PHASE);

			case NEW_BATTER:
				optimizationsRequired = true;
				if (!optimizeTeams(true))
					return true;
				thrower = defTeam.getDef(Thro);
				ball.owner = thrower;
				battler = attTeam.getNextBattler(batNumber);
				if (battler != null)
					event(NextBattler(battler));
				attempt = 0;
				state = NEW_ATTEMPT;

			case NEW_ATTEMPT:
				if (!optimizeTeams())
					return true;
				thrower = defTeam.getDef(Thro);
				ball.owner = thrower;
				for (p in players)
					p.onNewAttempt();
				if (battler == null || !battler.canPlay()){
					event(BattlerCannotPlayAttempt(batNumber));
					attempt = 2;
					state = ATTEMPT_END;
					return true;
				}
				field.update(battler, thrower);
				resetPositions();
				event(NextAttempt(round,phase,batNumber,attempt));
				throwFaults = 0;
				strikes = 0;
				fault = null;
				for (p in players)
					p.drugTime();
				if (fault != null)
					state = FAULT;
				else {
					event(PreThrow);
					state = PRE_THROW;
				}

			case PRE_THROW:
				if (!optimizeTeams())
					return true;
				if (battler == null || !battler.canPlay()){
					event(BattlerCannotPlayAttempt(batNumber));
					attempt = 2;
					state = ATTEMPT_END;
					return true;
				}
				if (stateTime == 0){
					batAttempt = null;
					specialThrow = null;
					specialSwing = null;
					field.update(battler, thrower);
					resetPositions();
					ball.isFlying = false;
					ball.positionReset = true;
					ball.pass = null;
					ball.position.z = 0;
					ball.position.x = thrower.x;
					ball.position.y = thrower.y;
					for (p in field.players)
						p.onPreThrow();
					prevAttemptDominators = null;
				}
				if (thrower.updateAway()){
					if (stateTime >= 5){
						if (stateTime == 5)
							event(RefereeIsWaitingThrower(thrower));
						if (randomInt(100) < 20){
							fault = { team:defTeam.id, player:thrower.id };
							event(Fault(defTeam, thrower));
							state = FAULT;
						}
					}
					return true;
				}
				// 0. select throw kind
				throwKind = tools.EnumTools.random(ThrowKind, randomizer);
				// throwKind = CurveThrow;
				if (thrower.triggerCompetence(Competence.get.Thrower)){
					var compares = [
						(thrower.skillSpeedThrow - battler.skillSpeedReception),
						(thrower.skillPowerThrow - battler.skillPowerReception),
						(thrower.skillCurveThrow - battler.skillCurveReception),
					];
					var bestIndex = tools.ArrayTools.indexOfGreatest(compares, Reflect.compare);
					throwKind = tools.EnumTools.fromIndex(ThrowKind, bestIndex);
					event(CompetenceActive(thrower, Competence.get.Thrower));
				}
				// 1. select targeting difficulty
				// The thrower decide here to throw safely or more dangerously to add some difficulty
				// to the batter's job.
				var targetingDifficulty = switch (attempt){
					case 0: 10;
					case 1: 8;
					default: 6;
				};
				var x = 10 - thrower.accuracy;
				// TODO: use double cos(v*3.14) there
				var rand = -x + random() * 2 * x;
				throwDifficulty = (targetingDifficulty + rand);
				throwPower = switch (throwKind){
					case PowerThrow: rollAndComment(thrower.skillPowerThrow * thrower.getMoraleFactor());
					case SpeedThrow: rollAndComment(thrower.skillSpeedThrow * thrower.getMoraleFactor());
					case CurveThrow: rollAndComment(thrower.skillCurveThrow * thrower.getMoraleFactor());
				}

				var maxAngle = new geom.PVector3D(20,0).angleZ(game.Field.RECEPTION_ZONE[0]);
				var extraAngle = if (throwDifficulty > 10) 0.1 else 0.0;
				var angle = (extraAngle + (throwDifficulty / 20)) * (2*maxAngle);

				if ((throwDifficulty > 10 && angle <= maxAngle) ||
					(throwDifficulty <= 10 && angle > maxAngle))
					throw "WTF : TD="+throwDifficulty+" A="+angle+" MA="+maxAngle;

				if (randomInt(2) == 0)
					angle *= -1;

				var bonusCompetence = switch (throwKind){
					case PowerThrow: (thrower.hasCompetence(Competence.get.PowerThrow) ? Competence.get.PowerThrow : null);
					case SpeedThrow: (thrower.hasCompetence(Competence.get.SpeedThrow) ? Competence.get.SpeedThrow : null);
					case CurveThrow: (thrower.hasCompetence(Competence.get.CurveThrow) ? Competence.get.CurveThrow : null);
				}
				event(Throw(throwKind, bonusCompetence));
				thrower.updateLife(THROW_LIFE_COST);
				if (throwPower.comment == Fumble){
					throwDifficulty = -1;
					angle = 4 * maxAngle + maxAngle * random();
					if (randomInt(2) == 0)
						angle *= -1;
				}
				else if (thrower.triggerCompetence(Competence.get.PerfectThrow)){
					specialThrow = Competence.get.PerfectThrow;
					event(CompetenceActive(thrower, specialThrow));
					angle = (maxAngle - 0.001);
					if (randomInt(2) == 0)
						angle *= -1;
				}
				else if (thrower.triggerCompetence(Competence.get.StomachAim)){
					specialThrow = Competence.get.StomachAim;
					event(CompetenceActive(thrower, specialThrow));
					angle = ball.position.angleZ(battler.position);
				}
				else if (thrower.triggerCompetence(Competence.get.RotoThrow)){
					specialThrow = Competence.get.RotoThrow;
					event(CompetenceActive2(thrower, battler, specialThrow));
				}
				else if (attempt < 2 && thrower.triggerCompetence(Competence.get.WhirlThrow)){
					specialThrow = Competence.get.WhirlThrow;
				}
				// throw at regular direction (more or less)
				var target = new geom.PVector3D(-1,0);
				target.rotateZ(angle);
				target.mult(25);
				target.add(ball.position);
				ball.owner = null;
				ball.alive = true;
				ball.throwAt(target, 4+roll()*2, throwKind);
				state = THROW;
				fault = null;
				thrower.stats.count(ThrPrecision);

			case THROW:
				// la balle est lancée, elle fonce vers le batteur
				// Que peut-il se passer pendant cette phase ?
				ball.update();
				battler.updateAway(); // 1 tick for the batter
				if (ball.velocity.length() <= 0.04 && ball.position.x > game.Field.RECEPTION_ZONE[0].x){
					state = THROW_FAULT;
					return true;
				}
				var moveSeg = new geom.Vector2D(
					{x:ball.oldPosition.x, y:ball.oldPosition.y},
					{x:ball.position.x, y:ball.position.y}
				);
				var batSeg = new geom.Vector2D({x:0.0, y:-2.0}, {x:0.0, y:2.0});
				var batPoint = geom.Vector2D.perProduct(moveSeg, batSeg);
				var strikeSeg = new geom.Vector2D(
					game.Field.RECEPTION_ZONE[0],
					game.Field.RECEPTION_ZONE[1]
				);
				var strikePoint = geom.Vector2D.perProduct(moveSeg, strikeSeg);
				// we will compute the perPerproduct to battler position
				// and reset the ball there if reception is successfull
				// we can also let the ball fly here and check collision
				// with the wall ("dawal")
				if (batPoint != null && swing(batPoint)){
					return true;
				}
				var refereeDecide = false;
				if (strikePoint != null){
					// Soit la balle touche le dawal et s'empale (strike)
					if (strikePoint.y >= strikeSeg.start.y && strikePoint.y <= strikeSeg.end.y && moveSeg.rectangleContains(strikePoint)){
						if (throwDifficulty > 10)
							throw "BAD, there should not be a strike there";
						ball.stop();
						ball.alive = false;
						ball.position.x = strikePoint.x;
						ball.position.y = strikePoint.y;
						// l'arbitre ne triche pas sur ce cas, là, c'est trop visible
						state = STRIKE;
						thrower.stats.success(ThrPrecision);
						thrower.stats.success(ThrStrike);
					}
					else {
						refereeDecide = true;
					}
				}
				else if (ball.velocity.length() == 0){
					refereeDecide = true;
				}
				if (refereeDecide){
					// Normalement c'est
					// - Si le batteur a effectué sa tentative le point est pour la défenseur
					// - Sinon c'est une lancer faute
					// Mais la corruption entre en jeu et l'arbitre va devoir décider
					// - si le batteur a vraiment effectué sa tentative (normalement faute batteur)
					// - si la balle a vraiment été envoyée hors zone de strike (normalement faute lanceur)
					// Dans le deuxième test, la difficulté du lancer rentre en compte car il ne faut pas non
					// plus que ça soit trop visible :)
					if (batAttempt != null){
						battler.stats.count(GenFault);
						if (roll() < 100 * battler.getHideFaultFactor()){
							thrower.stats.success(ThrStrike);
							state = STRIKE;
						}
						else {
							state = FALSE_THROW_FAULT;
							battler.stats.success(GenFault);
						}
					}
					else {
						thrower.stats.count(GenFault);
						if (roll() < 100 * thrower.getHideFaultFactor()){
							state = THROW_FAULT;
						}
						else{
							thrower.stats.success(GenFault);
							state = FALSE_STRIKE;
						}
					}
				}

			case FAULT:
				if (fault == null)
					state = ATTEMPT_END;
				else if (fault.team == attTeam.id)
					state = ATT_FAULT;
				else
					state = DEF_FAULT;

			case DEF_FAULT:
				++throwFaults;
				event(DefFault(throwFaults));
				defTeam.onFault();
				state = SCORE;

			case ATT_FAULT:
				event(AttFault);
				attTeam.onFault();
				state = ATTEMPT_END;

			case THROW_FAULT,FALSE_THROW_FAULT:
				ball.update();
				event(state == THROW_FAULT ? ThrowFault : FalseThrowFault);
				state = DEF_FAULT;

			case STRIKE,FALSE_STRIKE:
				strikes++;
				event(state == STRIKE ? Strike : FalseStrike);
				state = ATTEMPT_END;

			case FLY:
				updateAi();
				ball.update();
				if (ball.position.length() < 100 && ball.isFlying)
					return true;
				// Suivant la force de la réception, cette phase peut durer
				// plus ou moins longtemps et la balle aussi peut être
				// soit faute (hors terrain), soit explosée contre piques
				// du fond (homerun) ce qui met fin à la phase
				//
				// La balle peut être rattrapée en vol, on passe alors
				// directement en phase MELEE.
				else if (isOutFieldAngle(ball.position)){
					event(BatFault);
					state = ATTEMPT_END;
					return true;
				}
				else if (ball.position.length() <= 10){
					event(TooShort);
					state = ATTEMPT_END;
					return true;
				}
				else if (ball.position.length() >= 100){
					battler.stats.success(BatField);
					battler.stats.count(BatStar);
					battler.stats.success(BatStar);
					event(PicoStar);
					state = SCORE;
					return true;
				}
				else {
					battler.stats.success(BatField);
					battler.stats.count(BatStar);
					event(Ground(ball.position.length()));
					state = GROUND;
				}

			case GROUND:
				updateAi();
				ball.update();
				if (fault != null)
					state = FAULT;
				else if (!ball.alive)
					state = SCORE;
				else if (ball.owner != null)
					state = MELEE;
				else if (isOutField(ball.getPoint())){
					event(PicoOut);
					state = DEF_FAULT;
				}

			case MELEE:
				updateAi();
				ball.update();
				if (fault != null)
					state = FAULT;
				else if (!ball.alive)
					state = SCORE;
				else if (isOutField(ball.getPoint())){
					event(PicoOut);
					state = DEF_FAULT;
				}
				else if (ball.position.length() < 30 && ball.owner != null){
					if (ball.owner.isRunningToBase())
						ball.owner.stats.success(DefSave);
					event(PicoSafe(ball.owner));
					event(AttFailed);
					state = ATTEMPT_END;
					prevAttemptDominators = defTeam;
				}
				else if (ball.owner == null){
					state = GROUND;
				}

			case SCORE:
				event(AttScore);
				board[attTeam.id][round]++;
				attTeam.score++;
				state = ATTEMPT_END;
				prevAttemptDominators = attTeam;

			case ATTEMPT_END:
				totalAttemptsCounter++;
				if (attempt+1 >= 3 && totalAttemptsCounter % 3 > 0){
					totalAttemptsCounter += 3 - (totalAttemptsCounter % 3);
				}
				event(AttemptEnd);
				ball.alive = false;
				updateKos();
				attempt++;
				state = NEW_ATTEMPT;
				if (attempt >= 3){
					batNumber++;
					state = NEW_BATTER;
					if (batNumber >= 3){
						phase++;
						state = NEW_PHASE;
						if (phase >= 2){
							round++;
							state = NEW_ROUND;
							if (round >= totalRounds){
								state = GAME_OVER;
							}
							for (p in teamA.players) p.onRoundEnd();
							for (p in teamB.players) p.onRoundEnd();
						}
						else if (round == Math.floor(totalRounds/2) && phase == 1){
							state = HALF_TIME;
						}
					}
				}

			case GAME_OVER:
				if (teamA.score == teamB.score){
					winner = null;
					event(Draw);
				}
				else if (teamA.score > teamB.score){
					winner = teamA;
					event(Winner(winner));
				}
				else {
					winner = teamB;
					event(Winner(winner));
				}
				teamA.gameOver(this);
				teamB.gameOver(this);
				state = HOOLIGANS;

			case HOOLIGANS:
				var hA = teamA.ihooligans[hooliganRound];
				var hB = teamB.ihooligans[hooliganRound];
				if (hA == null && hB != null){
					teamB.hooligansVictories.push(hB.id);
					event(HooliganAlone(teamB, hB));
				}
				else if (hB == null && hA != null){
					teamA.hooligansVictories.push(hA.id);
					event(HooliganAlone(teamA, hA));
				}
				else if (hA != null && hB != null){
					var scoreHooA = Dice.D6.roll(hA.level+1, randomizer);
					var scoreHooB = Dice.D6.roll(hB.level+1, randomizer);
					if (scoreHooA > scoreHooB){
						teamA.hooligansVictories.push(hA.id);
						event(HooliganFight(teamA, hA, scoreHooA, teamB, hB, scoreHooB));
					}
					else if (scoreHooB > scoreHooA){
						teamB.hooligansVictories.push(hB.id);
						event(HooliganFight(teamB, hB, scoreHooB, teamA, hA, scoreHooA));
					}
					else {
						event(HooliganDraw(hA, hB, scoreHooA));
					}
				}
				hooliganRound++;
				if (hooliganRound == 5)
					state = END;

			case END:
				return false;
		}

		return true;
	}

	public function stateToString():String {
		return switch(state){
			case INIT: return "INIT";
			case HALF_TIME: return "HALF_TIME";
			case NEW_ROUND: return "NEW_ROUND";
			case NEW_PHASE: return "NEW_PHASE";
			case NEW_BATTER: return "NEW_BATTER";
			case NEW_ATTEMPT: return "NEW_ATTEMPT";
			case PRE_THROW: return "PRE_THROW";
			case THROW: return "THROW";
			case THROW_FAULT: return "THROW_FAULT";
			case FALSE_THROW_FAULT: return "FALSE_THROW_FAULT";
			case FAULT: return "FAULT";
			case ATT_FAULT: return "ATT_FAULT";
			case DEF_FAULT: return "DEF_FAULT";
			case STRIKE: return "STRIKE";
			case FALSE_STRIKE: return "FALSE_STRIKE";
			case FLY: return "FLY";
			case GROUND: return "GROUND";
			case MELEE: return "MELEE";
			case SCORE: return "SCORE";
			case ATTEMPT_END: return "ATTEMPT_END";
			case GAME_OVER: return "GAME_OVER";
			case HOOLIGANS: return "HOOLIGANS";
			case END: return "END";
		};
	}

	function swing( batPoint:geom.PVector ){
		// La balle est-elle faute ?
		if (throwPower.comment == Fumble){
			return false;
		}
		// Le type secondaire de lancer est sélectionné ici
		var malus = 0;
		if (specialThrow == Competence.get.PerfectThrow){
			malus = Std.int(Math.max(5, throwDifficulty - 10));
			throwDifficulty = 10; // no fault
		}
		else if (specialThrow == Competence.get.StomachAim){
			malus = Std.int(Math.max(10, throwDifficulty - 10));
			throwDifficulty = 10; // no fault;
		}
		else if (specialThrow == Competence.get.RotoThrow){
		}
		else if (specialThrow == Competence.get.WhirlThrow){
		}
		var batSkill = 0;
		if (battler.triggerCompetence(Competence.get.AbsorbSwing)){
			specialSwing = Competence.get.AbsorbSwing;
			batSkill += 5 * 5;
		}
		else if (throwDifficulty <= 4 && battler.triggerCompetence(Competence.get.Empale)){
			specialSwing = Competence.get.Empale;
			batSkill -= 10 * 5;
		}
		else if (battler.triggerCompetence(Competence.get.BellSwing)){
			specialSwing = Competence.get.BellSwing;
		}
		else if (battler.triggerCompetence(Competence.get.SureSwing)){
			specialSwing = Competence.get.SureSwing;
		}
		else if (battler.triggerCompetence(Competence.get.PicoRun)){
			specialSwing = Competence.get.PicoRun;
		}
		else if (battler.triggerCompetence(Competence.get.WhirlSwing)){
			specialSwing = Competence.get.WhirlSwing;
		}
		// La balle est hors de la zone mais le batteur a des chances de ne pas s'en
		// appercevoir ce qui va lui donner des malus de battle
		if (throwDifficulty > 10){
			// TODO: repérer les faux lancer ne devrait-il pas être une caractéristique à part ?
			var rollDifficulty = (100 - (throwDifficulty - 10) * 10);
			if (battler.triggerCompetence(Competence.get.Lynx))
				rollDifficulty -= 50;
			if (specialSwing == Competence.get.WhirlSwing)
				rollDifficulty *= 2;
			if (!battler.isAway && roll() < rollDifficulty){
				malus = Std.int(Math.max(0, throwDifficulty - 10));
				event(BattlerTricked(battler, thrower, malus));
			}
			else {
				// pas tombé dans le piège, on laisse partir la balle en faute
				event(BattlerNotTricked(battler, thrower));
				return false;
			}
			if (malus > 0 && battler.triggerCompetence(Competence.get.FlexyArms)){
				event(CompetenceActive(battler, Competence.get.FlexyArms));
				malus = 0;
			}
		}
		battler.stats.count(BatTouch);
		if (battler.isAway){
			return false;
		}
		batSkill += switch (throwKind){
			case PowerThrow: battler.skillPowerReception;
			case SpeedThrow: battler.skillSpeedReception;
			case CurveThrow: battler.skillCurveReception;
		}
		batSkill -= malus * 5;
		batAttempt = rollAndComment(batSkill * battler.getMoraleFactor() * battler.getLifeFactor() * Dice.limitFactor(throwPower.comment));
		event(BatTry);
		if (!batAttempt.success){
			if (specialThrow == Competence.get.StomachAim){
				battler.updateLife(-Math.round(battler.life * 0.5));
				thrower.stats.count(GenFault);
				if (randomInt(100) < specialThrow.pen * thrower.getHideFaultFactor()){
					fault = { team:defTeam.id, player:thrower.id };
					event(Fault(defTeam, thrower));
					state = FAULT;
					return true;
				}
				thrower.stats.success(GenFault);
			}
			return false;
		}
		battler.stats.success(BatTouch);
		battler.stats.count(BatField);
		if (specialSwing == Competence.get.Empale){
			event(CompetenceActive(battler, specialSwing));
			ball.alive = false;
			ball.x = batPoint.x;
			ball.y = batPoint.y;
			state = SCORE;
			thrower.stats.success(ThrPrecision);
			thrower.stats.count(ThrStrike);
			battler.stats.success(BatField);
			battler.stats.count(BatStar);
			battler.stats.success(BatStar);
			return true;
		}
		ballPower = rollAndComment(battler.skillBatterPower * battler.getMoraleFactor());
		var batPower = switch (ballPower.comment){
			case Impale: 100 + randomInt(20);
			case Critical: 90 + randomInt(20);
			case GoodSuccess: 70 + randomInt(25);
			case NormalSuccess: 60 + randomInt(15);
			case MarginalFailure: 30 + randomInt(35);
			case SignificantFailure: 20 + randomInt(15);
			case Fumble: 5 + randomInt(20);
		}
		if (battler.triggerCompetence(Competence.get.StrongArm)){
			batPower = Math.round(batPower * 1.3);
		}
		if (specialThrow == Competence.get.RotoThrow){
			batPower = Math.round(batPower * 0.5);
		}
		else if (specialThrow == Competence.get.WhirlThrow){
			var item = battler.getHammer();
			if (item != null){
				item.life = Std.int(Math.max(0, item.life-1));
				if (item.life == 0)
					battler.computeSkills();
			}
			attempt = 3; // TODO: test this, it may break the viewer
			event(CompetenceActive2(thrower, battler, specialThrow));
		}
		var batPrecision = rollAndComment(battler.skillBatterPrecision * battler.getMoraleFactor() * Dice.successFactor(batAttempt.comment));
		if (specialSwing == Competence.get.BellSwing){
			batPrecision.comment = Impale;
			event(CompetenceActive(battler, specialSwing));
		}
		var batAngle = Math.PI/2 * switch (batPrecision.comment){
			case Impale: 2/16; // attacker angle
			case Critical: 2/16 + (1/16) * random(); // near attacker, towards fault
			case GoodSuccess: 1.9/16 * random(); // between attackers
			case NormalSuccess: 2.1/16 + 1.8/16 * random(); // between an attacker and the fault line
			case MarginalFailure: 4/16 + 0.5/16 - 1/16 * random(); // near the fault line
			case SignificantFailure: 4.5/16 + 3/16 * random();
			case Fumble: 6/16 + 2/16 * random();
		}
		if (batAngle > Math.PI/4 && specialSwing == Competence.get.SureSwing){
			batAngle = Math.PI/4;
			event(CompetenceActive(battler, specialSwing));
		}
		if (randomInt(2) == 0) batAngle = -batAngle;
		battler.updateLife(BATTLER_LIFE_COST);
		var optimumAngleZ = OPTIMUM_Z_ANGLE;
		var randomSide = randomInt(2);
		var airRatio = 0.0;
		if (randomSide == 0)
			airRatio = optimumAngleZ * (batPrecision.result/100);
		else
			airRatio = 1 - (1-optimumAngleZ)*(batPrecision.result/100);
		event(Battled);
		if (specialSwing == Competence.get.PicoRun){
			batPower = Std.int(Math.max(100, batPower));
			airRatio = optimumAngleZ;
			event(CompetenceActive(battler, specialSwing));
		}
		else if (specialSwing == Competence.get.WhirlSwing){
			batPower = Math.round(batPower * 1.5);
			event(CompetenceActive(battler, specialSwing));
			// TODO: +5% pour rattraper le picoron... not implemented yet,
			// there is no real air catch phase in the engine
		}
		ball.position.z = 0;
		if (batPoint != null){
			ball.x = batPoint.x;
			ball.y = batPoint.y;
		}
		ball.kick(batAngle, airRatio, batPower);
		ballDest = new Point(ball.middleCourse.x, ball.middleCourse.y);
		rollInitiatives();
		resetAi();
		state = FLY;
		thrower.stats.success(ThrPrecision);
		thrower.stats.count(ThrStrike);
		return true;
	}

	function optimizeTeams( canSubstituteBattler:Bool=false ) : Bool {
		if (!optimizationsRequired)
			return true;
		if (!attTeam.optimize(event, batNumber, canSubstituteBattler)){
			event(TooMuchKo(attTeam));
			defTeam.score += FORFAIT_POINTS;
			board[defTeam.id][round] += FORFAIT_POINTS;
			state = GAME_OVER;
		}
		if (!defTeam.optimize(event, batNumber, canSubstituteBattler)){
			event(TooMuchKo(defTeam));
			attTeam.score += FORFAIT_POINTS;
			board[attTeam.id][round] += FORFAIT_POINTS;
			state = GAME_OVER;
		}
		optimizationsRequired = false;
		return (state != GAME_OVER);
	}

	function updateKos() {
		var result = false;
		for (p in players){
			if (p.knockedOut > 0){
				untyped p.knockedOut--;
				if (p.knockedOut <= 0)
					event(Recovered(p));
			}
		}
	}

	function getPlayer( id:Int, team:List<PlayerData> ){
		for (p in team)
			if (p.id == id)
				return p;
		return null;
	}

	function resetPositions(){
		for (p in players){
			p.reset();
			if (p.pos != null)
				p.setPos(Field.posToPoint(p.pos));
		}
		throwerMoved = false;
		ball.owner = thrower;
		ball.positionReset = true;
		ball.x = Field.THRO_POS.x;
		ball.y = Field.THRO_POS.y;
		ball.z = 1;
		teamA.leader = null;
		teamB.leader = null;
	}

	var initiatives : Array<{ roll:DiceRoll, player:PlayerData, cmpA:Float, cmpB:Float, cmpC:Float }>;

	function rollInitiatives(){
		initiatives = [];
		for (p in field.players)
			initiatives.push({ roll:rollAndComment(p.skillInitiative * p.getMoraleFactor()), player:p, cmpA:0.0, cmpB:0.0, cmpC:0.0 });
		for (i in initiatives){
			i.cmpA = Type.enumIndex(i.roll.comment);
			i.cmpB = i.roll.result - i.roll.limit;
			i.cmpC = i.player.idx;
		}
		initiatives.sort(function(a,b){
			var cmp = Reflect.compare(a.cmpA, b.cmpA);
			if (cmp != 0)
				return cmp;
			var cmp = Reflect.compare(a.cmpB, b.cmpB);
			if (cmp != 0)
				return cmp;
			return Reflect.compare(a.cmpC, b.cmpC);
		});
	}

	function resetAi(){
		for (p in initiatives)
			p.player.currentState = null;
	}

	function updateAi(){
		field.updateDistances();
		for (p in initiatives){
			p.player.update();
			if (!ball.alive || state == ATTEMPT_END)
				return;
		}
	}

	// Random and Dice stuff

	public inline function roll() : Int {
		return Dice.D100.roll(1, randomizer);
	}

	public inline function rollAndComment( ?limit ) : DiceRoll {
		return Dice.D100.rollAndComment(limit, randomizer);
	}

	public inline function random() : Float {
		return randomizer.rand();
	}

	public inline function randomInt( n:Int ) : Int {
		return randomizer.random(n);
	}
}
