package mt.kiroukou.game;


typedef Storage<T> = #if flash9 flash.Vector<T> #else Array<T> #end;

//external data
class PathNode<T>
{
	public var tile:T;
	public var x:Int;
	public var y:Int;
	public function new(x:Int, y:Int, tile:T)
	{
		this.x = x;
		this.y = y;
		this.tile = tile;
	}
	
	public function dispose()
	{
		tile = null;
	}
	
	public function toString():String
	{
		return "{ x:" + x + ", y:" + y + ", tile:" + tile+"}";
	}
}

//internal data
private class _PathNode<T>
{
	public var costF:Int;//is costF, final cost
	
	public var frame:Int;
	public var tile:T;
	public var parent:Null<_PathNode<T>>;
	public var costG:Int;
	public var costH:Int;
	public var x:Int;
	public var y:Int;
	public var closed:Bool;
	public var open:Bool;
	
	public function new()
	{
		init(null, 0, 0, 0);
	}

	public function dispose()
	{
		parent = null;
		tile = null;
	}
	
	public function init(pTile:T, ?px:Int = 0, ?py:Int = 0, ?frame:UInt = 0 )
	{
		open = false;
		closed = false;
		this.frame = frame;
		this.tile = pTile;
		this.parent = null;
		this.costG = this.costH = 0;
		this.costF = 1000000;
		this.x = px;
		this.y = py;
	}
	
	public function toString():String
	{
		return "{parent:" + parent + " x:" + x + ", y:" + y + ", tile:" + tile+"}";
	}
}

class PathFinder<T>
{
	var frame:Int;
	var grid: Array<Array<T>>;
	var useDiagonal:Bool;
	var restrictDiagonal:Bool;
	var check: Int -> Int -> T -> Bool;
	var penality: Int -> Int -> T -> Int;
	var debug: Int -> Int -> Void;
	var cache:Storage<_PathNode<T>>;
	var gridW:Int;
	var gridH:Int;
	var pathNodeGrid:Storage<PathNode<T>>;
	
	inline public function getGrid()
	{
		return grid;
	}

	public function new(pGrid:Array<Array<T>>, ?useDiagonal = false, ?restrictDiagonal = true)
	{
		this.grid = pGrid;
		this.useDiagonal = useDiagonal;
		this.restrictDiagonal = restrictDiagonal;
		//
		frame = 0;
		gridW = grid[0].length;
		gridH = grid.length;
		//
		cache = new Storage<_PathNode<T>>(gridW * gridH, true);
		for( i in 0...cache.length )
			cache[i] = new _PathNode();
		//
		pathNodeGrid = new Storage<PathNode<T>>(gridW * gridH, true);
		for( i in 0...gridH )
		for( j in 0...gridW )
			pathNodeGrid[i*gridW + j] = new PathNode(j, i, grid[i][j]);
	}
	
	public function dispose()
	{
		for( i in 0...cache.length ) {
			cache[i].dispose();
			cache[i] = null;
		}
		cache = null;
		for( i in 0...gridH )
		for( j in 0...gridW ) {
			pathNodeGrid[i * gridW + j].dispose();
			pathNodeGrid[i * gridW + j] = null;
		}
		pathNodeGrid = null;
		grid = null;
	}
	
	inline function get(x, y) { return grid[y][x]; }
	inline function getpn(x, y) :_PathNode<T>
	{
		var n = cache[y * gridW + x];
		if( n.frame != frame )
		{
			n.init( get(x, y), x, y, frame );
		}
		return n;
	}
	
	inline function estimateCost(x, y, tx, ty )
	{
		var dx = Std.int( Math.abs(x - tx) );
		var dy = Std.int( Math.abs(y - ty) );
		return( dx != 0 && dy != 0 ) ? Std.int( 10 * Math.sqrt(dx * dx + dy * dy)) : 10 *(dx + dy);
	}
	
