package ac.hero.god;
import Protocole;
import mt.bumdum9.Lib;



class Trident extends ac.hero.God {//}
	
	static var DIST = 200;
	var trident:fx.Trident;

	var trg:Monster;
	var vibe:Int;
	
	override function start() {
		super.start();
		
		trident = new fx.Trident();
		trident.x = -200;
		Scene.me.dm.add(trident, Scene.DP_UNDER_FX);
		trident.rotation = 45;
		trg = game.monster;

		spc = 0.1;
		vibe = 1;

	}
	
	override function updatePrayer() {
		super.updatePrayer();
	
		switch(step) {
			case 1:
				var cc = 1 - coef;
				trident.x = trg.folk.x-DIST*cc;
				trident.y = trg.folk.y - DIST * cc;
				if ( coef == 1 ) {
					var damage = trg.life >> 1;
					trg.hit({ value:damage, types:[PHYSICAL], source:cast game.heroes[0] });
					nextStep(0.05);
					Scene.me.fxGroundImpact(trg.folk.x, 30, 8, 3, 3);
					Scene.me.fxShake();
				}
			
			case 2:
				trident.rotation = 45 + (1 - coef) * 6 * vibe;
				vibe *= -1;
				//if ( timer % 2 == 0) vibe *= -1;
				if ( coef == 1 )
					nextStep(0.1);
				
			case 3:
				trident.alpha = 1 - coef * 1;
				if ( coef == 1 ) {
					trident.parent.removeChild(trident);
					nextStep();
				}
			case 4 :
				if ( timer == 20 )
					kill();
			
		}
	
		
	}
	
	
	
//{
}