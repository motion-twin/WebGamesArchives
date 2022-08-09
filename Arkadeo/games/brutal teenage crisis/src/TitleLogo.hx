@:bitmap("assets/logo.png") class GfxLogo extends flash.display.BitmapData {}

class TitleLogo extends flash.display.Sprite {
	public function new() {
		super();
		var bmp = new flash.display.Bitmap( new GfxLogo(0,0) );
		addChild(bmp);
	}
}
