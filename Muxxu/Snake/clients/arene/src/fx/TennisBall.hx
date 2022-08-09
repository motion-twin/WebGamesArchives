package fx;
import mt.bumdum9.Lib;

class TennisBall extends Fx{//}

	static var SPEED = 6;
	var ball:Part;
	var timer:Int;
	
	public function new(n) {
		super();
	
		ball = Part.get();
		ball.sprite.setAnim(Gfx.fx.getAnim("tennis_ball"));
		Stage.me.dm.add(ball.sprite, Stage.DP_FX);
		
		var cr = 2;
		ball.x = sn.x + ball.vx*cr;
		ball.y = sn.y + ball.vy*cr;
		ball.z = -(3+n*3);
		ball.launch(sn.angle+(Game.me.seed.rand()*2-1)*(0.1+n*0.2), SPEED, -2);
		
		ball.weight = 0.2;
		ball.frictBounceZ = 0.82;
		ball.frictBounceXY = 0.95;
		ball.dropShade();
	
	}
	
	override function update() {
		super.update();
		
		
		// COLLIDE FRUITS
		var ray = 2;
		var rect = new flash.geom.Rectangle(ball.x - ray, ball.y - ray, ray, ray);
		for ( fr in Game.me.fruits ) {
			if( fr.hitTest2(rect,ball.z) ) {
				bounceFruit(fr);
				break;
			}
		}
		
		// COLLIDE SMILEY
		for( sm in Smiley.list ){
			var dx = ball.x - sm.sprite.x;
			var dy = ball.y - sm.sprite.y;
			var dif = Smiley.RAY - Math.sqrt(dx * dx + dy * dy);
			if( dif > 0 ) {
				var a = Math.atan2(dy, dx);
				a += (Game.me.seed.rand() * 2 - 1)*0.1;
				ball.x += Snk.cos(a) * dif;
				ball.y += Snk.sin(a) * dif;
				ball.launch(a, SPEED, -2);
				sm.collide();
			}
		}
		
		
		// SPEED
		var speed = Math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy);
		if( speed < 2 ) {
			if( timer-- == 0 ) 	kill();
			ball.sprite.visible = timer % 8 < 4;
		}else {
			timer = 30;
			ball.sprite.visible = true;
			
		}
		ball.shade.visible = ball.sprite.visible;
	
		
		
	}
	
	function bounceFruit(fr:Fruit) {
		

		
		// BOUNCE
		var a = Math.atan2(ball.x - fr.x, ball.y - fr.y);
		ball.launch(a, SPEED, -2);
		if( ball.vz < -2 ) ball.vz = -2;
		// FX
		var p = Stage.me.getPart("onde");
		p.x = fr.x;
		p.y = fr.y;
		
		// EAT
		fr.light = true;
		new FruitToTarget(fr, 10,sn);
		
	}
	
	override function kill() {
		super.kill();
		ball.kill();
	}

//{
}