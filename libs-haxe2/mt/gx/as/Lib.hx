package mt.gx.as;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;

typedef TF = flash.text.TextField;
typedef TFO = flash.text.TextFormat;
typedef MC = flash.display.MovieClip;
typedef SP = flash.display.Sprite;
typedef BMD = flash.display.BitmapData;
typedef BMP = flash.display.Bitmap;
typedef MX = flash.geom.Matrix;
typedef CT = flash.geom.ColorTransform;
typedef PT = flash.geom.Point;

class Lib{
	#if flash
	public inline function domains(){
		var domain = flash.Lib.current.loaderInfo.url.split("/")[2];
		if ( domain.substr(0, 5) == "data." ) flash.system.Security.allowDomain(domain.substr(5));
	}
	#end
	
	public static inline function toFront( mc : DisplayObject ){
		if( mc.parent != null) mc.parent.setChildIndex( mc , mc.parent.numChildren - 1 );
		return mc;
	}

	public static inline function putBefore( mc0 : DisplayObject, mc1 : DisplayObject ){
		detach( mc0);
		var i = mc1.parent.getChildIndex( mc1 );
		mc1.parent.addChildAt( mc0, i + 1 );
	}

	public static inline function putAfter( mc0 : DisplayObject, mc1 : DisplayObject ){
		detach( mc0);
		if ( mc1.parent != null){
			var i = mc1.parent.getChildIndex( mc1 );
			mc1.parent.addChildAt( mc0, i  );
		}
	}

	public static inline function toBack( mc : DisplayObject ) {
		var p = mc.parent;
		if ( p != null) p.setChildIndex( mc , 0);
		return mc;
	}
	
	public static inline function detach(  a : flash.display.DisplayObject ){
		if ( a.parent != null) a.parent.removeChild( a );
	}
		
	public static inline function listChildren( mc : flash.display.DisplayObjectContainer) : List<DisplayObject>
	{
		var v =  new List<DisplayObject>();
		for ( i in 0...mc.numChildren)
			v.add( mc.getChildAt(i) );
		return v;
	}
	
	public static function stopAllAnimation(par:flash.display.DisplayObjectContainer){
		if ( Std.is(par, MovieClip )){
			var par : MovieClip = cast par;
			par.stop();
		}
		
		for ( m in 0...par.numChildren){
			var s = par.getChildAt(m);
			if( Std.is( s , DisplayObjectContainer))
				stopAllAnimation(cast s);
		}
	}
	
}