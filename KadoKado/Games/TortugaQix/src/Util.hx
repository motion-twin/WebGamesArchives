class Util {
	public static function colorToString( c:UInt ){
		var a : UInt = (c & 0xFF000000) >> 24;
		var r : UInt = (c & 0x00FF0000) >> 16;
		var g : UInt = (c & 0x0000FF00) >> 8;
		var b : UInt = (c & 0x000000FF);
		return 	"argb("+a+","+r+","+g+","+b+")";
	}

	public static function randomBetween(min:Float, max:Float) : Float {
		return min + (max-min)*Math.random();
	}

	public static function squareDist( a:geom.Pt, b:geom.Pt ){
		return
			(a.x - b.x) * (a.x - b.x) +
			(a.y - b.y) * (a.y - b.y);
	}
}