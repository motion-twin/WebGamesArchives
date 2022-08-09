package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class Attack extends Action {//}
	
	var agg:Hero;
	var vic:Monster;
	
	var damage:Damage;
	
	public function new(agg,vic:Monster,value:Int,?types) {
		super();
		
		if ( types == null ) 	types = [PHYSICAL];
		this.agg = agg;
		this.vic = vic;
		
		damage = { types:types, value:value, source:cast agg };
		if ( Lambda.has(types, GROUND) && vic.have(FLYING) ) damage.value = 0;


	}
	override function init() {
		super.init();
		
		var anim = "atk";
		for ( dt in damage.types ) {
			switch(dt) {
				case  STEAL(k) :	anim = "steal";
				default :
			}
		}
		
		if ( Folk.FAKE )	hit();
		else				agg.folk.play(anim, hit, true);
		
	}
	
	
	function hit() {
		nextStep();
		
		var n = vic.hit(damage);
		vic.majInter();
		agg.majInter();
		
		if ( n > 0 ) { // ON DAMAGE
			
			if ( agg.have(FORCE_OF_NATURE) ) {
				add( new ac.hero.ForceOfNature(agg,vic));
			}
		
			for ( dt in damage.types ) {
				switch(dt) {
					case  STEAL(k) :
						add( new ac.hero.Steal(agg, vic, k) );
						add( new Fall(agg.board) );
						
					default :
				}
			}
		}
		
		if( vic.willRiposte(damage) ) add( new MonsterAttack(vic, agg, vic.getAttack() ) );
		
		
		
	}
	
	// UPDATE
	override function update() {
		super.update();
		switch(step) {
			case 0:
			case 1:
				if (timer > 20 && tasks.length == 0 ) kill();
		}
		
		
		
	}


	
	
//{
}