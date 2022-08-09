package;

import Lib;

using GridTools;
class GridTools
{

	inline static function isValidCoord<T>( grid:Grid<T>, x : Int, y : Int )
	{
		return MLib.inRange( y, 0, grid.length-1 ) && MLib.inRange( x, 0, grid[y].length-1);
	}

	inline public static function getAt<T>( grid:Grid<T>, x:Int, y:Int ) : Null<T>
	{
		return isValidCoord(grid, x, y ) ? grid[y][x] : null;
	}

	inline public static function setAt<T>( grid:Grid<T>, x:Int, y:Int, cell:T ):T
	{
		grid[y][x] = cell;
		return cell;
	}

	public static function iter<T>( grid:Grid<T>, cb : T->Void )
	{
		for( y in 0...grid.length )
		{
			for( x in 0...grid[y].length )
			{
				cb( grid.getAt(x, y) );
			}
		}
	}

	public static function iterCoord<T>( grid:Grid<T>, cb : Int->Int->Void )
	{
		for( y in 0...grid.length )
		{
			for( x in 0...grid[y].length )
			{
				cb( x, y );
			}
		}
	}

	public static function map<T, A>( grid:Grid<T>, cb : T->A ):Grid<A>
	{
		var mapped = [];
		for( y in 0...grid.length )
		{
			mapped[y] = [];
			for( x in 0...grid[y].length )
			{
				mapped[y][x] = cb( grid.getAt(x, y) );
			}
		}

		return mapped;
	}

	public static function print<T>( grid:Grid<T>, cb : T->String )
	{
		var output = "";
		for( y in 0...grid.length )
		{
			output += "\n";
			for( x in 0...grid[y].length )
			{
				output += "\t"+cb( grid.getAt(x, y) );
			}
		}
		return output;
	}
	
	public static function getNeighbours<T>( grid:Grid<T>, x:Int, y:Int ) : {left:Null<T>, right:Null<T>, top:Null<T>, bottom:Null<T>, topLeft:Null<T>, topRight:Null<T>, bottomLeft:Null<T>, bottomRight:Null<T>}
	{
		return {left:grid.getAt(x-1, y),
				right:grid.getAt(x+1, y),
				top:grid.getAt(x, y-1),
				bottom:grid.getAt(x, y+1),
				topLeft:grid.getAt(x-1,y-1),
				topRight:grid.getAt(x+1,y-1),
				bottomLeft:grid.getAt(x-1,y+1),
				bottomRight:grid.getAt(x+1, y+1) };
	}
	
	public static function getDirectNeighbours<T>( grid:Grid<T>, x:Int, y:Int ) : {left:Null<T>, right:Null<T>, top:Null<T>, bottom:Null<T>}
	{
		return {
				left:grid.getAt(x-1, y),
				right:grid.getAt(x+1, y),
				top:grid.getAt(x, y-1),
				bottom:grid.getAt(x, y+1),
			};
	}

	public static function generate<T>( w:Int, h:Int, cb : Int->Int->T ) : Grid<T>
	{
		var grid = [];
		for( y in 0...h )
		{
			grid[y] = [];
			for( x in 0...w )
			{
				grid[y][x] = cb(x, y);
			}
		}
		return grid;
	}


}