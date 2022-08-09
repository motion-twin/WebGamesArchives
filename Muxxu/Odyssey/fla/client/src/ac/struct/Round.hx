package ac.struct;
import Protocole;
import mt.bumdum9.Lib;



class Round extends ac.Action {//}
	
	public var used:Array<SkillType>;
	public static var current:Round;
	
	public function new() {
		super();
		current = this;
		used = [];
		
		game.monster.summonSickness = false;
		
		
		// MAJ RUNES
		for ( h in Game.me.heroes ) h.majRunes();
		
		
		// INIT
		add( new HeroUpkeep() );
		add( new HeroTurn() );
		add( new HeroEndTurn() );
		
		add( new MonsterUpkeep() );
		add( new MonsterTurn() );
		
		onEndTasks = kill;
		
		//Main.log("--- NEW ROUND---");
		
	}
	

	//
	override function kill() {
		super.kill();
		
	}

	
//{
}






