package game.ai;

import game.PlayerData;

/*
 * Ball is comming, just wait for it.
 */
class WaitPass {
	public static function enter(p:PlayerData){
		p.team.leader = p;
	}
	public static function update(p:PlayerData){
		var resolver = p.resolver;
		if (resolver.ball.owner != null){
			p.changeState(IdleState);
			return;
		}
		var dist = p.distanceToBall();
		if (dist <= PlayerData.CATCH_DISTANCE){
			p.changeState(TakeBall);
		}
		else if (resolver.ball.velocity == null || resolver.ball.velocity.length() < 1 || p.isBallInDanger()){
			p.changeState(ChaseBall);
		}
		else if (p.isThrower() && resolver.ball.position.length() < 40){
			p.changeState(ChaseBall);
		}
	}
	public static function leave(p:PlayerData){
	}
	public static function toString(p:PlayerData) :String {
		return "Wait";
	}
}
