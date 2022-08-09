package fx;
import Protocole;
import mt.bumdum9.Lib;

//private typedef Move = { folk:Folk, tw:Tween, spc:Float };

class Burn extends mt.fx.Fx {//}
	
	

	var ball:fx.BurnBall;
	var wind:Float;
	var rot:Float;
	
	public function new(b:Ball,wind=0.0,rot=90) {
		super();		
		b.kill();
		
		var pos = b.board.getGlobalBallPos(b.px, b.py);
		this.wind = wind;
		this.rot = rot;
		
		ball = new fx.BurnBall();
		ball.x = pos.x + 10;		
		ball.y = pos.y + 10;		
		Game.me.dm.add(ball, Game.DP_FX);
		
	}

	
	// UPDATE
	override function update() {
		super.update();
		
		var max = 1 + Math.round(coef * 3);
		for( i in 0...max ){
			coef = Math.min(coef + 0.1, 1);
			var mc = new FxHoriFlame() ;
			var p = new mt.fx.Part( mc );
			Game.me.dm.add(mc, Game.DP_FX);
			var a = Math.random() * 6.28;
			var ray = Math.random() * 10;
			p.setPos(ball.x + Math.cos(a) * ray, ball.y + Math.sin(a) * ray);
			p.vx = wind*(0.5+Math.random());
			p.timer = 10;
			p.setScale((1 - coef)*0.6);
			p.root.rotation = rot;
			p.weight = - 0.02 - Math.random() * 0.1;
		}
		
		ball.scaleX = ball.scaleY = (1 - coef) * 0.75;
		ball.rotation = Std.random(360);
		
		if ( coef == 1 ) {
			ball.parent.removeChild(ball);
			kill();
		}
		
	}
	
	

	
	
//{
}