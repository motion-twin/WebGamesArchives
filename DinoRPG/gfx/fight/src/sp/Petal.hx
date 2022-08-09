package sp;
import mt.bumdum.Lib;

class Petal extends mt.bumdum.Phys {

	public var flBurst:Bool;
	public var gy:Float;

	public function new(mc) {
		super(mc);
		gy = 8;
	}

	public override function update() {
		super.update();
		if( y > gy ) {
			y = gy;
			vx = 0;
			vy = 0;
			weight = 0;
			root.smc.stop();
			if( flBurst ) {
				root._rotation = 0;
				root.gotoAndPlay("burst");
			}
			gy = null;
		}
	}
}