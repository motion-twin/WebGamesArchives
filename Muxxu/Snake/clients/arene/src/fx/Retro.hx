package fx;
import Protocole;
import mt.bumdum9.Lib;

private typedef FPart = { x:Float, y:Float, vx:Float, vy:Float, dp:Float, t:Int, col:Int };

class Retro extends Fx {//}


	
	public function new() {
		super();
	

		
	}
	
	override function update() {
		super.update();
		
		Game.me.gtimer -= 20;
		if( Game.me.gtimer <= 0 ) {
			Game.me.gtimer = 0;
			kill();
		}
		

	}
	
	


	
//{
}












