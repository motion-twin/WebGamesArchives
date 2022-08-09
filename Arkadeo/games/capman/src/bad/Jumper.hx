package bad;
import mt.bumdum9.Lib;
import Protocol;

class Jumper extends ent.Bad {

	var cooldown:Int;
	var slide:Int;
	var dec:Int;
	
	public function new() {
		bid = 3;
		super();
		
		jumper = true;
		spc = 0.045;
		free = 3;
		hunter = 3;
		uturn = true;
		
		cooldown = 0;
		jumpSpeed = 0.03;
		skin.play("jumper_base");
		dec = 0;
	}
	
	override function updatePos() {
		super.updatePos();
		var d = Cs.DIR[(dir + 1) % 4];
		root.x += d[0] * dec;
		root.y += d[1] * dec;
		if( shade != null ) {
			shade.x = root.x;
			shade.y = root.y + 10;
		}
	}
	
	override function update() {
		super.update();
		
		cooldown--;
		switch(step) {
			case SPECIAL :
				if( cooldown == 0 ) {
					jumper =  false;
					cooldown = 70;
					seekDir();
					step = MOVE;
					skin.play("jumper_base");
				}
			case JUMPING :
			default :
				dec = Math.round(Math.sin(moveCoef * 6.28));
				jumper = cooldown <= 0;
		}
	}
	
	override function onStartJump() {
		skin.play("jumper_jump");
	}
	
	override function onEndJump() {
		step = SPECIAL;
		cooldown = 15;
		skin.play("jumper_land");
	}
}

