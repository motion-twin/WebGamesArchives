package bad;
import mt.bumdum9.Lib;

class Arrow extends Bad  {
	

	public var speed:Float;
	public var angle:Float;
	public var va:Float;

	public function new(t) {
		super(t);
		angle = rnd(628)*0.01;
		va = 0;
		speed = 3;
	}

	public function follow(?tx,?ty,lim=0.05) {
		if ( tx == null ) tx = hero.x;
		if ( ty == null ) ty = hero.y;
		
		var dx = tx - x;
		var dy = ty - y;
		var ta = Math.atan2(dy, dx);
		var da = Num.hMod(ta - angle, 3.14);
		angle += Num.mm( -lim, da * 0.5, lim);
		
	}
	
	override function update() {
		super.update();
		angle += va;
		x += Math.cos(angle) * speed;
		y += Math.sin(angle) * speed;

	}
	
	override function onRecal(n:Int) {
		

		
		var dx = Math.cos(angle);
		var dy = Math.sin(angle);
		
		switch(n) {
			case 0 : angle = Math.atan2(dy,-dx);
			case 1 : angle = Math.atan2(-dy,dx);
		}
	}

	override function setAngle(an) {
		angle = an;
	}

}
