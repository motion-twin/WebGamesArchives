package fx;
import Protocole;

class Sponge extends Fx {//}
	
	

	public function new() {
		super();
		
		var a = Game.me.fruits.copy();
		for(fr in a ) {
			var ray = fr.getRay()*0.25;
			for( i in 0...4 ) {
				var f = function(){
					var p = Stage.me.getPart("soap");
					p.x = fr.x + (Math.random() * 2 - 1) * ray;
					p.y = fr.y + (Math.random() * 2 - 1) * ray;
					p.setSleep( i * 2);
					p.randMirror();
					p.updatePos();
				}
				haxe.Timer.delay(f, i * 100);
				
			}
			fr.kill();
		}
		kill();
	}

	

	
//{
}












