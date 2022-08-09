class Hero { //}

	static var S_WAIT = 0;
	static var S_MOVE = 1;
	static var S_JUMP = 2;

	var game : Game;
	var arrow : MovieClip;
	var mc : MovieClip;
	var x : float;
	var y : float;
	var frame : float;
	var way : int;
	var state : int;

	volatile var jump_pow : float;
	var jump_time : bool;
	volatile var jump_dx : float;

	function new( g ) {
		game = g;
		x = 150;
		state = S_WAIT;
		y = Const.MAXY;
		way = 1;
		jump_dx = 0;
		jump_pow = 0;
		frame = 0;
		arrow = game.dmanager.attach("arrow",5);
		mc = game.dmanager.attach("hero",Const.PLAN_HERO);
		mc.stop();
	}

	function main() {
		var speed = 5;
		var jspeed = 0.7;
		var maxpow = 25;


		jump_dx *= Math.pow(0.9,Timer.tmod);

		switch( state ) {
		case S_WAIT:
		case S_MOVE:

			if( Key.isDown(Key.LEFT) ) {
				if( state == S_WAIT )
					frame = 29;
				state = S_MOVE;
				way = -1;
				x -= Timer.tmod * speed;
			} else if( Key.isDown(Key.RIGHT) ) {
				if( state == S_WAIT )
					frame = 29;
				state = S_MOVE;
				way = 1;
				x += Timer.tmod * speed;
			} else {
				if( state == S_MOVE )
					frame = 40;
				state = S_WAIT;
			}

			if( Key.isDown(Key.UP) || Key.isDown(Key.SPACE) ) {
				jump_time = true;
				jump_pow = 4;
				jump_dx = (state == S_MOVE)?(way * speed):0;
				state = S_JUMP;
				frame = 58;

				var p = game.dmanager.attach("smoke",Const.PLAN_HERO);
				p._x = x;
				p._y = y;
			}

			break;
		case S_JUMP:

			if( Key.isDown(Key.LEFT) ) {
				way = -1;
				jump_dx -= Timer.tmod;
			} else if( Key.isDown(Key.RIGHT) ) {
				way = 1;
				jump_dx += Timer.tmod;
			}

			if( Key.isDown(Key.UP) || Key.isDown(Key.SPACE) ) {
				if( jump_time && jump_pow < maxpow ) {
					jump_pow *= Math.pow(1.4,Timer.tmod);
					if( jump_pow >= maxpow ) {
						jump_pow = maxpow;
						jump_time = false;
					}
				}
			} else
				jump_time = false;

			x += jump_dx * Timer.tmod / 1.5;
			if( !jump_time )
				jump_pow -= 1.2 * Timer.tmod;
			break;
		}


		y -= Timer.tmod * jspeed * jump_pow;


		if( y > Const.MAXY ) {
			jump_pow = 0;
			state = S_WAIT;
			frame = 94;
			y = Const.MAXY;
		}

		if( x < Const.MINX ) {
			x = Const.MINX;
			jump_dx *= -2;
		}

		if( x > Const.MAXX ) {
			x = Const.MAXX;
			jump_dx *= -2;
		}

		mc._x = x;
		mc._y = y;
		mc._xscale = 100;

		switch( state ) {
		case S_WAIT:
			frame += Timer.tmod;
			if( frame >= 94 ) {
				if( frame >= 106 )
					frame = 1;
			} else if( frame >= 40 ) {
				if( frame >= 46 )
					frame = Key.isDown(Key.DOWN)?59:1;
			} else if( Key.isDown(Key.DOWN) )
				frame = 59;
			else if( frame >= 25 )
				frame -= 24;
			break;
		case S_MOVE:
			frame += Timer.tmod;
			while( frame >= 36 )
				frame -= 3;
			break;
		case S_JUMP:
			frame += Timer.tmod;
			if( frame >= 73 && jump_pow > 0 )
				frame = 70;
			if( frame >= 93 )
				frame = 80;
			break;
		}

		mc.gotoAndStop(string(int(frame)));
		arrow._visible = (y < 0);
		arrow._x = x;

		if( Const.DEBUG )
			game.drawBox({ xMin : -10, yMin : -10, xMax : 10, yMax : 10 },x,y - 20);
	}

//{
}


