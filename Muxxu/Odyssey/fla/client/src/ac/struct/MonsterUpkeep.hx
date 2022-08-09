package ac.struct;
import Protocole;
import mt.bumdum9.Lib;



class MonsterUpkeep extends ac.Action {//}
	

	override function init() {
		super.init();		
		game.monster.onUpkeep();	
		onEndTasks = finish;
	}

	function finish() {
		add( new CheckDeath() );
		onEndTasks = kill;
	}
	
//{
}






