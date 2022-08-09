package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class Provoke extends MagicAttack {//}
	

	var impactTime:Null<Int>;
	
	public function new(agg,trg) {
		super(agg,trg);
		focusSequence = false;
	}
	override function start() {
		super.start();
		
		var anim = "atk";
		if ( agg.folk.haveAnim("provoke") ) {
			anim = "provoke";
			impactTime = 20;
		}
		
		agg.folk.play(anim, impact, true );	// "provoke"
		
		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		if ( step == 1 && impactTime != null && timer > impactTime ) impact();
		
	}
	
	public function impact() {
		nextStep();
		trg.armor = 0;
		trg.armorLife = 0;
		trg.majInter();
		
		var a = [SWORD, HAMMER, AXE];
		for ( b in trg.board.balls )
			if ( b.type == SHIELD ) {
				b.setType(a[Std.random(a.length)]);
				b.fxSpawn();
			}
				
		kill();

	}


	
//{
}


























