package ui;

import mt.deepnight.slb.BSprite;

class ShareButton extends Button {
	var msg			: String;
	public function new(p, s:BSprite, msg:String) {
		super(p, "", onShare);

		this.msg = msg;
		setSize(35, 35);
		setBg(s);

		hasClickFeedback = false;
	}

	function onShare() {
	}
}
