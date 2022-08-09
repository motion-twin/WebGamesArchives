package mt.db;

#if spod_macro
@:require(false,"mt.db.Id has been deprecated, please use spadm.Id instead")
#end
class Id {

	public static function encode( id : String ) : Int {
		var l = id.length;
		if( l > 6 )
			throw "Invalid identifier '"+id+"'";
		var k = 0;
		var p = l;
		while( p > 0 ) {
			var c = id.charCodeAt(--p) - 96;
			if( c < 1 || c > 26 ) {
				c = c + 96 - 48;
				if( c >= 1 && c <= 5 )
					c += 26;
				else
					throw "Invalid character "+id.charCodeAt(p)+" in "+id;
			}
			k <<= 5;
			k += c;
		}
		return k;
	}

	public static function decode( id : Int ) : String {
		var s = new StringBuf();
		if( id < 1 ) {
			if( id == 0 ) return "";
			throw "Invalid ID "+id;
		}
		while( id > 0 ) {
			var k = id & 31;
			if( k < 27 )
				s.addChar(k + 96);
			else
				s.addChar(k + 22);
			id >>= 5;
		}
		return s.toString();
	}

}