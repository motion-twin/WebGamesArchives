import mb2.Const;

class mb2.BossPowFeu {

	var game : mb2.Game;
	var boss : mb2.BossSerpent;

	var time;
	var px,py;
	var mc;

	function BossPowFeu( g : mb2.Game, b ) {
		game = g;
		boss = b;
		init();
		update();
	}

	function init() {
		mc = game.dmanager.attach("FXFire",Const.DUMMY_PLAN);
		mc.flLoopv = true;
		mc._x = boss.x;
		mc._y = boss.y;
		time = 10 + random(10);
	}

	function update() {
		time -= Std.deltaT;
		if( time < 0 ) {
			mc.flLoopv = false;
			boss.powers.remove(this);
		}
		if( game.ball.hole_death || game.ball.clign_count > 0 || mc._currentframe < 16 )
			return;

		var dx = mc._x - game.ball.mc._x;
		var dy = mc._y - game.ball.mc._y;
		var d = Math.sqrt(dx * dx + (dy * dy) / 3);
		if( d < 15 ) {
			time = 0;
			game.ball.kill();
		}
	}

	function destroy() {
		time = 0;
	}

}