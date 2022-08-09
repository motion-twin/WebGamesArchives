// Couard, le joueur s'enfui loin de la personne qui lui a collé une baffe et sort de
// cet état uniquement lorsqu'une distance minimum est atteinte
package game.ai;

import game.PlayerData;

class Coward {

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
		var dist = p.distanceToPlayer(p.targetPlayer);
		if (dist >= 50){
			p.changeState(game.ai.IdleState);
			return;
		}
		var vect = p.targetPlayer.position.clone().sub(p.position).negate();
		vect.add(p.position);
		p.seek(vect);
	}

	public static function leave(p:PlayerData) : Void {
	}

	public static function toString(p:PlayerData) : String {
		return "Coward";
	}
}