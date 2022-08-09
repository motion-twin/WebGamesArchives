package fx;
import mt.bumdum9.Lib;

class Pillule extends Fx{//}


	var timer:Int;
	
	public function new( ) {
		super();
		timer = 70;
		
	}
	
	override function update() {
		Game.me.snake.boost = 3;
		
	
			

			
		//var n = Std.random(20);
		var max = 2;
		if( sn.length > 200 ) max++;
		if( sn.length > 600 ) max++;
		if( sn.length > 1000 ) max++;
		
		for( n in 0...max ){
			var o = sn.getRingData(Std.random(Std.int(sn.length)));
			if( o == null || o.ring == null ) continue;
			var p = part.Line.get();
			
			p.x = o.ring.x;
			p.y = o.ring.y;
			p.timer = 10 + Std.random(10);
			p.x += Std.random(10) - 5;
			p.y += Std.random(10) - 5;
			var a = o.a+3.14;
			var sp = Math.random() * 5;
			p.vx = Snk.cos(a) * sp;
			p.vy = Snk.sin(a) * sp;
			Filt.glow(p.sprite, 4, 1, 0x00FFFF);
			
			p.sprite.blendMode = flash.display.BlendMode.ADD;
		}
			
			
	
		
		if( timer-- == 0 ) kill();
	}

//{
}