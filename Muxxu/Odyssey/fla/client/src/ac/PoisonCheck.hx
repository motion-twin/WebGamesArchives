package ac;
import Protocole;
import mt.bumdum9.Lib;



class PoisonCheck extends Action {//}
	
	
	var balls:Array<Ball>;


	override function init() {
		
		super.init();
		
		balls = [];
		for ( h in game.heroes ) {
			var max = h.numStatus(STA_POISON);
			if ( max == 0 ) continue;
			h.board.inter.show(STA_POISON);
		
			var a = h.board.getIcedBalls();
			if ( a.length > 0 ) {
				a = a.slice(0, max);
				balls = balls.concat(a);
				max -= a.length;
				if ( max == 0 ) continue;
			}
			
			var a = h.board.getRandomBalls( max, true );
			balls = balls.concat(a);
			
		}
		if( balls.length == 0 ) kill();
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				if ( balls.length > 0 ) {
					var b = balls.shift();
					if ( b.isFrozen() ) {
						b.blast();
					}else{
						b.explode();
					}
				}else {
					add( new Fall() );
					onEndTasks  = kill;
					nextStep();
				}
			case 1 :
				
				
			
		}
	}
	

	
//{
}


























