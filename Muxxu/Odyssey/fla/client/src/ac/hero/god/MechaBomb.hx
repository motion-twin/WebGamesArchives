package ac.hero.god;
import Protocole;
import mt.bumdum9.Lib;



class MechaBomb extends ac.hero.God {//}
	

	
	override function start() {
		super.start();
		hero.board.breathSpawn(5, MECHA_CRYSTAL);
		
	}
	
	override function updatePrayer() {
		super.updatePrayer();
	
		if ( timer == 20 ) kill();
		
		
		
	}
	
	

	
	//
	


	
	
//{
}