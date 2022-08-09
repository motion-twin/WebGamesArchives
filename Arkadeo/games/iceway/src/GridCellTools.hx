package ;

import Lib;


using GridCellTools;
using GridTools;
class GridCellTools
{

	inline static public function cleanGrid(grid: Grid<GridCell>)
	{
		grid.iter( function(c)
			{
				c.pathLevel = -1;
				c.pathRequires = [];
			}
		);
	}
	
	static public function getMaxLevel(grid: Grid<GridCell>)
	{
		var max = -1;
		grid.iter(function(cell) if( cell.pathLevel > max ) max = cell.pathLevel );
		return max;
	}

	static public function diffuseLength(grid: Grid<GridCell>, origin : GridCell, from : GridCell, level : Int, ?fromMove:Null<MoveDir> )
	{
		for( move in Lib.MOVES_DIRS )
		{
			if( move == fromMove ) continue;
			var t = grid.getMoveTarget( from, move );
			if( t == origin || t == from ) continue;
			if( t.pathLevel > 0 && t.pathLevel < level ) continue;
			t.pathLevel = level;
			grid.diffuseLength(origin, t, level + 1, Lib.getOppositeMove(move));
		}
	}
	
	static public function diffuseLengthComplex(grid: Grid<GridCell>, origin : GridCell, from : GridCell, level : Int, ?fromMove:Null<MoveDir> )
	{
		if( level == 0 )
		{
			var list = new List();
			grid.iter( 	function(cell)
						{
							if( cell.pathLevel > 0 )
							{
								list.add(cell);
							}
						} );
			//make a call on elements of that list
			for( cell in list )
			{
				grid.diffuseLengthComplex( origin, cell, cell.pathLevel );
			}
		}
		else
		{
			for( move in Lib.MOVES_DIRS )
			{
				if( move == fromMove ) continue;
				var t = grid.getMoveTarget( from, move );
				if( t == origin || t == from ) continue;
				if( t.pathLevel >= 0 && t.pathLevel <= level ) continue;
				//
				t.pathLevel = level;
				if( from.pathRequires.length > 0 )
					t.pathRequires = from.pathRequires.copy();
				grid.diffuseLengthComplex(origin, t, level + 1, Lib.getOppositeMove(move));
				//
				var cell = t;
				for( move2 in Lib.MOVES_DIRS )
				{
					//TODO avoid already done movement
					if( !grid.isValidMove(cell, move2) ) continue;
					var t = grid.getAtMove(cell, move2);
					if( t == origin || t == from ) continue;
					//
					if( t.pathLevel == -1 )
					{
						t.pathRequires.push(cell);
						t.pathLevel = level;
						grid.diffuseLengthComplex(origin, t, level + 1);
					}
				}
			}
		}
		/*
		grid.iter( function(cell) {
			if( cell.pathLevel > 0 )
			{
				for( move in Lib.MOVES_DIRS )
				{
					if( !grid.isValidMove(cell, move) ) continue;
					var t = grid.getAtMove(cell, move);
					if( t == null ) continue;
					if( (t.pathLevel == -1) )//|| (t2.pathRequires.length > t.pathRequires.length + 1) )
					{
						t.pathRequires.push(cell);
						t.pathLevel = level;
						grid.diffuseLength(origin, t, level + 1, Lib.getOppositeMove(move));
					}
				}
			}
		} );
		*/
	}
	
	inline public static function getMoveTarget( grid: Grid<GridCell>, from : GridCell, move : MoveDir  ) : GridCell
	{
		var dest = from;
		var dir = Lib.getDir( move );
		var ox = dest.x, oy = dest.y;
		var loop = 1 + MLib.max(Lib.GRID_HMAX, Lib.GRID_WMAX);
		while( --loop >= 0 )
		{
			if( !grid.isValidMove(dest, move) ) break;
			ox += dir[0]; oy += dir[1];
			dest = grid.getAt(ox, oy);
		}
		return dest;
	}
	
	inline public static function getEntityMoveTarget( grid: Grid<GridCell>, from : GridCell, move : MoveDir  ) : GridCell
	{
		var dest = from;
		var dir = Lib.getDir( move );
		var ox = dest.x, oy = dest.y;
		var loop = 1 + MLib.max(Lib.GRID_HMAX, Lib.GRID_WMAX);
		while( --loop >= 0 )
		{
			if( !grid.isValidMove(dest, move, true) ) break;
			ox += dir[0]; oy += dir[1];
			dest = grid.getAt(ox, oy);
		}
		return dest;
	}
	
