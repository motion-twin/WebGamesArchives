package ui;

import mt.deepnight.slb.BSprite;

class FacebookButton extends ShareButton {
	public function new(p, url) {
		super(p, m.Global.ME.tiles.get("btnFb"), url);
	}

	override function onShare() {
		super.onShare();
		Sharer.toFacebook(msg);
		
		Ga.social( Facebook, "share", "http://uppercup-football.com");
	}
}
