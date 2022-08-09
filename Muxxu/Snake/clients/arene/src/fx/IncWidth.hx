package fx;
import mt.bumdum9.Lib;

class IncWidth extends Fx{//}

	
	var timer:Int;
	var coef:Float;
	var inc:Float;
	
	public function new(ww,t=10) {
		super();
		timer = t;
		inc = ww / t;
		coef = 0;
		
	}
	
	override function update() {
	
		coef += inc;
		var scroll = Std.int(coef);
		if( scroll != 0 ){
			Stage.me.incSize(scroll,0);
			coef -= scroll;
		}
		if( timer-- == 0 ) kill();
	}

//{
}