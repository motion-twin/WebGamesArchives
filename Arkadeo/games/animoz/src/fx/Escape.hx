package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import api.AKApi;
import api.AKProtocol;
import Protocol;

class Escape extends mt.fx.Sequence 
{

	var ball:ent.Ball;
	var vx:Float;
	var acc:Float;
	var wait:Int;

	public var endJump : Void->Void;
	
	public function new(b:ent.Ball, wait = 0) 
	{
		super();
		ball = b;
		this.wait = wait;
	}
	
	function init() 
	{
		Game.me.dm.add(ball.root, Game.DP_ENTS_FLY);
		var e = new fx.TweenEnt(ball, Cs.WIDTH - (80 + Math.random() * 40), ball.y + (Math.random() * 2 - 1) * 40, 100);
		//e.addFx(SHAPE_COLOR(null));
		e.addFx(FLYING_PARTS);
		e.addFx(TWINKLE);
		e.addFx(UP_DOWN(ball));
		e.onFinish = run;
		//
		var e = new mt.fx.ShockWave(20, 50, 0.1);
		e.setPos(ball.root.x,ball.root.y);
		Game.me.dm.add(e.root, Game.DP_GROUND);
		//
		nextStep();
	}
	
	function run() 
	{
		if( endJump != null ) endJump();
		nextStep();
		acc = 0.2 + Math.random() * 0.7;
		vx = acc * 3;
		ball.bounce = true;
	}
	
	override function update() 
	{
		super.update();
		switch(step) 
		{
			case 0 :
				if( timer > wait ) init();
			case 2 :
				ball.x += vx;
				ball.updatePos();
				vx += acc;
				if ( ball.x  > Cs.WIDTH + Cs.SQ ) 
				{
					if ( AKApi.getGameMode() == GM_PROGRESSION )
					{
						AKApi.setProgression( Math.min(AKApi.getScore() / Game.me.scoreObjective.get(), 1) );
					}
					ball.kill();
					kill();
				}
		}
	}
}
