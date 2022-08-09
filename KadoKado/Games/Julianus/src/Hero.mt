class Hero {

	static var pow = 0.15;

	var game : Game;
	var blow : MovieClip;
	var eyes : MovieClip;
	var mc : MovieClip;
	var px : float;
	var py : float;
	var tx : float;
	var ty : float;
	var ang : float;
	var frame : float;
	volatile var speed : float;
	var action : bool;
	var partpow : float;

	var parts : Array<{> MovieClip, x : float, y : float, vx : float, vy : float, s : float }>;

	function moyAng(a,b) {
		if( Math.abs(a - b) > Math.PI ) {
			if( b < a )
				b += Math.PI * 2;
			else
				b -= Math.PI * 2;
		}
		a = (a + b) / 2;
		while( a <= Math.PI )
			a += Math.PI * 2;
		while( a > Math.PI )
			a -= Math.PI * 2;
		return a;
	}

	function new( g ) {
		action = false;
		game = g;
		frame = 0;
		speed = 0;
		ang = 0;
		partpow = 0;
		parts = new Array();
		mc = game.dmanager.attach("hero",Const.PLAN_HERO);
		eyes = game.dmanager.attach("eyes",Const.PLAN_HERO);
		tx = game.mc._xmouse;
		ty = game.mc._ymouse;
		px = tx + 1;
		py = ty;
	}

	function updateParts() {
		var action = this.action || Key.isDown(Key.SPACE);
		partpow = (partpow + (action?(pow * 30):0)) / 2;
		if( action && Std.random(2) == 0 ) {
			var p = downcast(game.dmanager.attach("part",Const.PLAN_PART));
			var a = ang + (Std.random(100) - 50) / 200;
			p.gotoAndStop(string(1+Std.random(p._totalframes)));
			p.x = px + Math.cos(a) * 20;
			p.y = py + Math.sin(a) * 20;
			p.vx = Math.cos(a) * partpow;
			p.vy = Math.sin(a) * partpow;
			p.s = 200;
			parts.push(p);
		}

		var i;
		var acc = Math.pow(0.97,Timer.tmod);
		for(i=0;i<parts.length;i++) {
			var p = parts[i];
			p.s += 20 * Timer.tmod;
			p._rotation += 20 * Timer.tmod;
			p._alpha -= 5 * Timer.tmod;
			if( p._alpha < 0 ) {
				p.removeMovieClip();
				parts.splice(i--,1);
			} else {
				p.x += p.vx * Timer.tmod;
				p.y += p.vy * Timer.tmod;
				p.vx *= acc;
				p.vy *= acc;
				p._x = p.x;
				p._y = p.y;
				p._xscale = p.s;
				p._yscale = p.s;
			}
		}
	}

	function adiff(a1,a2) {
		while( a1 < 0 )
			a1 += Math.PI * 2;
		while( a2 < 0 )
			a2 += Math.PI * 2;
		while( a1 >= 2 * Math.PI )
			a1 -= Math.PI * 2;
		while( a2 >= 2 * Math.PI )
			a2 -= Math.PI * 2;
		var a = Math.abs(a1 - a2);
		if( a < Math.PI )
			return a;
		return Math.PI * 2 - a;
	}

	function update() {
		var ray = 10;

		var s = 5;
		if( Key.isDown(Key.LEFT) && tx > 0 )
			tx -= Timer.tmod * s;
		if( Key.isDown(Key.RIGHT) && tx < 300 )
			tx += Timer.tmod * s;
		if( Key.isDown(Key.UP) && ty > 0 )
			ty -= Timer.tmod * s;
		if( Key.isDown(Key.DOWN) && ty < 300 )
			ty += Timer.tmod * s;

		var ttx = tx;
		var tty = ty;

		var action = this.action || Key.isDown(Key.SPACE);

		if( (blow != null) != action ) {
			if( action ) {
				blow = game.dmanager.attach("blow",Const.PLAN_HERO);
				game.dmanager.over(eyes);
			} else {
				blow.removeMovieClip();
				blow = null;
			}
		}

		var i;
		var mind = 50;
		var targb = null;
		var pp = pow * Math.pow((game.speed - game.speed_delta) / game.speed,3);
		for(i=0;i<game.bulles.length;i++) {
			var b = game.bulles[i];
			var dx = b.px - px;
			var dy = b.py - py;
			var d = Math.sqrt(dx*dx + dy*dy);
			if( action && d < 50 + b.size/2 ) {
				var a = Math.atan2(dy,dx);	
				if( adiff(a,ang) < Math.PI / 4 ) {
					b.vx += Timer.tmod * Math.cos(a) * pp;
					b.vy += Timer.tmod * Math.sin(a) * pp;
				}
			}
			d -= b.size;
			if( d < mind ) {
				mind = d;
				targb = b;
			}
		}
		var tang = Math.atan2(tty - py,ttx - px);

		if( targb != null )
			tang = Math.atan2(targb.py - py,targb.px - px);

		var x = ttx + Math.cos(ang + Math.PI) * ray;
		var y = tty + Math.sin(ang + Math.PI) * ray;
		var p = Math.pow(0.9,Timer.tmod);
		var ox = px;
		var oy = py;
		px = px * p + x * (1 - p);
		py = py * p + y * (1 - p);

		ang = moyAng(ang,tang);		

		ox -= px;
		oy -= py;
		speed = Math.sqrt(ox*ox+oy*oy);
		frame += Math.min(Math.max(0.3,Math.sqrt(speed)) * Timer.tmod ,1);
		var body : MovieClip = downcast(mc).body;
		body.gotoAndStop(string(1+ int(frame)%body._totalframes));
		body._rotation = ang * 180 / Math.PI;		
		var f;
		if( ang < 0 )
			f = 61 + int(ang * 30 / Math.PI);
		else 
			f = 1 + int(ang * 30 / Math.PI);

		updateParts();

		eyes.gotoAndStop(string(f));
		blow.gotoAndStop(string(f));
		eyes._x = px;
		eyes._y = py;
		blow._x = px;
		blow._y = py;
		mc._x = px;
		mc._y = py;
	}

}