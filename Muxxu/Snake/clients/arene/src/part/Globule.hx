package part;
import Protocole;
import mt.bumdum9.Lib;

// using Part;

class Globule extends Part
{//}
	static public var POOL:Array<Globule> = [];
	var qdx:Float;
	var qdy:Float;
	var sn:Snake;
	public var pos:Float;
	public var speed:Float;
	public var cr:Float;
	
	function new() {
		super();
		backPool = Globule.POOL;
		init();
	}
	override function init() {
		super.init();
		sn = Game.me.snake;
		pos = Math.random() * sn.length;
		speed = 0.5 + Math.random() * 4;
		timer = 30;
		cr = 3;
		
		var qa = Math.random() * 6.28;
		var qray = Math.random();
		qdx = Snk.cos(qa)*qray;
		qdy = Snk.sin(qa)*qray;
		
		updatePos();
	}
	public static function get() {
		if( Globule.POOL.length == 0 ) return new Globule();
		var p = Globule.POOL.pop();
		p.init();
		return p;
	}
	
	override function update() {
		
		pos += speed;
		if( pos < 0 || pos > sn.length ) {
			kill();
			return;
		}
		super.update();
		
	}
	
	override function updatePos() {
		var p = sn.getRingData(pos);
		x = p.ring.x + qdx * p.ring.size * Snake.QUEUE_RAY * cr ;
		y = p.ring.y + qdy * p.ring.size * Snake.QUEUE_RAY * cr;
		
		super.updatePos();
	}
	

	
	// using

//{
}