	inline function validMove(x0, y0, x1, y1):Bool
	{
		var res = true;
		if( x1 < 0 || x1 >= gridW || y1 < 0 || y1 >= gridH )
		{
			res = false;
		}
		else if( restrictDiagonal )
		{
			var n = getpn(x0, y1);
			res = check(n.x, n.y, n.tile);
			if( res == true )
			{
				n = getpn(x1, y0);
				res = check(n.x, n.y, n.tile);
			}
		}
		return res;
	}

	inline function getAdjacents(node:_PathNode<T>)
	{
		var nodes = new Array<_PathNode<T>>();
		var x = node.x;
		var y = node.y;
		if( (x - 1) >= 0 )
			nodes.push( getpn( x - 1, y ) );
		if( (x + 1) < gridW )
			nodes.push( getpn( x + 1, y ) );
		if( (y - 1) >= 0 )
			nodes.push( getpn( x, y - 1 ) );
		if( (y + 1) < gridH )
			nodes.push( getpn( x, y + 1 ) );
		if( useDiagonal )
		{
			if( validMove(x, y, x-1, y-1) )
				nodes.push( getpn( x - 1, y - 1 ) );
			if( validMove(x, y, x-1, y+1) )
				nodes.push( getpn( x - 1, y + 1 ) );
			if( validMove(x, y, x+1, y+1) )
				nodes.push( getpn( x + 1, y + 1 ) );
			if( validMove(x, y, x+1, y-1))
				nodes.push( getpn( x + 1, y - 1) );
		}
		return nodes;
	}
	
	public function resolve( pX:Int, pY:Int, pTX:Int, pTY:Int, pCheck:Int->Int->T->Bool, ?pPenality:Int->Int->T->Int=null, ?pDebug: Int->Int->Void = null ):List<PathNode<T>>
	{
		frame ++;//invalidate cache
		var current;
		//
		if( getpn( pTX, pTY ) == null )
			return null;
		current = getpn(pTX, pTY);
		if( !pCheck( current.x, current.y, current.tile ) )
			return null;
		current = getpn(pX, pY);
		if( !pCheck( current.x, current.y, current.tile ) )
			return null;
		//
		check = pCheck;
		debug = pDebug;
		penality = pPenality;
		//
		var closedList = new Storage<_PathNode<T>>();
		var openList = [];
		//
		var current = getpn( pX, pY );
		current.costG =(penality != null ) ? penality( current.x, current.y, current.tile ) : 0;
		current.costH = estimateCost( pX, pY, pTX, pTY );
		current.costF = current.costG + current.costH;
		openList.push(current);
		//
		while( openList.length > 0 && (openList.length < Std.int(cache.length)) )
		{
			current = openList.shift();
			current.open = false;
			current.closed = true;
			closedList.push(current);
			//
			var adj = getAdjacents( current );
			for( a in adj )
			{
				if( a == null || a.closed || !check( a.x, a.y, a.tile )  )
					continue;
				var d = current.costG + 10;
				if( current.x != a.x && current.y != a.y ) d += 4;
				if( penality != null ) d += penality( current.x, current.y, current.tile );
				//
				if( !a.open  )
				{
					a.costG = d;
					a.costH = estimateCost( a.x, a.y, pTX, pTY);
					a.costF = a.costG + a.costH;
					a.parent = current;
					a.open = true;
					openList.push(a);
					if( debug != null ) debug(a.x, a.y );
				}
				else if( a.open && a.costG > d )
				{
					a.costG = d;
					a.costF = a.costG + a.costH;
					a.parent = current;
					a.open = true;
					for( i in 0...openList.length ) {
						if( a.costF < openList[i].costF ) {
							openList.insert( i, a);
							break;
						}
					}
				}
			}
			//
			if( current.x == pTX && current.y == pTY )
				break;
		}
		//
		if( current.x != pTX || current.y != pTY )
		{
			return null;
		}
		//
		var output = new List<PathNode<T>>();
		do
		{
			output.add( pathNodeGrid[current.y * gridW + current.x] );// new PathNode( current.x, current.y, current.tile ) );
			current = current.parent;
		} while( current != null );
		return output;
	}
}
