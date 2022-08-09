package fx;
import mt.bumdum.Phys;

class Spark extends Phys{//}

	public var coef:Float;

	public function new(mc){
		super(mc);
		coef = 1;
	}
	override public function update(){

		var vit = Math.sqrt(vx*vx+vy*vy);
		var a = Math.atan2(vy,vx);
		root._xscale = vit*coef;
		root._rotation = a/0.0174;

		super.update();

	}



//{
}
