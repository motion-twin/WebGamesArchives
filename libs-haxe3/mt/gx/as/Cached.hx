package mt.gx.as;

import flash.display.BitmapData;
import flash.geom.Transform;

class Cached extends flash.display.Bitmap {
	public function new( o : flash.display.DisplayObject ){
		var c = mt.deepnight.Lib.flatten( o , true );
		super(c.bitmapData);
		transform = c.transform;
	}
	
	public function dispose(){
		bitmapData.dispose();
		bitmapData = null;
	}
}