package wave;
import Protocol;
import mt.bumdum9.Lib;


class Circle extends fx.Wave {

	var ray:Int;
	var cx:Float;
	var cy:Float;

	public function new(data, ray ) {
		super(data);
		this.ray = ray;
		cx = hero.x;
		cy = hero.y;
	}
	
	override function spawn(type) {
		var a = count * 6.28 / data.max;
		var x = cx + Math.cos(a) * ray;
		var y = cy + Math.sin(a) * ray;
		new fx.Spawn(type,x,y);
	}
	
}
