package mt;

class Lib {

	public static function inflate(src : haxe.io.Bytes, bufsize : Int ) {
		#if cpp
		var zl = new haxe.zip.Uncompress( -15);
		zl.setFlushMode(haxe.zip.FlushMode.SYNC);
		var b = haxe.io.Bytes.alloc(bufsize);
		var readpos = 0;
		var writepos = 0;
		var t = zl.execute(src, readpos, b , writepos);
		if (!t.done) throw "you should wait a final fix or prepare a buffer with right size.";
		zl.close();
		return b;
		#elseif flash
		var b = haxe.io.Bytes.alloc(bufsize);
		b.blit( 0, src, 0, src.length);
		var data = b.getData();
		data.position = 0;
		data.inflate();
		data.position = 0;
		return b;
		#else
		//might not allways work
		return haxe.zip.Uncompress.run(src, bufsize);
		#end
	}

	#if mBase
	static var 			isWindows =
		#if sys
		Sys.systemName() == "Windows"
		#else
		false
		#end
	;

	static inline var 	MIN = 1000 * 60;
	static inline var 	HOUR = MIN * 60;
	static inline var 	DAY = HOUR * 24;

	inline static function winDate( str ) {
		return isWindows ? haxe.Utf8.encode(str) : str;
	}

	public static function shortDate( d : Date ) : String {
		var times = BaseText.short_times.split("|");
		if( d == null )
			return times[0];
		if ( d.getTime() < 0 )
			return times[0];

		var now = Date.now();
		var dt = now.getTime() - d.getTime();
		var future = false;
		if( dt < 0 ) {
			var ft = BaseText.short_futur_times;
			if( ft != null ) {
				dt = -dt;
				times = ft.split("|");
				future = true;
			}
		}
		if( dt < HOUR )
			return times[1].split("%M").join(Std.string(Math.ceil((dt + 1)/MIN)));
		if( dt < HOUR * 4 ) {
			var h = Std.int(dt / HOUR);
			dt -= h * HOUR;
			return times[2].split("%H").join(Std.string(h)).split("%M").join(Std.string(Std.int(dt/MIN)));
		}
		var today = Date.fromString(now.toString().substr(0, 10) + " 00:00:00");
		dt = today.getTime() - d.getTime();
		if( future )
			dt = -(dt + DateTools.days(1));
		if( dt < 0 )
			return DateTools.format(d,times[3]);
		if( dt < HOUR * 24 )
			return DateTools.format(d,times[4]);

		//return "later";
		if( future )
			return times[5].split("%D").join(Std.string(Math.ceil(dt / DAY)));
		else
			return times[5].split("%D").join(Std.string(Math.floor(dt / DAY) + 1));
	}
	#end

	public static function mapOf( d : Dynamic ) : Map<String,Dynamic>{
		var m = new Map();
		for ( k in Reflect.fields( d ))
			m.set( k, Reflect.getProperty( d, k ));
		return m;
	}

	public static function getNativeCaps() :String {
		return
		#if (mBase&&!standalone)
			mtnative.device.Device.getNativeCaps();
		#elseif flash
			mt.flash.Lib.getNativeCaps();
		#else
			"";
		#end
	}

	public static function lang() : String{
		#if neko
			return Config.LANG;
		#elseif standalone
			return flash.system.Capabilities.language;
		#elseif mBase
			return Device.lang();
		#end
	}
}