package fx;
import mt.bumdum9.Lib;
class StoneHero extends WorldFx{//}
	
	
	var step:Int;
	var stone:pix.Element;
	
	public function new() {
		super();
		
		stone = new pix.Element();
		stone.drawFrame(Gfx.hero.get(1, "hero_hurt"));
		stone.x = h.root.x;
		stone.y = h.root.y-5;
		new mt.fx.Blink( stone, 40, 4 , 4 );
		World.me.island.dm.add(stone, world.Island.DP_FX);
		
		h.sprite.anim = null;
		h.sprite.drawFrame(Gfx.hero.get(0, "hero_hurt"));
		
		//h.face();
		
		step = 0;
		coef = 0;
		
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				coef = Math.min(coef + 0.01, 1);
				if( coef == 1 ) {
					step++;
					coef = 0;
				}
			case 1 :
				coef = Math.min(coef + 0.05, 1);
				if( coef == 1 ) {
					h.face();
					stone.parent.removeChild(stone);
					kill();
					World.me.setControl(true);
					
					var max = 8;
					for( i in 0...max ) {
						var a = (i / max) * 6.28;
						var speed = Math.random() * 0.8;
						var p = new pix.Part();
						addElement(p);
						p.vx = Math.cos(a) * speed;
						p.vy = Math.sin(a) * speed;
						p.xx = stone.x + p.vx * 10;
						p.yy = stone.y + p.vy * 10;
						p.updatePos();
						p.weight = 0.05 + Math.random() * 0.05;
						p.timer = 10 + Std.random(8);
						p.frict = 0.95;
						p.drawFrame(Gfx.fx.get(Std.random(7), "grey_stones"));

					}
				}
				
		}
		
	}
	
	
	
//{
}








