package;
import Lib;
import GridTools;

using GridCellTools;
using GridTools;
class LevelGenerator
{
	
	static var PATTERNS  = [{cols:[CBottom,CRight], 	extension:[	{move:MRight, cols:[CTop]},
																	{move:MDown, cols:[CLeft]}]},

							{cols:[CBottom,CLeft], 		extension:[	{move:MLeft, cols:[CTop]},
																	{move:MDown, cols:[CRight]}]},

							{cols:[CTop,CRight], 		extension:[	{move:MRight, cols:[CBottom]},
																	{move:MUp, cols:[CLeft]}]},

							{cols:[CTop,CLeft], 		extension:[	{move:MLeft, cols:[CBottom]},
																	{move:MUp, cols:[CRight]}]},
						];
	
	public static function cleanupGrid(grid:Grid<GridCell>)
	{
		grid.iter( function(c) {
			var locked = true;
			for( move in Lib.MOVES_DIRS )
			{
				if( grid.isValidMove( c, move ) )
				{
					locked = false;
					break;
				}
			}
			if( locked )
			{
				c.setBlock();
			}
		} );
		
		grid.iter( function(c) {
			if( !c.flags.has(Block) && !c.flags.has(Lake) )
			{
				grid.cleanGrid();
				c.pathLevel = 0;
				grid.diffuseLength(c, c, 1);
				
				var count = 0;
				grid.iter( function(t) {
					if( t.pathLevel > 0 ) count ++;
				} );
				
				if( count <= 10 )
				{
					c.setBlock();
					c.flags.set(Forest);
					grid.iter( function(t) {
						if( t.pathLevel > 0 )
						{
							t.setBlock();
							t.flags.set(Forest);
						}
					} );
				}
			}
		} );
		
		grid.iter( function(c) {
			if( c.flags.has(Block) )
			{
				if( c.countBlocksAround(grid) >= 1 )
					c.flags.set(Forest);
			}
		} );
		
		//clean collisions 
		grid.iter( function(c) {
			if( c.flags.has(Block) )
			{
				var nl = grid.getNeighbours( c.x, c.y );
				if( nl.top != null && !nl.top.flags.has(Lake) && !nl.top.flags.has(Block) && nl.top.collisionFlags.has(CBottom) ) nl.top.collisionFlags.unset(CBottom);
				if( nl.bottom != null && !nl.bottom.flags.has(Lake) && !nl.bottom.flags.has(Block) && nl.bottom.collisionFlags.has(CTop) ) nl.bottom.collisionFlags.unset(CTop);
				if( nl.right != null && !nl.right.flags.has(Lake) && !nl.right.flags.has(Block) && nl.right.collisionFlags.has(CLeft) ) nl.right.collisionFlags.unset(CLeft);
				if( nl.left != null && !nl.left.flags.has(Lake) && !nl.left.flags.has(Block) && nl.left.collisionFlags.has(CRight) ) nl.left.collisionFlags.unset(CRight);
			}
			else if( c.hasCollide() && !c.flags.has(Lake) )
			{
				var n = grid.getDirectNeighbours(c.x, c.y);
				if( n.right != null && c.collisionFlags.has( CRight ) )
				{
					c.collisionFlags.unset(CRight);
					if(!n.right.collisionFlags.has(CLeft) ) n.right.collisionFlags.set(CLeft);
				}
				if( n.bottom != null && c.collisionFlags.has( CBottom ) )
				{
					c.collisionFlags.unset(CBottom);
					if(! n.bottom.collisionFlags.has(CTop) ) n.bottom.collisionFlags.set( CTop );
				}
			};
		} );
	}
	
