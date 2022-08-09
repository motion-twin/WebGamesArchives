class Particule {

	var mc : MovieClip;
	var shade : MovieClip;

	var px : float;
	var py : float;

	var dx : float;
	var dy : float;
	var speed : float;
	var time : float;
	var ds : float;

	var scale : float;	

	function new(g,id,x,y) {
		mc = g.dmanager.attach("mcPart",Const.PLAN_PART);
		mc.gotoAndStop(string(id+1));
		shade = g.dmanager.attach("mcPart",Const.PLAN_PART_SHADE);
		shade.gotoAndStop("6");
		scale = Std.random(50)+70;
		ds = 0;
		time = (0.4 + Std.random(100)/100) / 2;
		speed = 3 + Std.random(10)/10;
		dx = (Std.random(100) - 50) / 50;
		dy = - Std.random(100) / 50;
		px = x + dx * speed * 2;
		py = y + dy * speed * 2;
	}

	function update() {
		var s = speed * Timer.tmod;
		speed += Timer.tmod / 10;
		dy += 0.07 * Timer.tmod;
		px += dx * s;
		py += dy * s;
		if( time > 0 ) {
			time -= Timer.deltaT;
			if( time <= 0 )
				ds = 10;
		}
		scale -= ds * Timer.tmod;
		if( scale <= 0 ) {
			mc.removeMovieClip();
			shade.removeMovieClip();
			return false;
		}		
		mc._xscale = scale;
		mc._yscale = scale;
		shade._xscale = scale + 40;
		shade._yscale = scale + 40;
		mc._x = px;
		mc._y = py;
		shade._x = px;
		shade._y = py;
		return true;
	}

}