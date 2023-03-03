import snake3.Const;

class snake3.Bonus extends snake3.Moveable {
	
	public var time;
	var dmanager;
	var id;

	function init(dman,id,time) {
		init_moveable();
		this.dmanager = dman;
		this.id = id;
		this.time = time;
	}

	function destroy() {
		shade.removeMovieClip();
		this.removeMovieClip();
	}

	function timeout() {
		this.gotoAndPlay("disparait");
	}

	function create_shade() {
		var s = dmanager.attach("snake3_bonus",Const.PLAN_FRUITSHADE);
		s.gotoAndStop(10);
		Std.getVar(s,"f").gotoAndStop(id);
		var c = new Color(s);
		c.setRGB(Const.COLOR_FRUIT_OMBRE);
		return s;
	}

	function update(g) {
		move();
		if( id == 23 )
			_rotation += Const.FLECHE_ROTATION_SPEED;
		if( id == 24 )
			_rotation = g.snake.ang * 180 / Math.PI;
	}
}
