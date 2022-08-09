package mt.fx;

class Delay extends mt.fx.Fx {
	
	var fr : Float;
	var delayedFunc : Void  -> Void;
	
	/**
	 * 
	 * @param	fr number of frames to wait
	 * @param	delayed is the callback
	 */
	public function new( fr:Float, delayed : Void -> Void) {
		super();
		delayedFunc = delayed;
		this.fr = fr;
	}
	
	public override function update() {
		super.update();
		fr--;
		if ( fr <= 0.0)
			kill();
	}
	
	public override function kill() {
		super.kill();
		delayedFunc();
		delayedFunc = null;
	}
}