package bad;
import mt.bumdum9.Lib;
import Protocol;

class Hunter extends ent.Bad {

	var cycle:Float;
	public function new() {
		bid = 4;
		super();
		spc = 0.08;
		free = 0;
		hunter = 3;
		uturn = true;
		skin.play("seeker_fly");
		cycle = 0;
	}

	override function update() {
		super.update();
		
		cycle = (cycle + 0.02) % 1;
		spc = 0.08 + Math.cos(cycle * 6.28) * 0.06;
	}
}
