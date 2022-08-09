package ac.hero;
import Protocole;
import mt.bumdum9.Lib;




class ShuffleBoard extends Action {//}
	
	
	var hero:Hero;
	var balls:Array<Ball>;
	var turn:Float;

	public function new(hero) {
		super();
		this.hero = hero;
	}
	override function init() {
		super.init();
		balls = hero.board.balls.copy();
		turn = 0;
		spc = 0.025;
	}
	
	override function update() {
		super.update();
		
		turn += 0.02;
		
		switch(step) {
			
			case 0 : //CIRCLE
				var id = 0;
				for ( b in balls ) {
					var co = id / balls.length;
					b.updatePos();
					var cp = getCirclePos(co+turn, id);
					
					var dx = cp.x - b.x;
					var dy = cp.y - b.y;
					
					b.x += dx * coef;
					b.y += dy * coef;
					
					id++;
				}
				if ( coef == 1 ) distribute();
				
			case 1 :
				var id = 0;
				for ( b in balls ) {
					var co = id / balls.length;
					b.updatePos();
					var cp = getCirclePos(co + turn, id);
					
					var dx = cp.x - b.x;
					var dy = cp.y - b.y;
					
					var cc = Num.mm(0, 3 - ((1-co)+coef * 3),1);
					
					b.x += dx * cc;
					b.y += dy * cc;
					
					id++;
					
				}
				if ( coef == 1 ) kill();
			
		}
	}
	
	
	function getCirclePos(coef:Float, id:Int) {
		var a = coef * 6.28;
		var rx = hero.board.xmax * Ball.SIZE *0.5;
		var ry = hero.board.ymax * Ball.SIZE * 0.5;
		
		//var cr = 1 + Math.cos(coef * 6.28 * 5) * 0.2;
		var cr = 1 - (id % 4) * 0.15;
		
		return {
			x : rx + Math.cos(a) * rx*cr,
			y : ry + Math.sin(a) * ry*cr,
		}
	}
	
	function distribute() {
		nextStep(0.01);
		var pos = [];
		for ( ba in balls ) pos.push( { x:ba.px, y:ba.py } );
		Arr.shuffle(pos);
		for ( ba in balls ) {
			var p = pos.pop();
			ba.setPos(p.x, p.y);
		}
		update();
		
	}

	

	
	//
	


	
	
//{
}