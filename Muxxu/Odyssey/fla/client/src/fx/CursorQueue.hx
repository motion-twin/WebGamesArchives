package fx;
import Protocole;
import mt.bumdum9.Lib;

class CursorQueue extends mt.fx.Fx {//}
	

	var ox:Float;
	var oy:Float;
	
	var cur: { x:Float, y:Float, vx:Float, vy:Float };
	
	public function new() {
		super();				
		cur = {	x:0.0, y:0.0, vx:0.0, vy:0.0	};
		
		var sock = new mt.fx.Sock(cur);
		Game.me.dm.add(sock.canvas, Game.DP_FX);
			
	}

	
	// UPDATE
	override function update() {
		super.update();
	
		var xm = Game.me.mouseX;
		var ym = Game.me.mouseY;
		cur.vx = xm - cur.x;
		cur.vy = ym - cur.y;
		cur.x = xm;
		cur.y = ym;
			
		
	}
	
	

	
	
//{
}