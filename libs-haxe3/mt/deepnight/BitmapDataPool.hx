package mt.deepnight;

import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.MLib;

private class BitmapCanvas {
	public var bd		: BitmapData;
	var id				: String;
	var pt0				: flash.geom.Point;

	public function new(p:BitmapDataPool, id:String, w:Float,h:Float) {
		this.id = id;
		bd = new flash.display.BitmapData(MLib.round(w),MLib.round(h),true,0x0);
		pt0 = new flash.geom.Point();
		p.addBitmapData(id, bd);
	}

	public function dot(w:Int, col:UInt, ?a=1.0) {
		for(x in 0...w)
			for(y in 0...w)
				bd.setPixel32(Std.int(bd.width*0.5-w*0.5+x), Std.int(bd.height*0.5-w*0.5+y), alpha(col,a));
	}

	public function line(w:Int, col:UInt, ?a=1.0) {
		for(x in 0...w)
			bd.setPixel32(Std.int(bd.width*0.5-w*0.5+x), Std.int(bd.height*0.5), alpha(col,a));
	}

	public function box(w:Int, h:Int, col:UInt, ?a=1.0) {
		for(x in 0...w)
			for(y in 0...h)
				bd.setPixel32(Std.int(bd.width*0.5-w*0.5+x), Std.int(bd.height*0.5-h*0.5+y), alpha(col,a));
	}

	public function circle(r:Float, col:UInt, ?a=1.0) {
		var s = new flash.display.Sprite();
		s.graphics.lineStyle(1,col,a);
		s.graphics.drawCircle(bd.width*0.5,bd.height*0.5,r);
		bd.draw(s);
	}

	public function disc(r:Float, col:UInt, ?a=1.0) {
		var s = new flash.display.Sprite();
		s.graphics.beginFill(col,a);
		s.graphics.drawCircle(bd.width*0.5,bd.height*0.5,r);
		bd.draw(s);
	}

	inline function alpha(c:Int, ?a=1.0) return Color.addAlphaF(c,a);

	public function filter(f:flash.filters.BitmapFilter) {
		bd.applyFilter(bd, bd.rect, pt0, f);
	}
}

class BitmapDataPool {
	var pool			: Map<String, Array<BitmapData>>;

	public function new() {
		pool = new Map();
	}

	public function addDisplayObject(id:String, o:DisplayObject, ?padding=0) {
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

	public function getOrCreate(id:String, create:Void->Array<DisplayObject>, ?padding=0, ?rndFunc:Int->Int) {
		if( exists(id) )
			return get(id);
		else {
			for(o in create())
				addDisplayObject(id, o, padding);

			return getRandom(id, rndFunc);
		}
	}

	public function initIfNeeded(id:String, w:Float, h:Float, create:BitmapCanvas->Void) {
		if( !exists(id) )
			create( createCanvas(id,w,h) );
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

	public function addFromLib(tiles:mt.deepnight.slb.BLib, ids:Array<String>) {
		for(k in ids)
			addBitmapData( k, tiles.getBitmapData(k) );
	}

	public inline function get(id:String, ?n=0) {
		return pool.get(id)[n];
	}

	public inline function getRandom(id:String, ?rndFunc:Int->Int) {
		var a = pool.get(id);
		return a[ rndFunc!=null ? rndFunc(a.length) : Std.random(a.length) ];
	}

	public function createCanvas(id:String, w,h) {
		return new BitmapCanvas(this, id, w,h);
	}


	public function destroy() {
		for( a in pool )
			for( bd in a )
				bd.dispose();
		pool = null;
	}
}