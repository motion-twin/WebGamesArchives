package mt.deepnight.hui;

import h2d.Graphics;
import h2d.Bitmap;
import h2d.Tile;
import h2d.Sprite;

class Image extends Component {
	var img				: Null<h2d.Sprite>;

	public function new(p, ?tile:Tile, ?graphics:Graphics, ?padding=0) {
		super(p);

		if( tile!=null )
			setTile(tile);

		if( graphics!=null )
			setGraphics(graphics);

		style.bg = None;
		style.padding = padding;
		setCursor(Default);

		disableInteractive();
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		if( img!=null ) {
			img.x = Std.int(w*0.5 - img.width*0.5);
			img.y = Std.int(h*0.5 - img.height*0.5);
		}
	}

	public function setGraphics(g:h2d.Graphics) {
		if( img!=null )
			img.dispose();

		img = g;
		content.addChild(img);
	}

	public function setTile(t:h2d.Tile) {
		if( img!=null )
			img.dispose();
		img = new h2d.Bitmap(t, content);
	}

	override function destroy() {
		super.destroy();

		if( img!=null )
			img.dispose();
	}

	override function getContentWidth() {
		return super.getContentWidth() + (img==null ? 0 : img.width);
	}

	override function getContentHeight() {
		return super.getContentHeight() + (img==null ? 0 : img.height);
	}
}