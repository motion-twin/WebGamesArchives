package fx;
import mt.bumdum9.Lib;
using mt.bumdum9.MBut;
import Protocol;

import api.AKApi;
import api.AKProtocol;

class GameOver extends mt.fx.Sequence {
	
	public function new() {
		super();
	}
	
	override function update() {
		super.update();
		var ball = Game.me.balls.pop();
		if( ball == null ) {
			kill();
			//AKApi.saveState();
			AKApi.gameOver(false);
		}else{
			ball.burst();
		}
	}
}
