class Bonus {

	var game : Game;
	var id : int;
	var mc : MovieClip;
	var x : float;
	var y : float;
	var dx : float;
	var dy : float;

	function new(g,id) {
		game = g;
		this.id = id;
		mc = game.dmanager.attach("bonus",Const.PLAN_BONUS);
		mc._xscale = 50;
		mc._yscale = 50;
		mc.gotoAndStop(string(id+1));
	}

	function activate() {
		switch( id ) {
		case 0:
			game.flash(0x00FF00);
			game.blob_timer = 5;
			break;
		case 1:
			game.flash(0xFF0000);
			game.hero.super_grapin_time = 20;
			break;
		case 2:
			var i;
			var b = game.blobs.duplicate();
			for(i=0;i<b.length;i++)
				b[i].hit();
			game.flash(0x0000FF);
			game.hero.special();
			break;
		case 3:
			game.stats.$b++;
			game.flash(0xFFFFFF);
			KKApi.addScore(Const.C5000);
			break;
		}
	}

	function fall() {
		dx = 0;
		dy = 2;
		x = mc._x;
		y = mc._y;
		game.addUpdate(callback(this,update));
	}

	function update() {
		dy += 0.9 * Timer.tmod;
		y += dy * Timer.tmod;
		x += dx * Timer.tmod;

		var my = Const.MINY - 10;
		if( y > my ) {
			y = my * 2 - y;		
			dy *= -0.5;
			if( Math.abs(dy) < 1 ) {
				dy = 0;
				y = my;
			}
		}

		var dx = x - game.hero.x;
		var dy = y - game.hero.y;
		var d = Math.sqrt(dx*dx+dy*dy);
		if( d < 30 && !game.hero.died ) {
			activate();
			mc.removeMovieClip();
			return false;
		}

		mc._x = x;
		mc._y = y;
		return true;
	}

}