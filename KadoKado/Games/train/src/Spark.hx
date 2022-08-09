import Common;
import mt.bumdum.Lib;
class Spark extends mt.bumdum.Phys {//}

	public function new(mc) {
		super(mc);
	}

	override function update(){
		var ox = x;
		var oy = y;
		super.update();

		var dx = x - ox;
		var dy = y - oy;
		root._rotation = Math.atan2(dy,dx)/0.0174;
		root._xscale = Math.sqrt(dx*dx+dy*dy)*100;

	}


//{
}
