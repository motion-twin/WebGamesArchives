class Tir {

	var game : Game;
	var mc : MovieClip;
	var fromMonster : bool;
	var x : float;
	var y : float;
	var dx : float;
	var dy : float;
	var pow : int;

	function new(g,t,x,y,dx,dy) {
		game = g;
		pow = 1;
		fromMonster = (t != 0);
		this.x = x;
		this.y = y;
		this.dx = dx;
		this.dy = dy;
		mc = game.dmanager.attach("tir",Const.PLAN_TIR);
		mc.gotoAndStop(string(t+1));
		mc._x = x;
		mc._y = y;
		mc._rotation = Math.atan2(dy,dx) * 180 / Math.PI;
	}

	function update() {
		x += dx * Timer.tmod;
		y += dy * Timer.tmod;
		mc._x = x;
		mc._y = y;

		if( fromMonster ) {
			if( Std.hitTest(game.hero.mc.col,mc) )
				game.gameOver();
		} else {
			var i;
			var l = game.monsters;
			for(i=0;i<l.length;i++) {
				var m = l[i];
				if( Std.hitTest(m.mc.sub.col,mc) ) {
					m.touched(this);
					mc.removeMovieClip();
					return false;
				}
			}
		}

		if( x < -10 || y < -10 || x > 310 || y > 310 ) {
			mc.removeMovieClip();
			return false;
		}
		return true;
	}

}