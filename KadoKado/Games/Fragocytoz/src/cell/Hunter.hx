package cell;

import mt.bumdum9.Lib;

class Hunter extends Cell{//}
	

	public function new(r) {
		super(r);
		consume = true;
		sprite.env.gotoAndStop(2);
		sprite.noyau.gotoAndStop(2);
	}
	

	
	override function update() {		
		
		ia();
		super.update();	
	}

		
	
	
//{
}





















