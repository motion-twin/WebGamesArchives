package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import api.AKApi;
import api.AKProtocol;
import fx.TweenEnt;
import Protocol;
import mt.kiroukou.math.MLib;

using mt.Std;
class Exit extends mt.fx.Sequence {

	var ball:ent.Ball;
	var vx:Float;
	var acc:Float;
	var wait:Int;

	public function new(b:ent.Ball, wait=0) {
		super();
		ball = b;
		this.wait = wait;
	}
	
	function init() {
		Game.me.dm.add(ball.root, Game.DP_ENTS_FLY);
		
		var e = new fx.TweenEnt(ball, Cs.WIDTH + 40, ball.y + (Math.random() * 2 - 1) * 40, 0, 10 );
		e.addFx(SHAKE(1));
		
		e.onFinish = kill;
		
		nextStep();
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				if( timer > wait ) init();
			case 1 :
				if( Std.random(4) == 0 ) {
					var particles = [gfx.FlowerParticle, gfx.HeartParticle, gfx.RainbowParticle, gfx.GrassParticle];
					particles.shuffle();
					var partClass = particles.first();
					//
					var ec = 10;
					var p = new mt.fx.Part( cast(Type.createEmptyInstance(partClass), flash.display.MovieClip) );
					p.setPos( ball.root.x + (Math.random() * 2 - 1) * ec, ball.root.y + (Math.random() * 2 - 1) * ec );
					p.timer = 30 + Std.random(15);
					p.weight = (0.05 + Math.random() * 0.1);
					p.fadeType = 1;
					p.setScale(.3 + .3 * Math.random());
					
					p.vr = MLib.frandRangeSym(5);
					p.rfr = 0.95;
					p.vx = MLib.frandRangeSym(5);
					p.vy = MLib.frandRange( -.1, -1.5);
					p.frict = 0.95;
					Game.me.dm.add(p.root, Game.DP_FX);
				}
		}
	}
	
	override function kill() {
		ball.kill();
		super.kill();
	}
}
