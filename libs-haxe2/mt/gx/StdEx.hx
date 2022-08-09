package mt.gx;

class StdEx
{
	public static function parseBool( str : String  ) : Null<Bool>
	{
		if (str == null) return null;
		
		switch(str.toLowerCase())
		{
			case "true", "1": return true;
		}
		
		return false;
	}
	
	//current ammount of seconds ellapsed since *we dont'care*
	public static function time() : Float
	{
		#if neko
		return neko.Sys.time();
		#elseif (flash||nme)
		return flash.Lib.getTimer() * 0.001;
		#elseif js
		return  Date.now().getTime()  * 0.001;
		#else
		return 0.0;
		#end
	}
	
	public static function format( t : String, ?params : Dynamic )
	{
		if( params != null ) {
			for( f in Reflect.fields(params) )
				t = t.split("::"+f+"::").join(Std.string(Reflect.field(params,f)));
		}
		return t;
	}

	
}