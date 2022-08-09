package fx;
import Protocole;

class CardFx extends Fx {//}
	
	var card:Card;

	public function new(ca) {
		card=ca;
		super();
		
	}
	
	override function update() {
		super.update();
		if ( !card.active ) vanish();
	}
	
	public function vanish() {
		kill();
	}

	
//{
}












