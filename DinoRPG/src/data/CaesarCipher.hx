package data;

class CaesarCipher
{
	var key:String;
	var offset:Int;
	var offsets:Array<Int>;
	public function new(offset:Int, key:String)
	{
		this.offset = offset;
		this.key = key;
		offsets = [];
		for( i in 0...key.length )
			offsets[i] = key.charCodeAt(i) - "A".code + offset;
	}
	
	public static function generateRandomKey( length:Int, ?charsToUse:String = "ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz" ) : String
	{
		var res = [];
		var i:Int;
		while(length-- >= 0 ){
			i = Std.random(charsToUse.length);
			res.push(charsToUse.charAt(i));
		}
		return res.join("");
	}
	
	public function encrypt(input:String):String
	{
		var s = "A".code;
		var e = "z".code;
		var d = e-s;
		var output = "";
		for ( i in 0...input.length )
		{
			var c = input.charCodeAt(i);
			if(  c >= s && c <= e )
			{
				var n = input.charCodeAt(i) + offsets[i % key.length] - s;
				while ( n > d )
					n -= d;
				c = s + n;
			}
			output += String.fromCharCode(c);
		}
		return output;
	}
	
	public function decrypt(input:String):String
	{
		var s = "A".code;
		var e = "z".code;
		var d = e-s;
		var output = "";
		for ( i in 0...input.length )
		{
			var c = input.charCodeAt(i);
			if(  c >= s && c <= e )
			{
				var n = input.charCodeAt(i) - offsets[i % key.length] - s;
				while ( n < 0 )
					n += d;
				c = s + n;
			}
			output += String.fromCharCode(c);
		}
		return output;
	}
}