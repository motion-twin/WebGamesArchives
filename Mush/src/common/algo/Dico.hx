package algo;


@:publicFields
class DicoNode<K,V> 
{
	var key	: K;
	var value : V;
	var fg : DicoNode<K,V>;
	var fd : DicoNode<K,V>;
	
	public function new(k:K,v:V,fg,fd)
	{
		this.key = k;
		this.value = v;
		this.fg = fg;
		this.fd = fd;
	}
}

class Dico<K,V>
{
	//o fg h
	//o f hd
	var head : DicoNode<K,V>;
	var order : K->K->Int;
	
	public function new( order : K->K->Int ) 
	{
		this.order = order;
		head = null;
	}
	
	public function add( k:K,v:V )
	{
		head = insert( head, new DicoNode(k,v,null,null) );
	}
	
	function insert( h : DicoNode<K,V>, nu : DicoNode<K,V> )
	{
		if ( h == null ) return nu;
		
		if( order( h.key, nu.key ) == 0 )
		{
			nu.fg = h;
			nu.fd = h.fd;
			h.fd = null;
			return nu;
		}
		else if( order( h.key, nu.key ) < 0 )
		{
			h.fg =  insert( h.fg, nu);
			return h;
		}
		else
		{
			h.fd =  insert( h.fd, nu);
			return h;
		}
	}
	
	public function get( k : K)
	{
		return dget(head, k);
	}
	
	function dget(h : DicoNode<K,V>, k : K) : V
	{
		if ( h == null)
		{
			return null;
		}
		
		if ( order( h.key, k) == 0)
		{
			return h.value;
		}
		else if ( order( h.key, k) < 0)
		{
			return	dget( h.fg, k);
		}
		else
		{
			return	dget( h.fd, k);
		}
		
		return null;
	}
	
}