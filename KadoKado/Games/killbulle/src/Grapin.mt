class Grapin {

	static var BASEY = Const.MINY - 30;

	var game : Game;
	var mc : MovieClip;
	var cordes : Array<MovieClip>;	
	var y : float;
	var x : float;	
	var speed : float;
	var rot : bool;
	var superg : bool;

	function new(g) {
		game = g;
		mc = game.dmanager.attach("grapin",Const.PLAN_GRAPIN);
		cordes = new Array();
		superg = (game.hero.super_grapin_time > 0);
		x = game.hero.x;
		y = BASEY;
		speed = 8;				
		mc.gotoAndStop(superg?"2":"1");
	}

	function destroyCordes() {
		var i;
		for(i=0;i<cordes.length;i++) {
			var c = cordes[i];
			c._alpha -= 10 * Timer.tmod;
			if( c._alpha <= 0 ) {
				c.removeMovieClip();
				cordes.splice(i--,1);
			}	
		}
		speed *= Math.pow(1.05,Timer.tmod);
		if( rot ) {
			mc._rotation += 40 * Timer.tmod;
			mc._x += speed / 6 * Timer.tmod;
			mc._y += Math.abs(speed) / 3 * Timer.tmod;
			mc._xscale *= Math.pow(0.98,Timer.tmod);
			mc._yscale = mc._xscale;
		} else
			mc._y -= speed * Timer.tmod;		
		if( mc._y > 320 || mc._y < -20 )
			mc.removeMovieClip();
		return cordes.length > 0 || mc._name != null;
	}

	function hits() {
		var i;
		if( game.hero.died )
			return false;

		for(i=0;i<game.blobs.length;i++) {
			var b = game.blobs[i];
			var s = int(b.size / 2);
			if( x >= b.x - s && x <= b.x + s && y <= b.y + s ) {
				b.hit();
				rot = ( y >= b.y );
				if( rot ) {
					game.dmanager.swap(mc,1);
					if( Std.random(2) == 0 )
						speed *= -1;
				}

				var pts = s * KKApi.val(Const.C20);
				game.stats.$s++;
				game.stats.$ts += pts;
				KKApi.addScore(KKApi.const(pts));

				if( superg ) {
					speed = Math.abs(speed);
					rot = false;
					continue;
				}
				return true;
			}
		}
		return false;
	}

	function update() {		

		y -= speed * Timer.tmod;

		var i;
		var ncordes = 1+int((BASEY - y)/25);
		for(i=0;i<ncordes;i++) {
			var c = cordes[i];
			if( c == null ) {
				c = game.dmanager.attach("corde",Const.PLAN_CORDE);
				c._y = BASEY - 25 * (i - 1);
				cordes.push(c);
			}
			c._yscale = 100;
			c._x = x;
		}
		cordes[i-1]._yscale = (cordes[i-1]._y - y) * 4;

		var h = hits();

		mc._x = x;
		mc._y = y;

		if( (y < -100) || h ) {
			if( y < -100 )
				mc.removeMovieClip();
			game.addUpdate(callback(this,destroyCordes));
			return false;
		}
		return true;
	}

}