@:bitmap("assets/title.png") class GfxTitle extends flash.display.BitmapData {}

class TitleLogo extends flash.display.Sprite {
	public function new() {
		super();
		var bmp = new flash.display.Bitmap( new GfxTitle(0,0) );
		addChild(bmp);
		//t.y+=50;
		//t.filters = [ new flash.filters.GlowFilter(0x0,0.25, 16,16,1, 2) ];
		//addChild(t);
	}
}