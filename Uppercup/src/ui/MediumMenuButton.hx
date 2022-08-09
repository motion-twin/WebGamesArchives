package ui;

import mt.deepnight.slb.BSprite;

class MediumMenuButton extends Button {
	public function new(p, str, cb) {
		super(p, str, cb, 2);

		setSize(147, 45);
		setBg( m.Global.ME.tiles.get("btnAcnee") );
	}
}
