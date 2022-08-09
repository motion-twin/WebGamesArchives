package ui;

import mt.deepnight.slb.BSprite;

class UrlTinyButton extends Button {
	var url			: String;

	public function new(p, s:BSprite, url:String) {
		super(p, "", openUrl);

		this.url = url;
		setSize(35, 35);

		hasClickFeedback = false;
		setBg(s);
	}

	function openUrl() {
		var r = new flash.net.URLRequest(url);
		flash.Lib.getURL(r);
	}
}
