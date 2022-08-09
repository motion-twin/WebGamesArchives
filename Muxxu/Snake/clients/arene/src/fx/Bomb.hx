package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Bomb extends Fx {//}
	
	static var RAY_MAX = 100;
	
	var coef:Float;
	var step:Int;
	var bomb:pix.Sprite;	
	
	public function new() {		
		super();		
		bomb = new pix.Sprite();
		bomb.setAnim(Gfx.fx.getAnim("bomb"));
		Stage.me.dm.add( bomb, Stage.DP_SNAKE);
		//bomb.x = Std.int(Game.me.snake.x);
		//bomb.y = Std.int(Game.me.snake.y);	
		
		var p = Stage.me.getRandomPos(20, 40);
		
		bomb.x = p.x;
		bomb.y = p.y;
		
		step = 0;
		coef = 0;
	}
	
	override function update() {
		
		switch(step) {
			case 0 :
				coef = Math.min(coef + 0.02, 1);
				if ( coef == 1 ) explode();
				
			case 1 :
			
				var ec = 20;
				var count = 20;
				while ( true ) {
					var inc = ec / ray;
					while ( an < 6.28 && count>0 ) {
						var p = Stage.me.getPart("burn");
						var dx = Snk.cos(an);
						var dy = Snk.sin(an);
						var sp = 1;
						var sp = (ray / 100) * 4;
						p.frict = 0.9;
						p.x = bomb.x + dx * ray;
						p.y = bomb.y + dy * ray;
						p.vx = dx*sp;
						p.vy = dy*sp;
						an += inc;
						count--;
					}
					if ( count == 0 ) break;
					ray += 12;
					an = 0;
				}
				// COLS
				checkCols();
				
				// END
				if ( ray > RAY_MAX ) {
					bomb.kill();
					kill();
				}
			
		}
	}
	
	var ray:Float;
	var an:Float;
	function explode() {
		step = 1;
		bomb.visible = false;	
		ray = 10;
		an = 0;
	}
	
	var cut:Null<Float>;
	function checkCols() {
		
		// FRUITS
		for (  fr in Game.me.fruits ) {
			var dx = fr.x - bomb.x;
			var dy = fr.y - bomb.y;
			if ( Math.sqrt(dx * dx + dy * dy) < ray ) {				
				fr.fxBurn();
				fr.kill();
			}
		}
		
		// SNAKE
		var sn = Game.me.snake;
		var first = true;
		var newCut:Null<Float> = 0;
		for ( ring in sn.queue ) {
			var dx = ring.x - bomb.x;
			var dy = ring.y - bomb.y;
			if ( Math.sqrt(dx * dx + dy * dy ) < ray ) {
				if ( first ) {
					sn.burn();
				}else{
					var q = sn.cut( sn.length - ring.pos );
					q.setBurn();
					//Col.setPercentColor(q.mcq, 1, 0);
				}
				break;
			}			
			first = false;
		}
		

	}


		
	
//{
}












