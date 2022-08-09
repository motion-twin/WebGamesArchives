#if js
JS MUST NOT CONTAIN THIS
#end

package game;
import game.InitialData;
import GameParameters;
import game.Dice.DiceRoll;
import Item.Organ;
import Item.Drug;

/*
  And here comes the event stuff.
 */

enum ThrowKind {
	SpeedThrow;
	PowerThrow;
	CurveThrow;
}

enum Event {
	DefStart;
	// DefParams(teamIdx:Int, p:Parameters);
	DefPlayer(team:game.Team, p:BasePlayer);
	DefEnd;
	GiveUp(team:game.Team);
	Draw;
	Winner(team:game.Team);
	RoundStart;
	HalfTime;
	PhaseStart(attTeam:game.Team, round:Int, phase:Int);
	NextBattler(player:PlayerData);
	NextAttempt(round:Int, phase:Int, nbrBat:Int, attempt:Int);
	AttemptEnd;
	PreThrow;
	Throw(kind:ThrowKind, bonusCompetence:Competence);
	BatTry;
	ThrowFault;
	FalseThrowFault;
	Strike;
	FalseStrike;
	Battled;
	TooShort;
	BatFault;
	PicoOut;
	PicoStar;
	AttScore;
	AttFailed;
	HasPicoron(player:PlayerData);
	PicoPafAttempt(player:PlayerData);
	PicoPaf(player:PlayerData);
	PicoSafe(player:PlayerData);
	Ground(dist:Float);
	Hit(att:PlayerData, def:PlayerData, life:Int, lostBall:Bool);
	Bobo(p:PlayerData, o:Organ);
	Injure(p:PlayerData, o:Organ);
	Ko(p:PlayerData);
	Recovered(p:PlayerData);
	ItemDamaged(p:PlayerData);
	ItemDestroyed(p:PlayerData);
	PlayerDisabled(p:PlayerData); // like ko but just for some time
	Replace(out:PlayerData, sub:PlayerData, p:Pos); // may be nobody there and we can now put someone at this pos
	Push(att:PlayerData, def:PlayerData, lostBall:Bool);
	DebugPos(p:IPoint);
	Fault(team:game.Team, player:PlayerData);
	AttFault;
	DefFault(faults:Int);
	TooMuchKo(team:game.Team);
	BattlerCannotPlayAttempt(batNbr:Int);
	ViceActive(player:PlayerData, vice:Vice);
	CompetenceActive(player:PlayerData, competence:Competence);
	CompetenceActive2(player:PlayerData, oponent:PlayerData, competence:Competence);
	RefereeJocker(player:PlayerData);
	BattlerTricked(player:PlayerData, thrower:PlayerData, malus:Int);
	BattlerNotTricked(player:PlayerData, thrower:PlayerData);
	RefereeIsWaitingThrower(player:PlayerData);
	UseDrug(player:PlayerData, drug:Drug);
	DrugFault(seen:Bool, player:PlayerData, drug:Drug);
	HooliganAlone(team:game.Team, h:IHooligan);
	HooliganFight(winnerTeam:game.Team, wh:IHooligan, ws:Int, loserTeam:game.Team, lh:IHooligan, ls:Int);
	HooliganDraw(ha:IHooligan, hb:IHooligan, s:Int);
}

interface GameListener {
	function onEvent( evt:Event ) : Void;
}
