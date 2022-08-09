package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Poison extends Fx {//}
	
	static var MULTI = 20;
	
	var timer:mt.flash.Volatile<Int>;
	var cycle:Int;
	
	public function new() {
		super();
		timer = 0;
		cycle = 18*MULTI;
	}
	
	override function update() {
		if( sn.dead) {
			kill();
			return;
		}
		
		if ( timer++ == Std.int(cycle / MULTI ) ) {
			cycle--;
			sn.explode(10);
			new AssBlood(1);
			timer = 0;
		}
		if ( sn.length <= 0 ) {
			kill();
			Game.me.gameover();
		}
		
	}
	
	

		
	
//{
}












