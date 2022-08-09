class Hero {

	var game : Game;
	var mc : {> MovieClip, sub : MovieClip };
	var grapin : Grapin;
	var died : bool;
	var x : float;
	var y : float;
	var dx : float;
	var dy : float;
	var frame : float;
	var moving : bool;
	var acc : float;
	var dir : int;
	var lock : bool;
	volatile var super_grapin_time : float;
	var death_timer : float;

	function new(g) {
		frame = 0;
		acc = 0;
		dir = 1;
		super_grapin_time = 0;
		lock = false;
		died = false;
		game = g;
		mc = downcast(game.dmanager.attach("hero",Const.PLAN_HERO));
		mc.stop();
		x = Const.WIDTH / 2;
		y = Const.MINY;
	}

	function kill() {
		dy = -10;
		dx = (x < Const.WIDTH / 2)?2:-2;
		died = true;
		death_timer = 1.5;
		frame = 0;
		mc.gotoAndStop("7");
	}

	function hit() {
		var i;
		var hx = x;
		var hy = y - mc._height / 3;
		var r = 8;
		for(i=0;i<game.blobs.length;i++) {
			var b = game.blobs[i];
			var dx = b.x - hx;
			var dy = b.y - hy;
			var d = Math.sqrt(dx*dx+dy*dy);
			if( d < b.size / 2.4 + r ) {

				x = b.x;
				y = b.y;
				kill();
				b.mc._xscale = 50;
				b.mc._yscale = 50;
				b.size = 50;

				var e = game.dmanager.attach("animExplose",Const.PLAN_BLOB);
				e._x = b.x;
				e._y = b.y;
				e._xscale = 50;
				e._yscale = 50;
				b.setColor(e);

				b.bonus.mc.removeMovieClip();
				b.bonus = Std.cast(this);				
				break;
			}
		}
	}

	function special() {
		frame = 0;
		mc.gotoAndStop("6");
		moving = false;
		lock = true;
	}

	function update() {

		if( super_grapin_time > 0 )
			super_grapin_time -= Timer.deltaT;

		frame += Timer.tmod;
		switch( mc._currentframe ) {
		case 2:
			if( frame >= mc.sub._totalframes )				
				frame -= (mc.sub._totalframes - 4);
			break;		
		}

		if( grapin != null ) {
			if( !grapin.update() )
				grapin = null;
		} else if( Key.isDown(Key.SPACE) && !died && !lock )  {
			grapin = new Grapin(game);
			if( !grapin.update() )
				grapin = null;
			frame = 0;
			moving = false;
			mc.gotoAndStop("4");
		}

		if( died ) {
			if( death_timer > 0 ) {
				death_timer -= Timer.deltaT;
				if( death_timer <= 0 )
					KKApi.gameOver(game.stats);
			}
			mc.sub.gotoAndStop(string(1+(int(frame)%mc.sub._totalframes)));
			return;
		}

		if( !lock ) {
			if( Key.isDown(Key.LEFT) ) {
				if( !moving ) {
					moving = true;
					frame = 0;
					mc.gotoAndStop("2");
				}
				dir = -1;
				if( acc > 0 )
					acc = 0;
				acc -= 1 * Timer.tmod;				
				if( acc < -5 )
					acc = -5;
			} else if( Key.isDown(Key.RIGHT) ) {
				if( !moving ) {
					moving = true;
					frame = 0;
					mc.gotoAndStop("2");
				}
				dir = 1;
				if( acc < 0 )
					acc = 0;
				acc += 1 * Timer.tmod;
				if( acc > 5 )
					acc = 5;
			} else {
				acc *= Math.pow(0.8,Timer.tmod);
				if( moving ) {
					moving = false;
					frame = 0;
					mc.gotoAndStop("3");
				}
			}
			x += acc * Timer.tmod;
		}


		if( moving ) {
			// nothing
		} else if( mc._currentframe == 2 )
			mc.gotoAndStop("1");
		else if( mc._currentframe >= 3 && frame >= mc.sub._totalframes ) {
			lock = false;
			acc = 0;
			mc.gotoAndStop("1");
		}

		mc._xscale = dir * 100;

		mc.sub.gotoAndStop(string(1+(int(frame)%mc.sub._totalframes)));

		if( x <= 30 )
			x = 30;
		else if( x >= Const.WIDTH - 20 )
			x = Const.WIDTH - 20;

		if( game.blob_timer <= 0 )
			hit();

		var dy = Math.max(0,Math.sin(x * Math.PI / 17)) * 3;

		mc._x = x;
		mc._y = y - dy;
	}

}