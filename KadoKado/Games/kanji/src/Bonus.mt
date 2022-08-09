class Bonus {

	var game : Game;
	var mc : MovieClip;
	var t : int;
	var s : float;

	function new(g,p,t) {
		s = 5;
		game = g;
		this.t = t;
		mc = game.dmanager.attach("bonus",Const.PLAN_BONUS);
		mc._x = p.x;
		mc._y = p.y;
		mc.gotoAndStop(string(t+1));
		mc._xscale = s;
		mc._yscale = s;
		game.entities.push(mc);
	}

	function update() {
		if( s < 100 ) {
			s += Timer.tmod * 10;
			if( s >= 100 )
				s = 100;
			mc._xscale = s;
			mc._yscale = s;
		}

		var dx = game.hero.mc._x - mc._x;
		var dy = (game.hero.mc._y - 20) - mc._y;
		if( dx * dx + dy * dy < Const.BONUS_RAY2 ) {
			var p = game.dmanager.attach("FXVanish",Const.PLAN_HERO+1);
			p._x = mc._x;
			p._y = mc._y;
			game.entities.remove(mc);
			mc.removeMovieClip();
			game.getBonus(this);
			return false;
		}
			

		return true;
	}

}
