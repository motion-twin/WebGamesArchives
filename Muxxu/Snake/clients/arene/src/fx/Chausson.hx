package fx;
import Protocole;

class Chausson extends Fx {//}

	static var SLOW = 0.3;
	static var DURATION = 50;
	
	public static var ACTIVE = false;
	public static var coef:Float;
	
	public var matrix:Array<Float>;
	
	var timer:Int;
	
	
	public function new() {
		if( ACTIVE ) return;
		super();
		ACTIVE = true;
		timer = DURATION;
		coef = 1;
		
		var a = 0.3;
		var b = 0.1;
		var c = 0.6;
		matrix = [
			a, b, c, 0, 50,
			a, b, c, 0, 40,
			a, b, c, 0, 0,
			0, 0, 0, 1, 0,
		];
		
		
		
	}
	
	override function update() {
		super.update();
		timer--;
		
		var c = (timer / DURATION);
		c = 1 - Snk.sin(c * 3.14);
		coef =  SLOW + c * (1 - SLOW);
		
		var cc = Math.min( (1 - c) * 1.5, 1);
		
		Game.me.screen.setColorMatrix(matrix, cc);
		
				
		if( timer == 0 ) kill();
	}
	
	override function kill() {
		ACTIVE = false;
		super.kill();
	}
	


	
//{
}












