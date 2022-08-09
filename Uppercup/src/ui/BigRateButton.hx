package ui;

import mt.deepnight.slb.BSprite;

class BigRateButton extends Button {
	public function new(p, str, cb) {
		super(p, str, cb);

		setBg(m.Global.ME.tiles.get("payButtonSmall"));
		setSize(sprBg.width, sprBg.height);
	}


	override function applyLabelFilters(bd:flash.display.BitmapData) {
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,-90, 0xDF7500, 1, 0,0));
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0xFFFF80, 0.6, 2,2, 8));
	}

}
