package mt.deepnight;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

class IconLoader {
	var cache				: Hash<BitmapData>;
	var basePath			: String;
	public var defWid		: Int;
	public var defHei		: Int;
	public var defExtension	: String;
	
	public function new(w,h, path:String) {
		basePath = path;
		if ( basePath.length>0 && basePath.charAt(basePath.length-1) != "/" )
			basePath += "/";
		defWid = w;
		defHei = h;
		defExtension = "png";
		cache = new Hash();
	}
	
	inline function getKey(n,f) {
		return f+"/"+n;
	}
	
	public function get(name:String, ?w:Int,?h:Int, ?folder="") {
		var k = getKey(name,folder);
		if ( !cache.exists(k) ) {
			if (w==null) w = defWid;
			if (h==null) h = defHei;
			var bd = new BitmapData(w,h,true,0x0);
			cache.set(k, bd );
			if ( name.indexOf(".")<0 )
				name+="."+defExtension;
			var url = new flash.net.URLRequest( basePath+folder+"/"+name );
			var loader = new flash.display.Loader();
			loader.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, callback(onLoadError,k));
			loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, callback(onLoadComplete,k, loader));
			loader.load(url);
		}
		return new Bitmap(cache.get(k));
	}
	
	public inline function getSprite(name, ?w,?h,?folder) : Sprite {
		var o = new flash.display.Sprite();
		o.addChild( get(name,w,h,folder) );
		return o;
	}
	public inline function getMovieClip(name, ?w,?h,?folder) : MovieClip {
		var o = new flash.display.MovieClip();
		o.addChild( get(name,w,h,folder) );
		return o;
	}
	
	function onLoadError(k:String, _) {
		#if debug
			trace("warning : icon ["+k+"] not found");
		#end
		var bd = cache.get(k);
		var spr = new flash.display.Sprite();
		var g = spr.graphics;
		g.lineStyle(4, 0xFFA57D,1);
		g.moveTo(2, 2);
		g.lineTo(bd.width-2, bd.height-2);
		g.moveTo(bd.width-2, 2);
		g.lineTo(2, bd.height-2);
		bd.fillRect(bd.rect, 0xffBB0000);
		bd.draw(spr);
	}
	
	function onLoadComplete(k:String, loader:flash.display.Loader, _) {
		var bd = cache.get(k);
		bd.draw( loader.content );
	}
}