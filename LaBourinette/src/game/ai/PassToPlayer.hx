package game.ai;

import Stat;
import game.PlayerData;

/*
 * The ball's owner chose to pass it to some friend.
 */
class PassToPlayer {
	public static function enter(p:PlayerData){
		var ball = p.resolver.ball;
		if (p.hasBall()){
			ball.x = p.x;
			ball.y = p.y;
			var dest = if (p.target != null) p.target else p.targetPlayer.position;
			ball.throwAt(dest, p.power);
			if (p.targetPlayer != null){
				p.stats.count(DefPass);
				ball.pass = {
					from:p,
					to:p.targetPlayer
				};
			}
			if (dest == p.targetPlayer.position)
				p.targetPlayer.changeState(WaitPass);
			else
				p.targetPlayer.changeState(InterceptBall);
			p.targetPlayer = p.foesByDistance()[0];
			p.changeState(BlockPlayer);
			return;
		}
		else {
			p.changeState(IdleState);
		}
	}
	public static function update(p:PlayerData){
	}
	public static function leave(p:PlayerData){
	}
	public static function toString(p:PlayerData){
		return "Pass("+p.targetPlayer.pos+")";
	}
}