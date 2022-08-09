package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class QueueDeath extends Fx {//}
	
	var burning:Bool;
	var queue:Array<QRing>;
	var coef:Float;
	public var mcq:flash.display.Sprite;
	
	public function new(from,to) {
		super();
		coef = 0;
		mcq  = new flash.display.Sprite();
		Stage.me.dm.add(mcq, Stage.DP_SNAKE);
		
		var a = Game.me.snake.queue;
		queue = [];
		for ( p in a ) {
			if ( p.pos >= from  && p.pos <= to ) queue.push(p);
		}

		if (queue.length == 0) kill();
	}
	
	override function update() {
	
		coef = Math.min(coef +0.07,1);
		mcq.graphics.clear();
		Snake.drawQueue(queue, mcq.graphics, 1-coef);
		
		if ( burning ) {
			
			// COLOR QUEUE
			var col = 0;
			var lim = 0.2;
			if( coef < lim ){
				var c = 1 - coef / lim;
				col = Col.objToCol( { r:255, g:Std.int(c * 255), b:0 } );
			}else {
				var c = Math.max(1-((coef - lim) / (1 - lim))*2,0);
				col = Col.objToCol( { r:Std.int(255*c), g:0, b:0 } );
			}
			Col.setPercentColor( mcq, 1, col);
			
			// FLAMES
			var max = Std.int(Math.max(1, queue.length / 4));
			var ec = 4+(1-coef)*14;
			for ( i in 0...max ) {
				var ring = queue[Std.random(queue.length)];
				var p = stg.getPart("miniflame");
				p.x = ring.x + (Math.random() - 0.5) * ec;
				p.y = ring.y + (Math.random() - 0.5) * ec;
				p.weight = -0.1;
			}
		
		}
		
		if ( coef == 1 ) kill();
	}
	
	//
	public function setBurn() {
		burning = true;
	}
	
	//
	override function kill() {
		mcq.parent.removeChild(mcq);
		super.kill();
	}
		
	
	
//{
}












