package iso.h;

class Supervisor extends iso.Helper {
	public function new() {
		super(Supervisor);
		init( cast new lib.Dwayne() );
	}
	
	override function update() {
		super.update();
		if( active && !moving() && !cd.hasSet("highlight", 30) )
			for(s in man.supervisorSeats)
				man.fx.highlightSeat(s.cx, s.cy);
	}
}

