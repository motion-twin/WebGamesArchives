package panel;
import Protocole;
import mt.bumdum9.Lib;


class Debug extends flash.display.Sprite{//}
	
	var fields:Array<flash.text.TextField>;
	
	public function new() {
		super();
		
		fields = [];
		for( i in 0...3){
			var field = Cs.getField(0xFFFFFF, 8, -1, "nokia");
			field.text = "test";
			field.width = Cs.mcw;
			field.x = i * 60;
			addChild(field);
			fields.push(field);
		}
		
		
		addEventListener(flash.events.Event.ENTER_FRAME, update);
		Game.me.dm.add(this, 10);
		Filt.glow(this, 2, 12, 0x004400);
		y = Cs.mch - 12;
	}
	function update(e) {
		var i = 0;
		for( field in fields ) {
			switch(i) {
				case 0 :	field.text = "sprites : " + pix.Sprite.all.length;
				case 1 :	field.text = "parts : " + Game.me.parts.length;
				case 2 :	field.text = "fx : " + Game.me.effects.length;
			}
			i++;
		}
	}
	public function kill() {
		removeEventListener(flash.events.Event.ENTER_FRAME, update);
		parent.removeChild(this);
	}


	
	

//{
}









