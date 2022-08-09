import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Lib;

class BitmapDataPool {
	var pool			: Map<String, Array<BitmapData>>;

	public function new() {
		pool = new Map();
	}

	public function addDisplayObject(id:String, o:flash.display.DisplayObject, ?padding=0) {
		var bmp = Lib.flatten(o, padding);
		if( !pool.exists(id) )
			pool.set(id, [bmp.bitmapData]);
		else
			pool.get(id).push(bmp.bitmapData);
		bmp.bitmapData = null;
	}

	public inline function exists(id:String) {
		return pool.exists(id) && pool.get(id).length>0;
	}

	public function addBitmapData(id:String, ?bd:BitmapData, ?arr:Array<BitmapData>) {
		if( arr!=null ) {
			if( !pool.exists(id) )
				pool.set(id, arr);
			else
				pool.set(id, pool.get(id).concat(arr));
		}
		else if( bd!=null ) {
			if( !pool.exists(id) )
				pool.set(id, [bd]);
			else
				pool.get(id).push(bd);
		}
	}

	public inline function get(id:String, ?n=0) {
		return pool.get(id)[n];
	}

	public inline function getRandom(id:String, ?rndFunc:Int->Int) {
		var a = pool.get(id);
		return a[ rndFunc!=null ? rndFunc(a.length) : Std.random(a.length) ];
	}


	public function destroy() {
		for( a in pool )
			for( bd in a )
				bd.dispose();
		pool = null;
	}
}