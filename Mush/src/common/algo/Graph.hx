package algo;

using Ex;

import HashEx;
import IntHashEx;
/**
 * neighbours are cached to enable lazy connexity computation
 * dublicate link are not accepted,
 * nodes should be created before use
 */

typedef EdgeDesc = { enter : Int , exit : Int , w : Int };

class DijkstraProcess
{
	var root : Int;
	var predecessors : IntHash<Null<Int>>;
	var weight : IntHash<Int>;//this is the weight of the path that is incoming to root using this node
	var data : Graph;
	
	var processedNodes : IntHash<Bool>;
	var pendingNodes : Heap;
	
	var computed : Bool ;
	
	function new()
	{
		root = -1;
		predecessors = new IntHash();
		weight = null;
		data = null;
		
		processedNodes = new IntHash<Bool>();
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
	
	private function process() : DijkstraProcess
	{
		Debug.ASSERT(root>=0,"no root");
		
		if (computed) return this;
		
		weight = new IntHash();
						
		var t = this;
		for ( x in 0...data.getNodeCount() )
		{
			predecessors.set(x, null);
		}
		
		pendingNodes = new Heap( data.getNodeCount() );
		for( x in data.getNeighbours(root) )
		{
			//Debug.MSG("adding : " + x);
			predecessors.set(x, root);
			
			var w = data.getEdgeWeight(root, x);
			weight.set( x , w );
			pendingNodes.heapify( { w: w , data:x } );
		}
		
		Debug.ASSERT(pendingNodes.checkConsistency());
		
		processedNodes.set(root, true);

		while(pendingNodes.length > 0)
		{
			var newOne = pendingNodes.getMin();
			
			pendingNodes.checkConsistency();	
			
			if (newOne != null )
			{
				processedNodes.set( newOne.data, true);
				pendingNodes.delMin();

				for(n in data.getNeighbours( newOne.data ))
				{
					if( processedNodes.get(n) ) continue; 

					var add = newOne.w + data.getEdgeWeight(newOne.data, n );
					
					var exists = weight.exists(n);
					if ( !exists || weight.get(n) < add )
					{
						weight.set(n, add);
						if ( !exists )
						{
							pendingNodes.heapify( { w: add, data:n} );
						}
						else
						{
							for(i in 0...pendingNodes.length)
							{
								if(pendingNodes.getEntry(i).data == n )
								{
									pendingNodes.getEntry(i).w = add;
									pendingNodes.updateWeight( i );
									
									break;
								}
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
	
	public static function  compute( input : Graph, root : Int ) : DijkstraProcess
	{
		var dijkstra = new DijkstraProcess();
		dijkstra.data = input;
		dijkstra.root = root;
		
		return dijkstra.process();
	}
}



typedef Node = { edges : List<EdgeDesc>, data : Dynamic };
class Graph
{
	
	private var nodes : IntHash< Node >;
	//private var edges : EdgeMap;
	private var nodeCount : Int;
	
	public function new() 
	{
		nodes = new IntHash();
		
		nodeCount = 0;
	}
	
	public inline function hasNode( i : Int ) : Bool
		return nodes.exists( i );
		
	public function getNodeById( i : Int ) : Node
		return nodes.get(i);
	
	public function iter( f : Int -> Node -> Void )
	{
		for ( k in nodes.keys() )
			f(k, nodes.get(k));
	}
	
	public function getNodeIds() : List<Int>
	{
		var t = this;
		return Lambda.list(  
			{ 
				iterator : (function() { return t.nodes.keys(); })
			}
		);
	}

	
	public function edge( inNode : Int, outNode : Int , weight : Int , bidir : Bool) : Graph
	{
		var i = nodes.get( inNode );
		var o = nodes.get( outNode );
		Debug.ASSERT( i != null && o != null , "nodes were not declared previously");
		Debug.ASSERT(weight >= 0,"weight are always assumed posivites or null");
		
		
		#if debug
		#end
		
		nodes.get(inNode).edges.push( { enter:inNode, exit:outNode , w: weight} );
		
		if ( bidir)
			nodes.get(outNode).edges.push( { enter:outNode, exit:inNode , w: weight} );
		
		return this;
	}
	
	public function getEdges( f : EdgeDesc -> Bool ) : Iterable<EdgeDesc>
	{
		var l = new List();
		for(n in nodes )
			for ( e in n.edges )
				if ( f( e ) )
					l.add( e );
					
		return l;
	}
	
	public inline function iterEdges( f : EdgeDesc -> Void )
	{
		for(n in nodes )
			for ( e in n.edges )
				f( e );
	}
	
	public function getNodeEdges( i: Int ) : Iterable<EdgeDesc>
	{
		var l = new List();
		for(n in nodes )
			for ( e in n.edges )
				if ( e.enter == i || e.exit == i )
					l.add( e );
		return l;
	}
	
	public function getEdgeWeight( inNode : Int, outNode : Int ) : Null<Int>
	{
		for ( e in nodes.get(inNode).edges ) 
		{
			if( e.enter == inNode && e.exit == outNode )
			{
				return e.w;
			}
		}
		return null;
	}
	
	public function clearEdge( inNode : Int, outNode : Int ) : Bool
	{
		for ( e in nodes.get(inNode).edges ) 
		{
			if( e.enter == inNode && e.exit == outNode )
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function addNode( ?data : Dynamic ) : Graph
	{
		nodes.set( nodeCount++ , { edges:new List() , data:data } );
		return this;
	}
	
	public function node( node : Int , ?data : Dynamic ) : Graph
	{
		Debug.ASSERT( nodes.get(node) == null , "duplicate node decl");
		
		nodes.set(  node, { edges:new List() , data:data} );
		nodeCount++;
		
		return this;
	}
	
	public inline function getNodeCount() : Int
	{
		return nodeCount;
	}

	public function getNeighbours( node : Int ) : List<Int> 
	{
		if ( !nodes.exists( node ))
			return new List();
		else 
		return nodes.get( node ).edges.map(
					function(e)
						return e.exit
		);	
	}
	
	public static function unitTest()
	{
		var testgraph : Graph = new Graph();
		
		/*
		 * 3----*
		 * |\   |
		 * 4-5  |
		 * |/   |
		 * 6    |
		 * |    |
		 * 7-9  |
		 * |    |
		 * 8----*
		 * 
		 */
		testgraph.node(3).node(4).node(5).node(6).node(7).node(8).node(9)
		.edge(3, 5, 0, true)
		.edge(3, 8, 1, true)
		.edge(3, 4, 3, true)
		.edge(4, 6, 1, true)
		.edge(4, 5, 1, true)
		.edge(5, 6, 1, true)
		.edge(6, 7, 0, true)
		.edge(7, 9, 1, true)
		.edge(7, 8, 5, true);
		
		
		var dijkstra_3 : DijkstraProcess= DijkstraProcess.compute(testgraph, 3);
		
		trace( dijkstra_3.pathTo(8) );
		trace( dijkstra_3.pathTo(9) );
		trace( dijkstra_3.pathTo(6) );
	
		
		var testgraph2 = new Graph();
		
		/*
		 * 3
		 * |\   
		 * 4-5  
		 * |/
		 * 6
		 */
		testgraph2.node(3).node(4).node(5).node(6)
		.edge(3, 4, 1, true)
		.edge(3, 5, 1, true)
		.edge(4, 6, 1, true)
		.edge(5, 6, 0, true);
		
		var dijkstra_6 : DijkstraProcess= DijkstraProcess.compute(testgraph2, 6);
		
		trace( dijkstra_6.pathTo(3) );
	}

	
}