class Bg {

	var game : Game;

	var bg : MovieClip;
	var bg1 : MovieClip;
	var bg2 : MovieClip;

	var pos_x : float;
	var pos_y : float;

	function new( g ) {
		game = g;
		bg = game.dmanager.attach("bg2",Const.PLAN_BG);
		bg1 = game.dmanager.attach("bg1",Const.PLAN_BG);
		bg2 = game.dmanager.attach("bg0",Const.PLAN_BG);
		bg.onMouseMove = callback(game,onMove);
		bg.onPress = callback(game,press,true);
		bg.onRelease = callback(game,press,false);
		bg.onReleaseOutside = callback(game,press,false);
		bg.useHandCursor = false;
		KKApi.registerButton(bg);
		pos_x = 0;
		pos_y = 0;
	}

	function update(dx) {
		var maxy = Const.MAXY - 300;
		var py;
		if( game.hero.py < 110 )
			py = 0;
		else if( game.hero.py > 210 )
			py = maxy;
		else
			py = maxy - (210 - game.hero.py) * maxy / 100;
		var p = Math.pow(0.95,Timer.tmod);
		pos_y = pos_y * p + py * (1 - p);
		pos_x -= dx * 2;
		if( bg2._alpha != 100 || Timer.tmod > 1.3 ) {
			bg2._alpha -= 10 * Timer.tmod;
			if( bg2._alpha <= 0 )
				bg2.removeMovieClip();
		}
		bg._x = - pos_x % (bg._width / 2);
		bg1._x = - (pos_x * 1.5) % (bg1._width / 2);
		bg2._x = - (pos_x * 1.5 * 1.5) % (bg2._width / 2);
		game.mc._y = -pos_y;
		game.mc._y = -pos_y;
	}

}