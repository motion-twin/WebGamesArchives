package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class Regeneration extends Action {//}
	
	
	var agg:Hero;
	var value:Int;
	var list:Array<BallType>;
	
	public function new(agg,n,?list) {
		if ( list == null ) list = [];
		this.agg = agg;
		this.value = n;
		this.list = list;
		
		super();
	}
	
	override function init() {
		var max =  agg.board.breathes.length;
		if ( value > max ) value = max;
		if ( value == 0 ) kill();
	}
	
	override function update() {
		super.update();
		
		switch(step) {
			case 0 :
				if ( agg.board.isBreathStable() ) nextStep();
			case 1 :
				if ( Game.me.gtimer % 4 == 0 ) {
					var bt = list.shift();
					agg.board.breathSpawn(1,bt);
					agg.majInter();
					if (--value == 0 ) kill();
					agg.folk.fxTwinkle(3, 0x88FF00);
				}
		}


	}


	
//{
}


























