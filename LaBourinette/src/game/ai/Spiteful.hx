// Rencunier, le joueur va poursuivre son adversaire pendant plusieurs rounds
// jusqu'à ce qu'il arrive à lui coller une beigne
package game.ai;

import game.PlayerData;

class Spiteful {

	public static function enter(p:PlayerData) : Void {
	}

	public static function update(p:PlayerData) : Void {
		if (p.stuntTurns > 0)
			p.stuntTurns--;
		if (p.stuntTurns > 0)
			return;
		if (p.life <= 0 || p.injure != null){
			p.changeState(game.ai.IdleState);
			return;
		}
		if (p.distanceToPlayer(p.targetPlayer) <= PlayerData.FIGHT_DIST){
			p.changeState(AttackPlayer);
		}
		else {
			p.seek(p.targetPlayer.position);
		}
	}

	public static function leave(p:PlayerData) : Void {
	}

	public static function toString(p:PlayerData) : String {
		return "Spiteful";
	}
}