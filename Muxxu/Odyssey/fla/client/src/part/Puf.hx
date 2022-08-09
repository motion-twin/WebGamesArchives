package part;
import Protocole;
import mt.bumdum9.Lib;



class Puf extends mt.fx.Arrow<gfx.Breath> {//}
	

	var ox:Float;
	var oy:Float;
	var breath:Breath;
	var va:Float;
		
	public function new(br) {
		
		breath = br;
		

		var mc = new gfx.Breath();
		super(mc);
		breath.board.dm.add( root, Board.DP_FX );
		
		//setScale(0.5);
		
		resetOffset();
		
		//setAlpha(0.2);
		//Filt.blur(root, 2, 2);
		
		va = 0;
	}
	function resetOffset() {
		ox = (Math.random() * 2 - 1) * 5;
		oy = (Math.random() * 2 - 1) * 5;
	}

	override function update() {
		
		super.update();
		
		var trg = breath.getTargetPos();
		
		var dx = trg.x+ox - x;
		var dy = trg.y+oy - y;
		var ta = Math.atan2(dy, dx);
	
		var da = Num.hMod(ta - an, 3.14);
		var lim = 0.1;
		an += Num.mm( -lim, da*0.5, lim);
		
		
		
		var calm_zone = 50 + scale * 70;
		
		var coef_angle = 0.25+(1 - (Math.abs(da) / 3.14))*0.75;
		var coef_dist = 0.008+Math.min( (Math.abs(dx) + Math.abs(dy)) / calm_zone, 1 )*0.992;
		asp =  coef_dist * coef_angle * 5;
		
		
		// RANDOM MOVE ANGLE
		if ( Std.random(50) == 0 ) 	va += (Math.random() * 2 - 1) * 0.4;
		va *= 0.95;
		an += va;
		
		// RANDOM MOVE OFFSET
		if ( Std.random(160) == 0 ) resetOffset();
		
		
		var prob = 300;
		if ( asp > 0.1 ) prob = Std.int(prob/(asp*8));
		
		if ( Std.random(prob) == 0  ) {
			
			var mc =  new gfx.Breath();
			breath.board.dm.add(mc, Board.DP_FX);
			var p = new mt.fx.Part(mc);
			p.setPos(x, y);
			p.vx = vx*0.2 + (Math.random() * 2 - 1) * 0.5;
			p.vy = vy*0.2 + (Math.random() * 2 - 1) * 0.5;
			p.timer = 30;
			p.fadeType = 2;
			p.fadeLimit = 20;
			p.frict = 0.95;
			p.weight -= 0.05 + Math.random() * 0.025;
			p.setScale(0.2 + Math.random() * 0.2);
			p.setAlpha(alpha);
		}
		
	}
	
	
//{
}