package mt.gx;

class Debug
{
	public static function assert( o : Null<Bool>, ?s:String, ?pos : haxe.PosInfos  ) : Dynamic
	{	
		if ( o == null || o == false )
		{
			var info = haxe.CallStack.exceptionStack().join(", ") + "\n\n" + haxe.CallStack.callStack().join(", ");
			if (s!=null)
				throw "Assertion failed ("+o+"): " + (s) + "\n" + info;
			else
				throw "assert ("+o+") \n" + info;
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
	
	public static inline function msg( o : Dynamic, ?pos : haxe.PosInfos  )
	{
		#if !master
			#if neko
			o = o + "<br/>";
			#end			
			
			haxe.Log.trace( o );
		#end
	}
	
	public static inline function dmsg( o : Dynamic, ?pos : haxe.PosInfos  )
	{
		#if (debug && !master)
			#if neko
			o = o + "<br/>";
			#end
			haxe.Log.trace( o , pos);
		#end
	}
}