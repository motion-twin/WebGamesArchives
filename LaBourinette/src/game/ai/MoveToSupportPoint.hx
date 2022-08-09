package game.ai;

import game.PlayerData;

/*
 * The player has to move to a specific location, its goal is to support the ball's owner.
 */
class MoveToSupportPoint {
	public static function enter(p:PlayerData){
		p.reservedSupport.reservation = p;
		p.supportValue = p.reservedSupport.score;
	}

	public static function update(p:PlayerData){
		var resolver = p.resolver;
		if (p.team.leader != p.targetPlayer || p.targetPlayer.stuntTurns > 0){
			p.changeState(IdleState);
			return;
		}
		var dist = p.position.distance(p.reservedSupport);
		if (dist <= PlayerData.FIGHT_DIST){
			p.changeState(IdleState);
			return;
		}
		p.seek(p.reservedSupport);
	}

	public static function leave(p:PlayerData){
		p.reservedSupport.reservation = null;
		p.reservedSupport = null;
	}

	public static function toString(p:PlayerData) : String {
		return "MoveToSup("+p.reservedSupport.name+" of "+p.targetPlayer.pos+" )";
	}
}

