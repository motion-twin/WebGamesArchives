package game.ai;

import game.PlayerData;

/*
 * We have to move towards the ball and intercept it quickly.
 */
class InterceptBall {
	public static function enter(p:PlayerData){
		p.team.leader = p;
	}
	public static function update(p:PlayerData){
		var ball = p.resolver.ball;
		if (p.distanceToBall() <= PlayerData.CATCH_DISTANCE){
			p.changeState(TakeBall);
			return;
		}
		if (ball.velocity == null || ball.owner != null || !ball.isFlying){
			p.changeState(IdleState);
			return;
		}
		var futurePositions = p.resolver.ball.nextPositions(5);
		var i = 0;
		var estimations = [];
		for (pos in futurePositions){
			var item = {
				id:i,
				pos: pos,
				goal: pos.length() <= 30,
				dist: p.position.distance(pos),
				reachable: false,
			};
			item.reachable = (item.dist <= (p.agility * ++i) + PlayerData.CATCH_DISTANCE);
			estimations.push(item);
		}
		estimations.sort(function(a,b){
			var cmp = Reflect.compare(a.dist, b.dist);
			if (cmp != 0)
				return cmp;
			return Reflect.compare(a.id, b.id);
		});
		p.seek(estimations[0].pos);
	}
	public static function leave(p:PlayerData){
	}
	public static function toString(p:PlayerData){
		return "InterceptBall("+p.target+")";
	}
}