class UID {

	public static var CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	public static function make(n,?r : Int -> Int) {
		var nchars = CHARS.length;
		var k = "";
		if( r == null )
			r = Std.random;
		for( i in 0...n )
			k += CHARS.charAt(r(nchars));
		return k;
	}

}