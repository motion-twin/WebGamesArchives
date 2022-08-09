class Ballon {

	static var speed = 0.05;
	static var factor = 1.3;
	static var ray = 15 * factor;

	var game : Game;
	var mc : MovieClip;
	var x : float;
	var y : float;
	var dx : float;
	var dy : float;
	var a : float;
	var t : int;

	var timer : float;
	var mind : float;
	var tx : float;
	var ty : float;

	function new(g,t) {
		game = g;
		this.t = t;
		mc = game.dmanager.attach("ballon",Const.PLAN_BALLON);
		mc.gotoAndStop(string(t+1));
		x = Std.random(300);
		y = -(20 + Std.random(300));
		dx = 0;
		dy = 0;
		nextStep();
		a = Std.random(100)/20;
		mc._x = x;
		mc._y = y;
		mc._xscale = 100 * factor;
		mc._yscale = 100 * factor;
	}

	function nextStep() {
		tx = Std.random(200)+50;
		ty = Std.random(200)+50;
		mind = ray * 2;
	}

	function plop(sc) {

		var p = game.dmanager.attach("plop",Const.PLAN_PART);
		p._x = mc._x;
		p._y = mc._y;
		var c = new Color(p);
		var colors = [0xE11B04,0x5AE606,0xFBC716,0x584886];
		c.setRGB(colors[t]);

		var s = game.dmanager.attach("partScore",Const.PLAN_PART);
		s._x = mc._x;
		s._y = mc._y;
		downcast(s).score = sc;
	}

	function destroy() {
		mc.removeMovieClip();
	}

	function update(nb) {
		var s = Timer.tmod * speed;
		var ddx = tx - x;
		var ddy = ty - y;
		var dd = Math.sqrt(ddx*ddx+ddy*ddy);
		var p = Math.pow(0.96,Timer.tmod);

		if( timer > 0 ) {
			timer -= Timer.deltaT;
			if( timer <= 0 )
				nextStep();
		}

		dx = dx * p + ddx * ( 1 - p );
		dy = dy * p + ddy * ( 1 - p );

		var r = 1;
		if( x < 40 )
			dx+=r;
		if( y < 40 )
			dy+=r;
		if( x > 260 )
			dx-=r;
		if( y > 260 )
			dy-=r;

		if( dd < mind * Timer.tmod )
			nextStep();

		x += dx * s;
		y += dy * s;

		if( y > 280 ) {
			y = 280 - (y - 280);
			dy = -Math.abs(dy);
			dx *= -1;
		}

		var i;
		var l = game.bals;
		var n = l.length;
		for(i=nb+1;i<n;i++) {
			var b = l[i];
			var dx = b.x - x;
			var dy = b.y - y;
			r = Math.sqrt(dx*dx + dy*dy);
			if( r < ray*2 ) {
				var a = Math.atan2(dy,dx);
				r = (ray*2 - r) / 2;
				var ca = r * Math.cos(a);
				var sa = r * Math.sin(a);
				x -= ca;
				y -= sa;
				b.x += ca;
				b.y += sa;
			}
		}

		mc._x = x;
		mc._y = y;
		return true;
	}

}