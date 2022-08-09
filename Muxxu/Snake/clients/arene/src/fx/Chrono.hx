package fx;
import Protocole;
import mt.bumdum9.Lib;

class Chrono extends CardFx {//}

	var time:Int;
	var action:Void->Void;

	public function new(ca, seconds, f) {
		super(ca);
		time = seconds*1000;
		action = f;
	}

	override function update() {
		super.update();
		if( Game.me.getTime() > time ) {
			card.flip();
			kill();
			action();
		}
	}
	
	



	
//{
}












