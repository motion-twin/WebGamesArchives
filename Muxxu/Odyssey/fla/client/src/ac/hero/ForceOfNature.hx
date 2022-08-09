package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class ForceOfNature extends Action {//}
	
	static var CONVERSION = 3;

	var agg:Hero;
	var vic:Monster;
	var damage:Int;
	
	public function new(agg,vic) {
		super();
		this.agg = agg;
		this.vic = vic;
		
		damage = Std.int(agg.board.breathes.length / CONVERSION);
		if ( damage > 3 ) damage = 3;
	}
	override function init() {
		super.init();
		
	}
	
	
	// UPDATE
	override function update() {
		super.update();
		if ( damage == 0 ) {
			kill();
			return;
		}
			
		if ( Game.me.gtimer % 8 == 0 ) {
			agg.board.damageBreath(CONVERSION);
			vic.incLife( -1);
			vic.majInter();
			new mt.fx.Flash(vic.folk, 0.25, 0xFF0000);
			damage--;
		}

	}
	
	//
	


	
	
//{
}