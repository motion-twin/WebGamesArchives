package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class MorphAll extends Action {//}
	
	
	var hero:Hero;
	var aa:BallType;
	var swap:Array<BallType>;
	var balls:Array<Ball>;
	
	public function new(hero,a,?b:BallType,?list:Array<BallType>) {
		super();
		aa = a;	
		if ( list == null ) list = [];
		if ( b != null ) list.push(b);
		swap = list;
		this.hero = hero;
	}
	override function init() {
		super.init();
		balls = [];
		for ( b in hero.board.balls ) if ( b.type == aa ) balls.push(b);
		Arr.shuffle(balls);
	}
	
	override function update() {
		super.update();
		if( Game.me.gtimer%2 == 0 ){		
			if ( balls.length == 0 ) {
				kill();
			}else {
				var b = balls.pop();
				b.morph(swap[Std.random(swap.length)]);
			}
		}
		
		
	}
	
	

	
	//
	


	
	
//{
}