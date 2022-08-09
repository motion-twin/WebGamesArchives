import Common;
import Protocol;

class Inventory {

	public var blockIndex : Int;
	public var inv : InventoryInfos;
	
	public function new(i) {
		this.inv = i;
	}
	
	#if neko inline #end
	public function display() {
	}
	
	#if neko inline #end
	function redraw() {
	}
	
	function maxCharge( k : ChargeKind ) {
		return Data.getCharge(k).max;
	}

	public function hasBlock( b : Block ) {
		for( i in inv.t )
			if( i != null && i.k == b.index )
				return true;
		return false;
	}

	public function hasBlocks( b : Block, n : Int ) {
		if( n < 0 ) return false;
		if( n == 0 ) return true;
		for( i in inv.t )
			if( i != null && i.k == b.index ) {
				n -= i.n;
				if( n <= 0 ) return true;
			}
		return false;
	}

	
	public function hasCharge( ck : ChargeKind ) {
		var ck = Type.enumIndex(ck);
		for( c in inv.charges )
			if( c.c == ck )
				return c.n > 0;
		return false;
	}
	
	
	public function get(index)
	{
		return inv.t[index];
	}
	
	public function drop(index) {
		var o = inv.t[index];
		if( inv.t.length > index ) {
			inv.t[index] = null;
			display();
		}
		return o;
	}
	
	public function useCharge( ck : ChargeKind ) {
		var ck = Type.enumIndex(ck);
		for( c in inv.charges )
			if( c.c == ck ) {
				c.n--;
				if( c.n <= 0 ) {
					inv.charges.remove(c);
					display();
				} else
					redraw();
				return true;
			}
		return false;
	}
	
	public function useBlocks( b : Block, count : Int ) {
		var n = count;
		if( count < 0 ) return false;
		if( count == 0 ) return true;
		for( i in inv.t )
			if( i != null && i.k == b.index ) {
				n -= i.n;
				if( n <= 0 ) break;
			}
		if( n > 0 ) return false;
		var changed = false;
		for( i in 0...inv.t.length ) {
			var s = inv.t[i];
			if( s != null && s.k == b.index ) {
				if( s.n > count ) {
					s.n -= count;
					break;
				}
				changed = true;
				inv.t[i] = null;
				count -= s.n;
				if( count == 0 ) break;
			}
		}
		if( changed ) display() else redraw();
		return true;
	}

	public inline function maxBlock( b : Block ) {
		return b.getMax(inv.maxWeight);
	}
	
	public function getCurrentBlock() {
		var i = inv.t[blockIndex-1];
		return i == null ? null : Block.all[i.k];
	}

	public function useCurrentBlock() {
		var s = inv.t[blockIndex - 1];
		if( s == null || s.n <= 0 )
			return false;
		s.n--;
		if( s.n == 0 ) {
			inv.t[blockIndex - 1] = null;
			display();
		} else
			redraw();
		return true;
	}

	public function addCharge( c : ChargeKind, n : Int ) {
		var cid = Type.enumIndex(c);
		var max = maxCharge(c);
		for( c in inv.charges )
			if( c.c == cid ) {
				if( c.n >= max )
					return 0;
				c.n += n;
				if( c.n > max ) {
					n -= c.n - max;
					c.n = max;
				}
				redraw();
				return n;
			}
		if( n > max )
			n = max;
		inv.charges.push( { c : cid, n : n } );
		display();
		return n;
	}
	
	public function addBlock( b : Block ) {
		if( b.charge != null ) {
			var n = addCharge(b.charge, 1);
			if( n <= 0 )
				return -1;
			return 0x80 + Type.enumIndex(b.charge);
		}
		var max = maxBlock(b);
		var found = null;
		var index = -1;
		for( k in 0...inv.t.length ) {
			var i = inv.t[k];
			if( i != null && i.k == b.index && i.n < max ) {
				found = i;
				index = k;
				break;
			}
		}
		if( found == null ) {
			for( i in 0...inv.t.length )
				if( inv.t[i] == null ) {
					inv.t[i] = { k : b.index, n : 1 };
					display();
					return i;
				}
			return -1;
		}
		found.n++;
		redraw();
		return index;
	}

	public function addBlocks( b : Block, count : Int ) {
		if( count <= 0 || b.charge != null )
			return 0;
		var n = count;
		var max = maxBlock(b);
		for( k in 0...inv.t.length ) {
			var i = inv.t[k];
			if( i != null && i.k == b.index ) {
				var rem = max - i.n;
				if( rem < 0 ) rem = 0;
				if( rem > n ) rem = n;
				i.n += rem;
				n -= rem;
				if( n == 0 ) {
					redraw();
					return count;
				}
			}
		}
		for( i in 0...inv.t.length )
			if( inv.t[i] == null ) {
				var k = n;
				if( k > max ) k = max;
				inv.t[i] = { k : b.index, n : k };
				n -= k;
				if( n == 0 ) {
					display();
					return count;
				}
			}
		if( count == n )
			return 0;
		display();
		return count - n;
	}

	public function canCharge( ck : ChargeKind ) {
		var cid = Type.enumIndex(ck);
		for( c in inv.charges )
			if( c.c == cid )
				return c.n < maxCharge(ck);
		return true;
	}
	
	public function canAddBlock( b : Block ) {
		if( b.charge != null )
			return canCharge(b.charge);
		var max = maxBlock(b);
		for( k in 0...inv.t.length ) {
			var i = inv.t[k];
			if( i == null ) return true;
			if( i.k == b.index && i.n < max ) return true;
		}
		return false;
	}
	
	public function canAddBlocks( b : Block, n : Int ) {
		if( n == 0 )
			return true;
		if( n < 0 || b.charge != null )
			return false;
		var max = maxBlock(b);
		for( k in 0...inv.t.length ) {
			var i = inv.t[k];
			if( i == null ) {
				n -= max;
				if( n <= 0 )
					return true;
			} else if( i.k == b.index && i.n < max ) {
				n -= max - i.n;
				if( n <= 0 )
					return true;
			}
		}
		return false;
	}
	
	public function useChargeForBlock( b : Block ) {
		var charge = null;
		var matter = b.matter;
		if( matter.quickBreaks != null )
			for( k in matter.quickBreaks )
				if( useCharge(k.c) )
					return true;
		return !matter.hasProp(PRequireCharge);
	}
}