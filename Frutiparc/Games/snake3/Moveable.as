
class snake3.Moveable extends MovieClip {

	var shade;
	var moving;
	var x_start;
	var y_start;
	var z_start;
	var x_dest;
	var y_dest;
	var coef_a;
	var coef_b;
	var speed;
	var t;

	public var x,y,z;
	public var scale;

	function init_moveable() {
		x = _x;
		y = _y;
		z = 0;
		moving = false;
	}

	function set_pos(px,py) {
		x = px;
		y = py;
		z = 0;
		moving = false;
		shade._visible = false;
		_x = x;
		_y = y;
	}

	function isMoving() {
		return moving;
	}

	function move() {
		if( moving ) {
			t += Std.tmod * speed;
			if( t >= 1 ) {
				x = x_dest;
				y = y_dest;
				z = 0;
				shade._visible = false;
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
			_xscale = (100 + z) * scale;
			_yscale = (100 + z) * scale;
			_x = x;
			_y = y - z;
		}
		return true;
	}

	function create_shade() {
		// A IMPLEMENTER
		var mc : MovieClip = Std.cast(0);
		return mc;
	}

	function add_shade() {
		if( shade == null )
			shade = create_shade();
		shade._visible = true;
		shade._y = y;
		shade._x = x;
	}

	function jump_near(ray,zmax,speed,bounds){
		this.speed = speed;
		x_start = x;
		y_start = y;
		z_start = z;

		t = 0;
		coef_b = zmax * 4 - z;
		coef_a = - coef_b - z;

		var ang = random(360) / (Math.PI * 2);
		x_dest = x + Math.cos(ang)*ray;
		y_dest = y + Math.sin(ang)*ray;
		
		var dw = _width/2;
		var dh = _height/2;
		if( x_dest - dw < bounds.left || x_dest + dw > bounds.right || y_dest - dh < bounds.top || y_dest + dh > bounds.bottom ) {
			jump_near(ray,zmax,speed,bounds);
			return;
		}

		add_shade();

		moving = true;
	}

	function fall(speed) {
		this.speed = speed;
		x_start = x;
		y_start = y;
		z_start = z;
		x_dest = x;
		y_dest = y;
		t = 0;
		coef_a = 5;
		coef_b = - z - coef_a;
		add_shade();
		moving = true;
	}
}
