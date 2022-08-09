package mt.pix;
import flash.display.BitmapData;

#if haxe3 
typedef Hash<T> = haxe.ds.StringMap<T>;
typedef IntHash<T> = haxe.ds.IntMap<T>;
#end

#if(nme||flax)
enum NMETileMode
{
	NTM_NONE;
	NTM_SINGLE;
	NTM_COMMIT_TO_STORE;
	
	NTM_NO_DRAW;
}
#end


class Store {
	var lastIndex:Int;
	var ddx:Int;
	var ddy:Int;
	
	public var timelines:Hash<Array < Int >> ;
	public var index:Hash<Int>;
	public var frames:Array<Frame>;
	public var texture:BitmapData;
	
	#if(nme||flax)
	public var	nmeTs : nme.display.Tilesheet;
	public var	nmeDrawTileMode : NMETileMode;
	public var 	nmeTileData : Array<Float>;
	public var	nmeDrawSurface : nme.display.Shape;
	var 		nmeTsIdx : Int;
	public var 	nmeElements : List<Element>;
	#end

	public function new( bmp:BitmapData ) {
		texture = bmp;
		frames = [];
		ddx = 0;
		ddy = 0;
		lastIndex = 0;
		index = new Hash();
		timelines = new Hash();
		
		#if(nme||flax)
		nmeTs = new nme.display.Tilesheet(bmp);
		nmeDrawTileMode  = NTM_NONE;
		nmeTileData = [];
		nmeElements = new List<Element>();
		nmeDrawSurface = new nme.display.Shape();
		#end
	}
	
	// TOOLS - REGISTER
	public function addFrame( x, y, w, h, flipX=false, flipY=false, ?rot ) {
		var fr = new Frame( texture, x, y, w, h, flipX, flipY, rot );
		fr.ddx = ddx;
		fr.ddy = ddy;
		frames.push(fr);
		
		#if(nme||flax)
		//wtf is ddx,ddy 
		nmeTs.addTileRect( new nme.geom.Rectangle(x, y, w, h) );
		fr.nmeFr = nmeTsIdx++;
		#end
		return fr;
	}
	
	public function slice( sx, sy, w, h, xmax=1, ymax=1, flipX=false, flipY=false, ?rot ) {
		for( y in 0...ymax ) {
			for( x in 0...xmax ) {
				addFrame( sx + x * w, sy + y * h, w, h, flipX, flipY, rot );
			}
		}
	}
	
	public function slice90( sx, sy, w, h, xmax = 1, ymax = 1) {
		for( n in 0...4 ) {
			slice(sx, sy, w, h, xmax, ymax, false, false, n * 1.57);
		}
	}
	
	public function addIndex(str:String) {
		index.set(str, frames.length);
		lastIndex = frames.length;
	}
	
	public function addAnim(str:String, frames:Array<Int>, ?rythm:Array<Int>, multi=1 ) {
		var a = [];
		var id = 0;
		for( n in frames ) {
			var max = 1;
			if( rythm != null ) {
				if( id < rythm.length )	max = rythm[id];
				else					max = rythm[rythm.length - 1];
			}
			for( i in 0...max) a.push(n + lastIndex);
			id++;
		}
		if( multi > 1 ) {
			for( k in 0...multi ) {
				var b = [];
				var inc =  k*a.length;
				for ( n in a ) b.push(n + inc );
				timelines.set(str + "_" + k, a);
			}
		} else {
			timelines.set(str, a);
		}
	}
	
	// OTHER TOOLS
	public function setOffset(dx=0,dy=0) {
		ddx = dx;
		ddy = dy;
	}
	
	public function swapTexture(bmp) {
		texture = bmp;
		for( fr in frames ) fr.texture = texture;
	}
	
	#if !(nme||flax)
	public function makeTransp(color) {
		texture.threshold(texture, texture.rect, new flash.geom.Point(0, 0), "==", color, 0);
	}
	#end
	
	// TOOLS - GET
	public function get(id:Null < Int >= 0, ?str:String) {
		if ( str != null ) id += index.get(str);
		return frames[id];
	}
	
	public function getLength() {
		return frames.length;
	}
	
	public function getTimeline(str:String) {
		return timelines.get(str);
	}
	
	public function dumpTimelines() {
		for( t in timelines.keys())
			trace(t + " -> " + timelines.get(t));
	}
	
	public function getIds() {
		var a = [];
		for ( n in index ) a.push(n);
		var f = function(a:Int, b:Int) {return (a < b)?-1:1;}
		a.sort(f);
		return a;
	}
	
	#if(nme||flax)
	public function getSurface()
	{
		return nmeDrawSurface;
	}
	
	public function update()
	{
		#if !flax
		if ( nmeDrawTileMode == NTM_COMMIT_TO_STORE)
		{
			nmeTileData.splice(0,nmeTileData.length);
			for ( n in nmeElements)
			{
				var c = n.nmeChunk;
				nmeTileData.push( c[0]);//x
				nmeTileData.push( c[1]);//y
				nmeTileData.push( c[2]);//fr
			}
			var gfx = nmeDrawSurface.graphics;
			gfx.clear();
			nmeTs.drawTiles( gfx, nmeTileData, false, 0 );//keep frame aspect for now...
		}
		#end
	}
	
	public function reg( e: Element)
	{
		nmeElements.push( e );
	}
	
	public function unreg( e: Element)
	{
		nmeElements.remove(e);
	}
	#end
}
