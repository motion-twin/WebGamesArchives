import mt.bumdum9.Lib;


class Frutibar extends flash.display.Sprite
{//}
	
	
	var bar:pix.Extendable;
	var bg:pix.Extendable;
	var totalWidth:Float;
	var flh:Null<Float>;
	
	public function new(w,skin) {
		super();
		totalWidth = w - 8;
		Inter.me.root.addChild(this);
		
		bg = new pix.Extendable( Gfx.main.get(0, "frutibar_bg"), 4, 8 );
		bar = new pix.Extendable( Gfx.main.get(skin, "frutibar"), 4, 9 );
		addChild(bg);
		addChild(bar);
		bg.setWidth(totalWidth);
	}
	
	public function getMid() {
		return x+bar.width * 0.5;
	}
	
	public function set(c:Float) {
		bar.setWidth( c*totalWidth );
		
	}
	
	public function update() {
		
		// FLASH
		if ( flh != null) {
			flh *= 0.75;
			var inc = Std.int(flh * 255);
			if ( inc < 10 ) {
				inc = 0;
				flh = null;
			}
			Col.setColor(bar, 0, inc );
		}
	}
	
	public function flash(c=1.0) {
		flh = c;
		Col.setColor(bar, 0, Std.int(flh * 255) );
	}
	
//{
}








