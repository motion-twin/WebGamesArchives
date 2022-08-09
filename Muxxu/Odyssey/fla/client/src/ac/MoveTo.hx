package ac;
import Protocole;
import mt.bumdum9.Lib;



class MoveTo extends Action {//}
	
	public static var SPEED_COEF = 2.0;
	
	var folk:Folk;
	var tx:Float;
	
	public function new(folk,tx) {
		super();
		this.folk = folk;
		this.tx  = tx;
		
	}
	override function init() {
		super.init();
		
	
		var speed = 6*SPEED_COEF;
		var dif = tx - folk.x;
		
		var move = new mt.fx.Tween( folk, tx, folk.y, speed / Math.abs(dif));
		move.onFinish = finish;

		folk.setSens((dif*folk.sens>0)?1:-1);
		folk.play("run");
		
	}
	
	
	function finish() {
		folk.play("stand");
		folk.setSens(1);
		kill();
	}



	
	
//{
}