package ;

/**
 * ...
 * @author 01101101
 */

class WeightedList<T> {
	
	var list:Array<T>;
	var counts:Array< { v:T, p:Int } >;
	
	public function new () {
		list = new Array();
		counts = new Array();
	}
	
	/**
	 * Add the specified number of occurences of the specified element to the list
	 * @param	v
	 * @param	p
	 */
	public function add (v:T, p:Int = 10) {
		for (i in 0...p) {
			list.push(v);
		}
		// Update or store count
		for (i in 0...counts.length) {
			if (counts[i].v == v) {
				counts[i].p += p;
				return;
			}
		}
		counts.push( { v:v, p:p } );
	}
	
	/**
	 * Removes all or some occurences of v
	 * @param	v
	 * @param	p	If -1, all occurences will be removed
	 */
	public function remove (v:T, p:Int = -1) {
		var found = 0;
		var index = 0;
		for (i in 0...counts.length) {
			if (counts[i].v == v) {
				found = counts[i].p;
				index = i;
				break;
			}
		}
		
		var left = (p > 0) ? Std.int(Math.min(p, found)) : found;
		if (left <= 0)	return;
		
		var j = 0;
		while (left > 0) {
			if (list[j] == v) {
				list.splice(j, 1);
				counts[index].p--;
				left--;
			}
			else j++;
		}
		
		if (counts[index].p <= 0)	counts.splice(index, 1);
	}
	
	/**
	 * Sets the count of an element to the specified value
	 * @param	v
	 * @param	p
	 */
	public function set (v:T, p:Int) {
		var c = getCount(v);
		if (c == p)	return;
		else if (c > p)	remove(v, c - p);
		else if (c < p)	add(v, p - c);
	}
	
	/**
	 * Returns a random value in the list
	 * @return
	 */
	public function draw (?f:Int->Int) :T {
		if (f == null)	f = Std.random;
		return list[f(list.length)];
	}
	
	/**
	 * Returns the count for the specified element
	 * @param	v	If null, total list length will be returned
	 * @return
	 */
	public function getCount (?v:T = null) :Int {
		if (v == null)	return list.length;
		for (i in 0...counts.length) {
			if (counts[i].v == v)	return counts[i].p;
		}
		return 0;
	}
	
	public function toString () :String {
		var s = "";
		s = list.toString();
		return s;
	}
	
}










