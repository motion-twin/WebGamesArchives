package fx;
import Protocole;
import mt.bumdum9.Lib;

class TrainingDeath extends Fx {//}

	var timer:Int;
	var step:Int;
	var prec:Void->Void;
	public function new() {
		super();
		step = 0;
		timer = 0;
		
	}
	
	override function update() {
		super.update();
		Game.me.timer = 0;

		switch(step) {
			case 0:
				if( sn.queue.length == 0 ) {
					prec = Game.me.action;
					new panel.Control(reborn);
					step++;
				}
			case 1:
				
			case 2:
				timer++;
				if( timer == 20 ) {
					sn.init();
					Game.me.initPlay();
					sn.speed = Cs.SNAKE_SPEED;
					kill();
					Game.me.initParams();
				}
		}
	}
	
	function reborn() {
		Game.me.action = prec;
		step++;
		timer = 0;
	}
	

	

	
	

		
	
//{
}
