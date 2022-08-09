package game.ai;

import game.Event;
import geom.PVector3D;
import game.PlayerData;

class CompetenceSlide {
	public static function enter(p:PlayerData) : Void {
		p.ticks = 0;
		var target = null;
		if (p.velocity.lengthSquared() > 0)
			target = p.velocity.clone().unit().mult(20);
		else {
			target = new PVector3D(20, 0);
			target.rotateZ(Math.PI*2*p.resolver.random());
		}
		p.target = target;
	}

	public static function update(p:PlayerData) : Void {
		p.ticks++;
		if (p.ticks <= 5)
			p.maxSpeed = p.getMaxMoveSpeed() * 2;
		else if (p.ticks <= 13)
			p.maxSpeed = p.getMaxMoveSpeed() / 2;
		else
			p.changeState(IdleState);
		p.seek(p.target);
	}

	public static function leave(p:PlayerData) : Void {
	}

	public static function toString(p:PlayerData) : String {
		return "CompetenceSlide("+p.target+")";
	}
}