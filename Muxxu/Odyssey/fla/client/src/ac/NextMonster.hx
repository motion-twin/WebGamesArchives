package ac;
import Protocole;
import mt.bumdum9.Lib;



class NextMonster extends Action {//}
	
	var firstMonster:Bool;
	
	public function new(first) {
		super();
		firstMonster = first;
	}
	override function init() {
		super.init();
		
		game.opp.lastLeave(spawn);

	
	}
	

	function spawn() {
		nextStep();
		game.nextMonster(firstMonster);
		var e = new mt.fx.Spawn(game.monster.pan, 0.1, true);
		e.onFinish = arrival;
		
		
		
	}
	
	function arrival() {
		nextStep();
		// ADAPTATION
		for ( h in Game.me.heroes ) if ( h.have(ADAPTATION) ) add( new ac.hero.Regeneration(h,2,[SWORD,SHIELD]));

	}


	override function update() {
		super.update();
		
		switch(step){
			case 0 :
			case 2 :
				if ( tasks.length == 0 ) kill();
				
		}
		
	}

	
	
//{
}