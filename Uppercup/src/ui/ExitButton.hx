package ui;

import mt.deepnight.slb.BSprite;

class ExitButton extends Button {
	public function new(p) {
		super(p, "", onExit, 1);

		setSize(42, 40);
		setBg( m.Global.ME.tiles.get("closeButton") );
		hasClickFeedback = false;
		setPos(3, 3);
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);
	}

	function onExit() {
		m.Global.ME.exitApp();
	}
}
