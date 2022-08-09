class Jama {

	var game : Game;
	var col : MovieClip;
	var tmp : MovieClip;
	var mc : {> MovieClip, sub : MovieClip }
	var x : float;
	var y : float;
	var t : int;
	var way : bool;
	var speed : float;
	var time : float;
	var sx : float;
	var sy : float;
	var hitUnder : bool;


	static var CIGOGNE = 0;
	static var BEE = 1;
	static var SANGLIER = 2;

	function new(g,p,t) {
		game = g;
		this.t = t;
		mc = downcast(game.dmanager.attach("jama",Const.PLAN_JAMA));
		mc.gotoAndStop(string(t+1));
		x = p.x;
		y = p.y;
		time = 0;
		sx = x;
		sy = y;
		way = (x > 0);
		init();
		mc._x = x;
		mc._y = y;
		game.entities.push(upcast(mc));
	}

	function init() {
		switch( t ) {
		case CIGOGNE:
			col = downcast(mc.sub).col;
			col._visible = false;
			if( way ) {
				mc._xscale = -100;
				x += 20;
			} else
				x -= 20;
			speed = 1 + 0.3 * game.level;
			break;
		case BEE:
			sx = (50 + Math.min(game.level,5) * 10);
			if( sy + sx > Const.MAXX )
				sy = Const.MAXX - sx;
			if( sy - sx < 0 )
				sy = sx;
			speed = 0.4 + 0.2 * game.level;
			if( way )
				mc._xscale = -100;
			break;
		case SANGLIER:
			y = Const.MAXY;
			sx = 0;
			speed = 8;
			mc.sub.stop();
			time = -2.7 + game.level * 0.15;

			tmp = game.dmanager.attach("prev",6);
			tmp._x = x + (way ? -20 : 20 );
			tmp._y = y - 10;

			if( way )
				mc._xscale = -100;
			else
				tmp._xscale = -100;


			break;
		}
	}

	function hit(hray) {

		if( game.hero.mc._name == null )
			return false;

		mc._x = x;
		mc._y = y;

		var b = ((col != null) ? col : upcast(mc)).getBounds(game.hero.mc);


		if( Const.DEBUG )
			game.drawBox(b,game.hero.mc._x,game.hero.mc._y);

		b.yMin += 20;
		b.yMax += 20;

		if( b.xMin * b.xMax > 0 ) {
			if( b.xMin < 0 ) {
				if( b.xMax < hray )
					return false;
			} else if( b.xMin > hray )
				return false;
		}


		if( b.yMin * b.yMax > 0 ) {
			if( b.yMin < 0 ) {
				if( b.yMax < hray )
					return false;
			} else if( b.yMin > hray )
				return false;
		}


		hitUnder = ((b.yMin + b.yMax) / 2 > 5);
		if( !hitUnder && Const.DEBUG )
			Log.trace((b.yMin + b.yMax) / 2);
		return true;
	}

	function remove() {
		game.entities.remove(upcast(mc));
		mc.removeMovieClip();
		return false;
	}

	function update() {
		var ret = true;
		time += Timer.deltaT;
		switch( t ) {
		case CIGOGNE:
			x += speed * Timer.tmod * (way?-1:1);
			if( hit(10) ) {
				if( hitUnder ) {
					var p = Math.abs(game.hero.jump_pow);
					p *= 0.7;
					p = Math.max(p,5);
					game.hero.jump_pow = p;
					game.hero.jump_time = true;
					game.hero.frame = 59;

					var d = game.dmanager.attach("FXFeather",Const.PLAN_JAMA+1);
					d._x = x;
					d._y = y;

					d = game.dmanager.attach("smoke",Const.PLAN_HERO);
					d._x = x;
					d._y = y;

					ret = remove();
				} else {
					if( Const.DEBUG ) {
						game.main = null;
						return false;
					}
					game.kill();
				}
			}
			if( x > 340 || x < -40 )
				ret = remove();
			break;
		case BEE:
			x += speed * Timer.tmod * (way?-1:1);
			y = Math.sin(time) * sx + sy;
			if( hit(5) )
				game.kill();
			if( x > 320 || x < -20 )
				ret = remove();
			break;
		case SANGLIER:
			if( time < 0 )
				break;
			tmp.removeMovieClip();
			sx += Timer.tmod;
			mc.sub.gotoAndStop(string( int(sx % mc._totalframes) + 1 ));
			x += speed * Timer.tmod * (way?-1:1);
			if( hit(10) )
				game.kill();
			if( x > 340 || x < -40 )
				ret = remove();
			break;
		}
		mc._x = x;
		mc._y = y;
		return ret;
	}

}