	public static function generate(level:Int, ?blockOnly = false):Grid<GridCell>
	{
		var random = Game.me.rand.random;
		var lakeRadius = random(3);
		//
		var qw = Lib.GRID_MID_WMAX;
		var qh = Lib.GRID_MID_HMAX;
		//
		var qTL = generateTLQuarter(level, lakeRadius);
		var qTR = flipQuarterY( generateTLQuarter(level, lakeRadius) );
		var qBL = flipQuarterX( generateTLQuarter(level, lakeRadius) );
		var qBR = symetricQuarter( generateTLQuarter(level, lakeRadius) );
		// on assemble le tout
		var grid = GridTools.generate( Lib.GRID_WMAX, Lib.GRID_HMAX, function(x, y) {
			var ref = 	if( MLib.inRange( x, 0, qw-1 ) && MLib.inRange(y, 0, qh-1 ) )
						{
							//TL
							qTL.getAt(x, y);
						}
						else if( MLib.inRange( x, qw, Lib.GRID_WMAX-1 ) && MLib.inRange(y, 0, qh-1 ) )
						{
							//TR
							qTR.getAt(x-qw, y);
						}
						else if( MLib.inRange( x, 0, qw-1 ) && MLib.inRange(y, qh, Lib.GRID_HMAX-1 ) )
						{
							//BL
							qBL.getAt(x, y-qh);
						}
						else if( MLib.inRange( x, qw, Lib.GRID_WMAX-1 ) && MLib.inRange(y, qh, Lib.GRID_HMAX-1 ) )
						{
							//BR
							qBR.getAt(x-qw, y-qh);
						}
						else
						{
							throw "impossible !";
						};
			ref.x = x;
			ref.y = y;
			ref.id = y * Lib.GRID_WMAX + x;
			return ref;
		});
		
		fixCollisions(grid);
		cleanupGrid(grid);
		
		if( blockOnly )
		{
			grid.iter( function(cell) {
				if( !cell.hasCollide() ) return;
				if( cell.flags.has(Lake) || cell.flags.has(Border) ) return;
				cell.setBlock();
			});
		}
		//get extended
		var homePlaces = [];
		grid.iter( function(c) if( c.flags.has(ExtendedCollision) ) homePlaces.push(c) );
		
		if( homePlaces.length == 0 )
			for( i in 0...Lib.GRID_REAL_WMAX )
				homePlaces.push( grid.getAt(i, 0) );
		
		for(c in homePlaces)
		{
			if( !c.hasCollision(grid, CBottom) && (c.hasCollision(grid, CLeft) || c.hasCollision(grid, CRight)) )
			{
				c.flags.set(Home);
				c.collisionFlags.unset(CTop);
				var u = grid.getAt(c.x, c.y - 1);
				if( u != null )
				{
					u.setBlock();
					u.flags.set(NoSkin);
				}
				break;
			}
		}
		
		return grid;
	}

	static function fixCollisions( grid:Grid<GridCell> )
	{
		var random = Game.me.rand.random;
		var qw = Lib.GRID_WMAX;
		var qh = Lib.GRID_HMAX;
		//
		var cids = [];
		var rids = [];
		for( i in 0...qw )
		{
			var count = countCollisionOnColumn(grid, i);
			if( count == 0 )
			{
				cids.push(i);
			}
		}
		//
		for( i in 0...qh )
		{
			var count = countCollisionOnRow(grid, i);
			if( count == 0 )
			{
				rids.push(i);
			}
		}
		// on ne veut pas qu'elle soit trop forte, autrement cela enlève bcp de diversité dans les blocks
		//first pass
		var offset = random(3);
		for( i in 0...MLib.min( cids.length-offset, rids.length-offset ) )
		{
			var cid = cids.pop();
			var rid = rids.pop();
			var cell = grid.getAt(cid, rid);
			var p = PATTERNS[random(PATTERNS.length)];
			for( col in p.cols )
				cell.collisionFlags.set(col);
		}
		//second pass
		while( cids.length > 0 )
		{
			var cid = cids.pop();
			grid.getAt( cid, random( qh ) ).setBlock();
			if( random(2) == 0 ) grid.getAt( cid, random( qh ) ).setBlock();
		}
		//
		while( rids.length > 0 )
		{
			var rid = rids.pop();
			grid.getAt(random( qw ), rid ).setBlock();
			if( random(2) == 0 ) grid.getAt(random( qw ), rid ).setBlock();
		}
	}
	
