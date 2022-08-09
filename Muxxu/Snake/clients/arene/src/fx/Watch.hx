package fx;
import mt.bumdum9.Lib;

class Watch extends Fx{//}

	var matrix:Array<Float>;
	var coef:Float;
	var parc:Float;

	public function new( ) {
		super();
		coef = 0;
		sn.freeze = true;
		parc = 0;
		
		var a = 0.3;
		var b = 0.1;
		var c = 0.6;
		matrix = [
			a, b, c, 0, 0,
			a, b, c, 0, 0,
			a, b, c, 0, 0,
			0, 0, 0, 1, 0,
		];
		
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + 0.01, 1);

		
		var cc = Snk.sin(coef * 3.14);
		parc += cc*2;
		while( parc > 0 ) {
			sn.back();
			parc--;
		}
		
		Game.me.screen.setColorMatrix(matrix, cc);
		
		Game.me.gtimer -= 1+Std.int(cc*5);
		if( Game.me.gtimer < 0 ) Game.me.gtimer = 0;
		
		if( coef == 1 || sn.trq.length < 5 ) {
			sn.freeze = false;
			kill();
		}
		
	}

//{
}