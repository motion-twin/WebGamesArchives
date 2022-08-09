package tools;

class ArrayTools {
	public static function at<A>( it:Iterable<A>, idx:Int ) : A {
		var i = -1;
		for (v in it)
			if (++i == idx)
				return v;
		return null;
	}

	public static function randomize<A>( arr:Array<A>, ?s:mt.Rand ) : Array<A> {
		var res = new Array();
		var nrs = new Array();
		var n = arr.length;
		for (i in 0...n)
			nrs[i] = i;
		var r = n;
		while (r > 0){
			var x = if (s == null) Std.random(r) else s.random(r);
			var pos = nrs[x];
			nrs[x] = nrs[r-1];
			res[pos] = arr[r-1];
			r--;
		}
		return res;
	}

	public static function indexOf<A>( arr:Array<A>, item:A ) : Null<Int> {
		for (i in 0...arr.length)
			if (arr[i] == item)
				return i;
		return null;
	}

	public static function indexOfGreatest<A>( arr:Array<A>, cmp:A->A->Int ) : Null<Int> {
		var min : A = null;
		var idx : Null<Int> = null;
		for (i in 0...arr.length){
			var v : A = arr[i];
			if (min == null || cmp(v,min) > 0){
				min = v;
				idx = i;
			}
		}
		return idx;
	}

	public static function setupTestCases( r:haxe.unit.TestRunner ) : Void {
		r.add(new TestArrayTools());
	}
}

class TestArrayTools extends haxe.unit.TestCase {
	function testAt1(){
		assertEquals(null, ArrayTools.at([1,2,3,4], 5));
	}

	function testAt2(){
		assertEquals(1, ArrayTools.at([1,2,3,4], 0));
	}

	function testGreatest(){
		assertEquals(1, ArrayTools.indexOfGreatest([1,5,3,4,0], Reflect.compare));
	}
}