	static function generateTLQuarter(level:Int, lakeRadius:Int) : Grid<GridCell>
	{
		var random = Game.me.rand.random;
		var qw = Lib.GRID_MID_WMAX;
		var qh = Lib.GRID_MID_HMAX;
		//
		var qgrid : Grid<GridCell> = GridTools.generate( qw, qh, function(x, y) {
			return new GridCell(x, y);
		});
		//borders pass
		for(i in 0...qw )
		{
			qgrid.getAt(i, 0).collisionFlags.set(CTop);
			qgrid.getAt(i, 0).flags.set(Border);
		}
		for( i in 0...qh )
		{
			qgrid.getAt(0, i).collisionFlags.set(CLeft);
			qgrid.getAt(0, i).flags.set(Border);
		}
		//simple edge locks
		var ry = 1 + random(qh - 2);
		var c = qgrid.getAt(0, ry);
		c.flags.set(Target); qgrid.getAt(0, ry + 1).flags.set(Target);
		c.collisionFlags.set(CBottom);
		
		var rx = 1 + random(qw - 2);
		var c = qgrid.getAt(rx, 0);
		c.flags.set(Target);  qgrid.getAt(rx + 1, 0).flags.set(Target);
		c.collisionFlags.set(CLeft);
		// corner
		for( i in 0...lakeRadius+1 )
		{
			var x = qw - i, y = qh - i;
			for( lx in x...qw )
			{
				if( i == lakeRadius ) qgrid.getAt(lx, y).collisionFlags.set(CTop);
				qgrid.getAt(lx, y).flags.set(Lake);
			}
			for( ly in y...qh )
			{
				if( i == lakeRadius ) qgrid.getAt(x, ly).collisionFlags.set(CLeft);
				qgrid.getAt(x, ly).flags.set(Lake);
			}
		}
		// 2 sides locks
		var hasDoneExtend = false;
		var count = 3;
		for(i in 0...count )
		{
			var isFreeCell = false;
			var rndCell : GridCell;
			var counter = 15;
			do
			{
				rndCell = qgrid.getAt( 1+random(qw-lakeRadius-1), random(qh) );
				if( rndCell.y == qh - 1 && rndCell.x == qw - 1 ) isFreeCell = false;
				else isFreeCell = isFree(qgrid, rndCell);
			} while( !isFreeCell && --counter > 0 );
			//
			if( !isFreeCell )
			{
				if( rndCell != null ) rndCell.setBlock();
				continue;
			}
			//apply pattern
			var pattern = PATTERNS[random(PATTERNS.length)];
			//can be extended ?
			if( !hasDoneExtend && pattern.extension.length > 0 )
			{
				var start = random(pattern.extension.length);
				for( i in 0...pattern.extension.length )
				{
					var id = MLib.wrap(start+i, 0, pattern.extension.length-1);
					var extend = pattern.extension[id];
					var moveLength = qgrid.getMoveLength(rndCell, extend.move);
					if( moveLength < 2 ) continue;
					//
					var next = qgrid.getAtMove( rndCell, extend.move );
					for( col in extend.cols )
					{
						next.collisionFlags.set( col );
					}
					hasDoneExtend = true;
					next.flags.set(ExtendedCollision);
					rndCell.flags.set(ExtendedCollision);
					next.flags.set(Target);
					break;
				}
			}
			//apply pattern collisions
			for( col in pattern.cols )
			{
				rndCell.collisionFlags.set( col );
			}
			rndCell.flags.set(Target);
		}
		return qgrid;
	}
	
	static function getRowCollisions( grid:Grid<GridCell>, row:Int ) : Array<GridCell>
	{
		var cols = [];
		var row = grid[row];
		if( row == null ) return cols;
		for( cell in row )
			if( (cell.collisionFlags.has(CLeft) || cell.collisionFlags.has(CRight)) && cell.flags.toInt() == 0 )
				cols.push(cell);
		return cols;
	}

	static function getColumnCollisions( grid:Grid<GridCell>, column:Int ): Array<GridCell>
	{
		var cols = [];
		for( i in 0...grid.length )
		{
			var cell = grid.getAt( column, i);
			if( cell == null ) return [];
			if( (cell.collisionFlags.has(CBottom) || cell.collisionFlags.has(CTop)) && cell.flags.toInt() == 0 )
				cols.push(cell);
		}
		return cols;
	}

	static function countCollisionOnRow( grid:Grid<GridCell>, row : Int )
	{
		var count = 0;
		for( i in 1...Lib.GRID_REAL_WMAX )
		{
			var cell = grid.getAt(i, row);
			if( cell.hasCollision(grid, CLeft) || cell.hasCollision(grid, CRight) )
				count ++;
		}
		return count;
	}

	static function countCollisionOnColumn( grid:Grid<GridCell>, column : Int )
	{
		var count = 0;
		for( i in 1...Lib.GRID_REAL_HMAX )
		{
			var cell = grid.getAt(column, i);
			if( cell.hasCollision(grid, CBottom) || cell.hasCollision(grid, CTop) )
				count ++;
		}
		return count;
	}

