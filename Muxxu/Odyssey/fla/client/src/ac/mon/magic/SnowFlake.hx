package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class SnowFlake extends MagicAttack {//}
	

	var flake:fx.SnowFlake;
	var ball:Ball;
	
	override function start() {
		super.start();
		
		
		
		ball = trg.board.getRandomBall();
		
		var a = agg.folk.getCenter();
		var b = ball.getGlobalPos();
		
		flake = new fx.SnowFlake();
		flake.x = a.x;
		flake.y = a.y;
		Filt.glow(flake, 10, 1.5, 0x00CCFF);
		flake.blendMode = flash.display.BlendMode.ADD;
		
		Game.me.dm.add(flake, Game.DP_FX);
		
		var move = new mt.fx.Tween(flake, b.x, b.y, 0.025);
		move.setSin( 80, 3.14);
		move.onFinish = impact;
		
		
	}
	
	//
	function impact() {
		flake.parent.removeChild(flake);
		
		
		if ( checkResistance()) {
			trg.fxAbsorb();
		}else {
			
			var a = ball.get4Nei();
			a.push(ball);
			for ( b in a )
				b.freeze();
			
				
			var pos = ball.getGlobalPos();
				
			var onde = new mt.fx.ShockWave(0, 100);
			onde.curveIn(0.5);
			onde.setPos(pos.x, pos.y);
			Game.me.dm.add(onde.root, Game.DP_FX);
		
		}
		
		
		end();
	}


	
//{
}


























