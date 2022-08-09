package fx;
import Protocole;
import mt.bumdum9.Lib;

class Exit extends Fx {//}

	var step:Int;
	var timer:Int;
	var multi:Null<Float>;
	
	public function new(?multi) {
		super();
		this.multi = multi;
		Game.me.stopPlay();
		timer = 0;
		step = 0;
		
	}
	
	override function update() {
	
		timer++;
		switch(step) {
			case 0 :
				var coef = timer / 20;
				sn.fxGlow(coef);
				
				if( timer == 20 ) {
					if( multi != null ){
						var dif = Std.int(Game.me.score * multi );
						Game.me.incScore(dif, sn.x, sn.y);
					}
					
					sn.fxAllSparkDust();
					sn.kill();
					step++;
				}
			case 1:
				if( timer > 20 ) Game.me.endGame();
		}
		

	}
	
	
	
	


	
//{
}












