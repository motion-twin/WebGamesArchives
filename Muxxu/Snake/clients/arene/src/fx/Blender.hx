package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;



class Blender extends CardFx {//}
	
	
	
	public function new(ca) {
		super(ca);
	
		
		
		
	}
	

	override function update() {
		super.update();
		

		
		var fruits = Game.me.fruits.copy();
		var a = [];
		for ( fr in fruits ) {
			var fr2 = a[fr.data.rank];
			if ( fr2 == null ) {
				a[fr.data.rank] = fr;
				continue;
			}
			a[fr.data.rank] = null;
			
			
			if ( fr.z < -5 || fr2.z < -5 || Math.abs(fr.vy)>1 || Math.abs(fr2.vy)>1  ) continue;
			
			var dx  = fr2.x - fr.x;
			var dy  = fr2.y - fr.y;			
			var a = Math.atan2(dy, dx);
			var speed = 3;
			var vx = Math.cos(a) * speed;
			var vy = Math.sin(a) * speed;
			
			fr.x += vx;
			fr.y += vy;
			fr2.x -= vx;
			fr2.y -= vy;
			
			if ( Math.abs(dx) + Math.abs(dy) < 5 ) {
				fr2.kill();
				fr.evolve(12);
				card.fxUse();
			}
			
			
		}
		
	
	}
	
	
	override function kill() {
		super.kill();
		
	}

	
	

	
//{
}












