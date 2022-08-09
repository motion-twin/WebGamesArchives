package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;



class Earthquake extends ac.hero.MagicAttack {//}
	

	var pol:Int;

	public function new(agg,trg) {
		super(agg, trg);
		Scene.me.fadeTo(0xAA8800,0.05);
	}
	
	override function start() {
		super.start();
		pol = 1;
		spc = 0.005;
		
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		
		
		var delta = Math.pow( Math.sin(coef * 3.14), 4);
		
		if ( Game.me.gtimer%2 == 0 ){
			Scene.me.y = pol * delta * 8;
			pol *= -1;
		}
	
		if ( timer == 100 ) {
			var damage = 10;
			if ( agg.have(ELEMENTS_CONTROL) ) damage += damage>>1;
			trg.hit( { value:damage, types:[PHYSICAL,GROUND], source:cast agg } );
			
		}
		
		var freq = 10-Std.int(delta*9);
		
		if ( Std.random(freq) == 0 )
			Scene.me.fxGroundImpact(Std.random(Cs.mcw), 20, 6,3+delta*2);
		
		if ( coef == 1 ){
			Scene.me.fadeBack();
			kill();
		}

		
	}
	
	
	
//{
}


























