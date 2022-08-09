package fx;
import Protocole;
import mt.bumdum9.Lib;

class Ankh extends Fx {//}

	var timer:Int;
	var step:Int;

	public function new() {
		super();
		step = 0;
		timer = 0;
	}
	
	override function update() {
		super.update();
		Game.me.timer = 0;
		
	
		switch(step) {
			case 0 :
				var inc = Std.int(  Math.max( 255 -sn.queue.length*20, 0) );
				Col.setColor( Game.me.screen, 0, inc );
				if( sn.queue.length == 0 && Game.me.have(ANKH) ) step++;
			case 1:
				if( Game.me.have(ANKH)&& timer++ == 6 ) resurect();
		}


	}
	
	function resurect() {
		
	
		Game.me.getCard(ANKH).flipOut();
		Col.setColor( Game.me.screen, 0, 0 );
		sn.init();
		Game.me.initPlay();
		kill();
		
		var m = [
			0, 1, 1, 0, 0,
			1, 0, 1, 0, 0,
			1, 1, 0, 0, 0,
			0, 0, 0, 1, 0.0,
		];
		
		new FlashScreen(0.1, m);
			
		
	}
	

	
	

		
	
//{
}
