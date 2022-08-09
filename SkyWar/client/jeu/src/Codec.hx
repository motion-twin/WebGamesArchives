class Codec extends mt.net.Codec {
	inline public function encode( str:String ){
		return run(str);
	}
	inline public function decode( str:String ){
		return run(str);
	}
}

class CodecX {

	static var IDCHARS = "$uasxIIntfo";
	public static var BASE64 = ":_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

	var str : String;
	var key : String;
	var ikey : Int;
	var pkey : Int;
	var crc : Int;

	public function new(key : String) {
		this.key = key;
		ikey = 0;
		for(i in 0...key.length){
			ikey *= 51;
			ikey += key.charCodeAt(i);
			ikey  = untyped ikey & 0xFFFFFFFF;
		}
	}

	function makeCrcString() {
		return
			BASE64.charAt(crc & 63) +
			BASE64.charAt((crc >> 6) & 63) +
			BASE64.charAt((crc >> 12) & 63) +
			BASE64.charAt((crc >> 18) & 63) +
			BASE64.charAt((crc >> 24) & 63)
		;
	}

	public function encode(o:Dynamic) : String {
		pkey = 0;
		crc = 0;
		str = "";
		encodeAny(o);
		str += makeCrcString();
		return str;
	}

	public function decode(s : String ) : Dynamic {
		pkey = 0;
		crc = 0;
		str = s;
		var o = decodeAny();
		var crc = makeCrcString();
		if( str != crc )
			throw "Decode CRC error : "+str+" != "+crc+" (o="+o+")";
		return o;
	}

	function writeStr(s : String) {
		for(i in 0...s.length)
			writeChar(s.charAt(i));
	}

	function writeChar(c) {
		var p = BASE64.indexOf(c,0);
		if( p == -1 ) {
			str += c;
			return;
		} else {
			var out = p ^ ((ikey >> pkey) & 63);
			crc *= 51;
			crc += out;
			crc = crc ^ 0xFFFFFFFF;
			str += BASE64.charAt(out);
		}
		pkey += 6;
		if( pkey >= 28 )
			pkey -= 28;
	}

	function readChar() {
		var cc = str.charAt(0);
		var c = BASE64.indexOf(cc,0);
		str = str.substr(1);
		if( c == -1 )
			return cc;
		crc *= 51;
		crc += c;
		crc = crc ^ 0xFFFFFFFF;
		c = c ^ ((ikey >> pkey) & 63);
		pkey += 6;
		if( pkey >= 28 )
			pkey -= 28;
		return BASE64.charAt(c);
	}

	function readStr() {
		var s = "";
		while( true ) {
			var c = readChar();
			if( c == null )
				return null;
			if( c == ":" )
				break;
			s += c;
		}
		return s;
	}

	function encodeArray( o : Array<Dynamic> ) {
		writeStr(Std.string(o.length));
		writeStr(":");
		for(v in o)
			encodeAny(v);
	}

	function encodeObject( o : Dynamic ) {
		for (f in Reflect.fields(o)){
			writeStr(f);
			writeStr(":");
			encodeAny(Reflect.field(o,f));
		}
		writeStr(":");
	}

	function encodeAny( o : Dynamic ) {
		if (o == null)
			writeStr(IDCHARS.charAt(1));
		else if (Std.is(o,Array)){
			writeStr(IDCHARS.charAt(2));
			encodeArray(untyped o);
		}
		else switch (untyped __typeof__(o)){
		case "string":
			writeStr(IDCHARS.charAt(3));
			writeStr(untyped o);
			writeStr(":");
		case "number":
			var n : Int = untyped o;
			/*
			if( Std.isNaN(n) )
				writeStr( IDCHARS.charAt(4) );
			else if( n == downcast(Std).infinity )
				writeStr( IDCHARS.charAt(5) );
			else if( n == -downcast(Std).infinity )
				writeStr( IDCHARS.charAt(6) );
			else {
			*/
				//n = Int(n);
				writeStr( IDCHARS.charAt(7) );
				if( n < 0 ) writeStr( IDCHARS.charAt(1) );
				writeStr(Std.string(Math.abs(n)));
				writeStr(":");
			//}
		case "boolean":
			if (untyped o == true)
				writeStr(IDCHARS.charAt(8));
			else
				writeStr(IDCHARS.charAt(9));
		default:
			writeStr(IDCHARS.charAt(10));
			encodeObject(untyped o);
		}
	}

	function decodeArray() {
		var n = Std.parseInt(readStr());
		var a = new Array();
		for(i in 0...n)
			a.push(decodeAny());
		return a;
	}

	function decodeObject() {
		var o = {};
		while( true ) {
			var k = readStr();
			if( k == null )
				return null;
			if( k == "" )
				break;
			var v = decodeAny();
			Reflect.setField(o, k, v);
		}
		return o;
	}

	function decodeAny() : Dynamic {
		var c = readChar();
		switch( c ) {
		case IDCHARS.charAt(1): return null;
		case IDCHARS.charAt(2): return decodeArray();
		case IDCHARS.charAt(3): return readStr();
//		case IDCHARS.charAt(4): return Std.cast(null * 1); // NaN
//		case IDCHARS.charAt(5): return downcast(Std).infinity;
//		case IDCHARS.charAt(6): return Std.cast(-downcast(Std).infinity);
		case IDCHARS.charAt(7):
			var neg = readChar();
			var str = readStr();
			var n;
			if( neg == IDCHARS.charAt(1) )
				n = -Std.parseInt(str);
			else
				n = Std.parseInt(neg+str);
			return n;
		case IDCHARS.charAt(8): return true;
		case IDCHARS.charAt(9): return false;
		case IDCHARS.charAt(10): return decodeObject();
		default:
			return null;
		}
	}
}
