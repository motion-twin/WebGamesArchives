package fx;
import Protocole;
import Snake;


class Brake extends Fx {//}


	public static var LIMIT = 30;
	public static var ACTIVE = false;
	public static var coef:Float;
	static var timer:Int;
	
	public function new() {
		timer = 200;
		if( ACTIVE ) return;
		coef = 1;
		super();
		ACTIVE = true;
	}
	
	override function update() {
		super.update();
		var ta = 0.5;
		if( timer-- < 0 ) ta = 1;
		coef += (ta - coef) * 0.1;
		if( coef > 0.99 )kill();
	}

	override function kill() {
		ACTIVE = false;
		super.kill();
	}
	


	
//{
}












