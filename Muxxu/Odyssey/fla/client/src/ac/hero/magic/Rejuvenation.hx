package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class Rejuvenation extends ac.hero.MagicAttack {//}
	

	
	public function new(agg) {
		super(agg);
		Scene.me.fadeTo(0x006644,0.05);
	}
	
	override function start() {
		super.start();


		agg.addStatus(STA_REJUVENATION);
		agg.majInter();
		
		//kill();
	}
	
	override function updateSpell() {
		super.updateSpell();
		
		var ec = Math.ceil(timer*0.1);
		if ( timer % ec == 0 )
			new mt.fx.Flash(agg.folk, 0.5, 0x88FF00);

		if ( timer == 50 ) {
			Scene.me.fadeBack();
			kill();
		}
		
	}
	

	



	
//{
}


























