import HashEx;
import IntHashEx;

class TextEx
{

	public static var VOWELL = ['a', 'e', 'i', 'o', 'u','y'];
	public static var CONSONANT = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'z'];
	public static var ALL :String = 'abcdefghijklmnopqrstuvwxyz';
	public static var ALL_UP :String = 'abcdefghijklmnopqrstuvwxyz'.toUpperCase();
	
	public static inline function format( t : String, ?params : Dynamic )
	{
		return formatWithBounds( t , "::", params);
	}
	
	public static inline function attrify( s )
	{
		return s
		.split("'").join("\'")
		.split('"').join('\"')
		//.split("'").join("_")
		.split("è").join("&egrave;");
	}
	
	public static inline function contains(str:String,pat:String) {
		return str.indexOf( pat ) >= 0;
	}
	
	public static inline function formatWithBounds( t : String, bounds:String, ?params : Dynamic )
	{
		if( params != null ) {
			for( f in Reflect.fields(params) )
				t = t.split(bounds+f+bounds).join(Std.string(Reflect.field(params,f)));
		}
		return t;
	}
	
	public static var regx : Hash<EReg>= new Hash();
	
	public static function formatWithBoundsAndCbk( t : String, bounds:String, cbk : String->String )
	{
		var r = regx.get(bounds);
		if ( r == null)
		{
			var patt = bounds + "([a-zA-Z0-9_]*)"+bounds;
			r = new EReg( patt, "g");
			regx.set(bounds, r);
		}
		
		Debug.ASSERT( t != null );
		return r.map(t,
			function( re:EReg){
				var p = re.matchedPos();
				var id = re.matched(1);
				return cbk( id );
			}
		);
	}
	
	public static function elapsed( date:Date  ) : String
	{
		var d = DateTools.parse( Date.now().getTime() - date.getTime());
		
		var t = 
		if( (d.days > 0) )
			Text.days_ago( d );
		else if( d.hours > 0)
			Text.hours_ago( d );
		else if( d.minutes > 0)
			Text.minutes_ago( d );
		else
			Text.recently;
			
		return t;
	}
	
	#if neko
	public static function tipify(id : String ) : String
	{
		var resp : { name:String, desc:String } = handler.Main.sidFind(id);

		if( resp == null || resp.name == "TODO") return id;
		
		#if debug
		if( resp == null) 		throw "BAD ID :"+id;
		if( resp.name == null) 	throw "BAD DESC :"+id;
		if( resp.desc == null) 	throw "BAD NAME :"+id;
		#end
		
		return new Tag("em")
		.attr("class", "em_lookup_id")
		.tip(resp.name, resp.desc )
		.content(resp.name)
		.toString();
		
		return "";
	}
	#end
	
	public static function quickFormat( st : String )
	{
		if ( st == null) return st;
		
		st = mt.deepnight.Lib.replaceTag(st, "*", "<strong>", "</strong>");
		st = mt.deepnight.Lib.replaceTag(st, "||", "<em>", "</em>");
		st = TextEx.formatWithBoundsAndCbk(st, ":", Gen.USER_TXT.generate);
		return st;
	}
	
	public static function htmlList( a : Iterable<String> )
	{
		var base =  "<ul>";
		for( s in a )
			base += "<li>"+s+"</li>";
		base += "</ul>";
		return base;
	}
	
}