package game.ai;

import geom.PVector3D;
import game.PlayerData;
import game.Event;

class ViceSoiling {
	public static function enter(p:PlayerData) : Void {
		if (p.team.leader == p)
			p.team.leader = null;
		p.knockOut(5, true);
		p.resolver.event(PlayerDisabled(p));
		p.target = new PVector3D(p.team.x, p.team.y);
	}

	public static function update(p:PlayerData) : Void {
		p.seek(p.target, 2);
	}

	public static function leave(p:PlayerData) : Void {
	}

	public static function toString(p:PlayerData) : String {
		return "ViceSoiling("+p.target+")";
	}
}