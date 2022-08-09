package ac.hero.god;
import Protocole;
import mt.bumdum9.Lib;



class Bud extends ac.hero.God {//}
	

	var num:Int;

	override function start() {
		super.start();
		num = 2;
	}
	
	override function updatePrayer() {
		super.updatePrayer();
	
		switch(step) {
			case 1:
				nextStep(0.1);
			case 2:
				if ( coef >= 1 ) {
					coef--;
					for ( h in game.heroes )
						add( new ac.hero.Regeneration(h, 1) );
						//add(new ac.hero.incBreath(h, 1));
					
					if ( num-- == 0 )
						kill();
				}
		}
		
		
	}
	
	

	
	//
	


	
	
//{
}