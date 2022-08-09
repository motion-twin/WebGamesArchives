package ui;

import mt.deepnight.slb.BSprite;

class BackButton extends Button {
	public function new(p, cb) {
		super(p, "", cb, 1);

		setSize(42, 40);
		setBg( m.Global.ME.tiles.get("backButton") );
		hasClickFeedback = false;
		setPos(3, 3);
	}
}
