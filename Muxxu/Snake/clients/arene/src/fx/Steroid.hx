package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Steroid extends CardFx {//}
	

	
	public function new(ca) {
		super(ca);

		
	}

	override function update() {
		var min = 3+Game.me.numCard(ECSTASY);
		if( Game.me.getTime() >= min * 60 * 1000 ) {
			
			Game.me.getCard(STEROID).flipOut();
			sn.headCollide();
			kill();
		}
		
		super.update();
	}
	
	
//{
}












