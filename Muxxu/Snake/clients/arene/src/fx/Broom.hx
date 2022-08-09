package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Broom extends CardFx {//}
	
	var timer:Int;
	
	public function new(ca) {
		super(ca);
		timer = 0;
	}
	

	override function update() {
		super.update();
		
		if( timer++ % 5 == 0 ) {
			var bmp = Stage.me.gore.bitmapData;
			var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -10);
			bmp.colorTransform(bmp.rect,ct);
			Stage.me.renderBg(bmp.rect);
		}

		
	}
	
	
//{
}












