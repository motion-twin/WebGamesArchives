package fx;
import Protocole;
import mt.bumdum9.Lib;

class FruitJump extends CardFx {//}

	
	
	override function update() {
		super.update();
		
		if( Game.me.gtimer % 4 != 0 ) return;
		
		for( fr in Game.me.fruits ) {
			if( fr.z == 0 && Game.me.seed.random(20) == 0 ) {
				
				fr.launch( Game.me.seed.rand() * 6.28, Game.me.seed.rand() * 5, -(1 + Game.me.seed.rand() * 3));
				
				var p = Stage.me.getPart("onde_slow",Stage.DP_BG);
				p.x = fr.x;
				p.y = fr.y;
			
			}
		}
	}
	

	// Game.me.seed.rand()
	//RND()

	
	

		
	
//{
}
