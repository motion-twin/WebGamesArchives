package game.ai;

import game.GameState;
import game.PlayerData;

/*
 * Chase the ball.
 */
class ChaseBall {
	public static function enter(p:PlayerData){
	}

	public static function update(p:PlayerData){
		var resolver = p.resolver;
		var dest = if (resolver.state == GameState.GROUND) resolver.ball.position
			else if (resolver.ball.isFlying) resolver.ball.landing
			else if (resolver.ball.owner != null) resolver.ball.position
			else resolver.ball.position; //TODO
		if (dest.length() >= 100){
			p.changeState(IdleState);
			return;
		}
		var dist = p.distanceToBall();
		if (resolver.ball.owner == null && dist <= 1){
			if (resolver.state == GameState.GROUND){
				p.changeState(p.ballContactState());
			}
			else {
				// we are waiting for the ball, may be some maraveux is
				// around the corner and we feel agressive
				var foes = p.foesByDistance();
				var dist = p.distanceToPlayer(foes[0]);
				if (dist <= PlayerData.FIGHT_DIST && resolver.random() > 0.5){
					p.contactPlayer(foes[0]);
				}
			}
		}
		// else if (resolver.ball.owner == null && dist <= PlayerData.CATCH_DISTANCE && resolver.state == GameState.GROUND &&
		else if (resolver.ball.owner == null && dist <= PlayerData.CATCH_DISTANCE && resolver.state == GameState.GROUND){
			p.changeState(p.ballContactState());
		}
		else if (resolver.ball.owner != null && resolver.ball.owner.team != p.team && dist <= PlayerData.FIGHT_DIST){
			p.contactPlayer(resolver.ball.owner);
		}
		else if (resolver.ball.owner != null && resolver.ball.owner.team == p.team){
			p.changeState(SupportRun);
		}
		else {
			p.seek(dest);
		}
	}

	public static function leave(p:PlayerData){
	}

	public static function toString(p:PlayerData) : String {
		return "ChaseBall : "+p.resolver.ball.position.toHex()+" with steering "+p.steering.toHex();
	}
}
