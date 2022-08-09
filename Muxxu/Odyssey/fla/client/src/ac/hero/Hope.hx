package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class Hope extends Action {//}
	
	var hero:Hero;
	var work:Array<Ball>;
	
	public function new(hero) {
		super();
		this.hero = hero;
	
		
	}
	override function init() {
		super.init();
		work = [];
		
		var hope = null;
		for ( b in hero.board.balls ) if ( b.type == BURNING_HOPE ) hope = b;
		
		for ( b in hero.board.balls ) {
			if ( !b.isFrozen() ) continue;
			work.push(b);
			var dx = b.x - hope.x;
			var dy = b.y - hope.y;
			b.temp = Math.sqrt(dx * dx + dy * dy);
			
		}
		work.sort(order);
		work = work.slice(0, 5);
		if (work.length == 0 ) kill();
		
	}
	
	function order(a:Ball, b:Ball) {
		if ( a.temp < b.temp ) return -1;
		return 1;
	}
	
	// UPDATE
	override function update() {
		super.update();
		
		if ( timer > 6 ) {
			timer = 0;
			var ball = work.shift();
			ball.blast();
			if ( work.length == 0 ) kill();
		}
		
		
	}
	
	//
	


	
	
//{
}