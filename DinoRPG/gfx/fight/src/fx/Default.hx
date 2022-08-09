package fx;

import mt.bumdum.Lib;

class Default extends State {
	var caster:Fighter;

	public function new( f ) {
		super();
		caster = f;
		addActor(f);
		spc = 0.1;
	}

	public override function update() {
		super.update();
		if(castingWait) return;
		if(coef == 1) end();
	}
}
