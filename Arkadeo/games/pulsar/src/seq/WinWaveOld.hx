package seq;
import mt.bumdum9.Lib;


class WinWave extends mt.fx.Sequence {//}
	
	var x:Float;
	var y:Float;
	var rayMax:Float;
	
	//var list:Array<Bad>;
	
	public function new() {
		super();
		//Game.me.step = 1;
		rayMax = Math.sqrt(Game.WIDTH * Game.WIDTH + Game.HEIGHT * Game.HEIGHT);
		x = Game.me.hero.x;
		y = Game.me.hero.y;
		
		//
		//
		flash.ui.Mouse.show();
		
		// BADS

		

	}
	
	function sortDist(a:Bad, b:Bad) {
		if ( a.dist < b.dist ) return -1;
		return 1;
	}

	
	
	override function update() {
		super.update();
		
		
		//Game.me.hero.update();
		
		switch(step) {
			case 0 :
				if (timer == 2) {
					startBlast();
				}
				
			case 1 :
				
				// LIST
				var list = [];
				for ( b in Game.me.bads ) {
					var dx = b.x - x;
					var dy = b.y - y;
					b.dist = Math.sqrt(dx * dx + dy * dy);
					list.push(b);
				}
				list.sort(sortDist);
			
				// ONDE
				var ray = rayMax * Math.pow(coef, 3);
				
				while( list.length>0 && list[0].dist < ray) {
					list.shift().explode();
				}
				
				// PARTS
				var mc = new SP();
				mc.graphics.lineStyle(ray*0.15, 0xFFFF00);
				mc.graphics.drawCircle( x, y, ray );
				Game.me.plasma.draw(mc);
				
				/*
				var max = Std.int((ray * 6.28)/20);
				for ( i in 0...max) {
					var a = coef * 100 + (i * 6.28 / max);
					var el = new EL();
					el.x = x + Math.cos(a) * ray;
					el.y = y + Math.sin(a) * ray;
					el.pxx();
					el.play("border_impact",false);
					el.anim.onFinish = el.kill;
					Game.me.dm.add(el, 1);
				}
				*/
				
				
				
				if ( coef == 1 ) {
					nextStep();
					kill();
				}
			
			case 2 :
				
				
		}
	
		
	}
	
	public function startBlast() {
		nextStep(0.02);
		coef = 0.2;

		
	}


	
	
//{
}












