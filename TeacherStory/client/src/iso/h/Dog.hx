package iso.h;

class Dog extends iso.Helper {
	public function new() {
		super(Dog);
		speed*=0.5;
		init( cast new lib.Tippex() );
		headY += 12;
	}
	
	override function update() {
		super.update();
		if( active && !cd.hasSet("woof", 30*mt.deepnight.Lib.rnd(12,30)) ) {
			man.fx.surprise(this);
			man.fx.word(this, Tx.Dog);
		}
	}
}

