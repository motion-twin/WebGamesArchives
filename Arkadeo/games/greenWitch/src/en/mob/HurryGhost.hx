package en.mob;

import flash.display.BlendMode;

class HurryGhost extends Ghost {
	public function new(x,y) {
		super(x,y);
		teint = mt.deepnight.Color.getColorizeMatrixFilter(0x491818, 1,0);
		sprite.filters = [teint];
		face.visible = false;
		trackDistance = 500;
		initLife( 50 );
	}

	override function getLoot() { return null; }
	override function getXp() { return null; }
}
