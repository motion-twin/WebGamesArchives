package mt.deepnight.mui;

import flash.display.DisplayObject;

class IconButton extends Button {
	var icon		: DisplayObject;

	public var padding(default,set)	: Int;

	public function new(p, icon:DisplayObject, cb:Void->Void, ?onDestroy:Void->Void) {
		super(p, "", cb);

		if( onDestroy!=null )
			this.onDestroy = onDestroy;
		this.icon = icon;
		content.addChild(icon);

		padding = 0;
		minWidth = minHeight = 0;
	}

	function set_padding(v) {
		askRender(true);
		return padding = v;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		icon.x = Std.int(w*0.5 - icon.width*0.5);
		icon.y = Std.int(h*0.5 - icon.height*0.5);
	}


	override function getContentWidth() {
		return super.getContentWidth() + icon.width + padding*2;
	}

	override function getContentHeight() {
		return super.getContentHeight() + icon.height + padding*2;
	}
}