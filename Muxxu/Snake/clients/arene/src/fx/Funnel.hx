package fx;
import mt.bumdum9.Lib;
import Protocole;


class Funnel extends CardFx {//}

	override function update() {
		super.update();
		var a = [];
		for ( fr in Game.me.fruits ) if (!fr.dummy) a.push(fr);
		
		var max = 12;
		if ( Game.me.have(SOAP) ) max >>= 1;
		
		if( a.length >= max ) {
			card.fxUse();
			for( fr in a ) new FruitToTarget(fr, 8,sn);
		}
	}
	

//{
}












