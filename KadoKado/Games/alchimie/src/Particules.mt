class Particules {//}

	var dmanager : DepthManager;
	var tbl : Array<{
		mc : MovieClip,
		x : float,
		y : float,
		a : float,
		vx : float,
		vy : float,
		va : float,
		ax : float,
		ay : float,
		f : float
	}>;

	function new(dman) {
		dmanager = dman;
		tbl = new Array();
	}

	function randAngle() {
		return (Std.random(3600) / 10) / (Math.PI * 2);
	}

	function add(x,y) {
		var mc = dmanager.attach("part",Const.PLAN_PART);
		var s = Std.random(100)/10 * (Std.random(2)*2-1);
		mc.gotoAndStop(string(Std.random(4)+1));
		mc._x = x;
		mc._y = y;
		var p = {
			mc : mc,
			x : x,
			y : y,
			a : randAngle(),
			vx : s,
			vy : -(Std.random(200)/10),
			va : s,
			ax : 0,
			ay : 1.5,
			f : 0.98
		};
		tbl.push(p);
	}

	function main() {
		var i;
		var n = tbl.length;
		for(i=0;i<n;i++) {
			var p = tbl[i];
			var f = Math.pow(p.f,Timer.tmod);			
			p.vx *= f;
			p.vy *= f;
			p.vx += p.ax;
			p.vy += p.ay;
			p.x += p.vx;
			p.y += p.vy;
			p.a += p.va;
			p.mc._x = p.x;
			p.mc._y = p.y;
			p.mc._rotation = p.a * 180 / Math.PI;			
			if( p.x < -100 || p.x > 400 || p.y < -100 || p.y > 400 ) {
				p.mc.removeMovieClip();
				tbl.splice(i,1);
				i--;
			}
		}
	}

//{
}