package part;
import mt.bumdum.Lib;


class Turner extends Part {

	public var svr:Float;

	public function new(mc) {
		super(mc);
		svr = 0;
	}

	public override function update() {
		super.update();
		root.smc._rotation += svr*mt.Timer.tmod;

	}
}