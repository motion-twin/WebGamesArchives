class Base64 {

	static var BASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	public static var BASEU = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_/";

	public static function encode( str:String ){
		return haxe.BaseCode.encode(str, BASE);
	}

	public static function decode( str:String ){
		return haxe.BaseCode.decode(str, BASE);
	}
}
