package fx;
import Protocole;
import mt.bumdum9.Lib;

class NotPlayable extends mt.fx.Fx {//}
	

	var board:Board;
	var msg:TF;
	var timer:Int;
	
	public function new(b) {
		super();
	
		board = b;
		msg = Cs.getField();
		board.dm.add(msg, 10);
		msg.text = "aucun coup disponible !";
		msg.width = msg.textWidth + 4;
		msg.x = (board.mcw - msg.width)*0.5;
		msg.y = board.mch * 0.5 - 8;
		Filt.glow(msg, 2, 4, 0);
		timer = 0;
		
		var a = [STA_CLOCK, STA_PACIFISM, STA_PACIFISM_2, STA_BOW_RELOAD];
		for ( sta in a ) board.inter.show(sta);
		
		
	}

	
	// UPDATE
	override function update() {
		super.update();
		msg.visible = timer++ % 8 >= 2;
		if ( timer > 50 ) {
			msg.parent.removeChild(msg);
			kill();
		}
		
	}
	


	
	
//{
}