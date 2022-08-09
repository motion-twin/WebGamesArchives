interface MoveManager {
	public function update() : Void;
}

class PathMoveManager implements MoveManager {
	var path : Path;
	var enemy : Enemy;
	var state : Int;
	var angle : Float;

	public function new( e:Enemy, p:Path ){
		enemy = e;
		path = p;
		state = 0;
		angle = 0;
	}

	public function update() : Void {
		switch (state){
			case 0: // join RDV				
				var speed = enemy.speed * mt.Timer.tmod;
				var dist = Geom.distance(enemy, path.point);
				angle = Geom.averageRadianAngle(angle, Geom.angleRad(enemy, path.point));
				Geom.moveAngle(enemy, angle, Math.min(dist, speed));
				if (dist <= speed){
					state = 1;
					path = path.next;
				}

			case 1:
				var targetAngle = Geom.angleRad(enemy, path.point);
				var remain = Geom.angleDiff(targetAngle, angle);				
				var rotateSpeed = Geom.deg2rad(enemy.speed * 5 * mt.Timer.tmod);
				if (remain <= rotateSpeed){
					angle = targetAngle;
					state = 0;
				}
				else {
					angle = Geom.fixRadianAngle(angle + rotateSpeed);
				}
		}
		enemy.rotation = Geom.rad2deg(angle) - 180;
	}
}

class CPathMoveManager implements MoveManager {
	var path : CPath;
	var enemy : Enemy;
	var state : Int;
	var theta : Float;
	var rotat : Float;
	var angle : Float;

	public function new( e:Enemy, p:CPath ){
		enemy = e;
		path = p;
		state = 0;
		theta = 0;
		angle = 0;
	}

	public function update() : Void {
		switch (state){
			case 0: // join RDV
				var rdv = path.getRendezVousPoint();
				var speed = enemy.speed * mt.Timer.tmod;
				var dist = Geom.distance(enemy, rdv);
				angle = Geom.averageRadianAngle(angle, Geom.angleRad(enemy, rdv));
				// INFO: will lose some precision with extra speed
				Geom.moveAngle(enemy, angle, Math.min(dist, speed));
				// joined RDV
				if (dist <= speed){
					state = 1;
					theta = path.rdvAngle;
					rotat = 0;
				}
				
			case 1: // rotate around cpath
				var rot = (enemy.speed / path.ray) * mt.Timer.tmod;
				rotat = Math.min(rotat+rot, path.byeAngle);
				theta = path.rdvAngle + rotat * path.direction;
				// INFO: will lose some precision there				
				var dx = path.center.x + path.ray * Math.cos(theta);
				var dy = path.center.y + path.ray * Math.sin(theta);
				angle = Geom.averageRadianAngle(angle, Geom.angleRad(enemy, {x:dx, y:dy}));
				enemy.x = dx;
				enemy.y = dy;
				// Geom.moveAngle(this, angle, speed*mt.Timer.tmod);
				if (rotat >= path.byeAngle){
					path = path.next;
					state = 0;
				}				
		}
		enemy.rotation = Geom.rad2deg(angle) - 90;
	}
}