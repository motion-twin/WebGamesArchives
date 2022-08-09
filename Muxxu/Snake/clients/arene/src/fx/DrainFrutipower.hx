package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class DrainFrutipower extends Fx {//}
	static var INC = 1;
	var timer:Float;
	var type:Int;

	public function new(t=0) {
		super();
		type = t;
	}

	override function update() {
		super.update();
		Game.me.incFrutipower( -1);
		
		switch(type) {
			case 1 :	if( Game.me.gtimer % 2 == 0 ) Game.me.incScore(750);
			case 2 :
				new fx.Reduce(10,1);
				//sn.drawAll();
		}
		
		if( Game.me.frutipower == Game.me.getFrutipowerMinimum() || sn.dead ) kill();
		
		
	}

	
	
//{
}












