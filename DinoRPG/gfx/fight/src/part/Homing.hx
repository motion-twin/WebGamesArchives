package part;

import mt.bumdum.Lib;

class Homing extends Part {

	public var flOrient:Bool;
	public var speed:Float;
	public var frict:Float;
	public var angle:Float;
	public var va:Float;
	public var ca:Float;

	public var trg:Fighter;//{x:Float,y:Float,z:Float};
	public var jumper:{max:Float, z:Float, bz:Float};

	public function new(mc) {
		super(mc);
		angle = 0;
		speed = 3;
		va = 0.2;
		ca = 0.1;
		ray = 20;
		dropShadow();
	}

	public override function update() {
		super.update();
		
		if( speed > 1 ) speed *= frict;

		if( trg != null ) {
			var tz = trg.z - trg.height * 0.5;
			var dx = trg.x - x;
			var dy = trg.y - y;
			var dz = tz - z;
			var da = Num.hMod( Math.atan2(dy, dx) - angle, 3.14 );
			var inc = Num.mm( -va, da*ca, va) * mt.Timer.tmod;
			angle = Num.hMod(angle + inc, 3.14);
			updateVit();
			if( jumper != null ) {
				var dist = Math.sqrt(dx*dx + dy*dy);
				var c = dist / jumper.max;
				z = jumper.bz * c + tz * (1 - c) + Math.sin(c * 3.14) * jumper.z;
			} else {
				z = dz * 0.2;
			}
		}

		if(flOrient) orient();
	}

	public function setAngle(n) {
		angle = n;
		updateVit();
	}
	
	public function setSpeed(n) {
		speed = n;
		updateVit();
	}
	
	public function updateVit() {
		vx = Math.cos(angle) * speed;
		vy = Math.sin(angle) * speed;
	}

	public function orient() {
		root._rotation = angle / 0.0174;
	}

}