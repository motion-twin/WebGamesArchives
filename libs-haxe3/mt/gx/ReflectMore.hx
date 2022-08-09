package mt.gx;

class ReflectMore
{
	static var rep : haxe.ds.ObjectMap < Dynamic, List<{ name:String, value:Dynamic }>> =
	new haxe.ds.ObjectMap();
	
	public static function setField( o : Dynamic, f : String, v:Dynamic) {
		var l = null;
		if ( !rep.exists( o ))	
			rep.set( o , l = new List() );
		else 
			l = rep.get( o );
			
		l.push( { name:f, value : v} );
	}
	
	public static function hasField( o : Dynamic, f : String) : Bool
	{
		if ( !rep.exists( o ))	return false;
		
		var l = rep.get( o );
		for ( e in l )
			if ( e.name == f )
				return true;
				
		return false;
	}
	
	public static function field( o : Dynamic, f : String) : Dynamic
	{
		if ( !rep.exists( o ))	return null;
		
		var l = rep.get( o );
		for ( e in l )
			if ( e.name == f )
				return e.value;
				
		return null;
	}
	
	public static function delete( o :Dynamic ) {
		rep.remove( o );
	}
}