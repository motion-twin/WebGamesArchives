package tools;

class LambdaTools {
	public static function find<T>( l:Iterable<T>, f:T->Bool) : T {
		for (v in l)
			if (f(v))
				return v;
		return null;
	}

	public static function filter<T>( l:Iterable<T>, f:T->Bool) : List<T> {
		var result = new List();
		for (v in l)
			if (f(v))
				result.push(v);
		return result;
	}

	public static function count<T>( l:Iterable<T>, f:T->Bool ) : Int {
		var result = 0;
		for (v in l)
			if (f(v))
				result++;
		return result;
	}

	public static function slice<T>( l:Iterable<T>, pos:Int, ?end:Null<Int>=null ) : List<T> {
		var i = 0;
		var r = new List<T>();
		for (v in l){
			if (i >= pos)
				r.push(v);
			if (++i == end)
				break;
		}
		return r;
	}

	public static function listConcat<T>( dest:List<T>, src:List<T> ){
		for (v in src)
			dest.add(v);
	}

	public static function group<T>( l:Iterable<T>, f:T->String ) : Hash<List<T>> {
		var result = new Hash();
		for (i in l){
			var k = f(i);
			var g = result.get(k);
			if (g == null){
				g = new List();
				result.set(k, g);
			}
			g.add(i);
		}
		return result;
	}
}