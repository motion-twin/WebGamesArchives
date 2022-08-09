package ui;

import mt.deepnight.slb.BSprite;

class RateTinyButton extends ui.Button {
	public function new(p,s, menu) {
		super(p, "", function() {
			m.Global.SBANK.UI_select(1);
			m.Global.ME.run(menu, function() new m.Rate(-1), false);
		});
		setSize(35, 35);

		hasClickFeedback = false;
		setBg(s);
	}
}
