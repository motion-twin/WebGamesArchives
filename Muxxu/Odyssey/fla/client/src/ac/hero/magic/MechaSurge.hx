package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;



class MechaSurge extends ac.hero.MagicAttack {//}
	


	
	override function start() {
		super.start();

		var ce = agg.folk.getCenter();
		
		var max = 64;
		var cr = 4;
		for ( i in 0...max ) {
			var a = (i / max) * 6.28;
			var speed = Math.random() * 4;
			var p = new mt.fx.Spinner(new fx.Drop(), 8 + Std.random(10));
			Scene.me.dm.add(p.root, Scene.DP_FX);
			p.vx = Math.cos(a) * speed;
			p.vy = Math.sin(a) * speed;
			
			p.fadeType = 2;
			p.timer = 10 + Std.random(40);
			p.twist(24, 0.95);
			p.setPos(ce.x + p.vx * cr, ce.y + p.vy * cr);
			Col.setColor(p.root, Col.getRainbow2(Math.random()));
			p.root.blendMode = flash.display.BlendMode.ADD;
			Filt.glow(p.root, 10, 2);
			
		}
		
		agg.hit( { value:5, types:[MAGIC], source:cast agg } );
		
		kill();
		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
	

		
	}
	
	//


	
//{
}


























