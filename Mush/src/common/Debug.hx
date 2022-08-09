
import haxe.CallStack;

class Debug
{
	#if !master 
	public static function NOT_NULL(d : Dynamic )
	{
		ASSERT( d != null );
	}
	#else
	public static inline function NOT_NULL(d : Dynamic ) { return ; };
	#end
	
	#if !master
	public static function NOT_ZERO( d : Int )
	{
		ASSERT( d != 0 );
	}
	#else
	public static inline function NOT_ZERO( d : Int ) { return ; };
	#end
	
	public static inline function getTarget()
	{
		return
		#if neko 
		"neko"
		#elseif flash
		"flash"
		#elseif js
		"js"
		#end
		;
	}
	
	#if !master
	public static inline function ASSERT( o : Bool, ?s:String, ?pos : haxe.PosInfos  ) 
	{
		if ( o == false )//|| _Obj == null )
		{
			if (s!=null)
			{
				throw "Assertion failed : " + (s) + " : " + o;
			}
			else
			{
				throw "Assert failed "+getTarget()+" "+pos.className+" "+pos.fileName+" "+" "+ pos.methodName+" "+pos.lineNumber;
			}
		}
		return null;
	}
	#else
	public static inline function ASSERT( _Obj : Bool, ?_s:String , ?pos : haxe.PosInfos  ) return;
	#end
	
	#if !master
	public static function NOP()
	{
		
	}
	#else
	public static inline function NOP() return;
	#end
	
	#if !master
	public static function ASSERT_MINMAX( obj : Float, min : Float , max: Float ,?_s:String, ?pos : haxe.PosInfos  )
	{
		if ( obj < min || obj > max)
		{
			throw _s + " : " + obj + " not in range ["+min+"..."+max+"]";
		}
	}
	#else
	public static inline function ASSERT_MINMAX( obj : Float, min : Float , max: Float , ?_s:String , ?pos : haxe.PosInfos  ) return;
	#end
	
	
	
	#if !master
	public static function BREAK( _Str : String, ?pos : haxe.PosInfos  ) 
	{
		throw _Str;
		return null;
	}
	#else
	public static inline function BREAK( _Str : String, ?pos : haxe.PosInfos  )
	{
		throw "error  / break ";
		return null;
	}
	#end

	#if !master
	public static function MSG( o : Dynamic, ?pos : haxe.PosInfos  )
	{
		haxe.Log.trace( o /*+" "+ pos*/, pos);
	}
	#else
	public static inline function MSG( o: Dynamic, ?pos : haxe.PosInfos  )
	{
	}
	#end

	
	public static function REPORT( _Str : String, ?pos : haxe.PosInfos  ) 
	{
		throw "Dear user, sorry for the inconvenience : please report this issue to the Motion-Twin support http://support.motion-twin.com " + _Str;
	}
	
	public static function CHECK( o :Dynamic,  ?_Str : String, ?pos : haxe.PosInfos  ) 
	{
		if ( o == null )
		{
			throw "FAILED : NULL " + _Str + pos;
		}
		else if ( o == false )
		{
			throw "FAILED : FALSE " + _Str + pos;
		}
		
		return null;
	}
}