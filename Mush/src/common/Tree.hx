package ;

/**
 * ...
 * @author de
 */

enum TreeNode<T>
{
	Leaf( o : T, parent : TreeNode<T>);
	Node( o : T , sons : List<TreeNode<T>>, parent:TreeNode<T> );
}

class Tree<T>
{
	var head : TreeNode<T>;
	public function new( h: TreeNode<T>) 
	{
		head = h;
	}
	
	public inline function getHead()
	{
		return head;
	}
	
	public function locate( o : T , head : TreeNode<T>) : TreeNode<T>
	{
		if ( head == null) return null;
		
		var sons = null;
		switch(head)
		{
			case Leaf( myO , _ ):if ( o == myO ) return head;
			case Node( myO , sns, _ ):
			if ( o == myO ) return head; 
			else sons = sns;
		}
		
		if( sons != null)
		for( x in sons )
		{
			var v = locate(o, x);
			if ( v != null)
			{
				return v;
			}
		}
		return null;
	}
	
	public function backTrack( o : T , head : TreeNode<T> ) : TreeNode<T>
	{
		if ( head == null) return null;
		
		switch(head)
		{
			case Leaf( myO , p ):
			if ( o == myO ) return head;
			else return backTrack( o, p);
			
			case Node( myO , sns, p ):
			if ( o == myO ) return head; 
			else 
			{
				backTrack( o, p);
			}
		}
		
		return null;
	}
	
	public function insert( o : T, s : T) : Void
	{
		head = pinsert( o, s , getHead());
	}
	
	function pinsert( o : T, s : T, current : TreeNode<T>) : TreeNode<T>
	{
		if ( current == null) return null;
		
		switch(current)
		{
			case Leaf( myO , p ):
			{
				if ( o == myO ) 
				{
					var l = new List();
					l.push( Leaf( s, current ));
					
					return Node(  myO, l, p);
				}
			}
			
			case Node( myO , sns, p ):
			if ( o == myO ) 
			{
				sns.push( Leaf( s, current ) );
			}
			else 
			{
				current = Node( myO, Lambda.map( sns, function(sn) return pinsert(o, s, sn) ), p );
			}
		}
		
		return current;
	}
	
	public function count( head : TreeNode<T> ) : Int
	{
		switch(head)
		{
			case Leaf(_, _): return 1;
			case Node( _, sns, _): 
			var r = 1;
			for (x in sns)
			{
				r += count(x);
			}
			return r;
		}
	}
}