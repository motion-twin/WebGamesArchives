package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class Recycle extends ac.hero.MagicAttack {//}
	

	
	public function new(agg) {
		super(agg);
		Scene.me.fadeTo(0x006644,0.05);
	}
	
	override function start() {
		super.start();

		var n = 8;
		agg.board.breathSpawn(n);
		Scene.me.fadeBack();
		//add( new ac.Fall(agg.board) );
		kill();
	}
	
	/*
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		if ( tasks.length == 0 )
			kill();
	
		
	}
	*/
	



	
//{
}


























