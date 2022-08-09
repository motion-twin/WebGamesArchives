package mt.flash;

class QSort {
	
	public static function sort<T>( s : Array<T>, compare : T -> T -> Int ) {
		#if flash
		s.sort(compare);
		#else
		if( s.length <= 1 ) return;
		var cmp = function(x, y) return compare(s[x], s[y]);
		var swap = function(x, y) {
			var tmp = s[x];
			s[x] = s[y];
			s[y] = tmp;
		};
		var stack = new List();
		stack.add(0);
		stack.add(s.length - 1);
		while( stack.length > 0 ) {
			var lo = stack.pop();
			var hi = stack.pop();
			var size = (hi - lo) + 1;
			if( size < 4 ) {
				if( size == 3 ) {
					if( cmp(lo, lo + 1) > 0 ) {
						swap(lo, lo + 1);
						if( cmp(lo + 1, lo + 2) > 0 ) {
							swap(lo + 1, lo + 2);
							if( cmp(lo, lo + 1) > 0 )
								swap(lo, lo + 1);
						}
					} else {
						if( cmp(lo + 1, lo + 2) > 0 ) {
							swap(lo + 1, lo + 2);
							if( cmp(lo, lo + 1) > 0 )
								swap(lo, lo + 1);
						}
					}
				} else if( size == 2 ) {
					if( cmp(lo, lo + 1) > 0 )
						swap(lo, lo + 1);
				}
			} else {
				var pivot = lo + (size >> 1);
				swap(pivot, lo);
				var left = lo;
				var right = hi + 1;
				while( true ) {
					do {
						left++;
					} while( left <= hi && cmp(left, lo) <= 0 );
					do {
						right--;
					} while( right > lo && cmp(right, lo) >= 0 );
					if( right < left )
						break;
					swap(left, right);
				}
				swap(lo, right);
				if( right - 1 - lo >= hi - left ) {
					if( lo + 1 < right ) {
						stack.add(lo);
						stack.add(right - 1);
					}
					if( left < hi ) {
						stack.push(hi);
						stack.push(left);
					}
				} else {
					if( left < hi ) {
						stack.add(left);
						stack.add(hi);
					}
					if( lo + 1 < right ) {
						stack.push(right - 1);
						stack.push(lo);
					}
				}
			}
		}
		#end
	}
	
}