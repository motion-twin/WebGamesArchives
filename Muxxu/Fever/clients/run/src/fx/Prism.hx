package fx;

class Prism extends mt.fx.Fx{//}
	
	
	var iceCube:pix.Element;
	

	public function new() {
		super();
		var inter = world.Inter.me;
		inter.setFreeze(true);
		inter.cleanName();
		
		iceCube = inter.getLastIceCube();
				
	}
	
	override function update() {
		
		iceCube.x += 8;
		
		
		for( i in 0...1 ) {
			var p = getDust();
			p.setPos( iceCube.x - Std.random(8), iceCube.y);
			
		}
		
		var lim = world.Inter.me.lrx - 16;
		
		if( iceCube.x > lim ) {
			// FX
			new mt.fx.Flash(World.me.screen);
			
			// SPARKS
			var max = 16;
			for( i in 0...max ) {
				var p = getDust();
				p.xx = lim + ((i / max) * 2 - 1) * 20;
				p.yy = 2 + Std.random(12);
				p.vy = 0;
				p.updatePos();
			}
			
			// MAJ

			world.Inter.me.majStatus();
			
			//
			world.Inter.me.setFreeze(false);
			//
			kill();
		}
		
	}
	
	function getDust() {
		var p = new pix.Part();
		p.setAnim(Gfx.fx.getAnim("spark_twinkle"));
		
		p.vy = - Math.random()*2;
		p.frict = 0.95;
		p.weight = 0.05 + Math.random() * 0.1;
		p.timer = 12 + Std.random(8);
		p.anim.gotoRandom();
		World.me.dm.add(p, 8);
		return p;
	}
	

	
	
//{
}








