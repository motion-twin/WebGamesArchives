package fx.morph;
import mt.bumdum9.Lib;

class Waver extends fx.Morpher{//}

	var base:flash.display.BitmapData;
	
	public function new(z) {
		super(z);
		

		var n = 20;
		var cycle  = morph.width / n;
		
		
		for( x in 0...morph.width ) {
			for( y in 0...morph.height ) {
			
				var c  = 0.5 + Math.cos( (x/cycle)*6.28 )*0.5;
				var ec = 128 * Math.pow( (y / morph.height), 1.5 );
				
				var r = 128 + Std.int( c*ec);
				var g = 128;
				var b = 128;
				var color = Col.objToCol( { r:r, g:g, b:b } );
				morph.setPixel(x, y, color);
			}
		}
		
		base = bmp.clone();
		
		//showMorph();
		
	}
			
	override function update() {
		
		
		coef = (coef + 0.05) % 1;
	
		var bh = 1;
		var ymax = Math.ceil(bmp.height / bh);
				
		for( y in 0...ymax ) {
			
			var c = (coef + (y / ymax)*3)%1;
		
			var cx = Math.cos(c * 6.28);
	
			var rect = new flash.geom.Rectangle(0, y*bh, bmp.width, bh);
			//dis.scaleX = cx * 40;
			dis.scaleX = cx * 20 * fadeCoef;
			//dis.mapPoint = new flash.geom.Point(0,0);
				
			bmp.applyFilter(base, rect, new flash.geom.Point(0, y*bh), dis);
		}

		scroll(2);
		
		super.update();
		
		
		/*
		dis.scaleX = dis.scaleY = coef*40;
		bmp.applyFilter(base, base.rect, new flash.geom.Point(0, 0), dis);
		*/
	
	}
	
	function scroll(ww) {
		var line = new flash.display.BitmapData(ww, morph.height, false, 0);
		line.copyPixels( morph, new flash.geom.Rectangle(morph.width-ww, 0, ww, morph.height), new flash.geom.Point(0, 0) );
		morph.scroll(ww,0);
		morph.copyPixels( line, line.rect, new flash.geom.Point(0, 0) );
		line.dispose();
	}

	override function kill() {
		super.kill();
		
	}
	
	
//{
}










