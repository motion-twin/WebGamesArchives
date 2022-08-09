package ac.mon.magic;
import Protocole;
import mt.bumdum9.Lib;



class StoneGaze extends MagicAttack {//}
	

	var star:fx.Star;
	var ball:Ball;
	
	override function start() {
		super.start();
				
		star = new fx.Star();
		Game.me.dm.add(star, Game.DP_FX);
		var pos = agg.folk.getCenter();
		star.x = pos.x;
		star.y = pos.y;
		
		
		ball = trg.board.getRandomBall();
		var pos  = ball.getGlobalPos();
		var move = new mt.fx.Tween(star, pos.x, pos.y, 0.035);
		move.curveInOut();
		move.setSin(80, -2);
		move.onFinish = impact;
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
			
		
	}
	
	public function impact() {
		star.parent.removeChild(star);
		
		if ( checkResistance() ) {
			trg.fxAbsorb();
		}else {
			ball.morph(STONE);
		}
		
		end();
	}
	
	
	
//{
}


























