package mt.gx.algo;

import haxe.ds.IntMap;
import mt.gx.Debug;
import mt.gx.algo.Dijkstra;


using mt.gx.Ex;

/**
 * ...
 * @author de
 * neighbours are cached to enable lazy connexity computation
 * dublicate link are not accepted,
 * nodes should be created before use
 * those are classes because they are faster in general
 */
@:publicFields
class Edge{ 
	var enter : Int;
	var exit : Int;
	var w : Int;
	
	public function new(enter,exit,w) {
		this.enter = enter; this.exit = exit; this.w = w;
	}
}

@:publicFields
class Node<T>{ 
	var edges : List<Edge>;
	var data : T;
	
	public function new(edges,data) {
		this.edges = edges; this.data = data;
	}
}

class Graph<T> {
	private var nodes : IntMap< Node<T> >;
	private var nodeCount : Int;
	
	public function new() 
	{
		nodes = new IntMap();
		nodeCount = 0;
	}
	
	public inline function hasNode( i : Int ) : Bool
		return nodes.exists( i );
		
	public function getNodeById( i : Int )
		return nodes.get(i);
	
	public function iter( f : Int -> Node<T> -> Void ){
		for ( k in nodes.keys() )
			f(k, nodes.get(k));
	}
	
	public inline function getNodeIds() : Iterable<Int>
	{
		var t = this;
		return Lambda.list( { iterator : t.nodes.keys } );
	}
	
	public function edge( inNode : Int, outNode : Int , weight : Int , bidir : Bool = true)
	{
		var i = nodes.get( inNode );
		var o = nodes.get( outNode );
		Debug.assert( i != null && o != null , "nodes were not declared previously");
		Debug.assert(weight >= 0,"weight are always assumed posivites or null");
		
		nodes.get(inNode).edges.push( new Edge(inNode,outNode,weight) );
		if ( bidir) nodes.get(outNode).edges.push( new Edge(outNode,inNode,weight) );
		
		return this;
	}
	
	public function getEdges( f : Edge -> Bool ) : Iterable<Edge>{
		var l = new List();
		for(n in nodes )
			for ( e in n.edges )
				if ( f( e ) )
					l.add( e );
					
		return l;
	}
	
	public inline function iterEdges( f : Edge -> Void ){
		for(n in nodes )
			for ( e in n.edges )
				f( e );
	}
	
	public function getNodeEdges( i: Int ) : Iterable<Edge>{
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
	
	public function addNode( ?data : T ){
		nodes.set( nodeCount++ , new Node( new List(),data ) );
		return this;
	}
	
	public function node( node : Int , ?data : T) {
		mt.gx.Debug.assert( nodes.get(node) == null , "duplicate node decl");
		
		nodes.set(  node, new Node( new List(),data) );
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
		var testgraph = new Graph<Int>();
		
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
		
		
		var dijkstra_3  = Dijkstra.compute(testgraph, 3);
		
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
		
		var dijkstra_6 = mt.gx.algo.Dijkstra.compute(testgraph2, 6);
		
		trace( dijkstra_6.pathTo(3) );
	}

	
}