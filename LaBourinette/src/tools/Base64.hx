package tools;

class Base64 {
	public static var BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-/";
	public static function encode( str:String ) : String {
		return new haxe.BaseCode(haxe.io.Bytes.ofString(BASE64)).encodeString(str);
	}
	public static function encodeBytes( str:haxe.io.Bytes ) : String {
		return (new haxe.BaseCode(haxe.io.Bytes.ofString(BASE64)).encodeBytes(str)).toString();
	}
	public static function decode( str:String ) : String {
		return new haxe.BaseCode(haxe.io.Bytes.ofString(BASE64)).decodeString(str);
	}
	public static function decodeBytes( str:String ) : haxe.io.Bytes {
		return new haxe.BaseCode(haxe.io.Bytes.ofString(BASE64)).decodeBytes(haxe.io.Bytes.ofString(str));
	}
}