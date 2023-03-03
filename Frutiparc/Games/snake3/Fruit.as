import snake3.Const;

class snake3.Fruit extends snake3.Moveable {
	
	var dmanager;
	var id;
	var f_timeout;

	public var time;

	function init(dmanager,id,time) {
		init_moveable();
		this.id = id;
		this.time = time;
		this.dmanager = dmanager;
		f_timeout = undefined;
	}

	function set_id(new_id) {
		id = new_id;
		Std.getVar(this,"f").gotoAndStop(id);
	}

	function get_id() {
		return id;
	}

	function points() {
		return Const.fruit_points(id);
	}

	function eat(col) {
		return ( z == 0 && Std.hitTest(this,col) );
	}

	function create_shade() {
		var s = dmanager.attach("snake3_fruit",Const.PLAN_FRUITSHADE);
		s.gotoAndStop("ombre");
		Std.getVar(s,"f").gotoAndStop(id);
		return s;
	}

	function move() {
		super.move();
		if( moving ) 
			return true;
		else {
			time -= Std.tmod;
			return (time > 0);
		}
	}

	function destroy() {
		shade.removeMovieClip();
		this.removeMovieClip();
	}

	function timeout() {
		f_timeout(this);
		this.gotoAndPlay("disparait");
	}

	function on_eat( s : snake3.Snake ) {
		s.add_queue(id);
	}

	function on_timeout( a ) {
		f_timeout = a;
	}

}
