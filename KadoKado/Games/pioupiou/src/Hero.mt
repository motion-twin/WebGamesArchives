class Hero { //}

	static var FALLING = 0;
	static var NORMAL = 1;
	static var CLIMB_LEFT = 2;
	static var CLIMB_RIGHT = 3;
	static var END_CLIMB_LEFT = 4;
	static var END_CLIMB_RIGHT = 5;
	static var DEATH = 6;

	var game : Game;
	var mc : MovieClip;
	var death_mc : MovieClip;
	var flRun:bool;
	var x : float;
	var y : float;
	var r : float;
	var state : int;
	var sens : int;
	var frame : float;
	var death_time : float;

	function new( g ) {
		game = g;
		state = NORMAL;
		x = 150;
		y = 200;
		r = 0;
		sens = 1;
		frame = 0;
		flRun = false;
		mc = game.dmanager.attach("hero",Const.PLAN_HERO);
		mc.stop();
	}

	function scrollUp() {
		y += Const.BLK_HEIGHT;
	}

	function getPos() {
		return game.level.getPos(x,y+Const.BLK_HEIGHT-1);
	}

	function recal(x,y) {
		if( x != null )
			this.x = x * Const.BLK_WIDTH + Const.DELTA_X;
		if( y != null )
			this.y = (game.level.base_y - y) * Const.BLK_HEIGHT + Const.DELTA_Y;
	}

	function tbl(x,y) {
		return game.level.tbl[x][y];
	}

	function climbFalling(p) {
		if( tbl(p.x,p.y) == null )
			return;
		var b = game.level.getFalling(p.x,p.y+1);
		if( b == null )
			b = game.level.getFalling(p.x,p.y);
		if( b != null && !Std.hitTest(b.mc,mc) )
			return;
        r = 0;
		state = FALLING;
	}

	function death() {
		if( state == DEATH )
			return;
		mc._yscale = 100;
		mc._visible = false;
		state = DEATH;
		death_time = 1;
		death_mc = game.dmanager.attach( "FXFeather",Const.PLAN_FX );
		death_mc._x = mc._x;
		death_mc._y = mc._y;
	}

	function main() {

		var climb_speed = 8;
		var fall_speed = 20;

		var p = getPos();

		var minX = p.x * Const.BLK_WIDTH + Const.DELTA_X + 10;
		var maxX = (p.x + 1) * Const.BLK_WIDTH + Const.DELTA_X - 10;

		if( p.x == 0 )
			minX += 9;
		else if( p.x == Const.LVL_WIDTH-1 )
			maxX -= 9;

		if( p.x > 0 && tbl(p.x-1,p.y) == null )
			minX -= Const.BLK_WIDTH;
		if( p.x < Const.LVL_WIDTH - 1 && tbl(p.x+1,p.y) == null )
			maxX += Const.BLK_WIDTH;

		if( state == CLIMB_LEFT || state == CLIMB_RIGHT || state == END_CLIMB_LEFT || state == END_CLIMB_RIGHT )
			climbFalling(p)

		flRun = false;
		switch(state) {
		case NORMAL:
			if( tbl(p.x,p.y-1) == null ) {
				if( Key.isDown(Key.LEFT) )
					x -= 5 * Timer.tmod;
				else if( Key.isDown(Key.RIGHT) )
					x += 5 * Timer.tmod;
				state = FALLING;
				break;
			}
			if( Key.isDown(Key.LEFT) ) {
				sens = -1;
				flRun = true;
				r = Math.max(-5,r-1*Timer.tmod)
				if( x > minX ) {
					x -= 5 * Timer.tmod;
					if( x <= minX )
						x = minX;
				} else if( p.x > 0 && mc._yscale >= 100 ) {
					r += 20 * Timer.tmod;
					if( r >= 20 )
						state = CLIMB_LEFT;
				}
			} else if( Key.isDown(Key.RIGHT) ) {
				sens = 1;
				flRun = true;
				r = Math.min(r+1*Timer.tmod,5)
				if( x < maxX ) {
					x += 5 * Timer.tmod;
					if( x >= maxX )
						x = maxX;
				} else if( p.x < Const.LVL_WIDTH - 1 && mc._yscale >= 100 ) {
					r -= 20 * Timer.tmod;
					if( r <= -20 )
						state = CLIMB_RIGHT;
				}
			} else
				r = 0;
			break;
		case FALLING:
			var i;
			for(i=0;i<10;i++) {
				y += fall_speed / 10 * Timer.tmod;
				p = getPos();
				if( tbl(p.x,p.y) != null ) {
					recal(null,p.y+1);
					state = NORMAL;
					break;
				}
			}
			break;
		case CLIMB_LEFT:
			sens = -1;
			if( tbl(p.x,p.y) == null && tbl(p.x,p.y+1) == null && Key.isDown(Key.LEFT) ) {
				flRun = true;
				r += 5 * Timer.tmod;
				if( r >= 80 )
					r = 80;
				y -= climb_speed * Timer.tmod;
			} else {
				r = 0;
				state = FALLING
			}
			p = getPos();
			if( tbl(p.x-1,p.y) == null ) {
				recal(null,p.y);
				state = END_CLIMB_LEFT;
			}
			break;
		case END_CLIMB_LEFT:
			r -= 10 * Timer.tmod;
			if( r <= 0 ) {
				r = 0;
				x -= 11;
				state = NORMAL;
			}
			break;
		case CLIMB_RIGHT:
			sens = 1;
			if( tbl(p.x,p.y) == null && tbl(p.x,p.y+1) == null && Key.isDown(Key.RIGHT) ) {
				flRun = true;
				r -= 5 * Timer.tmod;
				if( r <= -80 )
					r = -80;
				y -= climb_speed * Timer.tmod;
			} else {
				r = 0;
				state = FALLING;
			}
			if( tbl(p.x+1,p.y) == null ) {
				recal(null,p.y);
				state = END_CLIMB_RIGHT;
			}
			break;
		case END_CLIMB_RIGHT:
			r += 10 * Timer.tmod;
			if( r >= 0 ) {
				r = 0;
				x += 11;
				state = NORMAL;
			}
			break;
		case DEATH:
			death_time -= Timer.deltaT;
			if( death_time < 0 )
				KKApi.gameOver(game.data);
			break;
		}

		//
		mc._xscale = sens * 100;
		if( flRun )
			frame = (frame+Timer.tmod*2)%16;
		else
			frame = 0;
		mc.gotoAndStop(string(Math.round(frame+1)))
		//

		p = getPos();
		var k = tbl(p.x,p.y);
		if( k != null ) {
			var b = game.level.getFalling(p.x,p.y+1);
			if( b == null )
				death();
			else
				mc._yscale = 100 - b.dy * 100 / Const.BLK_HEIGHT;
		} else {
			mc._yscale += 10 * Timer.tmod;
			if( mc._yscale >= 100 )
				mc._yscale = 100;
		}

		switch( state ) {
		case CLIMB_LEFT:
		case END_CLIMB_LEFT:
			mc._x = x - 8;
			break;
		case CLIMB_RIGHT:
		case END_CLIMB_RIGHT:
			mc._x = x + 8;
			break;
		default:
			mc._x = x;
			break;
		}
		mc._y = y + Const.BLK_HEIGHT;
		mc._rotation = r;
	}



//{
}


