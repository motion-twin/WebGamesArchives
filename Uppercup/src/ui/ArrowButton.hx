package ui;

import mt.deepnight.slb.BSprite;

class ArrowButton extends Button {
	public function new(p, next:Bool, cb) {
		super(p, "", cb, 1);

		hasClickFeedback = false;
		setSize(60,60);
		setBg( m.Global.ME.tiles.get(next ? "Ui_NextArrow" : "Ui_PreviousArrow"), false );
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);
	}
}
