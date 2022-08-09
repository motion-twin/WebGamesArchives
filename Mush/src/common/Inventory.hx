package ;

using Ex;
import Protocol;
import Types;

/**
 * ...
 * @author de
 */
class Inventory
{
	public var 		d : Array<ItemDesc>;
	public var 		maxSize : Null<Int>;
	
	public var 		length(get, never) : Int;
	
	// null means infinite
	public function new( size : Null<Int> )
	{
		d = [];
		this.maxSize = size;
	}
	
	public inline function iterator()								return d.iterator();
	public inline function get( i:Int ) : ItemDesc 					return d[i];
	public inline function clear() 									d.splice(0, d.length);
	public inline function get_length()								return d.length;
	public inline function splice(i, l) 							return d.splice(i, l);
	public inline function isFull() 								return ( maxSize != null && d.length >= maxSize);

	public inline function clone() {
		var inv = new Inventory(maxSize);
		for ( i in d )
			inv.push( i );
		return inv;
	}
	
	public inline function pop()
	{
		return d.pop();
	}
	
	public function stack( hero : db.Hero ) : Iterable<InvItem>
	{
		var infer = new List<InvItem>();
		for(x in d )
		{
			var e = infer.find( function( e) return ItemUtils.itemEq(e.it , x , hero) );
			
			if ( e == null )	infer.add( {it:x,qty:1,uid: - infer.length - 1} );
			else				e.qty++;
		}
		
		var arr = infer.array();
		arr.sort( function(i1,i2)
				{
					var s1 = Std.string(i1.it.id);
					var s2 = Std.string(i2.it.id);
				
					return if ( s1 < s2 ) 1 else if ( s2 > s1 ) -1 else 0;
				}
		);
		
		return arr;
	}
	
	public function toString()
	{
		var r = "";
		for ( i in d)
			r += Std.string( i );
			
		return r;
	}
	
	public function heroInv() : List<InvItem>	return d.mapi(function(i, x) return { it:x, qty:1, uid:i } );
	
	//does not sort result
	//does a simple id comp
	public function simpleStack() : Iterable<InvItem>
	{
		var infer = new List<InvItem>();
		for ( x in d )
		{
			var e = infer.find( function( e)
			{
				if ( (e.it.id == CONSUMABLE || e.it.id == TREE_POT ) && x.id == e.it.id )
				{
					for(ci in e.it.customInfos)
						switch(ci)
						{
							default:
							case Skin( t, v ):
								for(ci2 in x.customInfos)
									switch(ci2)
									{
										default:
										case Skin( t2, v2 ):
											if ( t2 != t || v2 != v)
												return false;
									}
						}
					
					return true;
				}
				else
					return e.it.id == x.id;
			});
			
			if ( e == null )
				infer.add( {it:x,qty:1,uid: - infer.length - 1} );
			else
				e.qty++;
		}
		
		return infer;
	}
	
	
	public function findUnique(i : ItemDesc) : ItemDesc{
		for(x in d )
			if( ItemUtils.itemEq( x , i))
				return x;
		return null;
	}
	
	public function findInStack(i : ItemDesc, hero:db.Hero) : ItemDesc{
		for(x in d )
			if( ItemUtils.itemEq( x , i, true,hero))
				return x;
		return null;
	}
	
	public function findAny(i : ItemId) : ItemDesc{
		for(x in d )
			if( x.id == i )
				return x;
		return null;
	}
	
	public function findWorking(i : ItemId ) : ItemDesc{
		for(x in d )
			if ( x.id == i && !x.status.has(BROKEN))
				return x;
		return null;
	}
	
	public function findWorkingAndCharged(i : ItemId ) : ItemDesc{
		for(x in d )
			if ( x.id == i && !x.status.has(BROKEN)){
				var ch = ItemUtils.getChargeParam( x );
				if( ch!=null&&ch > 0)
					return x;
			}
		return null;
	}
	
	public function hasWorking(i : ItemId ) : Bool{
		for(x in d )
			if ( x.id == i && !x.status.has(BROKEN))
				return true;
		return false;
	}
	
	public function hasWorkingAndNotHidden(i : ItemId ) : Bool{
		for(x in d )
			if ( x.id == i && !x.status.has(BROKEN) && !x.status.has(HIDDEN) )
				return true;
		return false;
	}
	
	//removes one item by id that is not broken
	public function removeWorking( i : ItemId ) : Bool
	{
		var pos = 0;
		for(x in d )
		{
			if ( x.id == i && !x.status.has(BROKEN))
			{
				d.splice( pos , 1 );
				return true;
			}
			pos++;
		}
		return false;
	}
	

	public function removeOne( i : ItemId ) : Bool
	{
		var pos = 0;
		for(x in d )
		{
			if ( x.id == i )
			{
				d.splice( pos , 1 );
				return true;
			}
			pos++;
		}
		return false;
	}

	//i want to remove perceived item
	public function remove( i : ItemDesc, hero:db.Hero = null ) : Bool
	{
		for(x in 0...d.length )
			if ( ItemUtils.itemEq( i, d[x], false,hero ) )
			{
				d.splice( x, 1);
				return true;
			}
		return false;
	}
	
	public function removeUid( i : ItemDesc )
	{
		mt.gx.Debug.assert( i != null);
		var pos = 0;
		for ( o in d )
		{
			if ( o.uid == i.uid)
			{
				d.splice( pos, 1);
				return;
			}
			pos++;
		}
		
		throw Throwable.RemoveUid(i.uid);
	}
	
	public function removeP( proc : ItemDesc -> Bool ) : ItemDesc
	{
		for(x in 0...d.length )
			if( proc( d[x] ) )
			{
				d.splice( x, 1);
				return d[x];
			}
		return null;
	}
	
	
	/**
		Adds the element [x] at the end of the array.
	**/
	public function push( i  : ItemDesc ) : Bool
	{
		Debug.ASSERT( i != null );
		
		if ( i == null ) return false;
		if ( maxSize!=null && d.length >= maxSize)
			return false;

		d.push(i);
		return true;
	}
}