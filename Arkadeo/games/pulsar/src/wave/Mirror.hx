package wave;
import Protocol;
import mt.bumdum9.Lib;


class Mirror extends fx.Wave {//}

	


	
	override function spawn(type) {
		
		var cx = Game.WIDTH >> 1;
		var cy = Game.HEIGHT >> 1;
				
		var dx = hero.x - cx;
		var dy = hero.y - cy;
		
		new fx.Spawn(type,cx-dx,cy-dy);
		
		
	}
	

	
	
//{
}












