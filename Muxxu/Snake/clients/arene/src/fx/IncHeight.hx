package fx;
import mt.bumdum9.Lib;

class IncHeight extends Fx{//}

	
	var timer:Int;
	var coef:Float;
	var inc:Float;
	
	public function new(hh,t=10) {
		super();
		timer = t;
		inc = hh / t;
		coef = 0;
		
	}
	
	override function update() {
	
		coef += inc;
		var scroll = Std.int(coef);
		if( scroll != 0 ){
			Stage.me.incSize(0,scroll);
			coef -= scroll;
		}
		if( timer-- == 0 ) kill();
	}

//{
}