package mt.deepnight.mui;

import flash.display.DisplayObject;

class Image extends Component {
	var image		: DisplayObject;
	var padding		: Int;

	public function new(p, image:DisplayObject, ?padding=0, ?onDestroy:Void->Void) {
		super(p);
		this.image = image;
		if( onDestroy!=null )
			this.onDestroy = onDestroy;
		content.addChild(image);
		hasBackground = false;
		this.padding = padding;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		image.x = Std.int(w*0.5 - image.width*0.5);
		image.y = Std.int(h*0.5 - image.height*0.5);
	}

	override function getContentWidth() {
		return super.getContentWidth() + image.width + padding*2;
	}

	override function getContentHeight() {
		return super.getContentHeight() + image.height + padding*2;
	}
}