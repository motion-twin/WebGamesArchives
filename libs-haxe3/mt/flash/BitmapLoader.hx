package mt.flash;

enum ResizeMode {
	NoResize;
	FitSquare(px:Int);
	FitCropSquare(px:Int);
}

class BitmapLoader {

	public static var MAX_CACHE = 60;
	public static var MAX_CONCURRENT_DOWNLOADS = 2;

	static var CACHE = new Map<String, Null<h2d.Tile>>();
	static var QUEUE : Array<{url:String, onLoad: h2d.Tile->Void, shouldLoad: Null<Void->Bool>, resize: ResizeMode } > = [];
	static var DOWNLOADING	 = 0;

	static function queuePop(){
		var n = QUEUE.shift();
		if( n != null && n.url != null ){
			if( CACHE.get(n.url) != null )
				download( n.url, n.onLoad, n.shouldLoad, n.resize );
			else
				haxe.Timer.delay(function() download( n.url, n.onLoad, n.shouldLoad, n.resize ), 70);
		}
	}

	static function gcCache() {
		var count = Lambda.count(CACHE,function(tile) return tile!=null);
		var todoClean = count - MAX_CACHE;
		if ( todoClean > 0 )
			todoClean = cleanCache( todoClean );

		if ( todoClean > 0 ) {
			// call textureGC to dispose textures not used on last frame
			h3d.Engine.getCurrent().mem.startTextureGC( 1 );
			// retry
			cleanCache( todoClean );
		}
	}

	static function cleanCache( todoClean : Int ) {
		//trace("Try to clean: "+todoClean+" avatars");
		for ( k in CACHE.keys() ) {
			if ( todoClean <= 0 )
				break;

			var tile = CACHE.get(k);
			if ( tile == null )
				continue;

			var tex = tile.getTexture();
			// if texture is not used anymore, texture should be already disposed on GPU by Engine (after X frames)
			// then, clean CPU bitmap
			if ( tex != null && tex.isDisposed() ) {
				tex.destroy(true);
				//trace("remove diposed tex from cache (url=" + k + ")");
				CACHE.remove(k);
				todoClean--;
			}
		}
		return todoClean;
	}

	public static function download( url: String, onLoad: h2d.Tile-> Void, ?shouldLoad:Void->Bool, ?resize:ResizeMode ) : Void {
		if( resize == null )
			resize = NoResize;

		if ( shouldLoad == null )
			shouldLoad = function() return true;

		if (!shouldLoad() ){
			queuePop();
			return;
		}

		if ( url == null ) {
			onLoad( null );
			queuePop();
			return;
		}

		var t = CACHE.get(url);
		if( t != null ){
			onLoad( t );
			queuePop();
			return;
		}

		var alreadyLoading = CACHE.exists(url);
		if ( !alreadyLoading && DOWNLOADING < MAX_CONCURRENT_DOWNLOADS ) {
			gcCache();
			DOWNLOADING++;
			CACHE.set( url, null );

			var l = new flash.display.Loader();

			var ctx = new flash.system.LoaderContext(true);
			var r = new flash.net.URLRequest(url);
			l.load(r, ctx);

			function onError(_) {
				CACHE.remove( url );
				DOWNLOADING--;
				if( shouldLoad() )
					onLoad( null );
				queuePop();
			}

			#if flash
			l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.NETWORK_ERROR, onError );
			#end
			l.contentLoaderInfo.addEventListener( flash.events.SecurityErrorEvent.SECURITY_ERROR, onError );
			l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, onError );
			l.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, function(e:flash.events.Event) {
				gcCache();

				// Download complete
				try {
					var li : flash.display.LoaderInfo = cast e.target;
					var bmp : flash.display.Bitmap = cast li.content;
					var bd = bmp.bitmapData;
					switch( resize ){
						case NoResize:
						case FitSquare(px):
							var s = MLib.fmin( px/bd.width, px/bd.height );
							bd = mt.deepnight.Lib.scaleBitmap(bd, s, true);
						case FitCropSquare(px):
							var s = MLib.fmax( px/bd.width, px/bd.height );
							var nbd = new flash.display.BitmapData( px, px, bd.transparent, 0x0 );
							var m = new flash.geom.Matrix();
							m.scale(s,s);
							m.translate((px-bd.width*s) * 0.5, (px-bd.height*s) * 0.5);
							nbd.draw(bd, m);
							bd.dispose();
							bd = nbd;
					}
					t = h2d.Tile.fromFlashBitmap(bd);
					CACHE.set( url, t );

					if( shouldLoad() )
						onLoad(t);
				}
				catch (e:Dynamic) {
					if( shouldLoad() )
						onLoad( null );
				}
				DOWNLOADING--;
				queuePop();
			});
		}else{
			QUEUE.push( {url: url, onLoad: onLoad, shouldLoad: shouldLoad, resize: resize} );
		}
	}

	public static function isValid( tile : h2d.Tile ){
		if( tile == null )
			return false;
		var tex = tile.getTexture();
		// tex.isDisposed() => GPU mem disposed
		// tex.bmp == null => CPU mem disposed
		if( tex == null || (tex.isDisposed() && tex.bmp==null) )
			return false;
		return true;
	}

}
