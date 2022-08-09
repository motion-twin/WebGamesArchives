package ac.mon;
import Protocole;
import mt.bumdum9.Lib;


class PoisonBreath extends Action {//}
	

	public var agg:Monster;
	public var trg:Hero;

	
	public function new(agg,trg) {
		super();
		this.agg = agg;
		this.trg = trg;
	}
	
	override function init() {
		super.init();
		
		var anim = "atk";
		if ( agg.folk.haveAnim("poison") ) 	anim = "poison";
		agg.folk.play(anim, impact, true );

	}
	


	
	public function impact() {
		for ( h in game.heroes ) {
			h.addStatus(STA_POISON);
			h.majInter();
		}
		kill();
	}


//{
}






