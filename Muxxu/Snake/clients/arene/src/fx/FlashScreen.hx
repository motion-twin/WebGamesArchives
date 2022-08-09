package fx;
import mt.bumdum9.Lib;

class FlashScreen extends Fx{//}

	var matrix:Array<Float>;
	var coef:Float;
	var speed:Float;

	public function new(sp = 0.1, ?m:Array<Float> ) {
		
		if( m == null ) {
			m = [
				0,0,0,0,255,
				0,0,0,0,255,
				0,0,0,0,255,
				0,0,0,1,0.0,
			];
			
		}
		
		super();
		speed = sp;
		coef = 1.0;
		matrix = m;
		maj();
		
	}
	
	override function update() {
		coef = Math.max(coef - speed, 0);
		maj();
		if( coef == 0 ) kill();
	}
		
	function maj() {
		Game.me.screen.setColorMatrix(matrix, coef);
	}
	

	
//{
}