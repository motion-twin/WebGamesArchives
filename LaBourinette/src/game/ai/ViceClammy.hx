package game.ai;

import game.PlayerData;

class ViceClammy {
	public static function enter(p:PlayerData) : Void {
		var vector = new geom.PVector3D(5 + p.resolver.randomInt(10), 0, 0);
		vector.rotateZ((p.resolver.random() * Math.PI*2) - Math.PI);
		vector.add(p.position);
		p.target = vector;
	}

	public static function update(p:PlayerData) : Void {
		if (p.position.distance(p.target) <= PlayerData.CATCH_DISTANCE){
			p.stop();
			p.stuntTurns = 5;
			p.changeState(Stunt);
		}
		else {
			p.seek(p.target);
		}
	}

	public static function leave(p:PlayerData) : Void {
	}

	public static function toString(p:PlayerData) : String {
		return "ViceClammy("+p.target+")";
	}
}