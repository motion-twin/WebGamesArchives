package ui;

import mt.deepnight.slb.BSprite;

class MenuButton extends Button {
	public function new(p, str, cb) {
		super(p, str, cb);

		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, 0x5A6F8D,1, 0,0),
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
			new flash.filters.GlowFilter(0xFFFFFF,0.2, 2,2,10),
		];
		setSize(300, 50);
	}
}
