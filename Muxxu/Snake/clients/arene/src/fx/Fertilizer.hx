package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Fertilizer extends CardFx {//}
	

	var timer:Int;
	public function new(ca) {
		super(ca);
		timer = 20;
	}
	

	override function update() {
		var min = 3;
		if( timer-- < 0 && Game.me.getTime() >= min * 60 * 1000 ) {
			Game.me.getCard(FERTILIZER).flipOut();
			Game.me.incFrutipower(25);
			kill();
		}
		super.update();
	}
	
	
//{
}












