package game.ai;
import Stat;
import game.Dice;
import game.Event;
import game.PlayerData;

/*
 * Push a chosen oponent.
 */
class PushPlayer {
	public static var PUSH_LIFE = -1;
	public static var PUSHED_LIFE = -5;
	public static var PUSHED_TICKS = 5;

	public static var INJURE_HURT_ROLL = 10001;
	public static var INJURE_CHANCES = 1;
	public static var HURT_CHANCES = 10;

	public static function enter(p:PlayerData){
	}

	public static function update(p:PlayerData){
		if (p.distanceToPlayer(p.targetPlayer) < PlayerData.FIGHT_DIST){
			p.stats.count(p.isAttacker() ? AttPush : DefPush);
			p.updateLife(PUSH_LIFE);
			var attack = p.resolver.rollAndComment(p.skillPush * p.getMoraleFactor());
			if (attack.comment == Fumble){
				// TODO event il tombe en tentant de pousser un joueur
				p.stuntTurns = PUSHED_TICKS;
				p.updateLife(PUSHED_LIFE);
				p.changeState(Stunt);
				return;
			}
			if (attack.comment != Impale){
				p.delAggr(2);
				var pushBack = p.resolver.rollAndComment(p.targetPlayer.skillPush * p.targetPlayer.getMoraleFactor() * Dice.limitFactor(attack.comment));
				if (pushBack.success){
					// TODO event PushBack
					p.stuntTurns = PUSHED_TICKS;
					p.updateLife(PUSHED_LIFE);
					p.changeState(Stunt);
					p.moveAngle(p.targetPlayer.angle(p), p.targetPlayer.power);
					return;
				}
			}
			var pushPow = p.power;
			if (attack.comment == Impale){
				p.delAggr(3);
				pushPow *= 2;
			}
			p.targetPlayer.addAggr(2);
			p.targetPlayer.stuntTurns = PUSHED_TICKS;
			p.targetPlayer.updateLife(PUSHED_LIFE);
			p.targetPlayer.changeState(Stunt);
			p.targetPlayer.moveAngle(p.angle(p.targetPlayer), pushPow);
			p.stats.success(p.isAttacker() ? AttPush : DefPush);
			p.resolver.event(Push(p, p.targetPlayer, (p.resolver.ball.owner == p.targetPlayer)));
			var random = p.resolver.randomInt(INJURE_HURT_ROLL);
			if (random < INJURE_CHANCES * p.targetPlayer.getInjureFactor()){
				p.targetPlayer.hurt(true);
			}
			else if (random < (INJURE_CHANCES + HURT_CHANCES + p.hurtBonus*20) * p.targetPlayer.getInjureFactor()){
				p.targetPlayer.hurt();
			}
			p.targetPlayer.loseBall();
			if (p.resolver.fault == null){
				var faultSeen = p.resolver.randomInt(1000) < 5;
				if (faultSeen){
					p.resolver.fault = { team:p.team.id, player:p.id };
					p.resolver.event(Fault(p.team, p));
				}
			}
		}
		p.changeState(IdleState);
	}

	public static function leave(p:PlayerData){
	}

	public static function toString(p:PlayerData) : String {
		return "Push("+p.targetPlayer.pos+")";
	}
}