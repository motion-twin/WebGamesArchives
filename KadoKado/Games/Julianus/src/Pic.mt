class Pic {

	var id : int;
	var game : Game;
	var mc : {> MovieClip, sub : MovieClip };
	var px : float;
	var py : float;
	var a : float;
	var rspeed : float;

	function new(g,i,x,y) {
		id = i;
		a = Std.random(360) / Math.PI;
		game = g;
		rspeed = 0;
		mc = downcast(game.dmanager.attach("pic",Const.PLAN_PIC));
		mc.gotoAndStop(string(id+1));
		px = x;
		py = y;
		mc._x = x;
		mc._y = y;
	}

	function getBonus(k) {
		var p = game.dmanager.attach("fxBonus",Const.PLAN_PART);
		p._x = px;
		p._y = py;
		mc.removeMovieClip();
		game.stats.$bo[k]++;
		KKApi.addScore(Const.SCORES[k]);
		game.bcount--;
	}

	function update(deltax) {
		px += deltax;
		mc._x = px;

		var sizex = 10;
		if( id == 2 )
			sizex += 50;
		else if( id == 1 )
			sizex += 10;

		if( px < -sizex ) {
			mc.removeMovieClip();
			return false;
		}
		var i;
		var bl = game.bulles;
		var len = bl.length;
		var ray = (id == 1)?50:((id >= 3)?34:30);
		var sr = (id >= 2)?13:7;

		var dpx = 0, dpy = 0;
		if( id == 2 ) {
			a += Timer.tmod / 50;
			dpx = Math.cos(a) * 50;
			dpy = Math.sin(a) * 50;
			px += dpx;
			py += dpy;
			mc.sub._x = dpx;
			mc.sub._y = dpy;
		}

		for(i=0;i<len;i++) {
			var b = bl[i];
			var dx = b.px - px;
			var s = b.size / 2;
			if( dx < ray+s && dx > -ray-s ) {
				var dy = b.py - py;
				var d = Math.sqrt(dx*dx+dy*dy);
				if( d < s + sr ) {
					switch( id ) {
					case 3:
					case 4:
					case 5:
						getBonus(id-3);
						break;
					default:
						b.separate();
						game.kills.push(this);
						break;	
					}					
					return false;
				} else if( d < s + ray ) {
					if( id == 1 ) {
						var p = Timer.tmod * 10 / (d * d);
						b.vx += dx * p;
						b.vy += dy * p;
					}
					rspeed += 2 * Timer.tmod;
					if( rspeed > 25 )
						rspeed = 25;
				}
			}
		}		
		px -= dpx;
		py -= dpy;
		if( rspeed > 1 && id == 1 ) {
			mc.sub.gotoAndStop( (rspeed == 25)?"2":"1" );
			if( rspeed != 25 )
				mc.sub._rotation += rspeed * Timer.tmod;
			rspeed *= Math.pow(0.95,Timer.tmod);
		}
		return true;
	}

	function updateKill(deltax) {
		px += deltax;
		var p = Math.pow(0.7,Timer.tmod);
		mc._xscale *= p;
		mc._yscale *= p;
		if( mc._xscale <= 10 ) {
			mc.removeMovieClip();
			return false;
		}
		mc._x = px;
		return true;
	}

}