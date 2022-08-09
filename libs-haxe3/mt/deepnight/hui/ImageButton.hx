package mt.deepnight.hui;

import h2d.Bitmap;
import h2d.Tile;

class ImageButton extends Button {
	var bmp		: Bitmap;

	public function new(p, tile:Tile, cb:Void->Void) {
		super(p, "", cb);

		bmp = new h2d.Bitmap(tile, content);
		minWidth = minHeight = 0;
		style.paddingExpandsBox = true;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		switch( style.contentHAlign ) {
			case None :
			case Left : bmp.x = 0;
			case Center : bmp.x = Std.int(w*0.5 - bmp.width*0.5);
			case Right : bmp.x = Std.int(w - bmp.width);
		}

		switch( style.contentVAlign ) {
			case None :
			case Top : bmp.y = 0;
			case Center : bmp.y = Std.int(h*0.5 - bmp.height*0.5);
			case Bottom : bmp.y = Std.int(h - bmp.height);
		}
	}

	override function destroy() {
		super.destroy();
		bmp.dispose();
	}

	override function getContentWidth() {
		return super.getContentWidth() + bmp.width;
	}

	override function getContentHeight() {
		return super.getContentHeight() + bmp.height;
	}
}