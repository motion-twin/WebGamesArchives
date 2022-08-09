package fx.morph;
import mt.bumdum9.Lib;

class Twister extends fx.Morpher {//}


	
	public function new(z) {
		super(z);

		// MORPH
		var cx = morph.width * 0.5;
		var cy = morph.height * 0.5;
		for( x in 0...morph.width ) {
			for( y in 0...morph.height ) {
				var dx = x - cx;
				var dy = y - cy;
				var a = Math.atan2(dy, dx) + 1.57;
				var dist = Math.sqrt(dx * dx + dy * dy);
				var d = 128;
				var r = 128 + Std.int(Math.cos(a) * d);
				var g = 128 + Std.int(Math.sin(a) * d);
				var b = 128;
				var color = Col.objToCol( { r:r, g:g, b:b } );
				morph.setPixel(x, y, color);
			}
		}
		
		//showMorph();
	}
			
	override function update() {
		super.update();
		
		coef = Math.min(coef + 0.1, 1);
		
		dis.scaleX = dis.scaleY = coef*12/zoom;
		
		var base = bmp.clone();
		bmp.applyFilter(base, base.rect, new flash.geom.Point(0, 0), dis);
		
		var co = 1.01;
		//if( Game.me.gtimer%2 == 0 ) bmp.colorTransform( bmp.rect, new flash.geom.ColorTransform(co,co,co,1,2,2,1,0) );
		
		screen.blendMode = flash.display.BlendMode.OVERLAY;
		
		//screen.blendMode = flash.display.BlendMode.SCREEN;
		
		/*
		var m = new flash.geom.Matrix();
		m.scale(1/zoom,1/zoom);
		bmp.draw( Scene.me.bg, m, new flash.geom.ColorTransform(1, 1, 1, 0.1, 0, 0, 0, 0));
		*/
		
	}

	
//{
}










