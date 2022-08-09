package;

import Lib;

using GridCellTools;
using GridTools;
class PathGenerator
{
	public static var grid :Grid<GridCell>;

	inline public static function moveCell( from : GridCell, move : MoveDir, length:Int ):GridCell
	{
		var dir = Lib.getDir( move );
		var ox = from.x;
		var oy = from.y;
		var tx = ox + dir[0] * length;
		var ty = oy + dir[1] * length;
		var tmp = grid.getAt( tx, ty ).clone();
		grid.getAt(ox, oy).copyContent(tmp);
		grid.getAt(tx, ty).copyContent( from );
		return grid.getAt(tx, ty);
	}

	public static function randomizeStart( from : GridCell ):GridCell
	{
		var random = Game.me.rand.random;
		var moves = [MLeft, MRight, MUp, MDown];
		var offset = random(4);
		for( i in 0...moves.length )
		{
			var id = MLib.wrap(i+offset, 0, moves.length-1);
			var move = moves[id];
			var l = grid.getMoveLength( from, move );
			var minOffset = 1;
			if( l > minOffset )
			{
				var t = null;
				do
				{
					t = moveCell( from, move, minOffset + random(1 + l - minOffset) );
					minOffset = 0;
				} while( t == null || t.flags.has(GeneratorLocked) );
				return t;
			}
		}
		return from;
	}

	public static function getRandomCell()
	{
		var random = Game.me.rand.random;
		var cell;
		do
		{
			cell = grid.getAt( random( Lib.GRID_WMAX ), random( Lib.GRID_HMAX ) );
		} while( cell == null || cell.flags.has(Block) || cell.flags.has(Lake) || cell.flags.has(GeneratorLocked) );
		
		return cell;
	}
	
	/*
	public static function computeTargetsComplexity()
	{
		grid.iter( function(cell) {
			if( cell.pathLevel > 0 )
			{
				cell.setAsTarget();
				cell.targetInfos = { complexity:0, requires:[] };
				for( move in Lib.MOVES_DIRS )
				{
					if( grid.isValidMove( cell, move ) )
					{
						var t = grid.getAtMove(cell, move);
						if( !t.isTarget() )
						{
							t.setAsTarget();
							t.targetInfos = { complexity:cell.targetInfos.complexity + 1, requires:cell.targetInfos.requires.concat([cell]) };
							
							for( move2 in Lib.MOVES_DIRS )
							{
								if( grid.isValidMove( t, move2 ) )
								{
									var t2 = grid.getMoveTarget( t, move2 );
									if( !t2.isTarget() )
									{
										t2.setAsTarget();
										t2.targetInfos = { complexity:cell.targetInfos.complexity + 1, requires:cell.targetInfos.requires.concat([cell]) };
									}
								}
							}
						}
					}
				}
			}
		});
	}
	*/
	/*
	public static function computeTargetsComplexity()
	{
		//COMPLEXITY 0
		grid.iter( function(cell) {
			if( cell.pathLevel > 0 )
			{
				cell.setAsTarget();
				cell.targetInfos = { complexity:0, requires:[] };
			}
		});
		
		//COMPLEXITY 1
		var processList = new List();
		grid.iter( function(cell) {
			if( cell.pathLevel == -1 && cell.hasCollide() && cell.countCollisions(grid) < 4 )
			{
				//cell.setAsTarget();
				processList.add(cell);
			}
		} );
		
		function computeCellComplexity(cell:GridCell)
		{
			if( cell.targetInfos.complexity >= 0 ) return;
			//
			var moves : Array<MoveDir> = [MLeft, MRight, MUp, MDown];
			var complexities = [];
			for( move in moves )
			{
				if( grid.isValidMove( cell, move ) )
				{
					var t = grid.getMoveTarget( cell, move );
					// check if target has been processed .If not, then we need to post process this one
					if( t.isTarget() && t.targetInfos.complexity == -1 )
					{
						return;
					}
					else if( t.isTarget() )
					{
						complexities.push( { complexity : t.targetInfos.complexity, requires:t.targetInfos.requires.copy() } );
					}
					else
					{
						// From here now, we need to be sure there's a 1 length move possible !
						var moves2 = moves.copy();
						moves2.remove(move); moves2.remove(Lib.getOppositeMove(move));
						for( move2 in moves2 )
						{
							var t2 = grid.getMoveTarget( t, move2 );
							if( t2.pathLevel == -1 ) continue;
							var l = grid.getMoveLength(t, move2);
							if( l == 1 )
							{
								complexities.push( { complexity:1, requires:[t2] } );
							}
							else if( l == 2 )
							{
								complexities.push( { complexity:2, requires:[grid.getAtMove(t, move2), t2 ] } );
							}
						}
					}
				}
			}
			if( complexities.length > 0 )
			{
				// we now pick the best one, so the lowest one
				complexities.sort( function(c1, c2) return c1.complexity - c2.complexity );
				cell.targetInfos = complexities[0];
			}
		}
		//On tente de résoudre ça en plusieurs passes
		for( i in 0...10 )
		{
			for( cell in processList )
			{
				computeCellComplexity( cell );
				if( cell.targetInfos.complexity >= 0 )
					processList.remove(cell);
			}
		}
		//cleaning
		for( cell in processList )
		{
			cell.flags.unset(Target);
			cell.targetInfos = null;
		}
	}
	*/
	
