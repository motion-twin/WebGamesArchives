package fx;
import mt.bumdum9.Lib;

class Reduce extends Fx{//}


	public var quant:Float;
	public var spc:Float;
	
	public function new(q:Int, c) {
		super();
		quant = q;
		spc = c;
	}
	
	override function update() {
		super.update();
		quant -= spc;
		sn.length -= spc;
		if( sn.length < Snake.MINIMUM_LENGTH && !sn.dead ) sn.length = Snake.MINIMUM_LENGTH;
		
		var o = sn.getRingData(sn.length);
		var p = Stage.me.getPart("spark_onde");
		p.x = o.ring.x + Std.random(10) - 5;
		p.y = o.ring.y + Std.random(10) - 5;
		p.weight = -(0.1 + Math.random() * 0.1);
		if( quant <= 0 || sn.length == Snake.MINIMUM_LENGTH ) kill();
	}
	
	function spark() {
		
	}
	
		

//{
}