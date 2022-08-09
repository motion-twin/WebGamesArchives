package mt.gx.algo;

import mt.gx.algo.Graph;
import mt.gx.algo.Heap;
import mt.gx.Debug;

import haxe.ds.IntMap;

class Dijkstra<T>{
	var root : Int;
	var predecessors : IntMap<Null<Int>>;
	var weight : IntMap<Float>;//this is the weight of the path that is incoming to root using this node
	var data : Graph<T>;
	
	var processedNodes : IntMap<Bool>;
	var pendingNodes : mt.gx.algo.Heap<Int>;
	
	var computed : Bool;
	
	function new()
	{
		root = -1;
		predecessors = new IntMap();
		weight = null;
		data = null;
		
		processedNodes = new IntMap<Bool>();
		pendingNodes = null;
		computed = false;
	}
	
	public function pathTo( n : Int ) : List<Int>
	{
		var res = new List<Int>();
		var i = n;

		res.push(i);
		while(i!=root)
		{
			if (predecessors.get(i) == null)
			{
				return null;
			}

			res.push(predecessors.get(i));
			i = predecessors.get(i);
		}
		
		return res;
	}
	
	private function process()
	{
		mt.gx.Debug.assert(root>=0,"no root");
		
		if (computed) return this;
		
		weight = new IntMap();
						
		for ( x in 0...data.getNodeCount() )
			predecessors.set(x, null);
		
		pendingNodes = new mt.gx.algo.Heap<Int>( data.getNodeCount() );
		for( x in data.getNeighbours(root) )
		{
			//Debug.MSG("adding : " + x);
			predecessors.set(x, root);
			
			var w = data.getEdgeWeight(root, x);
			weight.set( x , w );
			pendingNodes.heapify( { w: w , data:x } );
		}
		
		Debug.assert(pendingNodes.checkConsistency());
		processedNodes.set(root, true);

		while (pendingNodes.length > 0) {
			
			var newOne = pendingNodes.getMin();
			pendingNodes.checkConsistency();	
			
			if (newOne != null ){
				processedNodes.set( newOne.data, true);
				pendingNodes.delMin();

				for(n in data.getNeighbours( newOne.data )) {
					if( processedNodes.get(n) ) continue; 

					var wadd : Float = newOne.w + data.getEdgeWeight(newOne.data, n );
					var exists = weight.exists(n);
					if ( !exists || weight.get(n) < wadd ) {
						weight.set(n, wadd);
						if ( !exists ){
							pendingNodes.heapify( { w: wadd, data:n} );
						}
						else {
							for(i in 0...pendingNodes.length)
								if(pendingNodes.getEntry(i).data == n )
								{
									pendingNodes.getEntry(i).w = wadd;
									pendingNodes.updateWeight( i );
									
									break;
								}
						}

						predecessors.set(n , newOne.data);
					}
				}
			}
			else
			{
				//trace("early dijkstra break");
				break;
			}
		}

		computed = true;
		return this;
	}
	
	public static function compute<T>( input : Graph<T>, root : Int ) : Dijkstra<T>{
		var dijkstra = new Dijkstra<T>();
		dijkstra.data = input;
		dijkstra.root = root;
		
		return dijkstra.process();
	}
}

