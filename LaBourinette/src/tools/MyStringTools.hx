package tools;

class MyStringTools {

	public static function doubleToHex( f:Float ) : String {
		var x = new haxe.io.BytesOutput();
		x.writeDouble(f);
		var c = new haxe.BaseCode(haxe.io.Bytes.ofString("0123456789ABCDEF"));
		var x = c.encodeBytes(x.getBytes());
		return x.toString();
	}

	public static function format( t : String, ?params : Dynamic ) {
		if( params != null ) {
			for( f in Reflect.fields(params) )
				t = t.split("::"+f+"::").join(Std.string(Reflect.field(params,f)));
		}
		return t;
	}
}
