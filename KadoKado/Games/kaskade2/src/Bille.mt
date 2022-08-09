class Bille {

	static var COS = Math.cos(Math.PI/4);
	static var SIN = Math.sin(Math.PI/4);

	static var INV_COS = Math.cos(-Math.PI/4);
	static var INV_SIN = Math.sin(-Math.PI/4);

	var mc : MovieClip;
	var star : MovieClip;
	var id : int;
	var group : Array<Bille>;
	var px : float;
	var py : float;

	var gx : float;
	var gy : float;

	function new(game : Game,px,py) {
		mc = game.dmanager.attach("bille",Const.PLAN_BILLE);
		star = downcast(mc).star;	
		if( game.nlevels == Const.MAXCOLORS )		
			id = Const.MAXCOLORS-1;
		else
			id = game.random(game.nlevels);
		mc.gotoAndStop(string(id+1));
		mc._xscale = 0;
		mc._yscale = 0;
		setPos(px,py);
		activate(false);
	}

	function setPos(x,y) {
		px = x * Const.BILLE_RAY - (Const.LVL_WIDTH * Const.BILLE_RAY) / 2;
		py = y * Const.BILLE_RAY - (Const.LVL_HEIGHT * Const.BILLE_RAY) / 2;
		move();
	}

	function move() {
		mc._x = px * COS - py * SIN + Const.DELTA_X;
		mc._y = px * SIN + py * COS + Const.DELTA_Y;
	}

	function activate(b) {
		downcast(mc).sub.gotoAndStop(b?2:1);
	}

	function gravityLeft() {
		gx = Const.BILLE_RAY;
		gy = 0;
	}

	function gravityDown() {
		gx = 0;
		gy = Const.BILLE_RAY;
	}

	function gravityMain() {
		var s = 10 * Timer.tmod;
		if( gx > 0 ) {
			if( gx >= s )
				gx -= s;
			else {
				s = gx;
				gx = 0;
			}
			px += s;
		}
		if( gy > 0 ) {
			if( gy >= s )
				gy -= s;
			else {
				s = gy;
				gy = 0;
			}
			py += s;
		}
		move();
		return( gx != 0 || gy != 0 );
	}

}
