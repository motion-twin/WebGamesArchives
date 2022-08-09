package game.ai;

import game.PlayerData;

/*
 * The player is exhausted on the field and cannot do much more until next attempt phase.
 */
class Exhausted {

	public static function enter(p:PlayerData) : Void {
	}

	public static function update(p:PlayerData) : Void {
		if (p.life > 10){
			p.changeState(IdleState);
			return;
		}
		if (p.team.leader == p)
			p.team.leader = null;
		if (p.resolver.time % 10 == 0)
			p.life++;
		if (p.velocity.lengthSquared() > 0)
			p.velocity.div(2);
	}

	public static function leave(p:PlayerData) : Void {
	}

	public static function toString(p:PlayerData) : String {
		return "Exhausted("+p.life+")";
	}
}