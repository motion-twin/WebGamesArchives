package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class ShieldBoost extends Fx {//}
	static var INC = 0.05;
	var timer:Float;
	
	public function new(ammount=1.0) {
		super();
		timer = ammount/INC;
	}
	

	override function update() {
		super.update();
		Game.me.incShield(INC);
		if( timer-- <= 0 ) kill();
		
	}

	
	
//{
}












