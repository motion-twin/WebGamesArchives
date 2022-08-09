package ui;

import mt.deepnight.slb.BSprite;

class TwitterButton extends ShareButton {
	public function new(p, msg:String) {
		super(p, m.Global.ME.tiles.get("btnTwitter"), msg);
	}

	override function onShare() {
		super.onShare();
		Sharer.toTwitter(msg, "http://uppercup-football.com", ["Uppercup"]);
		
		Ga.social( Twitter, "share", "http://uppercup-football.com");
	}
}
