package mt;

class Utf8 {

	#if !js
	/**
		Contains the whole ASCII charset.
	**/
	public static var ASCII = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

	/**
		The Latin1 (ISO 8859-1) charset (only the extra chars, no the ASCII part)
	**/
	public static var LATIN1 = "¡¢£¤¥¦§¨©ª«¬-®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ";

	public static var DEFAULT_CHARS = ASCII + LATIN1;

	public static function sanitize(str:String) {
		var s = removeAccents(str);
		return removeAstrals(s);
	}

	/*
	 * Does not take planes into account...maybe we should...idk
	 */
	public static function removeEmojis(str:String) {
		var s = new StringBuf();
		haxe.Utf8.iter( str, function(p) {
			if( !isAstral( p ) )
				s.addChar( p );
		});
		return s.toString();
	}

	//we re all in this together now, aren't we.
	public static function removeAstrals(str:String) {
		return removeEmojis(str);
	}

	public static inline function isAstral(point) {
		return ( point >= 0x10000 && point <= 0x10FFFF );
	}

	public static inline function getPlane(point) : Int	{
		return point >>> 16;
	}

	public static inline function removePlane(point) : Int	{
		return point & 0xffff;
	}
	#end

	#if neko
	// in neko, len is only an initial buffer size
	inline static function _newUtf8(len:Int){
		return new haxe.Utf8( len );
	}
	#elseif cpp
	// in cpp, len is the string length
	inline static function _newUtf8(len:Int){
		return new haxe.Utf8( 0 );
	}
	#end

	public static function removeAccents( s : String ) {
		#if (neko || cpp)
		var b = _newUtf8(s.length);
		haxe.Utf8.iter(s,function(c) {
		#else
		var b = new StringBuf();
		(for( i in 0...s.length ) {
			var c = s.charCodeAt(i);
		#end
			switch( c ) {
			case "é".code, "è".code, "ê".code, "ë".code, "ẻ".code, "ể".code: b.addChar("e".code);
			case "É".code, "È".code, "Ê".code, "Ë".code, "Ẻ".code, "Ể".code: b.addChar("E".code);
			case "à".code, "â".code, "ä".code, "á".code, "ă".code, "ã".code, "å".code, "ả".code, "ẩ".code, "ẳ".code: b.addChar("a".code);
			case "À".code, "Â".code, "Ä".code, "Á".code, "Ă".code, "Ã".code, "Å".code, "Ả".code, "Ẩ".code, "Ẳ".code: b.addChar("A".code);
			case "ù".code, "û".code, "ü".code, "ú".code, "ū".code, "ủ".code, "ử".code: b.addChar("u".code);
			case "Ù".code, "Û".code, "Ü".code, "Ú".code, "Ū".code, "Ủ".code, "Ử".code: b.addChar("U".code);
			case "î".code, "ï".code, "í".code, "ì".code, "ỉ".code: b.addChar("i".code);
			case "Î".code, "Ï".code, "Í".code, "Ì".code, "Ỉ".code: b.addChar("I".code);
			case "ô".code, "ó".code, "ö".code, "õ".code, "ø".code, "ỏ".code, "ổ".code, "ở".code: b.addChar("o".code);
			case "Ô".code, "Ó".code, "Ö".code, "Õ".code, "Ø".code, "Ỏ".code, "Ổ".code, "Ở".code: b.addChar("O".code);
			case "ŷ".code, "ÿ".code, "ý".code, "ỳ".code, "ỷ".code: b.addChar("y".code);
			case "Ŷ".code, "Ÿ".code, "Ý".code, "Ỳ".code, "Ỷ".code: b.addChar("Y".code);
			case "æ".code, "Æ".code: b.addChar("a".code); b.addChar("e".code);
			case "œ".code, "Œ".code: b.addChar("o".code); b.addChar("e".code);
			case "ç".code: b.addChar("c".code);
			case "Ç".code: b.addChar("C".code);
			case "ñ".code: b.addChar("n".code);
			case "Ñ".code: b.addChar("N".code);
			case "š".code: b.addChar("s".code);
			case "Š".code: b.addChar("S".code);
			case "ž".code: b.addChar("z".code);
			case "Ž".code: b.addChar("Z".code);
			default:
				b.addChar(c);
			}
		});
		return b.toString();
	}

	public static var NBSP = "\u00A0"; // UTF8=0xC2A0

	public static function addNbsps<T:String>(str:T) : T {
		str = cast StringTools.replace(str, " !", NBSP+"!");
		str = cast StringTools.replace(str, " ?", NBSP+"?");
		str = cast StringTools.replace(str, " :", NBSP+":");
		str = cast StringTools.replace(str, " ;", NBSP+";");
		str = cast StringTools.replace(str, " / ", NBSP+"/"+NBSP);
		return str;
	}

	public static function uppercase( s : String ) : String {
		#if (flash || js || hl)
		return s.toUpperCase();
		#else
		var r = _newUtf8( s.length );
		haxe.Utf8.iter(s,function(c){
			if( c >= "a".code && c <= "z".code  )
				r.addChar( c - 0x20 );
			else if( c >= "à".code && c <= "ö".code )
				r.addChar( c - 0x20 );
			else if( c >= "ø".code && c <= "þ".code )
				r.addChar( c - 0x20 );
			else
				r.addChar( c );
		});
		return r.toString();
		#end
	}


	public static function lowercase( s : String ) : String {
		#if (flash || js || hl)
		return s.toLowerCase();
		#else
		var r = _newUtf8( s.length );
		haxe.Utf8.iter(s,function(c){
			if( c >= "A".code && c <= "Z".code  )
				r.addChar( c + 0x20 );
			else if( c >= "À".code && c <= "Ö".code )
				r.addChar( c + 0x20 );
			else if( c >= "Ø".code && c <= "Þ".code )
				r.addChar( c + 0x20 );
			else
				r.addChar( c );
		});
		return r.toString();
		#end
	}

	public static function capitalizeWord( s : String ) : String {
		#if (flash || js || hl)
			return uppercase(s.substr(0,1)) + s.substr(1);
		#else
			return uppercase(haxe.Utf8.sub(s,0,1)) + haxe.Utf8.sub(s,1,haxe.Utf8.length(s)-1);
		#end
	}


}