	static function getTarget( complexity : Null<Int>, level:Int )
	{
		var random = Game.me.rand.random;
		var targets = [];
		//
		grid.iter( 	function(cell)
					{
						if( cell.flags.has(GeneratorLocked) )
							return;
						if( cell.flags.has( Block ) )
							return;
						if( cell.flags.has(Target) )
						{
							var cellLevel = cell.pathLevel;
							for( r in cell.pathRequires )
								cellLevel = MLib.max(cellLevel, r.pathLevel);
							var id = MLib.abs( cellLevel - level );
							if( targets[id] == null ) targets[id] = [cell];
							else targets[id].push(cell);
						}
					}
		);
		var t = null;
		while( targets.length > 0 )
		{
			var a = targets.shift();
			if( a == null ) continue;
			t = a[random(a.length)];
			if( t != null )
			{
				break;
			}
		}
		return t;
	}

	static function getBestStart()
	{
		var best = null;
		grid.iter( 	function(cell)
					{
						if( cell.flags.has(GeneratorLocked) ) return;
						if( best == null ) best = cell;
						else if( best.pathLevel < cell.pathLevel ) best = cell;
					}
		);
		return best;
	}
	
	static function getStarts(level:Int, range:Int=0)
	{
		var starts = [];
		grid.iter( 	function(cell)
					{
						if( cell.flags.has(GeneratorLocked) ) return;
						if( MLib.inRange( cell.pathLevel, level - range, level + range ) )	starts.push(cell);
					}
		);
		return starts;
	}

	public static function computeKdoPath( from : GridCell, kdoLevel : Int )
	{
		grid.cleanGrid();
		from.pathLevel = 0;
		grid.diffuseLength(from, from, 1);
		return getTarget(null, kdoLevel );
	}
	
