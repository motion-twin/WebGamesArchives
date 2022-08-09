package bad;
import mt.bumdum9.Lib;

class DiagonEgg extends Bad  {
	
	public function new() {
		super(DIAGON_EGG);
		setFamily();
		var sk = cast setSkin(new gfx.Egg(), 5);
		sk.scaleX = sk.scaleY = 1.25;
		frict = 0.75;
		ray = 8;
		if( have(DIAGON_EGG_LIFE) ) life += 2;
	}
	
	override function update() {
		super.update();
		if ( timer > 250 ) {
			spawn(DIAGON);
			kill();
		}
	}
}
