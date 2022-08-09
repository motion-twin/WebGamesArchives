package fx;
import mt.bumdum9.Lib;
class Teleport extends mt.fx.Fx{//}
	
	
	var h:world.Hero;
	var step:Int;

	
	public function new() {
		super();
		h = World.me.hero;
		h.sprite.setAnims( Gfx.hero.getAnims(["hero_sorcery", "hero_sorcery_loop"]) );
		
		step = 0;
		coef = 0;
	}
	
	override function update() {
		super.update();
	
		switch(step) {
			case 0 :
				coef = Math.min(coef + 0.025, 1);
				if( coef == 1 ) {
					step++;
					coef = 0;
				}
			case 1 :
				coef = Math.min(coef + 0.05, 1);
				var c = Math.pow(coef,0.5);
				Col.setColor(World.me.screen,0,Std.int(255*c));
				if( coef == 1 ) swap();
			case 2 :
				coef = Math.min(coef + 0.05, 1);
				var c = 1-Math.pow(coef, 2);
				Col.setColor(World.me.screen, 0, Std.int(255 * c));
				if( coef == 1 ) {
					World.me.setControl(true);
					kill();
				}
				
		}
		
	}
	
	function swap() {
		
		var p = world.Loader.me.data._savePoint;
		var island = new world.Island(p._x, p._y );
		island.attachOcean();
		World.me.dm.add(island, World.DP_MAP);
		World.me.island.kill();
		World.me.island = island;
		h.swapToIsland(island);
					

		for( nsq in island.statueSquare.rnei ) {
			if( nsq.ent == null ) {
				h.setSquare(nsq);
				break;
			}
		}
		
		h.face();
		new fx.HeroSpark();
		
		// GLOW
		var a = [h.root, island.statueSquare.ent];
		for( mc in a ) {
			if( mc == null ) continue;
			var fx = new mt.fx.Flash(mc, 0.01);
			fx.glow(2, 4);
		}
		
		//
		step++;
		coef = 0;
	}


	
	
//{
}