	static function flipQuarterY( grid:Grid<GridCell> )
	{
		var qw = Lib.GRID_MID_WMAX;
		var qh = Lib.GRID_MID_HMAX;
		return GridTools.generate( qw, qh, function(x, y) {
				var ref = grid.getAt(qw - 1 - x, y);
				var copy = ref.clone();
				copy.x = x;
				copy.y = y;
				if( ref.hasCollide() && !ref.flags.has(Block) )
				{
					if( ref.collisionFlags.has( CLeft ) )
					{
						copy.collisionFlags.set( CRight );
						copy.collisionFlags.unset( CLeft );
					}
					if( ref.collisionFlags.has( CRight ) )
					{
						copy.collisionFlags.set( CLeft );
						copy.collisionFlags.unset( CRight );
					}
				}
				return copy;
			} );
	}

	static function flipQuarterX( grid:Grid<GridCell> )
	{
		var qw = Lib.GRID_MID_WMAX;
		var qh = Lib.GRID_MID_HMAX;
		return GridTools.generate( qw, qh, function(x, y) {
				var ref = grid.getAt(x, qh - 1 - y);
				var copy = ref.clone();
				copy.x = x;
				copy.y = y;
				if( ref.hasCollide() && !ref.flags.has(Block) )
				{
					if( ref.collisionFlags.has( CTop ) )
					{
						copy.collisionFlags.set( CBottom );
						copy.collisionFlags.unset( CTop );
					}
					if( ref.collisionFlags.has( CBottom ) )
					{
						copy.collisionFlags.set( CTop );
						copy.collisionFlags.unset( CBottom );
					}
				}
				return copy;
			} );
	}

	static function symetricQuarter( grid:Grid<GridCell> )
	{
		var qw = Lib.GRID_MID_WMAX;
		var qh = Lib.GRID_MID_HMAX;
		return GridTools.generate( qw, qh, function(x, y) {
				var ref = grid.getAt(qw - 1 - x, qh - 1 - y);
				var copy = ref.clone();
				copy.x = x;
				copy.y = y;
				if( ref.hasCollide() && !ref.flags.has(Block) )
				{
					copy.collisionFlags = haxe.EnumFlags.ofInt(0);
					if( ref.collisionFlags.has( CLeft ) ) 	copy.collisionFlags.set( CRight );
					if( ref.collisionFlags.has( CRight ) ) 	copy.collisionFlags.set( CLeft );
					if( ref.collisionFlags.has( CTop ) ) 	copy.collisionFlags.set( CBottom );
					if( ref.collisionFlags.has( CBottom ) )	copy.collisionFlags.set( CTop );
				}
				return copy;
			} );
	}
	
	public static function isFree(grid:Grid<GridCell>, cell:GridCell)
	{
		if( cell == null || cell.hasCollide() ) return false;
		for( col in [CLeft, CRight, CBottom, CTop] )
			if( cell.hasCollision( grid, col ) )
				return false;
		
		var nl = grid.getNeighbours(cell.x, cell.y);
		if( nl.topLeft != null && (nl.topLeft.hasCollision(grid,CRight) || nl.topLeft.hasCollision(grid,CBottom)) )
			return false;
		
		if( nl.topRight != null && (nl.topLeft.hasCollision(grid,CLeft) || nl.topLeft.hasCollision(grid,CBottom)) )
			return false;
			
		if( nl.bottomLeft != null && (nl.topLeft.hasCollision(grid,CRight) || nl.topLeft.hasCollision(grid,CTop)) )
			return false;
		
		if( nl.bottomRight != null && (nl.topLeft.hasCollision(grid,CLeft) || nl.topLeft.hasCollision(grid,CTop)) )
			return false;
			
		return true;
	}
	
	
	public static function isFree2(grid:Grid<GridCell>, cell:GridCell)
	{
		if( cell == null || cell.hasCollide() ) return false;
		var neighbours = grid.getNeighbours(cell.x, cell.y);
		return  neighbours.left != null && !neighbours.left.hasCollide() &&
				neighbours.right != null && !neighbours.right.hasCollide() &&
				neighbours.top != null && !neighbours.top.hasCollide() &&
				neighbours.bottom != null && !neighbours.bottom.hasCollide() &&
				neighbours.topLeft != null && !neighbours.topLeft.hasCollide() &&
				neighbours.topRight != null && !neighbours.topRight.hasCollide() &&
				neighbours.bottomLeft != null && !neighbours.bottomLeft.hasCollide() &&
				neighbours.bottomRight != null && !neighbours.bottomRight.hasCollide();
	}
}