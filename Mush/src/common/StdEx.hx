package ;
import mt.Assert;

/**
 * ...
 * @author de
 */

class StdEx
{
	public static function id() { }
	
	public static function parseBool( str : String  ) : Null<Bool>
	{
		if (str == null) return null;
		var s = str.toLowerCase();
		
		return 
		if( s=="1"||StringTools.startsWith(s,'true'))
			true;
		else 
			false;
	}
	
	//current ammount of seconds ellapsed since *we dont'care*
	public static function time() : Float
	{
		#if neko
		return Sys.time();
		#elseif flash
		return flash.Lib.getTimer() * 0.001;
		#elseif js
		return  Date.now().getTime()  * 0.001;
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

	public static function lsFlags<T:EnumValue>( e:Enum<T>, v : haxe.EnumFlags<T> )
	{
		var l = [];
		var ival = v.toInt();
		for ( a in Type.allEnums(e))
		{
			var idx = Type.enumIndex( a );
			if ( (ival & (1<<idx)) != 0 )
				l.push( a);
		}
		return l;
	}
	
	public static function inject( o : Dynamic , add: Dynamic) {
		Assert.notNull(o);
		Assert.notNull(add);
		for ( a in Reflect.fields(add)) 
			Reflect.setProperty(o, a, Reflect.getProperty(add, a));
		return o;
	}
	
	
}