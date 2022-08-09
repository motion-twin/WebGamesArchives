package mt.flash;

#if !flash
	#error "mt.flash.Screenshot only available on Flash"
#end

class Screenshot {
	public static function setCallback( cb : Void -> String ){
		flash.external.ExternalInterface.addCallback('exportScreenshot', cb);
	}

	#if h3d
	public static function exportScene2d( scene : h2d.Scene, scale=0.2 ) {
		var bData : flash.display.BitmapData;
		if( h3d.Engine.getCurrent()!=null && scene != null ) {
			var engine = h3d.Engine.getCurrent();
			var w = engine.width;
			var h = engine.height;

			// apply scale
			scene.scale( scale );
			engine.resize( Std.int(w * scale), Std.int(h * scale) );

			// Render to bitmap
			var s3d : h3d.impl.Stage3dDriver = cast engine.driver;
			s3d.onCapture = function(bmp:hxd.BitmapData) : Void {
				bData = bmp.toNative();
			}
			engine.render( scene );
			s3d.onCapture = null;

			// revert to original scale
			engine.resize( w, h );
			scene.scale( 1 / scale );

			// blur bitmap
			var blurFilter = new flash.filters.BlurFilter(3, 3, flash.filters.BitmapFilterQuality.HIGH);
			bData.applyFilter(bData, bData.rect, new flash.geom.Point(0, 0), blurFilter);
		}
		else
			bData = new flash.display.BitmapData(4,4,false,0x0);

		var encoder = new mt.flash.PngEncoder(bData);
		return haxe.crypto.Base64.encode( haxe.io.Bytes.ofData(encoder.encode()) );
	}
	#end
}
