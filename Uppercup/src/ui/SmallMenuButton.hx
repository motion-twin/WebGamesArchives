package ui;

import mt.deepnight.slb.BSprite;

class SmallMenuButton extends Button {
	public function new(p, str, cb) {
		super(p, str, cb, 1);

		setSize(100, 45);
		setBg( m.Global.ME.tiles.get("mediumButton") );
	}
}
