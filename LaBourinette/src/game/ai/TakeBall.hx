package game.ai;

import game.PlayerData;

/*
 * Ball is near, take it!
 */
class TakeBall {
	public static function enter(p:PlayerData){
		var dist = p.distanceToBall();
		if (dist <= PlayerData.FIGHT_DIST){
			var foes = p.foes();
			p.resolver.field.sortDistances(1, foes);
			if (foes.length > 0 && foes[0].distanceToBall() <= PlayerData.FIGHT_DIST * 1.25 && p.triggerCompetence(Competence.get.FootPlay)){
				var pass = p.findPass();
				if (pass != null){
					p.passToPlayer(pass.player, pass.dest);
					p.changeState(IdleState);
					return;
				}
			}
			var roll = p.resolver.rollAndComment(p.skillCatchBall * p.getMoraleFactor() * p.resolver.ball.catchOrKillDifficulty());
			if (roll.success){
				p.team.leader = p;
				p.resolver.ball.takenBy(p);
				if (p.distanceToOrigin() < 30){
					p.stuntTurns = 1;
					p.changeState(Stunt);
				}
				else
					p.changeState(RunToBase);
			}
			else {
				p.stuntTurns = 1;
				p.stop();
				p.changeState(Stunt);
			}
		}
		else {
			p.changeState(IdleState);
		}
	}
	public static function update(p:PlayerData){
	}
	public static function leave(p:PlayerData){
	}
	public static function toString(p:PlayerData){
		return "TakeBall";
	}
}
