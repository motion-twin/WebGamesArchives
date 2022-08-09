package mt.fx;

class Update extends mt.fx.Fx {
	
	var updateFunc : mt.fx.Fx -> Void;
	
	public function new( update : mt.fx.Fx -> Void) {
		super();
		updateFunc = update;
	}
	
	public override function update() {
		super.update();
		updateFunc(this);
	}
	
	public override function kill() {
		super.kill();
		updateFunc = null;
	}
}