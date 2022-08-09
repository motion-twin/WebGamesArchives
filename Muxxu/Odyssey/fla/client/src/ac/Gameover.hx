package ac;
import Protocole;
import mt.bumdum9.Lib;



class Gameover extends Action {//}
	
	
	override function init() {
		super.init();
		
	}
	
	// UPDATE
	override function update() {
		super.update();
		if ( timer == 20 ) game.end(false);
	}


	
	
//{
}