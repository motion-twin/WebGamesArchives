package game.ai;
import Stat;
import game.PlayerData;
import geom.PVector3D;

/*
 * We own the ball and we have to bring it to the base.
 */
class RunToBase {

	public static function enter(p:PlayerData){
		p.team.leader = p;
		p.stats.count(DefSave);
	}

	public static function update(p:PlayerData){
		if (!p.hasBall()){
			p.changeState(IdleState);
			return;
		}
		if (p.distanceToOrigin() <= 29){
			return;
		}
		var resolver = p.resolver;
		var distToGoal = p.distanceToOrigin();
		var foes = p.foesByDistance();
		// finish line, if no obstacle we run
		if (distToGoal - 30 < p.agility * 1.5){
			var goal = geom.PVector3D.ORIGIN.clone();
			goal.sub(p.position);
			goal.normalize();
			goal.mult(p.agility * 1.5);
			goal.add(p.position);
			var collision = false;
			for (foe in foes){
				if (foe.insideRectangle(p.position, goal)){
					collision = true;
					break;
				}
			}
			if (!collision){
				if (!p.isSelfish){
					var friends = p.friends();
					friends.remove(p);
					for (friend in friends){
						if (friend.insideRectangle(p.position, goal)){
							if (p.passToPlayer(friend, goal))
								return;
							else
								break;
						}
					}
				}
				p.seek(goal);
				return;
			}
		}
		var shouldPass = 0.0;
		for (foe in foes){
			var distToFoe = p.distanceToPlayer(foe);
			if (distToFoe >= 15)
				continue;
			// foe in front of us
			if (foe.x < p.x){
				// but the goal line is nearest, just ignore the foe
				if (distToGoal-30 < distToFoe)
					continue;
				// chances are the foe will reach us before we reach the line
				shouldPass += 0.5;
			}
			else {
				// behind us
				shouldPass += ((15 - distToFoe) / 15) / 3;
			}
		}
		var r = resolver.random()*2;
		if (r < shouldPass && !p.isSelfish){
			var target = p.findPass();
			if (target != null){
				if (p.passToPlayer(target.player, target.dest))
					return;
			}
		}
		p.seek(PVector3D.ORIGIN);
	}

	public static function leave(p:PlayerData){
	}

	public static function toString(p:PlayerData){
		return "RunToBase "+p.steering;
	}
}