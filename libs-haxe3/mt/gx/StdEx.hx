package mt.gx;
import haxe.Timer;

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
	
	public static function format( t : String, ?params : Dynamic )
	{
		if( params != null ) {
			for( f in Reflect.fields(params) )
				t = t.split("::"+f+"::").join(Std.string(Reflect.field(params,f)));
		}
		return t;
	}
	
	/*
	public static function inject( o : Dynamic , add: Dynamic){
		for ( a in Reflect.fields(add)) 
			Reflect.setProperty(o, a, Reflect.getProperty(add,a));
	}
	*/

	
	public static function hasFunction(o:Dynamic,fname:String){
		var c = Type.getClass( o );
		if ( c == null) {
			var  p = Reflect.getProperty( o, fname );
			if ( p == null ) return false;
			return Reflect.isFunction( p );
		}
		else {
			var f = Type.getInstanceFields( c );
			return Lambda.has(f,fname);
		}
	}
	
	
}