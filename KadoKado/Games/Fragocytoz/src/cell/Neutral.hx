package cell;

import mt.bumdum9.Lib;

class Neutral extends Cell{//}
	

	public function new(r) {
		super(r);
	}
	
	/*
	override function draw() {
		
		drawCircle(0x8888AA,0xAAAACC);
	}
	*/
	
	override function update() {		

		
		if( Std.random(200) == 0 && Math.sqrt(vx*vx+vy*vy) < Cell.IMPULSE ) {
			randomImpulse();
		}
		
		super.update();
	}	
	
//{
}





















