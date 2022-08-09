package mt.gx.as;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.system.Capabilities;

typedef TF = flash.text.TextField;
typedef TFO = flash.text.TextFormat;
typedef MC = flash.display.MovieClip;
typedef SP = flash.display.Sprite;
typedef BMD = flash.display.BitmapData;
typedef BMP = flash.display.Bitmap;
typedef MX = flash.geom.Matrix;
typedef CT = flash.geom.ColorTransform;
typedef PT = flash.geom.Point;

enum PlayerType {
	Plugin;
	Air;
	Standalone;
	External;
}

class Lib{
	#if flash
	public static inline function domains(){
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
	
	public static function mkSquare( gfx : flash.display.Graphics,x,y,sz,col,?alpha = 1.0,?borderCol=0x0,?borderAlpha=1.0){
		if( borderAlpha==null ||borderAlpha<=0)
			gfx.lineStyle( 0.1, borderCol,borderAlpha);
		gfx.beginFill(col,alpha);
		gfx.drawRect(x,y,sz,sz);
		gfx.endFill();
	}
	
	public static function mkCircle( gfx : flash.display.Graphics,x,y,sz,col,?alpha = 1.0,?borderCol=0x0,?borderAlpha=1.0){
		if( borderAlpha==null ||borderAlpha<=0)
			gfx.lineStyle( 0.1, borderCol,borderAlpha);
		gfx.beginFill(col,alpha);
		gfx.drawCircle(x,y,sz);
		gfx.endFill();
	}
	
	public static function mkRect( gfx : flash.display.Graphics,x,y,szx,szy,col,?alpha = 1.0,?borderCol=0x0,?borderAlpha=1.0){
		if( borderAlpha==null ||borderAlpha<=0)
			gfx.lineStyle( 0.1, borderCol,borderAlpha);
		gfx.beginFill(col,alpha);
		gfx.drawRect(x,y,szx,szy);
		gfx.endFill();
	}
	
	public static function removeFilters( obj : flash.display.DisplayObject){
		obj.filters = [];
	}
	
	public dynamic static function getTf(txt:String,?font="nokia",?size:Int = 14,?col:Int = 0x77FF77 ) {
		var t = new flash.text.TextField();
		
		t.width = 800;
		t.height = 800;
		
		t.text = txt;
		
		var tf = new flash.text.TextFormat(font,size,col,true);
		t.embedFonts = true;
		t.setTextFormat( t.defaultTextFormat = tf );
		
		t.multiline = true;
		t.wordWrap = true;
		t.selectable = false;
		t.mouseEnabled = false;
		t.background = false;
		t.filters = [ new flash.filters.GlowFilter( 0, 1, 2, 2, 12 )];
		t.cacheAsBitmap = true;
		
		t.width = t.textWidth + 5;
		t.height = t.textHeight + 5;
		return t;
	}
	
	#if !sys
	public static inline function getPlayerType() : PlayerType {
		var pType:String = Capabilities.playerType;
		
		#if debug
		trace(pType);
		#end
		
		if (pType == "Plugin" || pType == "ActiveX") {/* swf is running a browser */ 	return Plugin;  };
		if (pType == "Desktop") {/* swf is running in a desktop AIR application */		return Air; };
		if (pType == "StandAlone") {/* swf is running in a standalone Flash Player */ 	return Standalone; };
		if (pType == "External") {/* swf is running in the Flash IDE preview player */	return External; };
		
		return null;
	}
	#end
}