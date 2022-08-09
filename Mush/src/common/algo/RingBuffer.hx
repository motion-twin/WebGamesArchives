package algo;


using Ex;
/**
 * ...
 * @author de
 */

class RingBuffer<T>
{
	var rep : Array<T>;
	var sz : Int;
	
	public function new( sz : Int ) 
	{
		rep = new List();
	}
	
	public function pushBack(v :  T) 
	{
		if ( rep.length > sz)
			rep.shift();
			
		rep.pushBack( v );
	}
	
	public function pushFront( v :  T )
	{
		if ( rep.length > sz)
			rep.pop();
			
		rep.pushFront( v );
	}
	
}