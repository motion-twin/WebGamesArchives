package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class FireSword extends ac.hero.MagicAttack {//}
	

	
	public function new(agg) {
		super(agg);
		Scene.me.fadeTo(0xAA6600,0.05);
	}
	
	override function start() {
		super.start();

		for ( h in game.heroes ) {
			h.addStatus(STA_FIRE_SWORD);
			h.majInter();
		}
		Scene.me.fadeBack(0.02);
	}
	
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		var ec = Math.ceil(timer*0.1);
		if ( timer % ec == 0 )
			for ( h in game.heroes )
				new mt.fx.Flash(h.folk, 0.5, 0xFF8800);
		
		
		
		if ( timer == 50 )
			kill();
		
	}
	
	



	
//{
}


























