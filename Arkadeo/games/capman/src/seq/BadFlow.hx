package seq;
import mt.bumdum9.Lib;
import Protocol;

class BadFlow  extends mt.fx.Sequence {

	static var SPEED = 0.05;
	var id:Int;
	public function new() {
		super();
		id = 0;
	}

	override function update() {
		super.update();
		if( timer == Cs.MONSTERS_SPAWN_DELAY[id] ) {
			new fx.Spawn(id + 1);
			id++;
			if( Cs.MONSTERS_SPAWN_DELAY.length == id ) kill();
		}
	}
}
