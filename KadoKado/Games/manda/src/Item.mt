class Item extends Movable {

	var id : int;
	volatile var time : float;

	function new(id,mc,time) {
		super(mc);
		this.id = id;		
		this.time = time;
		rndPos();
	}

	function update() {
		move();
		if( !isMoving() )
			time -= Timer.deltaT;
		if( time > 0 )
			return true;
		mc.gotoAndPlay("disparait");
		return false;
	}

	function rndPos() {
		var x,y;
		var ntrys = 200;
		do {
			x = Std.random(Const.WIDTH);
			y = Std.random(Const.HEIGHT);
		} while( !inBounds(x,y) && --ntrys > 0 );
		mc._x = x;
		mc._y = y;
	}

	function inBounds(x,y) {
		var f : MovieClip = downcast(mc).f;
		var b = f.getBounds(mc);
		var xs = 100 / f._xscale;
		var ys = 100 / f._yscale;
		b.xMin *= xs;
		b.xMax *= xs;
		b.yMin *= ys;
		b.yMax *= ys;

		var lv = Const.LEVEL_BOUNDS;
		return ( x + b.xMin > lv.left && y + b.yMin > lv.top && x + b.xMax < lv.right && y + b.yMax < lv.bottom );
	}

	function destroy() {
		mc.removeMovieClip();
	}

}