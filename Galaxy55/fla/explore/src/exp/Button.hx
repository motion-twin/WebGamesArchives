package exp;

class Button implements haxe.Public {
	var man			: Manager;
	var spr			: flash.display.Sprite;
	var padding		: Int;
	
	var over		: Bool;
	var clickStarted: Bool;
	var active		: Bool;
	
	var onOver		: Void->Void;
	var onOut		: Void->Void;
	var onClick		: Void->Void;
	
	public function new(s:flash.display.Sprite) {
		man = Manager.ME;
		spr = s;
		padding = 0;
		active = true;
		
		over = clickStarted = false;
		onOver = onOut = onClick = function() {}
	}
	
	function registerStageClick(down:Bool) {
		if( !active )
			return;
		if( down )
			if( over )
				clickStarted = true;
			else
				clickStarted = false;
		else
			if( over && clickStarted )
				onClick();
			else
				clickStarted = false;
	}
	
	public function update(pt) {
		if( !active )
			return;
		var rect = spr.getBounds(man.buffer.container);
		if( padding!=0 )
			rect.inflate(padding, padding);
		if( !over && rect.contains(pt.x, pt.y) ) {
			over = man.root.useHandCursor = man.root.buttonMode = true;
			onOver();
		}
		if( over && !rect.contains(pt.x, pt.y) ) {
			over = man.root.useHandCursor = man.root.buttonMode = false;
			onOut();
		}
	}
}
