package seq;
import mt.bumdum9.Lib;
import Protocol;

/**
 * make bads spawn
 */
class TimeUp  extends mt.fx.Sequence {//}

	
	var limit:Int;
	
	public function new() {
		super();
		limit = Game.me.coinMax * 25;
	}
	
	
	override function update() {
		super.update();
		if( timer > limit ) {
			
			timer = 0;
			limit = 600;
			//var b = Game.me.spawnBad(4);
			//b.autoPos();
			new fx.Spawn(4);
			if( Game.me.bads.length > 16 ) kill();
		}
	}
	


	
	

	
	
//{
}












