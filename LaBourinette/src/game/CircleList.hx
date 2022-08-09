package game;

class CircleItem<T> {
	public var start : Float;
	public var len : Float;
	public var value : T;
	public var end(getEnd,null) : Float;
	public var next : CircleItem<T>;
	public var prev : CircleItem<T>;

	public function new( s:Float, l:Float, v:T ){
		start = s;
		len = l;
		value = v;
		next = null;
		prev = null;
	}

	public function getMid() : Float {
		return start + len /2;
	}

	function getEnd() : Float {
		return start + len;
	}

	public function toString() : String {
		return Std.string({v:Std.string(value), a:[start, end], l:len });
	}
}

class CircleList<T> {
	var range : Float;
	public var head : CircleItem<T>;

	public function new(defaultValue:T, ?range:Null<Float>=null){
		if (range == null)
			range = Math.PI*2;
		this.range = range;
		this.head = new CircleItem<T>(0, range, defaultValue);
	}

	public function normalizeAngle( a:Float ) : Float {
		a = a % range;
		if (a < 0)
			a += range;
		return a;
	}

	public function getAngle( a:Float ) : CircleItem<T> {
		a = normalizeAngle(a);
		var iter = head;
		do {
			if (iter.start <= a && iter.end >= a)
				return iter;
			iter = iter.next;
		}
		while (iter != null && iter != head);
		return null;
	}

	public function finalize(){
		if (head.prev != null)
			return;
		var iter = head;
		do {
			if (iter.next != null)
				iter.next.prev = iter;
			else {
				iter.next = head;
				head.prev = iter;
			}
			iter = iter.next;
		}
		while (iter != null && iter != head);
	}

	public function checkIntegrity(){
		var data = new StringBuf();
		var iter = head;
		var visited = new List();
		do {
			data.add(str(iter)); data.add("\n");
			if (Lambda.has(visited, iter))
				throw "Circle is looping\n"+data.toString();
			if (iter.next == null && Math.round(iter.end*1000)/1000 != Math.round(range*1000)/1000)
				throw "Last angle do not end at "+range+"\n"+data.toString();
			visited.push(iter);
			iter = iter.next;
		}
		while (iter != null && iter != head);
		var iter = head;
		do {
			if (iter.next != null && strf(iter.end) != strf(iter.next.start))
				throw "Part "+str(iter.next)+" do not start at "+iter.end+" as specified by "+str(iter)+"\n"+data.toString();
			iter = iter.next;
		}
		while (iter != null && iter != head);
	}

	public function insert(i:CircleItem<T>){
		i.start = i.start % range;
		if (i.start < 0)
			i.start += range;
		if (i.end > range){
			var q = new CircleItem<T>(i.start, range - i.start, i.value);
			// Math.min(range-i.start, Math.min(range, range+i.start+i.len), i.value);
			insert(q);
			insert(new CircleItem<T>(0, i.len-q.len, i.value));
			return;
		}
		var iter = head;
		var prev = null;
		do {
			if (i.start <= iter.start){
				// cut iter at begining
				i.next = iter;
				if (prev == null)
					head = i;
				else
					prev.next = i;
				var lost = (i.len - (iter.start - i.start));
				iter.len -= lost;
				iter.start += lost;
				// ok the item has been inserted entirely, no need to continue
				if (iter.len > 0){
					return;
				}
				// current iter has been erased by inserted item,
				// continue
				i.next = iter.next;
			}
			else if (i.start < iter.end){
				// cut iter
				// trace("putting "+str(i)+" at the end of "+str(iter));
				var oldEnd = iter.end;
				iter.len -= (iter.end - i.start);
				if (oldEnd > i.end){
					// cut inside
					var remain = new CircleItem<T>(i.end, oldEnd-i.end, iter.value);
					remain.next = iter.next;
					iter.next = i;
					i.next = remain;
					return;
				}
				else if (oldEnd == i.end){
					// just fit in the end
					i.next = iter.next;
					iter.next = i;
					return;
				}
				// cut and overlaps the end of iter, the next loop should be i.start <= iter.start
			}
			prev = iter;
			iter = iter.next;
		}
		while (iter != null && iter != head);
	}

	static function strf(f:Float) : String {
		return Std.string( Math.round(f*10000) / 10000 );
	}

	public function str(c:CircleItem<T>) : String {
		return Std.string({ s:c.start, l:c.len, v:c.value });
	}

	public function astr(a:Float) : String {
		if (range == Math.PI*2)
			return Std.string(Math.round(a*360 / range));
		return Std.string(a);
	}

	public function toString() : String {
		var buf = new StringBuf();
		var iter = head;
		do {
			var s = Math.round(iter.start*1000)/1000;
			var e = Math.round((iter.start+iter.len)*1000)/1000;
			var l = Math.round(iter.len*1000) / 1000;
			buf.add("+ ["+iter.value+"] from "+astr(s)+" to "+astr(e)+" (len="+astr(l)+")\n");
			iter = iter.next;
		}
		while (iter != null && iter != head);
		return buf.toString();
	}

