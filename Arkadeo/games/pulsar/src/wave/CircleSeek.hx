package wave;
import Protocol;
import mt.bumdum9.Lib;


class CircleSeek extends fx.Wave {//}

	
	var ray:Int;


	public function new(data, ray ) {
		super(data);
		this.ray = ray;
	}
	
	override function spawn(type) {
		
		var a = count * 6.28 / data.max;
		var x = hero.x + Math.cos(a) * ray;
		var y = hero.y + Math.sin(a) * ray;
		new fx.Spawn(type,x,y);
		
		
	}
	

	
	
//{
}












