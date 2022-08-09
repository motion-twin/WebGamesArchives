package data;

class Tools {

	public static function format( text ) {
		text = StringTools.trim(text);
		return ~/\*(.*?)\*/g.replace(text,"<b>$1</b>");
	}

	public static function intArray( str : String ) {
		return Lambda.array(Lambda.map(str.split(";"),Std.parseInt));
	}

	public static function makeId( id : String ) {
		return mt.db.Id.encode(id);
	}

	public static function makeName( id : Int ) {
		return mt.db.Id.decode(id);
	}

	public static function random<T>( a : Array<T>, f : T -> Int, r : neko.Random ) : Int {
		var p = new Array();
		var tot = 0;
		for( x in a ) {
			if( x == null ) {
				p.push(0);
				continue;
			}
			var n = f(x);
			tot += n;
			p.push(n);
		}
		if( tot == 0 )
			return null;
		var n = r.int(tot);
		for( i in 0...p.length ) {
			n -= p[i];
			if( n < 0 )
				return i;
		}
		return null;
	}

}