	public static function computePath( targetLevel : Int, error:Int )
	{
		var random = Game.me.rand.random;
		var home = null, from = null, to = null, pathLength, moves = [], helpers = [], kdoPositions = [];
		grid.iter(function(c) if( c.flags.has(Home) ) home = c );
		//
		if( home == null ) return null;
		home.flags.set(GeneratorLocked);
		//
		var path1 = createPath(home, targetLevel, kdoPositions);
		if( path1 == null ) return null;
		//
		var best = -1;
		for( c1 in path1 )
		{
			var target = c1.cell;
			var path2 = createPath(target, targetLevel, kdoPositions);
			if( path2 == null ) continue;
			for( c2 in path2 )
			{
				if( (c1.level + c2.level) > best )
				{
					best = c1.level + c2.level;
					to = target;
					from = c2.cell;
					helpers = c1.requires.copy();
				}
			}
		}
		
		if( from == null || to == null ) return null;
		
		to.flags.set(GeneratorLocked);
		from.flags.set(GeneratorLocked);
		for( kdo in kdoPositions.copy() )
		{
			if( kdo.flags.has(GeneratorLocked) )
			{
				kdoPositions.remove(kdo);
			}
		}
		
		if( best < (targetLevel-error) ) return null;

		return { girl: from, boy: to, home: home, helpers:helpers, length: api.AKApi.const(best), kdo : kdoPositions };
	}
	
	public static function createPath( target : GridCell, targetLevel: Int, kdoPositions : Array<GridCell> )
	{
		if( target == null ) return null;
		target.flags.set(GeneratorLocked);
		//
		var fromList = [];
		grid.iter( 	function(current)
					{
						if( current.flags.has( GeneratorLocked ) ) return;
						if( !current.flags.has(Target) ) return;
						//
						grid.cleanGrid();
						current.pathLevel = 0;
						grid.diffuseLength(current, current, 1);
						//
						if( target.pathLevel == -1 ) return;
						
						kdoPositions.remove(current);
						kdoPositions.push(current);
						
						var id = MLib.abs(targetLevel - target.pathLevel);
						if( fromList[id] == null ) fromList[id] = [ { cell:current, level:target.pathLevel, requires:[] } ];
						else fromList[id].push( { cell:current, level:target.pathLevel, requires:[] } );
					} );
		//
		while( fromList.length > 0 )
		{
			var l = fromList.shift();
			if( l == null ) continue;
			return l;
		}
		return null;
	}
	
	inline static var MAX_REQUIRES = 2;
	public static function createComplexPath( target : GridCell, targetLevel: Int )
	{
		if( target == null ) return null;
		target.flags.set(GeneratorLocked);
		//
		var fromList = [];
		grid.iter( 	function(current)
					{
						//if( fromList.length > 0 ) return;//TODO
						if( current.flags.has(GeneratorLocked) ) return;
						if( !current.flags.has(Target) ) return;
						//
						grid.cleanGrid();
						current.pathLevel = 0;
						grid.diffuseLength(current, current, 1);
						//
						if( target.pathLevel == -1 ) {
							grid.diffuseLengthComplex(current, current, 0);
							
							var cell = target, requires = [];
							while( cell.pathRequires.length > 0 )
							{
								for( r in cell.pathRequires )
								{
									requires.push(r);
								}
								cell = requires[requires.length - 1];
							}
							
							if( requires.length == 0 || requires.length > MAX_REQUIRES ) return;
							
							var id = MLib.abs(targetLevel - target.pathLevel);
							if( fromList[id] == null ) fromList[id] = [ { cell:current, level:target.pathLevel, requires:requires } ];
							else fromList[id].push( { cell:current, level:target.pathLevel, requires:requires } );
						}
					} );
		//
		while( fromList.length > 0 )
		{
			var l = fromList.shift();
			if( l == null ) continue;
			return l;
		}
		return null;
	}
	/*
		var path = createPath(target, targetLevel);
		if( path == null ) return null;
		for( p in path )
		{
			var current = p.cell;
			grid.cleanGrid();
			current.pathLevel = 0;
			grid.diffuseLengthComplex(current, current, 1);
			trace( target.pathRequires );
			if( target.pathRequires.length > 0 ) return [ { cell:current, level:target.pathLevel, requires:target.pathRequires } ];
			//var id = MLib.abs(targetLevel - target.pathLevel);
			//if( fromList[id] == null ) fromList[id] = [ { cell:current, level:target.pathLevel, requires:target.pathRequires.
		}
		return path;
	}
	*/
}

