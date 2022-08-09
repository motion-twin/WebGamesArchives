package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class Laser extends MagicAttack {//}
	

	var count:Int;
	var balls:Array<Ball>;

	public function new(mon,trg) {
		super(mon,trg);
		focusSequence = false;
	}
	
	override function start() {
		super.start();
		
		count = getMagicImpact(trg.board.balls.length >> 1);
		if ( count < 3 ) count = 3;
		
		agg.folk.play("laser",impact,true);
		
		
		balls  = trg.board.balls.copy();
		balls.sort(order);
		
	}
	
	function order(a:Ball, b:Ball) {
		if ( a.px * 100 + a.py > b.px * 100 + b.py ) return 1;
		return -1;
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
	
		switch(step) {
			case 2 :
				
				if ( count-->0 ) {
					var b = balls.pop();
					var a = b.slice(16);
					for ( p in a ) {
						p.vx = -Math.random() * 8;
						p.frict = 0.9;
						p.timer = 10 + Std.random(20);
						p.fadeType = 2;
					}
					
					
				}else {
					kill();
				}
				
		
		}

	}
	
	public function impact() {
		nextStep();
	}
	
	
	
//{
}


























