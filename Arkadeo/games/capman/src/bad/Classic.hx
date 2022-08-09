package bad;
import mt.bumdum9.Lib;
import Protocol;

class Classic extends ent.Bad {
	public function new() {
		bid = 0;
		super();
		spc = 0.04;
		
		free = 4;
		hunter = 1;
		
		skin.play("smiley_turn");
	}
}
