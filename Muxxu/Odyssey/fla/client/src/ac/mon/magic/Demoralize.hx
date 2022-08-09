package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class Demoralize extends MagicAttack {//}
	


	public function new(agg,trg) {
		super(agg,trg);
		focusSequence = false;
	}

	override function start() {
		super.start();
		
		agg.folk.play("atk", impact, true );
		
		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		switch(step) {
			case 2 :
				if ( timer % 3 == 0 ) {
					var end = true;
					for ( h in Game.me.heroes ) {
						if ( h.board.breathes.length == 0 ) continue;
						h.board.damageBreath(1);
						end = false;
						
					}
					if ( end ) kill();
				}
				
		}
	}
	
	public function impact() {
		
		nextStep();
		

	}


	
//{
}


























