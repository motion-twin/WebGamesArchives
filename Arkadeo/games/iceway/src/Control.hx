package ;
import Lib;

using GridTools;
using Std;
class Control
{
	var lastCell : Null<GridCell>;
	var g : Game;
	var _locked : Bool;
	var playerLastCells : Array<GridCell>;
	
	inline static var ACTIVATION_DELAY = 1;
	
	var activationTime : Int;
	public var selectedEntity(default, null) : Null<InteractiveEntity>;
	public var useKeyboard : Bool;
	
	public function new(game : Game)
	{
		g = game;
		_locked = false;
		playerLastCells = [];
	}
	
	public function lock()
	{
		_locked = true;
	}
	
	public function unlock()
	{
		_locked = false;
	}
	
	public function isLocked()
	{
		return _locked;
	}
	
	public function init()
	{
		#if standalone
		mt.flash.Key.init();
		#else
		#end
		activationTime = ACTIVATION_DELAY;
		useKeyboard = false;
		//g.bindOnKeyFocus(onEntityFocus);
		lock();
	}
	
	public function reset()
	{
		var mc = g.dm.getMC();
		for( i in 0...mc.numChildren )
		{
			var clip = mc.getChildAt(i);
			if( !Std.is( clip, flash.display.InteractiveObject ) ) continue;
			var i : flash.display.InteractiveObject = cast clip;
			i.tabEnabled = false;
			i.focusRect = false;
		}
		
		var index = 0;
		for( e in g.intEntities )
		{
			e.gfx.focusRect = false;
			e.gfx.tabEnabled = true;
			e.gfx.tabIndex = index++;
			//
			e.hideArrows();
			e.unselect();
		}
		activationTime = ACTIVATION_DELAY;
		giveEntityFocus(g.player);
		gfx.Selection.cleanAll();
		lock();
	}
	
	public function showPath( cell : GridCell, move:MoveDir, ent : InteractiveEntity )
	{
		var dir = Lib.getDir( move );
		var tcell = Game.me.grid.getAt( cell.x + dir[0], cell.y + dir[1] );
		if( tcell == null ) return;
		var coord = Lib.getCoord( tcell, false );
		var l = GridCellTools.getEntityMoveLength( Game.me.grid, cell, move );
		for( i in 1...l+1 )
		{
			var cell = gfx.Selection.get().setCell( Game.me.grid.getAt( cell.x + i * dir[0], cell.y + i * dir[1] ) ).setFilters( selectedEntity.gfx.filters );
			if( !api.AKApi.isReplay() )
			{
				cell.bindOnClick( function() {
					api.AKApi.emitEvent( Game.AK_EVENT_MOVE_DIR );
					api.AKApi.emitEvent(Lambda.indexOf(Game.me.allEntities, ent));
					api.AKApi.emitEvent(Lambda.indexOf(Lib.MOVES_DIRS, move));
				} );
			}
		}
	}
	
	public function update()
	{
		if( isLocked() ) return;
		if( api.AKApi.isReplay() ) return;
		var before = selectedEntity;
		//
		var mc = g.dm.getMC();
		var mouseX = mc.mouseX;
		var mouseY = mc.mouseY;
		var overCell = g.grid.getAt( (mouseX / Lib.TILE_SIZE).int(), (mouseY / Lib.TILE_SIZE).int() );
		
		useKeyboard = overCell == lastCell;
		if( !useKeyboard && overCell != lastCell )
		{
			gfx.Selection.cleanAll();
			if( overCell != null )
			{
				var entities : Array<{e:InteractiveEntity, m:MoveDir}> = [];
				for( e in g.intEntities )
				{
					var move = isEntityTarget( e, overCell );
					if( move != null )
						entities.push( {e:e, m:move} );
				}
				
				if( entities.length > 0 )
				{
					var best = entities[0];
					var bestDist = best.e.cell.cellDistXY( mouseX, mouseY );
					for( i in 1...entities.length )
					{
						var d = entities[i].e.cell.cellDistXY( mouseX, mouseY );
						if( d < bestDist )
						{
							best = entities[i];
						}
					}
					
					if( best.e != selectedEntity )
					{
						if( selectedEntity != null )
						{
							selectedEntity.unselect();
						}
						selectedEntity = best.e;
						selectedEntity.select();
					}
					
					if( activationTime <= 0 )
					{
						if( bestDist <= Lib.TILE_MID_SIZE )
						{
							for( dir in Lib.MOVES_DIRS )
								showPath( selectedEntity.cell, dir, selectedEntity );
						}
						else
						{
							showPath( selectedEntity.cell, best.m, selectedEntity );
						}
					}
				}
			}
		}
		//
		if( before == selectedEntity )
			activationTime --;
		//
		lastCell = overCell;
	}
	
	/*
	function onEntityFocus( ev : flash.events.FocusEvent )
	{
		var entity = null;
		for( e in g.intEntities )
			if( e.gfx == ev.relatedObject )
				entity = e;
		if( entity != null )
			giveEntityFocus(entity);
	}
	*/
	
	public function isEntityTarget( entity : Entity, cell : GridCell ) : Null<MoveDir>
	{
		for( move in Lib.MOVES_DIRS )
			if( GridCellTools.isCellMoveTarget(Game.me.grid, entity.cell, move, cell ) )
				return move;
		return null;
	}
	
	public function giveEntityFocus(entity:InteractiveEntity)
	{
		//useKeyboard = true;
		//if( selectedEntity == entity ) return;
		selectedEntity = entity;
		for( e in g.intEntities )
		{
			if( e == entity )
			{
				e.select();
				e.showArrows(true);
			}
			else
			{
				e.hideArrows();
				e.unselect();
			}
		}
	}
}