package game.ai;
import Stat;
import game.Event;
import game.Dice;
import game.PlayerData;

/*
 * Attack a player (with violence).
 */
class AttackPlayer {

	static var WITH_HAMMER = {
		ATT_LIFE : -3,
		HIT_LIFE : 10,
		HIT_TICKS : 20,
		FAULT : 20,
		PAIN_RATE : 1000, // /10000 => 10%
		INJURE_RATE : 200, // /10000 => 2%
		KO_RATE : 2,
	};

	static var WITHOUT_HAMMER = {
		ATT_LIFE : -2,
		HIT_LIFE : 10,
		HIT_TICKS : 10,
		FAULT : 15,
		PAIN_RATE : 500, // /10000 => 5%
		INJURE_RATE : 100, // /10000 => 1%
		KO_RATE : 1,
	};

	public static function enter(p:PlayerData){
	}

	public static function update(p:PlayerData){
		var params = if (p.isAttacker()) WITH_HAMMER else WITHOUT_HAMMER;
		if (p.targetPlayer == null){
			p.changeState(IdleState);
			return;
		}
		var dist = p.distanceToPlayer(p.targetPlayer);
		if (dist <= PlayerData.FIGHT_DIST){
			p.stats.count(p.isAttacker() ? AttAttack : DefAttack);
			// SPECIAL DEFENSE
			var specialDefense = specialDefense(p);
			if (specialDefense != null){
				p.resolver.event(CompetenceActive2(p.targetPlayer, p, specialDefense));
				switch (specialDefense){
					case Competence.get.Pitify:
						PushPlayer.update(p);
						return;
					case Competence.get.AngelJump:
					case Competence.get.Slide:
						p.targetPlayer.changeState(game.ai.CompetenceSlide);
					case Competence.get.MoveAway:
						p.stuntTurns = PushPlayer.PUSHED_TICKS;
						p.updateLife(PushPlayer.PUSHED_LIFE);
						p.changeState(Stunt);
						p.moveAngle(p.targetPlayer.angle(p), p.targetPlayer.power);
						p.loseBall();
						p.resolver.event(CompetenceActive2(p.targetPlayer, p, Competence.get.MoveAway));
						if (p.resolver.fault == null){
							p.targetPlayer.stats.count(GenFault);
							var faultSeen = p.resolver.roll() < (Competence.get.MoveAway.pen) * p.targetPlayer.getHideFaultFactor();
							if (faultSeen){
								p.resolver.fault = { team:p.targetPlayer.team.id, player:p.targetPlayer.id };
								p.resolver.event(Fault(p.targetPlayer.team, p.targetPlayer));
							}
							else {
								p.targetPlayer.stats.success(GenFault);
							}
						}
						return;
				}
				p.updateLife(params.ATT_LIFE);
				p.stuntTurns = params.HIT_TICKS;
				p.changeState(Stunt);
				return;
			}
			// HAMMER/PUNCH ATTACK VALUE
			p.updateLife(params.ATT_LIFE);
			var attack = p.resolver.rollAndComment(p.skillAttack * p.getMoraleFactor() * (p.isAngry ? 2 : 1));
			if (attack.comment == Fumble){
				// TODO event il tombe en tentant d'attaquer un joueur
				p.delAggr(20);
				p.stuntTurns = params.HIT_TICKS;
				p.changeState(Stunt);
				return;
			}
			// SELECT SPECIAL ATTACK
			// NOTE: we might want to create a special attack to prevent the above Fumble or the esquive phase
			var specialAttack = specialAttack(p);
			// REGULAR ESQUIVE ATTEMPT
			if (attack.comment != Impale){
				p.delAggr(10);
				var esquive = p.resolver.rollAndComment(p.targetPlayer.skillEsquive * p.getMoraleFactor() * Dice.limitFactor(attack.comment));
				if (esquive.success){
					// TODO event esquive
					p.stuntTurns = params.HIT_TICKS;
					p.changeState(Stunt);
					return;
				}
			}
			// HAMMER/PUNCH WILL HIT OPONENT
			if (specialAttack == Competence.get.Sniper){
				p.resolver.event(CompetenceActive2(p, p.targetPlayer, Competence.get.Sniper));
				p.resolver.ball.alive = false;
				p.resolver.event(PicoPaf(p));
				return;
			}
			p.stats.success(p.isAttacker() ? AttAttack : DefAttack);
			// DAMAGE COMPUTATION
			var specialAttackEffect = specialAttackEffect(p);
			var damages = params.HIT_LIFE;
			// Impale bonus
			if (attack.comment == Impale){
				p.delAggr(20);
				damages *= 2;
			}
			if (specialAttack == Competence.get.BigBang){
				damages += 10;
				p.resolver.event(CompetenceActive2(p, p.targetPlayer, Competence.get.BigBang));
			}
			if (specialAttackEffect == Competence.get.ViciousHit){
				damages += 5;
				p.resolver.event(CompetenceActive2(p, p.targetPlayer, Competence.get.ViciousHit));
			}
			if (damages > 0 && p.targetPlayer.triggerCompetence(Competence.get.NaturalArmor)){
				damages = Std.int(Math.max(0, damages-2));
				p.resolver.event(CompetenceActive(p, Competence.get.NaturalArmor));
			}
			p.targetPlayer.addAggr(15);
			var lost = Std.int(Math.min(p.targetPlayer.life, damages));
			if (lost > 1 && p.targetPlayer.triggerCompetence(Competence.get.NoPain)){
				lost = 1;
				p.resolver.event(CompetenceActive(p.targetPlayer, Competence.get.NoPain));
			}
			if (p.targetPlayer.stuntTurns < 0)
				p.targetPlayer.stuntTurns = 0;
			var nbrHits = 1;
			var extraFault = 0;
			if (specialAttack == Competence.get.BangBang){
				extraFault += 10;
				nbrHits = 2;
				p.resolver.event(CompetenceActive2(p, p.targetPlayer, Competence.get.BangBang));
			}
			for (i in 0...nbrHits){
				p.targetPlayer.stuntTurns += params.HIT_TICKS;
				p.targetPlayer.changeState(Stunt);
				p.resolver.event(Hit(p, p.targetPlayer, lost, (p.resolver.ball.owner == p.targetPlayer)));
				if (lost >= 1){
					var koRate = params.KO_RATE;
					if (specialAttackEffect == Competence.get.StomachHit){
						var n = p.resolver.randomInt(p.targetPlayer.activeDrugs.length);
						var d = null;
						for (a in p.targetPlayer.activeDrugs){
							if (--n <= 0){
								d = a;
								break;
							}
						}
						if (d != null){
							p.targetPlayer.activeDrugs.remove(d);
							p.targetPlayer.computeSkills();
							p.resolver.event(CompetenceActive2(p, p.targetPlayer, Competence.get.StomachHit));
						}
					}
					if (specialAttackEffect == Competence.get.Vampire){
						p.updateLife(lost);
						p.resolver.event(CompetenceActive(p, Competence.get.Vampire));
					}
					var rand = p.resolver.randomInt(10000);
					if (rand < (params.INJURE_RATE) * p.targetPlayer.getInjureFactor()){
						p.targetPlayer.hurt(true);
					}
					else if (rand < (params.INJURE_RATE + params.PAIN_RATE + p.hurtBonus*100) * p.targetPlayer.getInjureFactor()){
						p.targetPlayer.hurt();
					}
					if (p.targetPlayer.hasVice(Vice.get.FRAGILE)){
						lost = Std.int(Math.round(lost * 2));
						// TODO: event
					}
					if (p.triggerCompetence(Competence.get.LargeHands)){
						koRate += 5;
						p.resolver.event(CompetenceActive2(p, p.targetPlayer, Competence.get.LargeHands));
					}
					if (specialAttack == Competence.get.Stunt){
						p.targetPlayer.stuntTurns = 300;
						p.targetPlayer.changeState(Stunt);
						koRate += 50;
						p.resolver.event(CompetenceActive2(p, p.targetPlayer, Competence.get.Stunt));
					}
					p.targetPlayer.updateLife(-lost);
					if (p.resolver.randomInt(100) < koRate){
						p.targetPlayer.knockOut(4);
					}
					else if (p.targetPlayer.life > 0 && !p.targetPlayer.isAngry && p.targetPlayer.triggerCompetence(Competence.get.Angry)){
						p.targetPlayer.isAngry = true;
						p.targetPlayer.addAggr(30);
						p.resolver.event(CompetenceActive(p.targetPlayer, Competence.get.Angry));
					}
				}
			}
			// FAULT DECISION
			var faultSeen = false;
			var defenserFault = 0;
			if (p.resolver.ball.owner == p.targetPlayer){
				p.targetPlayer.loseBall();
			}
			if (p.targetPlayer.life > 0 && p.targetPlayer.knockedOut == 0 && p.targetPlayer.triggerCompetence(Competence.get.Tumble)){
				extraFault += 30;
				p.targetPlayer.moveAngle(p.angle(p.targetPlayer), p.power*1.5);
				p.resolver.event(CompetenceActive(p.targetPlayer, Competence.get.Tumble));
			}
			else {
				p.targetPlayer.moveAngle(p.angle(p.targetPlayer), p.power);
			}
			if (p.resolver.fault == null){
				faultSeen = p.resolver.roll() < (params.FAULT + extraFault) * p.getHideFaultFactor();
				if (faultSeen){
					p.stats.count(GenFault);
					p.resolver.fault = { team:p.team.id, player:p.id };
					p.resolver.event(Fault(p.team, p));
					return;
				}
				else if (p.targetPlayer.life > 0 && p.targetPlayer.knockedOut == 0 && p.targetPlayer.triggerCompetence(Competence.get.Simulate)){
					defenserFault == 10;
					extraFault = 50;
					p.resolver.event(CompetenceActive(p.targetPlayer, Competence.get.Simulate));
					faultSeen = p.resolver.roll() < (extraFault) * p.getHideFaultFactor();
					if (faultSeen){
						p.resolver.fault = { team:p.team.id, player:p.id };
						p.resolver.event(Fault(p.team, p));
						return;
					}
					faultSeen = p.resolver.roll() < (defenserFault) * p.targetPlayer.getHideFaultFactor();
					if (faultSeen){
						p.resolver.fault = { team:p.targetPlayer.team.id, player:p.targetPlayer.id };
						p.resolver.event(Fault(p.targetPlayer.team, p.targetPlayer));
						return;
					}
				}
				else if (p.team.corruptBonus > 0 && p.resolver.randomInt(100) < 25){
					p.resolver.event(RefereeJocker(p));
				}
				p.stats.count(GenFault);
				p.stats.success(GenFault);
			}
			p.stuntTurns = params.HIT_TICKS;
			p.changeState(Stunt);
			// SOME THINGS CAN PREVENT
			if (!p.resolver.ball.alive){
				return;
			}
			if (!p.targetPlayer.canPlay()){
				return;
			}
			if (p.targetPlayer.hasVice(Vice.get.COWARD) && p.resolver.random() < 0.5){
				p.targetPlayer.triggerVice(Vice.get.COWARD);
				p.targetPlayer.targetPlayer = p;
				p.targetPlayer.changeState(game.ai.Coward);
			}
			else if (p.targetPlayer.hasVice(Vice.get.SPITEFUL) && p.resolver.random() < 0.1){
				p.targetPlayer.triggerVice(Vice.get.SPITEFUL);
				p.targetPlayer.targetPlayer = p;
				p.targetPlayer.changeState(game.ai.Spiteful);
			}
			return;
		}
		p.changeState(IdleState);
	}

