package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Pin extends CardFx {//}
	
	
	var pins:Array<pix.Element>;
	var timer:Int;
	
	public function new(ca) {
		super(ca);
		pins = [];
		timer = 0;
	}
	

	override function update() {
		
		timer++;
		
		var seed = new mt.Rand(Game.me.seedNum);
		
	
		var n = 30;
		var sn = Game.me.snake;
		var id = 0;
		
		while( n < sn.length ) {
			
			if( id == pins.length ) {
				var sp = new pix.Element();
				sp.drawFrame(Gfx.fx.get(Std.random(2),"pin"));
				Stage.me.dm.add(sp, Stage.DP_SNAKE);
				pins.push(sp);
			}
			
			var sp = pins[id];
			var o = sn.getRingData(n);
			
			sp.x = Std.int(o.ring.x);
			sp.y = Std.int(o.ring.y - o.ring.size*3);
			sp.visible = sn.isRingIn(o.ring);
			
			id++;
			n += 10+seed.random(50);
		}
		
		//trace(id);
		while( pins.length > id ) pins.pop().kill();
		
		//
		if(timer%10==0) Game.me.incFrutipower( -0.05 );
		
		
		super.update();
		
		
	}
	

	override function kill() {
		while( pins.length > 0 ) pins.pop().kill();
		super.kill();
	}

	
//{
}












