package game.ai;

import geom.PVector3D;
import game.GameState;
import game.PlayerData;

/*
 * Cut runner's retreat.
 */
class CutRetreat {
	public static function enter(p:PlayerData){
	}
	public static function update(p:PlayerData){
		var ball = p.resolver.ball.position;
		if (p.resolver.isOutField(ball)){
			p.changeState(IdleState);
			return;
		}
		var ballAngle = ball.angleZ();
		var distToBall = p.position.distance(ball);
		if (distToBall <= PlayerData.CATCH_DISTANCE && p.resolver.ball.owner == null && p.resolver.state == GameState.GROUND){
			p.changeState(p.ballContactState());
		}
		if (distToBall <= PlayerData.FIGHT_DIST && p.resolver.ball.owner != null && p.resolver.ball.owner.team != p.team){
			p.contactPlayer(p.resolver.ball.owner);
			return;
		}
		var originToBall = ball.length();
		var distMid = originToBall - distToBall;
		if (distMid < 30)
			distMid = 30;
		var mid = new PVector3D(distMid, 0).rotateZ(ballAngle);
		var distToMid = p.position.distanceSquared(mid);
		if (distToMid >= 1)
			p.seek(mid);
		else
			p.changeState(IdleState);
	}
	public static function leave(p:PlayerData){
	}
	public static function toString(p:PlayerData){
		return "CutRetreat";
	}
}