	public static function specialDefense(attacker:PlayerData){
		var target = attacker.targetPlayer;
		if (target.isAttacker()){
			if (target.triggerCompetence(Competence.get.MoveAway))
				return Competence.get.MoveAway;
			return null;
		}
		if (target.triggerCompetence(Competence.get.Pitify) && attacker.power > target.power){
			return Competence.get.Pitify;
		}
		if (target.triggerCompetence(Competence.get.AngelJump)){
			target.competencesCooldown.set(Competence.get.AngelJump.dbid, 1);
			return Competence.get.AngelJump;
		}
		if (target.triggerCompetence(Competence.get.Slide)){
			return Competence.get.Slide;
		}
		return null;
	}

	public static function specialAttack(p:PlayerData){
		if (p.isAttacker()){
			if (p.targetPlayer.hasBall() && p.triggerCompetence(Competence.get.Sniper))
				return Competence.get.Sniper;
		}
		else {
			if (p.triggerCompetence(Competence.get.BangBang))
				return Competence.get.BangBang;
			if (p.triggerCompetence(Competence.get.BigBang))
				return Competence.get.BigBang;
			if (p.triggerCompetence(Competence.get.Fork))
				return Competence.get.Fork;
		}
		if (p.triggerCompetence(Competence.get.Stunt))
			return Competence.get.Stunt;
		if (p.triggerCompetence(Competence.get.Vampire))
			return Competence.get.Vampire;
		return null;
	}

	public static function specialAttackEffect(p:PlayerData){
		if (p.targetPlayer.activeDrugs.length > 0 && p.triggerCompetence(Competence.get.StomachHit))
			return Competence.get.StomachHit;
		if (p.triggerCompetence(Competence.get.ViciousHit))
			return Competence.get.ViciousHit;
		return null;
	}

	public static function leave(p:PlayerData){
	}

	public static function toString(p:PlayerData){
		return "Attack("+p.targetPlayer.pos+")";
	}
}