package ac;
import Protocole;
import mt.bumdum9.Lib;



class MonsterAttack extends Action {//}
	
	var agg:Monster;
	var victims:Array<{trg:Hero,damage:Damage}>;

	var playAnim:Bool;
	
	public function new(agg, ?vic:Hero, ?vics:Array<Hero>, value:Int, ?types, playAnim = true ) {
		super();
		this.playAnim = playAnim;
		
		if ( types == null ) 	types = [PHYSICAL];
		this.agg = agg;
		if ( vics == null  ) vics = [vic];
		
		//
		if ( agg.have(VENOM) ) 		types.push(POISON);
		if ( agg.have(PETRIFY) ) 	types.push(STONER);
		if ( agg.have(ACID_ATK) ) 	types.push(ACID);
		
		victims = [];
		for ( trg in vics ) {
			var dam = { types:types, value:value, source:cast agg };
			victims.push( { trg:trg, damage:dam } );
		}
		
	}
	
	override function init() {
		super.init();
			
		if ( !playAnim || Folk.FAKE )	 hit();
		else							agg.folk.play("atk", hit, true);
		
		
		
		for ( o in victims )
			if ( o.trg.haveStatus(STA_DODGE) )
				o.trg.folk.play("dodge",null,true);
	}
	
	function hit() {
		nextStep();
		
		for ( o in victims ) {
			
			if ( o.trg.haveStatus(STA_DODGE) ) {
				o.trg.removeStatus(STA_DODGE);
				continue;
			}
			
			var n = o.trg.hit(o.damage);
					
			for (type in o.damage.types) {
				switch(type) {
					case DRAIN :
						agg.regenerate(n);
					default :
				}
			}
			
			// THORNS
			if ( o.trg.have(THORNS) ) agg.incLife( -1);
			
			// CONVERSION
			if ( o.trg.have(CONVERSION) && n > 0 && o.trg.board.balls.length > 0 ) 	add( new ac.hero.Regeneration(o.trg, 1, [FLOWER]));
			
			o.trg.majInter();
			agg.majInter();
			
		}
		
	}


	
	
	// UPDATE
	override function update() {
		super.update();

		switch(step) {
			case 0:
			case 1:
				if (timer > 20 && tasks.length == 0 ) kill();
		}
		//
		
		
		
	}


	
	
//{
}