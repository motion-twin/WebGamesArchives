package;


class RandList<T>
{
	var l:List<{v:T, count:Int}>;
	var total:Int;
	
	public function new() 
	{
		clean();
	}
	
	function get(v:T)
	{
		for ( o in l )
			if ( o.v == v )
				return o;
		return null;
	}
	
	public function size()
	{
		return l.length;
	}
	
	public function clean()
	{
		l = new List();
		total = 0;
	}
	
	public function addArray(a:Array<T>)
	{
		for ( v in a )
		{
			add(v);
		}
	}
	
	public function add(v:T, ?proba:Int = 1)
	{
		var o = get(v);
		if ( o == null )
			l.add({v:v, count:proba});
		else
			o.count += proba;
		
		total += proba;
	}
	
	public function decrementValue(v:T)
	{
		for ( o in l )
		{
			if ( o.v == v && o.count > 0)
			{
				total -= 1;
				o.count -= 1;
				return true;
			}
		}
		return false;
	}
	
	public function removeValue(v:T)
	{
		for ( o in l )
		{
			if ( o.v == v )
			{
				total -= o.count;
				return l.remove(o);
			}
		}
		return false;
	}
	
	public function draw()
	{
		var count = Std.random(total);
		var crt = 0;
		for ( o in l )
		{
			if ( count <= crt + o.count )
			{
				return o.v;
			}
			crt += o.count;
		}
		throw 'impossible draw';
	}
}