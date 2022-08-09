package ac.struct;
import Protocole;
import mt.bumdum9.Lib;



class CheckDeath extends ac.Action {//}
	

	override function init() {
		super.init();
		

		
		if ( game.monster.life == 0 )
			add( new ac.MonsterDeath(game.monster) );
			
		for ( h in game.heroes )
			if ( h.checkDeath() )
				add( new ac.HeroDeath(h) );
				
		onEndTasks = kill;
	}
	
	
	

	

	
//{
}






