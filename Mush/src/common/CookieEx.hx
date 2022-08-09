import HashEx;
import haxe.Serializer;
import haxe.ds.StringMap;

class CookieEx
{
	//false means minimized
	public static var objectiveTable : StringMap<Bool> /*= new Hash()*/;
	
	public static function read()
	{
		var g : String;
		
		#if js
		g = js.Cookie.get( "objectiveTable" );
		#end
		
		#if neko
		g = neko.Web.getCookies().get(  "objectiveTable" );
		#end
		
		if (g != null )
		{
			objectiveTable = haxe.Unserializer.run( g );
		}
		else
		{
			objectiveTable = new StringMap<Bool>();
		}
	}
	
	public static function flush()
	{
		#if js
		js.Cookie.set( "objectiveTable" , haxe.Serializer.run( objectiveTable ));
		#end
		
		#if neko
		neko.Web.setCookie( "objectiveTable" , StringTools.urlEncode(haxe.Serializer.run( objectiveTable )));
		#end
	}
	
}