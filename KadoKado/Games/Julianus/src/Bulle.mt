class Bulle {

	static var gravity = 0.01;
	static var border_pow = 0.3;

	var game : Game;
	var mc : MovieClip;
	var ts : float;
	var px : float;
	var py : float;
	var vx : float;
	var vy : float;	
	volatile var size : float;
	var t : float;

	function new(g,x,y) {
		game = g;
		mc = game.dmanager.attach("bulle",Const.PLAN_BULLE);
		setSize(17);
		ts = 0;
		px = x;
		py = y;
		t = 0;
		vx = 0;
		vy = 0;
		ts = 0;
	}

	function setSize(s) {
		size = s;
		mc._xscale = s;
		mc._yscale = s;
	}

	function kill() {
		var p = game.dmanager.attach("pop",Const.PLAN_PART);
		p._x = px;
		p._y = py;
		p._xscale = size;
		p._yscale = size;
		mc.removeMovieClip();
	}

	function separate() {

		var p = game.dmanager.attach("pop",Const.PLAN_PART);
		p._x = px;
		p._y = py;
		p._xscale = size;
		p._yscale = size;

		game.stats.$k++;

		var s = Math.sqrt(size * size / 3);
		if( s < 17 ) {
			mc.removeMovieClip();
			game.bulles.remove(this);			
			return;
		}		

		var v = Math.sqrt(vx*vx+vy*vy);
		var tmp;		
		tmp = vx;
		vx = -vy * (v + 2) / v;
		vy = tmp * (v + 2) / v;

		var a = Math.atan2(vy,vx);
		var dx = Math.cos(a) * s / 2;
		var dy = Math.sin(a) * s / 2;

		var b = new Bulle(game,px-dx,py-dy);
		px += dx;
		py += dy;
		b.setSize(s);
		b.vx = -vx;
		b.vy = -vy;
		setSize(s);
		game.bulles.push(b);
		mc._x = px;
		mc._y = py;
		b.mc._x = b.px;
		b.mc._y = b.py;
	}

	function update(dx) {
		var friction = Math.pow(0.98,Timer.tmod);
		vx *= friction;
		vy *= friction;
		vy += gravity * Timer.tmod;
		px += dx + vx * Timer.tmod;
		py += vy * Timer.tmod;
		if( py < size / 2 ) {
			py = size / 2;
			vy = Math.abs(vy);
		}
		if( py > Const.MAXY - size / 2 ) {
			py = Const.MAXY - size / 2;
			vy = - Math.abs(vy);
		}
		if( px < size / 2 ) {
			px = size / 2;
			vx = Math.abs(vx);
		}
		if( px < size + size / 2 ) 
			vx += Timer.tmod * border_pow;
		if( py > Const.MAXY - size )
			vy -= Timer.tmod * border_pow;
		else if( py < size )
			vy += Timer.tmod * border_pow;

		var i;
		for(i=0;i<game.bulles.length;i++) {
			var b = game.bulles[i];
			if( b != this ) {
				var ddx = b.px - px;
				var ddy = b.py - py;
				var d = Math.sqrt(ddx*ddx+ddy*ddy);
				var s = b.size + size;
				if( d < s / 2 ) {
					if( b.size > size ) {
						vx = b.vx;
						vy = b.vy;
						px = b.px;
						py = b.py;
					}
					ts = 5;
					game.stats.$f++;
					setSize(Math.sqrt(size*size + b.size*b.size));
					b.size = size;
					b.px = px;
					b.py = py;
					b.kill();
					game.bulles.splice(i--,1);
				}
			}
		}

		var a = Math.atan2(vy,vx);
		var v = Math.min( Math.sqrt(vx*vx+vy*vy) , 2 );
		t += Timer.tmod * ts / 10;
		ts *= Math.pow(0.95,Timer.tmod);
		if( ts < 1 )
			ts = 1;

		var spow = size * ts / 20;
		mc._xscale = size + Math.cos(a + t) * spow;
		mc._yscale = size + Math.sin(a + t) * spow;
		mc._x = px;
		mc._y = py;
	}

}