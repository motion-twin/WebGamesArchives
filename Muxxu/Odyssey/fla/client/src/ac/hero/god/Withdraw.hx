package ac.hero.god;
import Protocole;
import mt.bumdum9.Lib;



class Withdraw extends ac.hero.God {//}
	
	override function start() {
		super.start();
	
		var first = game.getFirst();
		game.heroes.unshift( game.heroes.pop() );
		
		for ( h in game.heroes )
			add( new MoveBack(h.folk) );
		
		game.majPanels(true);
		
		
	}
	
	override function updatePrayer() {
		super.updatePrayer();
		if ( tasks.length == 0 )
			kill();
		
	}
	
	

	
	//
	


	
	
//{
}