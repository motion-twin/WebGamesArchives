package fx;
import mt.bumdum.Phys;

class Spark extends Phys{//}

	public function new(mc){
		super(mc);
	}
	override public function update(){

		var vit = Math.sqrt(vx*vx+vy*vy);
		var a = Math.atan2(vy,vx);
		root._xscale = vit;
		root._rotation = a/0.0174;

		super.update();

	}



//{
}