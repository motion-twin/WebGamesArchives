package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class BounceSnake extends Fx {//}
	

	public function new() {

		super();
		
		var a = sn.angle;
		var ray = Snake.HEAD_RAY;
		if ( sn.x <= ray || sn.x > Stage.me.width - ray ) {
			sn.x = Num.mm( ray, sn.x, Stage.me.width - ray );
			sn.angle = Math.atan2( Snk.sin(a), -Snk.cos(a));
		}
		if ( sn.y <= ray || sn.y > Stage.me.height - ray ) {
			sn.y = Num.mm( ray, sn.y, Stage.me.height - ray );
			sn.angle = Math.atan2( -Snk.sin(a), Snk.cos(a));
		}

		
		// FX
		var p = Stage.me.getPart("onde");
		p.x = sn.x;
		p.y = sn.y;
		
		kill();
		
	}
	

	

	
	

		
	
//{
}












