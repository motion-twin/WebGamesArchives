package mt.gx;


class Debug
{
	public static function assert( o : Null<Dynamic>, ?s:String, ?pos : haxe.PosInfos  ) : Dynamic
	{
		if ( o == false || o ==null)
		{
			if (s!=null)
				throw "Assertion failed : " + (s);
			else
 				throw "assert";
		}
		return null;
	}
	
	public static function nz(v)
	{
		assert( v != 0.0);
	}
	
	
	public static function brk( _Str : String, ?pos : haxe.PosInfos  ) : Dynamic
	{
		throw _Str;
		return null;
	}
	
	public static function msg( o : Dynamic, ?pos : haxe.PosInfos  )
	{
		#if neko
		o = o + "<br/>";
		#end
		haxe.Log.trace( o , pos);
	}
	
	
}