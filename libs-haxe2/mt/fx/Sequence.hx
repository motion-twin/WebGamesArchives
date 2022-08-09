package mt.fx;
import mt.bumdum9.Lib;

class Sequence extends mt.fx.Fx {

	var step:Int;
	var timer:Int;
	var spc:Float;
	
	public function new( ?pManager ) {
		super(pManager);
		step = 0;
		timer = 0;
		coef = 0;
		spc = 0.1;
	}

	override function update() {
		super.update();
		coef = Math.min(coef + spc,1);
		timer++;
	}
	
	public function nextStep(?spc) {
		setStep( step+1, spc );
	}
	
	public function setStep(step : Int, ?spc) {
		this.timer = 0;
		this.coef = 0;
		this.step = step;
		if( spc != null ) this.spc = spc;
	}
}
