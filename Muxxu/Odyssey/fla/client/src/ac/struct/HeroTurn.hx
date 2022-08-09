package ac.struct;
import Protocole;
import mt.bumdum9.Lib;



class HeroTurn extends ac.Action {//}
	
	
	public var cons:Constraints;
	public var extra:Array<Constraints>;
	public static var current:HeroTurn;
	

	override function init() {
		super.init();
		current = this;
		extra = [];
		go();
		
	}
	public function go() {
		//trace("go");
		
		add( new UserChoice() );
		add( new ac.Fall() );
		add( new CheckDeath() );
		onEndTasks = end;
	
	}
	
	
	// EXTRA TURN
	public function extraTurn(?heroes, ?balls) {
		
		extra.push( { heroes:heroes, balls:balls } );
	}


	
	
	public function end() {


		for ( h in game.heroes ) {
			h.onEndTurn();
			h.majInter();
		}

		
		if ( extra.length > 0 ) {
			cons = extra.shift();
			go();
		}else {
			kill();
		}
		
	}


	
//{
}






