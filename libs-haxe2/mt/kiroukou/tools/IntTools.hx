
package mt.kiroukou.tools;

class IntTools {
	
	inline public static function getBit( v : Int, pos : Int) : Bool {
		return v & (1 << pos) != 0;
	}
	
	inline public static function setBit( v : Int, pos : Int ) : Int {
		return v | 1 << pos;
	}
	
	inline public static function unsetBit( v : Int, pos : Int ) : Int {
		return v & 0xFFFFFFF - (1 << pos);
	}
		
	inline public static function toString(num : Int, base:Int = 2) : String
	{
        var reference = "0123456789ABCDEFGHIJKLMNOPQRSTUVW";
        var result = new StringBuf();
        var maxPow = 0;
        var test = 0;
        while( Std.int(Math.pow(base, maxPow)) <= num)
        {
            maxPow++;
        }

        var i = maxPow - 1;
        while (i > = 0)
        {
            var basePow = Math.pow(base, i);
            var pow = Math.floor(num / basePow);
            result.add(reference.charAt(Std.int(pow)));
            num -= Std.int(pow * basePow);
            i--;
        }
        var r = result.toString();
        return r.length == 0 ? "0" : r;
    }
	
	
	inline public static function toBase255(val:Int):String
	{
		var e = 0;
		var res = "";
		while( true )
		{
			var d = Math.floor( val / Math.pow(255, e++) ) % 255;
			if( d == 0 ) break;
			res = String.fromCharCode(d) + res;
		}
		return res;
	}
}