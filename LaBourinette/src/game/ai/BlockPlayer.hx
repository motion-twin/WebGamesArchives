package game.ai;

import game.PlayerData;

/*
 * Stay between an oponent and the ball.
 */
class BlockPlayer {
	public static function enter(p:PlayerData){
	}
	public static function update(p:PlayerData){
		if (p.team.leader == p){
			p.changeState(IdleState);
			return;
		}
		var ball = p.resolver.ball;
		var mid = ball.position.clone().add(p.targetPlayer.position).div(2);
		var distToOponent = p.distanceToPlayer(p.targetPlayer);
		var distToMid = p.position.distance(mid);
		if (distToOponent < PlayerData.FIGHT_DIST){
			p.contactPlayer(p.targetPlayer);
			return;
		}
		if (distToMid <= distToOponent){
			p.seek(mid);
			return;
		}
		p.changeState(IdleState);
	}
	public static function leave(p:PlayerData){
	}
	public static function toString(p:PlayerData) : String {
		return "Block("+p.targetPlayer.pos+")";
	}
}