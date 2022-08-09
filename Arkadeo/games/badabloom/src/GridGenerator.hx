package ;

import mt.MLib;
import Game;

class GridGenerator
{

	public var GRID_HMAX(get_gridHMax, null):Int; 
	inline function get_gridHMax() { return Game.GRID_HMAX; }
	public var GRID_WMAX(get_gridWMax, null):Int; 
	inline function get_gridWMax() { return Game.GRID_WMAX; }
	public var TILE_SIZE(get_tileSize, null):Int;
	inline function get_tileSize() { return Game.TILE_SIZE; }
	
	var gridData:Array<Array<NodeData>>;
	
	public function new(wGrid:Int, hGrid:Int) 
	{
		init();
	}
	
	function init()
	{
		gridData = [];
		for ( i in 0...GRID_HMAX  )
		{
			gridData[i] = [];
			for ( j in 0...GRID_WMAX  )
			{
				var pts:Null<Int> = null;
				if ( MLib.frand(Game.me.rand.rand) > 0.6 )
					pts = MLib.randRange(1, 10, Game.me.rand.rand) * Cs.GRID_POINTS_COEF.get();
				gridData[i][j] = { left:null, right:null, top:null, bottom:null, points:pts };
			}
		}
	}
	
	public function cleanTuto(level:Int)
	{
		for ( i in 0...GRID_HMAX  )
		{
			if ( i == GRID_HMAX >> 1 ) 
				continue;
			
			for ( j in 0...GRID_WMAX  )
			{
				if ( j == GRID_WMAX >> 1 && level == 1 )
					continue;
				gridData[i][j] = null;
			}
		}
		return gridData;
	}
	
	public function generate()
	{
		/*
		var edgeEatProba = 0.0;
		for ( i in 0...GRID_HMAX )
			if ( MLib.frand(Game.me.rand.rand) < edgeEatProba )
				if ( i % 2 == 0) eatCell(0, i, 1.0 )
				else eatCell(GRID_WMAX, i, 1.0 );
				
		for ( i in 0...GRID_WMAX )
			if ( MLib.frand(Game.me.rand.rand) < edgeEatProba )
				if ( i % 2 == 0) eatCell(i, 0, 1.0 )
				else eatCell(i, GRID_HMAX, 1.0 );
		
		var centerEatProba = 0.0;
		if ( MLib.frand(Game.me.rand.rand) < centerEatProba )
			eatCell( MLib.randRange(1, GRID_WMAX - 2, Game.me.rand.rand), MLib.randRange(1, GRID_HMAX - 2, Game.me.rand.rand), 1.0 );
		
		cleanGrid();
		*/
		return gridData;
	}
	
	function cleanGrid()
	{
		for ( j in 0...GRID_HMAX  )
		for ( i in 0...GRID_WMAX  )
		{
			var node = getAt(i, j);
			if ( node != null )
			{
				var l = getAt(i - 1, j);
				var r = getAt(i + 1, j);
				var t = getAt(i, j - 1);
				var b = getAt(i, j + 1);
				if ( l == null && r == null && t == null && b == null ) setAt(i, j, null);
			}
		}
	}
	
	inline function getAt(x:Int, y:Int)
	{
		var v = if ( x < 0 || x >= GRID_WMAX || y < 0 || y >= GRID_HMAX ) null;
				else gridData[y][x];
		return v;
	}
	
	inline function setAt(x:Int, y:Int, v)
	{
		var r = ( x < 0 || x >= GRID_WMAX || y < 0 || y >= GRID_HMAX );
		if( !r ) gridData[y][x] = v;
		return r;
	}
	
	function eatCell(x:Int, y:Int, proba:Float)
	{
		if (getAt(x, y) == null ) return;
		if ( MLib.frand(Game.me.rand.rand) <= proba )
		{
			setAt(x, y, null);
			var dir = Type.createEnumIndex(Dirs, MLib.randRange(1, Type.allEnums(Dirs).length-1, Game.me.rand.rand));
			var probaDamping = 0.5;
			switch( dir )
			{
				case NONE:
				case LEFT: 	eatCell(x - 1, y, proba * probaDamping);
				case RIGHT: eatCell(x + 1, y, proba * probaDamping);
				case UP: 	eatCell(x, y - 1, proba * probaDamping);
				case DOWN: 	eatCell(x, y + 1, proba * probaDamping);
			}
		}
	}
	
	
}