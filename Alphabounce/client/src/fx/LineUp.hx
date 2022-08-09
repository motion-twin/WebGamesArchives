package fx;
import mt.bumdum.Phys;

class LineUp extends Phys{//}

	public var factor:Float;

	public function new(mc){
		super(mc);
		factor = 1;
	}

	override public function update(){
		super.update();
		var xs = -100*factor*vx;
		var ys = -100*factor*vy;
		
		if(Math.abs(xs)<100)xs=100;
		if(Math.abs(ys)<100)ys=100;
		
		root._xscale = xs;
		root._yscale = ys;

		
	}



//{
}