	inline static public function getAtMove( grid: Grid<GridCell>, from:GridCell, move:MoveDir):GridCell
	{
		var dir = Lib.getDir(move);
		return grid.getAt( from.x + dir[0], from.y + dir[1] );
	}
	
	public static function isValidMove( grid: Grid<GridCell>, from : GridCell, move : MoveDir, ?checkEntities = false ): Bool
	{
		var dir = Lib.getDir(move);
		var next = grid.getAt( from.x + dir[0], from.y + dir[1] );
		if( next == null ) return false;
		if( next == from ) return false;
		if( checkEntities )
		{
			for( e in Game.me.intEntities )
			{
				if( e.cell == next )
				{
					return false;
				}
			}
		}
		//--------------------------
		return switch( move )
		{
			case MLeft:
				!( 	(from.hasCollide() && from.collisionFlags.has(CLeft))
					||
					(next.hasCollide() && next.collisionFlags.has(CRight))
				);
			case MRight:
				!( 	(from.hasCollide() && from.collisionFlags.has(CRight))
					||
					(next.hasCollide() && next.collisionFlags.has(CLeft))
				);
			case MUp:
				!( 	(from.hasCollide() && from.collisionFlags.has(CTop))
					||
					(next.hasCollide() && next.collisionFlags.has(CBottom))
				);
			case MDown:
				!( 	(from.hasCollide() && from.collisionFlags.has(CBottom))
					||
					(next.hasCollide() && next.collisionFlags.has(CTop))
				);
		}
	}

	inline public static function isCellMoveTarget( grid: Grid<GridCell>, from : GridCell, move : MoveDir, targetCell:GridCell  ) : Bool
	{
		var dest = from;
		var dir = Lib.getDir( move );
		var ox = dest.x;
		var oy = dest.y;
		var loop = 1+MLib.max(Lib.GRID_HMAX, Lib.GRID_WMAX);
		while( --loop >= 0 && dest != targetCell )
		{
			if( !grid.isValidMove(dest, move, true) ) break;
			ox += dir[0]; oy += dir[1];
			dest = grid.getAt(ox, oy);
		}
		return dest == targetCell;
	}
	
	public static function getMoveLength( grid: Grid<GridCell>, from : GridCell, move : MoveDir ) : Int
	{
		var length = 0;
		var cell = from;
		var dir = Lib.getDir( move );
		var ox = dir[0];
		var oy = dir[1];
		while( true )
		{
			if( !grid.isValidMove(cell, move) ) break;
			cell = grid.getAt(cell.x + ox, cell.y + oy );
			length ++;
		}
		return length;
	}
	
	public static function getEntityMoveLength( grid: Grid<GridCell>, from : GridCell, move : MoveDir ) : Int
	{
		var length = 0;
		var cell = from;
		var dir = Lib.getDir( move );
		var ox = dir[0];
		var oy = dir[1];
		while( true )
		{
			if( !grid.isValidMove(cell, move, true) ) break;
			cell = grid.getAt(cell.x + ox, cell.y + oy );
			length ++;
		}
		return length;
	}
	
	public static function getPathMoves( grid: Grid<GridCell>, path:Array<MoveDir>, cell : GridCell, to:GridCell )
	{
		if( cell == to ) return true;
		
		var tLeft = grid.getMoveTarget( cell, MLeft );
		var tRight = grid.getMoveTarget( cell, MRight );
		var tUp = grid.getMoveTarget( cell, MUp );
		var tDown = grid.getMoveTarget( cell, MDown );
		
		var leftValid = tLeft.pathLevel == cell.pathLevel + 1;
		var rightValid = tRight.pathLevel == cell.pathLevel + 1;
		var upValid = tUp.pathLevel == cell.pathLevel + 1;
		var downValid = tDown.pathLevel == cell.pathLevel + 1;
		
		if( leftValid && grid.getPathMoves( path, tLeft, to ) )
		{
			path.unshift( MLeft );
			return true;
		}
		if( rightValid && grid.getPathMoves( path, tRight, to ) )
		{
			path.unshift( MRight );
			return true;
		}
		if( upValid && grid.getPathMoves( path, tUp, to ) )
		{
			path.unshift( MUp );
			return true;
		}
		if( downValid && grid.getPathMoves( path, tDown, to ) )
		{
			path.unshift( MDown );
			return true;
		}
		return false;
	}
}