	public static function main() : Void {
		CircleListTest.main();
	}

}

class CircleListTest {
	static function test(c:CircleList<Int>, expected:Array<{ s:Float, l:Float, v:Int }> ){
		var strf = function(f:Float){
			return Std.string( Math.round(f*10000) / 10000 );
		}
		var str = function(x:CircleItem<Int>) : String {
			return Std.string({s:strf(x.start), l:strf(x.len), v:strf(x.value)});
		}
		var iter = c.head;
		var i = 0;
		for (v in expected){
			if (iter == null)
				throw "Excepted(s) #"+i+" "+v+" but got null\nin circle:\n"+c;
			if (strf(v.s) != strf(iter.start))
				throw "Excepted(s) #"+i+" "+v+" but got "+str(iter)+"\nin circle:\n"+c;
			if (strf(v.v) != strf(iter.value))
				throw "Excepted(v) #"+i+" "+v+" but got "+str(iter)+"\nin circle:\n"+c;
			if (strf(v.l) != strf(iter.len))
				throw "Excepted(l) #"+i+" "+v+" but got "+str(iter)+"\nin circle:\n"+c;
			i++;
			iter = iter.next;
		}
	}

	static function testBigSplit(){
		var circle = new CircleList(0, 1);
		circle.insert(new CircleItem(0.5, 0.2, 1));
		test(circle, [
			{ s:0.0, l:0.5, v:0 },
			{ s:0.5, l:0.2, v:1 },
			{ s:0.7, l:0.3, v:0 }
		]);
	}

	static function testInsertBegin(){
		var circle = new CircleList(0, 1);
		circle.insert(new CircleItem(0, 0.2, 1));
		test(circle, [
			{ s:0.0, l:0.2, v:1 },
			{ s:0.2, l:0.8, v:0 }
		]);
	}

	static function testInsertErase(){
		var c = new CircleList(0, 1);
		c.insert(new CircleItem(0.5, 0.1, 1));
		c.insert(new CircleItem(0.4, 0.3, 2));
		test(c, [
			{ s:0.0, l:0.4, v:0 },
			{ s:0.4, l:0.3, v:2 },
			{ s:0.7, l:0.3, v:0 }
		]);
	}

	static function testEraseExact(){
		var c = new CircleList(0,1);
		c.insert(new CircleItem(0.5, 0.1, 1));
		c.insert(new CircleItem(0.5, 0.1, 2));
		test(c, [
			{ s:0.0, l:0.5, v:0 },
			{ s:0.5, l:0.1, v:2 },
			{ s:0.6, l:0.4, v:0 }
		]);
	}

	static function testBigOverlapsBegin(){
		var c = new CircleList(0,1);
		c.insert(new CircleItem(-0.3, 0.6, 1));
		test(c, [
			{ s:0.0, l:0.3, v:1 },
			{ s:0.3, l:0.4, v:0 },
			{ s:0.7, l:0.3, v:1 }
		]);
	}

	static function testBigOverlaps(){
		var c = new CircleList(0, 1);
		c.insert(new CircleItem(0.9, 0.2, 1));
		test(c, [
			{ s:0.0, l:0.1, v:1 },
			{ s:0.1, l:0.8, v:0 },
			{ s:0.9, l:0.1, v:1 }
		]);
	}

	static function testReal(){
		var c = new CircleList(0, 1);
		c.checkIntegrity();
		c.insert(new CircleItem(-0.5, 0.1, 1));
		c.checkIntegrity();
		c.insert(new CircleItem( 0.5, 0.5, 1));
		c.checkIntegrity();
		trace(c);
		c.insert(new CircleItem(-0.05, 0.05, 1 ));
		c.checkIntegrity();
		c.insert(new CircleItem( 0.8, 0.1, 1 ));
		c.checkIntegrity();
		c.insert(new CircleItem( 0.1, 0.05, 1 ));
		c.checkIntegrity();
		test(c, [
		]);
	}

	static function testStrange(){
		var c = new CircleList(0, 1000);
		c.insert(new CircleItem(-500, 50, 1));
		c.insert(new CircleItem(-250, 50, 2));
		c.insert(new CircleItem( 200, 50, 2));
		trace(c);
	}

	static function testOcclu(){
		var c = new CircleList(0, 360.0);
		c.insert(new CircleItem(-49.27, 52.26, 1));
		c.insert(new CircleItem(98.71, 9.19, 2));
		trace(c);
	}

	public static function main(){
		/*
		testBigSplit();
		testInsertBegin();
		testInsertErase();
		testEraseExact();
		testBigOverlaps();
		testBigOverlapsBegin();
		testReal();
		*/
		testOcclu();
	}
}