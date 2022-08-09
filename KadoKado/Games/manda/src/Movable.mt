class Movable {

	var mc : MovieClip;
	var shade : MovieClip;
	var moving : bool;
	var x_start : float;
	var y_start : float;
	var z_start : float;
	var x_dest : float;
	var y_dest : float;
	var coef_a : float;
	var coef_b : float ;
	var speed : float;
	var t : float;

	var x : float;
	var y : float;
	var z : float;
	var scale : float;

	var createShade : void -> MovieClip;
	var inBounds : float -> float -> bool;

	function new(mc) {
		this.mc = mc;
		x = mc._x;
		y = mc._y;
		z = 0;
		moving = false;
	}

	function setPos(px,py) {
		x = px;
		y = py;
		z = 0;
		moving = false;
		mc._x = x;
		mc._y = y;
		shade.removeMovieClip();
		shade = null;
	}

	function isMoving() {
		return moving;
	}

	function move() {
		if( moving ) {
			t += Timer.tmod * speed;
			if( t >= 1 ) {
				x = x_dest;
				y = y_dest;
				z = 0;
				shade.removeMovieClip();
				shade = null;
				moving = false;
			} else {
				x = x_start + (x_dest - x_start) * t;
				y = y_start + (y_dest - y_start) * t;
				z = coef_a * t * t + coef_b * t + z_start;
			}
			if( z != 0 ) {
				shade._x = x + z/4;
				shade._y = y + z/3;
				shade._xscale = (100 - z/2) * scale;
				shade._yscale = (100 - z/2) * scale;
			}
			mc._xscale = (100 + z) * scale;
			mc._yscale = (100 + z) * scale;
			mc._x = x;
			mc._y = y - z;
		}
	}

	function addShade() {
		if( shade == null )
			shade = createShade();
		shade._visible = true;
		shade._y = y;
		shade._x = x;
	}

	function jumpNear(ray : float,zmax : float,speed : float,bounds : { left : float, right : float, top : float, bottom : float }){
		this.speed = speed;
		x_start = x;
		y_start = y;
		z_start = z;

		t = 0;
		coef_b = zmax * 4 - z;
		coef_a = - coef_b - z;

		var ntrys = 100;
		do {
			var ang = Std.random(360) / (Math.PI * 2);
			x_dest = x + Math.cos(ang)*ray;
			y_dest = y + Math.sin(ang)*ray;
		} while( !inBounds(x_dest,y_dest) && --ntrys > 0 );
		
		addShade();
		moving = true;
	}

	function fall(speed) {
		this.speed = speed;
		x = mc._x;
		y = mc._y;
		x_start = x;
		y_start = y;
		z_start = z;
		x_dest = x;
		y_dest = y;
		t = 0;
		coef_a = 5;
		coef_b = - z - coef_a;
		addShade();
		moving = true;
	}

}