class WaveEnemy extends Enemy {	
	public var bait : Bait;
	public var leader : WaveEnemy;
	public var child : WaveEnemy;
	public var angle : Float;

	public function new(){
		super();
		speed = 5 * (60/mt.Timer.wantedFPS);
		bait = null;
		wave = true;
	}

	override public function onDeath(){
		super.onDeath();
		if (child != null)
			child.leader = leader;
		if (leader != null)
			leader.child = child;
		else if (child != null)
			child.move = move;
	}

	public function updateLeader(){
		throw "Not implemented";
	}
	
	override public function update(){
		// super.update();
		// we do not call super.update() because the move behaviour is decided
		// by the wave leader which might have a specific move behaviour
		if (shot != null)
			shot.update();
		
		if (leader == null){
			if (bait == null || (bait.t + 100 / speed) < Game.instance.now){
				var next = { x:x, y:y, a:angle, t:Game.instance.now, next:null };
				if (bait != null)
					bait.next = next;
				bait = next;
				/*
				Game.instance.fxLayer.graphics.beginFill(0x000000);
				Game.instance.fxLayer.graphics.drawCircle(bait.x, bait.y, 2);
				Game.instance.fxLayer.graphics.endFill();
				*/
			}
			updateLeader();
		}
		else {
			if (bait == null){
				bait = leader.bait;
			}
			if (bait == null){
				return;
			}
			var dist = speed * mt.Timer.tmod;
			var remain = Geom.distance(this, bait);
			if (bait != null && dist > remain){
				x = bait.x;
				y = bait.y;
				bait = bait.next;
				dist -= remain;
			}
			if (bait == null){
				return;
			}
			var toBait = Geom.fixRadianAngle(Geom.angleRad(this, bait));
			// angle = Geom.averageRadianAngle(angle, bait.a);
			angle = Geom.averageRadianAngle(angle, toBait);
			Geom.moveAngle(this, angle, dist);
		}
		rotation = Geom.rad2deg(angle) + 180;
	}
}