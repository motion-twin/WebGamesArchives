package ui;

import mt.deepnight.slb.BSprite;

class ColorButton extends Button {
	public function new(p, cb) {
		super(p, "", cb, 1);

		setSize(40, 40);
		setBg( m.Global.ME.tiles.get("btnColor") );
	}
}
