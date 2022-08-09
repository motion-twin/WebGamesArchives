package mt.gx.as;

import flash.display.BitmapData;
import flash.geom.Transform;
import flash.display.DisplayObject;

using mt.gx.Ex;

class CachedSp extends flash.display.Sprite {
	public var inner : flash.display.Bitmap;
	public var source : DisplayObject; 
	public function new( o : DisplayObject, showOriginal : Bool = false ) {
		super();
		inner =  mt.deepnight.Lib.flatten( o , true );
		transform = inner.transform;
		inner.transform.matrix = new flash.geom.Matrix();
		
		if ( showOriginal) {
			source = o;
			source.detach();
			addChild( source );
		}else 
			addChild(inner);
	}
	
	public function dispose(){
		removeChild(inner);
		inner.bitmapData.dispose();
		inner.bitmapData = null;
		inner = null;
		
		if(source!=null){
			if ( source.parent == this )
				source.detach();
			source = null;
		}
	}
}