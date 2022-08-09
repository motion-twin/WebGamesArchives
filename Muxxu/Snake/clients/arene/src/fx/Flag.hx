package fx;
import Protocole;
import mt.bumdum9.Lib;

class Flag extends CardFx {//}
	

	public var field:TF;
	public static var me:Flag;	
	public var score:mt.flash.Volatile<Int>;
	var step:Int;
	
	public function new(ca) {
		super(ca);
		me = this;
		

		
		field = Cs.getField(0xFFFFFF, 8, -1);
		
		card.gfx.illus.addChild(field);
		
		Filt.glow(field, 2, 4, 0);
		
		step = 0;
		
	}
	

	override function update() {
		super.update();
	
		if( step == 1 ) majScore();
		
	}

	
	public function bet() {
		score = Game.me.score;		
		majScore();
		card.removeAction();
		step = 1;
		card.fxUse();
	}
	
	public function majScore() {
		
		var sc = 2 * score-Game.me.score;		
		field.text = Std.string(sc);
		field.x = -Std.int(field.textWidth * 0.5);
		if ( sc < 0 ) {
			field.visible = false;
			card.flipOut();
			card.cash(score);
			kill();
		}

	}
	
	// KILL
	override function kill() {
		super.kill();
		me = null;
		field.parent.removeChild(field);
	}

	
//{
}












