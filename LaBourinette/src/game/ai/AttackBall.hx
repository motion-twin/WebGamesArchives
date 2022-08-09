package game.ai;

import Stat;
import game.Event;
import game.PlayerData;

/*
 * Ball is near, kill it!
 */
class AttackBall {
	static var ATTACK_LIFE = -3;

	public static function enter(p:PlayerData){
		var resolver = p.resolver;
		var ball = resolver.ball;
		if (ball.owner != null){
			p.targetPlayer = ball.owner;
			p.changeState(AttackPlayer);
			return;
		}
		if (!ball.alive){
			return;
		}
		var dist = p.distanceToBall();
		if (dist <= PlayerData.CATCH_DISTANCE){
			p.updateLife(ATTACK_LIFE);
			var roll = resolver.rollAndComment(p.skillKillBall * p.getMoraleFactor() * ball.catchOrKillDifficulty());
			interruptionPicoTackle(resolver, roll);
			if (roll.success){
				resolver.event(PicoPaf(p));
				resolver.ball.alive = false;
			}
			else {
				resolver.event(PicoPafAttempt(p));
				p.stuntTurns = 16;
				if (p.hasCompetence(Competence.get.Juggler)){
					//TODO: event ?
					p.stuntTurns = Math.round(p.stuntTurns / 2);
				}
				p.stop();
				p.changeState(Stunt);
			}
		}
		else if (resolver.ball.owner != null){
			p.changeState(ChaseBall);
		}
	}

	public static function update(p:PlayerData){
	}

	public static function leave(p:PlayerData){
	}

	public static function toString(p:PlayerData){
		return "AttackBall";
	}


	static function interruptionPicoTackle(resolver:game.Resolver, roll){
		if (resolver.ball.owner != null)
			return;
		for (p in resolver.defTeam.players){
			if (p.life > 0 && p.isOnField() && p.hasCompetence(Competence.get.PicoTackle) && p.distanceToBall() <= PlayerData.CATCH_DISTANCE*1.5 && resolver.roll() < 50){
				resolver.event(CompetenceActive(p, Competence.get.PicoTackle));
				p.position.set(resolver.ball.position);
				roll.success = false;
				return;
			}
		}
	}
}