package mt.gx;

class Pair<A,B> {
	public var first : A;
	public var second : B;

	public function new( a : A,b :B) {
		first = a;
		second = b;
	}
	
	public inline function toString() return 'first:$first second:$second';
}