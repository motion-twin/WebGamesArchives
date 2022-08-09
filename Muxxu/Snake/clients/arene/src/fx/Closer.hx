package fx;
import Protocole;

class Closer extends CardFx {//}



	public function new(ca) {
		super(ca);
	}
	
	override function update() {
		super.update();
		
		var coef = 0.3;
		//var coef = 0.6;
		
		var id = 0;
		for( p in sn.trq ) {
			id++;
			if( id < 10  ) continue;
			var dx = p.x - sn.x;
			var dy = p.y - sn.y;
			var a = Math.atan2(dy,dx);
			var dist = Math.sqrt(dx * dx + dy * dy);
			//var lim = 550;
			var lim = 300;
			var speed = Math.max((lim - dist) / lim , 0) * coef;
			
			p.x -= Snk.cos(a) * speed;
			p.y -= Snk.sin(a) * speed;
			var pos = Stage.me.clamp(p.x, p.y, 4);
			p.x = pos.x;
			p.y = pos.y;

		}
		

		
		
	}
	

	
//{
}












