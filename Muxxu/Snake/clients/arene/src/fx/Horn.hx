package fx;
import Protocole;

class Horn extends Fx {//}


	var coef:Float;
	
	public function new(nx:Float,ny:Float) {
		super();
		coef = 1.0;
	}
	
	override function update() {
		super.update();
		
		coef *= 0.95;
		
		var id = 0;
		for( p in sn.trq ) {
			id++;
			if( id < 10  ) continue;
			var dx = p.x - sn.x;
			var dy = p.y - sn.y;
			var a = Math.atan2(dy,dx);
			var dist = Math.sqrt(dx * dx + dy * dy);
			var lim = 550;
			var speed = Math.max((lim - dist) / lim , 0) * 3 * coef;
			
			p.x += Snk.cos(a) * speed;
			p.y += Snk.sin(a) * speed;
			var pos = Stage.me.clamp(p.x, p.y, 4);
			p.x = pos.x;
			p.y = pos.y;
			
			
		}
		
		if( coef < 0.05 ) kill();
		
		
	}
	

	
//{
}












