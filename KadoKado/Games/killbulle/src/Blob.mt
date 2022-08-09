class Blob {

	var game : Game;
	var x : float;
	var y : float;
	var dx : float;
	var dy : float;
	var speed : float;
	var size : float;
	var dir : int;
	var bonus : Bonus;
	var mc : MovieClip;

	function new(g,size,b) {
		game = g;
		bonus = b;
		this.size = size;
		speed = 5 + game.level / 20;
		y = -100;
		dx = 2.5;
		dy = 1;
		dir = Std.random(2)*2-1;
		x = game.hero.x + dir * 50;
		mc = game.dmanager.attach("blob",Const.PLAN_BLOB);
		mc._xscale = size;
		mc._yscale = size;
		setColor(mc);
	}

	function setColor(mc : MovieClip) {
		var c = new Color(downcast(mc).col);
		var t;
		if( bonus == null )
			t = {
				ra : 82,
				rb : 40,
				ga : 86,
				gb : 30,
				ba : 52,
				bb : -51,
				aa : 100,
				ab : 0
			}
		else
			t = {
				ra : 82,
				rb : 150,
				ga : 86,
				gb : 10,
				ba : 52,
				bb : -51,
				aa : 100,
				ab : 0
			};
		c.setTransform(t);
	}

	function hit() {
		game.blobs.remove(this);
		var e = game.dmanager.attach("animExplose",Const.PLAN_BLOB);
		e._x = x;
		e._y = y;
		e._xscale = size / 2;
		e._yscale = size / 2;
		setColor(e);
		game.level++;

		mc.removeMovieClip();
		var dsize = size / 2;
		if( size == 150 )
			dsize = 100;
		if( size >= 25 && bonus == null ) {
			var b;
			b = new Blob(game,dsize,null);
			b.x = x + size/4;
			b.y = y;
			b.dy = -Math.abs(dy);
			b.dir = 1;
			b.update();
			game.blobs.push(b);
			
			b = new Blob(game,dsize,null);
			b.x = x - size/4;
			b.y = y;
			b.dy = -Math.abs(dy);
			b.dir = -1;
			b.update();

			game.blobs.push(b);
		} else {
			bonus.fall();
			game.tsize -= size;
		}
	}

	function update() {

		dy += 0.9 * Timer.tmod;
		var d = Math.sqrt(dx*dx+dy*dy);
		var s = speed / 15 * Timer.tmod;
		x += dir * dx * s;
		y += dy * s;

		if( y > Const.MINY - size/2 ) {
			y = Const.MINY - size/2;
			dy = -20 - Math.sqrt(size);
		}

		if( x < size/2 ) {
			x = size - x;
			dir *= -1;
		} else if( x > Const.WIDTH - size/2 ) {
			x = Const.WIDTH * 2 - size - x;
			dir *= -1;
		}

		bonus.mc._x = x;
		bonus.mc._y = y;
		mc._x = x;
		mc._y = y;
		return true;
	}

}