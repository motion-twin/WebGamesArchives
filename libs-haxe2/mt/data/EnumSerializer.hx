package mt.data;

@:native("MTE") class EnumSerializer<T> {

	var t : Enum<T>;
	public var a : Array<T>;

	public function new( t : Enum<T>, a : Array<T> ) {
		this.t = t;
		this.a = a;
	}

	function hxSerialize( s : haxe.Serializer ) {
		s.serialize(Type.getEnumName(t));
		if( a == null ) {
			s.serialize("");
			return;
		}
		var buf = new StringBuf();
		var params = new Array<Null<Int>>();
		var values = new Array<Dynamic>();
		for( x in a ) {
			if( x == null ) {
				buf.addChar("X".code);
			} else {
				var idx = Type.enumIndex(x);
				buf.addChar("A".code + (idx & 31));
				buf.addChar("A".code + (idx >> 5));
				var pl = Type.enumParameters(x);
				if( params[idx] == null ) {
					buf.addChar("A".code + pl.length);
					params[idx] = pl.length;
				}
				for( p in pl )
					values.push(p);
			}
		}
		buf.addChar("E".code);
		s.serialize( buf.toString() );
		s.serialize( values );
	}

	function hxUnserialize( s : haxe.Unserializer ) {
		t = cast s.getResolver().resolveEnum(s.unserialize());
		var buf : String = s.unserialize();
		if( buf == "" ) return;
		if( buf.charCodeAt(buf.length - 1) != "E".code )
			throw "assert";
		var values : Array<Dynamic> = s.unserialize();
		var pos = 0;
		var max = buf.length - 1;
		var params = new Array<Null<Int>>();
		this.a = new Array();
		while( pos < max ) {
			var c1 = buf.charCodeAt(pos++) - "A".code;
			if( c1 == "X".code - "A".code ) {
				a.push(null);
				continue;
			}
			var idx = c1 | ((buf.charCodeAt(pos++) - "A".code) << 5);
			var pcount = params[idx];
			if( pcount == null ) {
				pcount = buf.charCodeAt(pos++) - "A".code;
				params[idx] = pcount;
			}
			if( pcount == 0 )
				a.push(Type.createEnumIndex(t,idx));
			else
				a.push(Type.createEnumIndex(t,idx,values.splice(0,pcount)));
		}
	}

}