package ;

import Protocol;
using Ex;

/**
 * ...
 * @author de
 */

class Locale 
{

	public static function isShortArtFr(str:String):Bool
	{
		var st = str.charAt( 0 ).toLowerCase();
		
		if ( TextEx.VOWELL.has( st ) ) return true;
		if ( st == "h" ) return true;
		return false;
	}
	
	public static function pronom_personnel( gender : Gender ) 
	{
		if ( gender == Male )
			return 'il';
		else 
			return 'elle';
	}
	
	public static function art_le( str : String = "", gender : Gender,surround="") 
	{
		if ( isShortArtFr( str ) )
			return "l'"+surround+str+surround;
		else if (gender == Male )
			return "le "+surround+str+surround;
		else return "la "+surround+str+surround;
	}
	
	public static function art_un( str : String, gender : Gender,surround="") 
	{
		if (gender == Male ) return "un "+surround+str+surround;
		else return "une "+surround+str+surround;
	}
	
	public static function art_au( str : String, gender : Gender,surround="") 
	{
		if ( !isShortArtFr( str ) )
			return "au "+surround+str+surround;
		else if (gender == Male )
			return "à le "+surround+str+surround;
		else return "à la "+surround+str+surround;
	}
	
	public static function art_du( str : String, gender : Gender,surround="") 
	{
		if ( isShortArtFr( str ) )
			return "de l'"+surround+str+surround;
		else if (gender == Male )
			return "du "+surround+str+surround;
		else return "de la "+surround+str+surround;
	}
	
	public static function art_de( str : String, gender : Gender,surround="") 
	{
		if ( isShortArtFr( str ) )
			return "d'"+surround+str+surround;
		else return "de "+surround+str+surround;
	}
	
	public static function fstCap( str : String )
	{
		return str.charAt(0).toUpperCase() + str.substr( 1 );
	}
	
	public static function art_en_a( str : String, gender : Gender,surround="") 
	{
		if ( isShortArtFr( str ) )
			return "an "+surround+str+surround;
		else return "a "+surround+str+surround;
	}
	
	public static function art_es_un( str : String, gender : Gender,surround="") 
	{
		if (gender == Male ) 
			return "un "+surround+str+surround;
		else /*gender==Female*/
			return "una "+surround+str+surround;
	}
	
	public static function art_es_del( str : String, gender : Gender,surround="") 
	{
		if (gender == Male )
			return "del "+surround+str+surround;
		else return "de la "+surround+str+surround;
	}
	
}