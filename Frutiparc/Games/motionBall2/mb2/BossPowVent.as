import mb2.Const;

class mb2.BossPowVent {

	var game : mb2.Game;
	var boss;

	var parts;
	var ray,x,y,ang;
	var hit;

	function BossPowVent( g : mb2.Game, b ) {
		game = g;
		boss = b;
		init();
		update();
	}

	function init() {
		ray = 0;
		ang = 0;
		hit = 0;
		x = boss.x;
		y = boss.y;
		parts = new Array();
		var i;
		var nparts = 5;
		for(i=0;i<nparts;i++) {
			var p = game.dmanager.attach("FXWind",Const.BOSS_PLAN);
			p.ang = Math.PI * 2 * i / nparts;
			p.time = 2;
			p.ox = x;
			p.oy = y;
			parts.push(p);
		}
	}

	function update() {
		var i;
		ray += 5 * Std.tmod;
		ang += Std.tmod / 12;
		for(i=0;i<parts.length;i++) {
			var p = parts[i];
			p.time -= Std.deltaT;
			if( p.time < 0 ) {
				p.removeMovieClip();
				parts.remove(p);
				i--;
			} else {
				var s = Math.min(ray,100);
				p._xscale = s;
				p._yscale = s;
				var a = p.ang + ang;
				var px = Math.cos(a) * ray + x;
				var py = Math.sin(a) * ray + y;
				p._x = px;
				p._y = py;
				var va = Math.atan2( py - p.oy , px - p.ox );
				p._rotation = va * 180 / Math.PI;
				p.ox = px;
				p.oy = py;
			}
		}

		if( hit == 0 ) {
			var dx = x - game.ball.x;
			var dy = y - game.ball.y;
			var d = Math.sqrt(dx*dx+dy*dy);
			if( d < 10 )
				d = 10;
			if( d < ray ) {
				dx /= d;
				dy /= d;
				var pow = (boss.tb ? 30 : 10) / Math.sqrt(d);
				game.ball.sx -= dx * pow;
				game.ball.sy -= dy * pow;
			}
		} else {
			hit -= Std.deltaT;
			if( hit <= 0 )
				hit = 0;
		}

		if( parts.length == 0 )
			boss.powers.remove(this);
	}

	function destroy() {
	}

}