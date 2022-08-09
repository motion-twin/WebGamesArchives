class Hero {

	var x : float, y : float;
	var game : Game;
	var mc : MovieClip;
	var a : float;
	var lock : bool;
	var moving : int;
	var gameOver : bool;

	var ty : float;
	var r : float;

	function new(g) {
		game = g;
		mc = game.dmanager.attach("hero",Const.PLAN_HERO);
		a = 0;
		x = 25;
		y = 150;
		mc._x = x;
		mc._y = y;
		r = Std.random(4) + 3;
	}

	function action() {
		if( !lock ) {
			lock = true;
			moving = (x < 150)?1:-1;
			mc.gotoAndPlay("dard");
			game.last = null;
		}
	}

	function doGameOver() {
		gameOver = true;
		a = -1;
		mc.gotoAndStop("death");
	}

	function update(steps) {
		var dx = 20 / steps;
		var dy = ((moving != null) ? 5 : 10) / steps;

		if( gameOver ) {
			a += 0.03 * Timer.tmod;
			x += ((mc._xscale < 0)?-1:1) * Timer.tmod / 2;
			y += a * Timer.tmod;

			if( y > 280 ) {
				y = 280 - (y - 280);
				a = -Math.abs(a) * 0.8;
				r = Math.random() * 10 - 4;
			}

			mc._rotation +=	r * Timer.tmod;
			mc._x = x;
			mc._y = y;
			return;
		}

		if( Key.isDown(Key.UP) ) {
			y -= dy * Timer.tmod;
			if( y < 20 )
				y = 20;
		} else if( Key.isDown(Key.DOWN) ) {
			y += dy * Timer.tmod;
			if( y > 285 )
				y = 285;
		}
		if( moving != null ) {
			x += moving * dx * Timer.tmod;
			if( x > 275 || x < 25 ) {
				if( x > 275 )
					x = 275;
				else
					x = 25;
				mc._xscale = (x > 150)?-100:100;
				mc.gotoAndPlay("normal");
				moving = null;
			}
		} else {
			if( Key.isDown(Key.SPACE) || ( Key.isDown(Key.RIGHT) && x < 150 ) || ( Key.isDown(Key.LEFT) && x > 150 ) )
				action();
			else
				lock = false;
		}

		if( ty != null ) {
			var p = Math.pow((moving == null)?0.7:0.99,Timer.tmod);
			y = y * p + ty * (1 - p);
			if( Math.abs(ty-y) < 5 ) {
				y = ty;
				ty = null;
			}
			if( y < 20 )
				y = 20;
			else if( y > 285 )
				y = 285;
		}

		a += Timer.tmod / (10 * steps);
		var tx = x + Math.cos(a) * 5;
		var ty = y + Math.sin(a) * 5;
		var p = Math.pow(0.7,Timer.tmod);
		var x = mc._x * p + tx * (1 - p);
		var y = mc._y * p + ty * (1 - p);
		mc._x = x;
		mc._y = y;

		if( moving != null ) {
			var i;
			var r = Ballon.ray + 5;
			r = r*r;
			for(i=0;i<game.getBalsLength();i++) {
				var b = game.bals[i];
				dx = x - b.x + 12;
				dy = y - b.y + 10;
				if( dx*dx+dy*dy < r )
					game.getBallon(b);
			}
		}

	}

}