class Hero {

	static var NORMAL = 0;
	static var FALLING = 1;
	static var JUMPING = 2;
	static var DEATH = 3;

	static var A_WALK = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
	static var A_BEC = [58,59,60,61,62,63,64];
	static var A_FACE = [20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35];
	static var A_CREUSE = [58,59,60,61,62,63,64];
	static var A_DEATH = [78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103];

	var game : Game;
	var mc : MovieClip;
	var anim : Array<int>;
	var frame : float;
	var sx : float;
	volatile var x : float;
	volatile var y : float;
	var state : int;
	var moving : bool;
	var key_time : float;
	var death : MovieClip;

	function new( g, px, py ) {
		game = g;
		key_time = 0;
		mc = game.dmanager.attach("hero",Const.PLAN_HERO);
		state = NORMAL;
		anim = A_WALK;
		frame = 0;
		x = (px + 0.5) * Const.BLOCK_SIZE;
		y = py * Const.BLOCK_SIZE;
	}	

	function kill(bx,by) {
		if( state == DEATH )
			return;
		var px = int(x/Const.BLOCK_SIZE);
		var py = int(y/Const.BLOCK_SIZE);
		if( bx == px && by == py ) {
			state = DEATH;
			death = game.dmanager.attach("FXFeather",Const.PLAN_PART);
			death._x = mc._x;
			death._y = mc._y;
			mc.removeMovieClip();
		}
	}

	function animDone() {
		if( anim == A_BEC ) {
			frame += 3;
		}
		if( anim == A_CREUSE && state == JUMPING ) {
			var px = int(x/Const.BLOCK_SIZE);
			var py = int(y/Const.BLOCK_SIZE);
			game.genParts(px,py+1,0,-1);
			game.getBonus(px,py+1);
			game.level.tbl[px][py+1] = Level.EMPTY;
			game.update = true;
			game.stats.$c++;
			moving = true;
			anim = A_FACE;
			frame = 0;
			state = NORMAL;
		}
		if( anim == A_DEATH )  {
			anim = A_WALK;
			mc.removeMovieClip();
			KKApi.gameOver(game.stats);
		}
	}

	function update() {

		if( death != null ) {
			if( death._name == null )
				KKApi.gameOver(game.stats);				
			return;
		}

		var dx = 0;
		var s = Const.BLOCK_SIZE;
		var speed = 5;

		if( state == NORMAL ) {
			if( Key.isDown(Key.LEFT) ) {
				anim = A_WALK;
				moving = true;
				mc._xscale = -100;
				dx = -1;
			} else if( Key.isDown(Key.RIGHT) ) {
				anim = A_WALK;
				moving = true;
				mc._xscale = 100;
				dx = 1;
			} else if( Key.isDown(Key.DOWN) && key_time <= 0 ) {				
				var py = int(y/s);
				var px = int(x/s);
				var l = game.level.tbl[px][py+1];
				if( l == Level.EARTH ) {
					anim = A_CREUSE;
					frame = 0;
					state = JUMPING;
					animDone();
				} else if( l == Level.BLOCK ) {
					if( anim != A_BEC ) {
						anim = A_BEC;
						frame = 0;
					}
					game.doCasse(px,py+1);
				} else if( l == Level.BLOCKSPE ) {
					if( anim != A_BEC ) {
						anim = A_BEC;
						frame = 0;
					}
					if( game.diff > 0 )
						game.deltaLife(-Timer.tmod);
				}
				moving = true;
			} else
				key_time -= Timer.deltaT;
		}

		frame += Timer.tmod;
		if( frame >= anim.length ) {
			frame %= anim.length;
			animDone();
		}

		switch( state ) {
		case NORMAL:
			if( !moving ) {
				anim = A_WALK;
				frame = 0;
				break;
			}
			var x2 = x + dx * speed * Timer.tmod;
			var px = int(x/s);
			var px1 = int(x2/s - 0.3);
			var px2 = int(x2/s + 0.3);
			var py = int(y/s);
			var ok = true;

			if( px1 < px )
				px1 = px - 1;
			if( px2 > px )
				px2 = px + 1;

			if( dx <= 0 )
			switch( game.level.tbl[px1][py] ) {
			case Level.EARTH:
				game.genParts(px1,py,1,0);
				game.getBonus(px1,py);
				game.level.tbl[px1][py] = Level.EMPTY;
				game.update = true;
				break;
			case Level.BLOCKSPE:
			case Level.BLOCK:
				ok = false;
				break;
			}

			if( dx >= 0 )
			switch( game.level.tbl[px2][py] ) {
			case Level.EARTH:
				game.genParts(px2,py,-1,0);
				game.getBonus(px2,py);
				game.level.tbl[px2][py] = Level.EMPTY;
				game.update = true;
				break;
			case Level.BLOCKSPE:
			case Level.BLOCK:
				ok = false;
				break;
			}

			if( ok )
				x = x2;
			else {
				// recal
				var nx = (((dx < 0)?(px1 + 1.5):(px2 - 0.5))) * s;
				if( dx < 0 )
					x = Math.min(x,nx);
				else
					x = Math.max(x,nx);
			}

			px = int(x/s - 0.3 * dx);
			if( game.level.tbl[px][py+1] == Level.EMPTY ) {
				sx = x;
				x = (px + 0.5) * s;
				state = FALLING;
			}
			break;

		case FALLING:

			if( sx != null ) {
				var p = Math.pow(0.5,Timer.tmod);
				sx = sx * p + x * (1 - p);
				if( Math.abs(sx - x) < 1 )
					sx = null;
			} else
				y += 8 * Timer.tmod;
			var px = int(x/s);
			var py = int(y/s);
			if( game.level.tbl[px][py+1] != Level.EMPTY ) {
				y = py * s;
				state = NORMAL;
			}
			break;
		}

		if( x < 0 )
			game.changeLevel(-1,0);
		else if( x >= 300 )
			game.changeLevel(1,0);
		else if( y >= 290 ) {
			y = 290;
			game.changeLevel(0,1);
		}

		var px = int(x/s);
		var py = int(y/s);
		var i;

		mc._yscale = 100;
		if( state == NORMAL )
			for(i=0;i<game.falls.length;i++) {
				var f = game.falls[i];
				if( f.x == px && f.y + 1 == py ) {
					mc._yscale = 100 * (y - f._y) / 30;
				}
			}

		mc._x = (sx != null)?sx:x;
		mc._y = y + s;
		mc.gotoAndStop(string(anim[int(frame)]));
		moving = false;
	}

}
