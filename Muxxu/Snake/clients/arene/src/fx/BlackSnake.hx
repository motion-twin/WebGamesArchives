package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

typedef BQPos = { x:Float, y:Float, h:Float };

class BlackSnake extends Fx {//}
	static var RAY = 			4;
	static var TURN_SPEED = 	0.08;

	var trgRank:Int;
	
	var an:Float;
	public var x:Float;
	public var y:Float;
	var speed:Float;
	var length:Float;
	var mcq:flash.display.Sprite;
	var trq:Array<BQPos>;
	var queue:Array<QRing>;
	
	//var timer:Int;
	var card:Card;

	public function new(ca) {
		card  = ca;
		super();
		
		x = stg.width -20;
		y = stg.height*0.5;

		trq = [];
		queue = [];
		speed = 1.5;
		an = -3.14;
		length = 50;
		//
		mcq = new flash.display.Sprite();
		stg.dm.add(mcq, Stage.DP_SNAKE);
		//
		//timer = 200;
	}
	
	override function update() {
	
		var trg = getTarget();
		if ( trg == null ) trg = seekTarget();
		if ( trg != null) {
			var dx = trg.x - x;
			var dy = trg.y - y;
			var ta  = Math.atan2(dy, dx);
			var da = Num.hMod( ta - an, 3.14);
			if ( da > TURN_SPEED ) 	an += TURN_SPEED;
			if ( da < -TURN_SPEED ) 	an -= TURN_SPEED;
		}
		
		x += Snk.cos(an) * speed;
		y += Snk.sin(an) * speed;
		trq.unshift( { x:x, y:y, h:0.0 } );
		if( trq.length > 50 ) trq.pop();
		
		testCols();
		
		draw();
		if ( !card.active ) vanish();

	}
	
	public function draw() {
		
		buildQueue();
		if (queue.length == 0) return;
		
		var gfx = mcq.graphics;
		gfx.clear();
		
		for( i in 0...2 ){
			var cur = queue[0];
			
			gfx.lineStyle(5, 0);
			var dy = 0.0;
			if ( i == 1 ) {
				gfx.lineStyle(1, 0x555555);
				dy = -1.5;
			}
			gfx.moveTo(cur.x, cur.y+dy);
			
			for ( i in 1...queue.length) {
				var ring = queue[i];
				gfx.lineTo(ring.x, ring.y+dy);
			}
		}
		
				
	}
	
	function buildQueue() {
	
		// BUILD
		queue = [];
		var parc = 0.0;
		var id = 0;
		var cur = trq[0];
		while (true) {
			var p = trq[id];
			var nx = p.x;
			var ny = p.y;
			var dx = cur.x - p.x;
			var dy = cur.y - p.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if ( parc + dist > length ) {
				var rdist = length - parc;
				var coef  = rdist / dist;
				nx = cur.x - coef * dx;
				ny = cur.y - coef * dy;
			}
			parc += dist;
			queue.push({x:nx,y:ny,size:1.0, pos:parc});
			cur = p;
			//
			id += 3;
			if ( id >= trq.length ) break;
			if ( parc >= length ) break;
		}
		
		// HEIGHT
		var lim = 10.0;
		var a = [];
		var ref = queue[Std.int(queue.length * 0.5)];
		if( sn.queue != null ){
			for ( q in sn.queue ) {
				var dx = q.x - ref.x;
				var dy = q.y - ref.y;
				if ( Math.sqrt(dx * dx + dy * dy) < length * 0.5 ) a.push(q);
			}
		}
		
		for ( q in queue ) {
			var dist  = lim;
			//var prev  = lim;
			for ( q2 in a ) {
				var dx = q2.x - q.x;
				var dy = q2.y - q.y;
				var n = Math.abs(dx) + Math.abs(dy);
				n = Math.sqrt(dx * dx + dy * dy);
				if ( n < dist ) {
					//prev = dist;
					dist = n;
				}
			}
			//dist = (dist + prev) * 0.5;
			
			var c = 1 - dist / lim;
			var c = Snk.sin(c * 1.57);
			q.y -= c * 8;
		}
		
		
		
	}
	
	function testCols() {
		// FRUITS
		for ( fr in Game.me.fruits ) {
			if ( fr.hitTest(x, y, 4) ) {
				fr.scoreCoef *= 0.5;
				fr.calCoef *= 0.5;
				fr.vitCoef *= 0.5;
				new fx.Eaten(fr,this);
				fr.kill();
			}
		}
		
		// WALL
		if ( !stg.isIn(x, y, RAY) ) death();
		
	}
	
	public function getTarget() {
		for ( fr in Game.me.fruits ) if ( fr.data.rank == trgRank ) return fr;
		return null;
	}
	public function seekTarget() {
		var min = 999.9;
		var fruit = null;
		for ( fr in Game.me.fruits ) {
			var dx = x - fr.x;
			var dy = y - fr.y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if ( dist < min ) {
				fruit = fr;
				min = dist;
				trgRank = fruit.data.rank;
			}
		}
		return fruit;
		
	}

	public function death() {
		if ( card.active ) card.flip();
	}
	public function vanish() {
		
		var ec = 4;
		for ( q in queue ) {
			for( i in 0...4 ){
				var p = Part.get();
				p.sprite.graphics.beginFill(0);
				p.sprite.graphics.drawCircle(0, 0, 2 + Math.random() * 2);
				p.weight = - Math.random() * 0.3;
				p.frict = 0.95;
				p.setPos( q.x + (Math.random() * 2.1) * ec, q.y + (Math.random() * 2.1) * ec );
				p.fadeType = 1;
				p.timer = 10 + Std.random(10);
				p.fadeLimit = 7;
				p.sleep = i;
				p.sprite.visible = false;
				stg.dm.add(p.sprite, Stage.DP_FX);
			}
			
		}
		kill();
	}
	
	override function kill() {
		if(mcq.parent!=null)mcq.parent.removeChild(mcq);
		super.kill();
		
	}
	
	
//{
}












