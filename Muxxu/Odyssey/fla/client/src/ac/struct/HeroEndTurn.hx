package ac.struct;
import Protocole;
import mt.bumdum9.Lib;



class HeroEndTurn extends ac.Action {//}
	

	override function init() {
		super.init();
		
		for ( h in game.heroes ) {
			h.board.onEndTurn();
		}
		add( new ac.hero.ShieldMove() );
		
		onEndTasks = kill;
		
	}


	
//{
}






