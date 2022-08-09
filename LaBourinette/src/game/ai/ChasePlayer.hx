package game.ai;

import game.PlayerData;

/*
 * Chase some chosen victim.
 */
class ChasePlayer {

	public static function enter(p:PlayerData){
	}

	public static function update(p:PlayerData){
		if (p.distanceToPlayer(p.targetPlayer) <= PlayerData.FIGHT_DIST)
			p.contactPlayer(p.targetPlayer, true);
		else
			p.seek(p.targetPlayer.position);
	}

	public static function leave(p:PlayerData){
	}

	public static function toString(p:PlayerData) :String {
		return "ChasePlayer("+p.targetPlayer.pos+")";
	}
}
