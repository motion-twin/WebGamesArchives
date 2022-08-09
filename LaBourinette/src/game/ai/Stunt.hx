package game.ai;

import game.PlayerData;

/*
 * The player is stunted and has to wait a few turns before moving again.
 */
class Stunt {

	public static function enter(p:PlayerData){
	}

	public static function update(p:PlayerData){
		if (--p.stuntTurns <= 0){
			p.changeState(IdleState);
		}
		else {
			if (p.velocity.lengthSquared() > 0)
				p.velocity.div(2);
		}
	}

	public static function leave(p:PlayerData){
	}

	public static function toString(p:PlayerData) : String {
		return "Stunt("+p.stuntTurns+")";
	}
}