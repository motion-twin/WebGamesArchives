package ;

import Dirs;
import Dirs.*;
import Data;
import Types;
import IsoProtocol;
import Protocol;
using Ex;

/**
 * ...
 * @author de
 */
class Player extends HumanNPC
{
	public var pathFx : fx.PathHighlight;
	public var hereFx : fx.PosHighlight;
	
	public function new(grid : Grid, data:ClientChar)
	{
		pathFx = new fx.PathHighlight(grid);
		super(grid,data);
		hereFx = new fx.PosHighlight( grid);
	}
	
	public function location()		return grid.getRid();
	override public function setPos(x:Int, y:Int)
	{
		super.setPos(x, y);
		if ( hereFx != null)
			hereFx.setPos( x, y);
		doMini();
	}
	
	public override function getEntitySet() 
	{
		var l = super.getEntitySet();
		
		if( hereFx!=null)
			l.pushBack( hereFx );
		
		if( pathFx!=null)
			l.pushBack( pathFx );
		
		return l;
	}
	
	public override function update()
	{
		super.update();
		var isPatrol = Protocol.roomDb( grid.getRid() ).type == PATROL_SHIP;
		el.visible = !isPatrol;
		if ( hereFx != null)
			hereFx.el.visible = !isPatrol;
	}
	
	public override function changeRoom(from:Grid,to:Grid)
	{
		Debug.ASSERT( to != null);
		
		
		super.changeRoom( grid, to );
		
		if(from != null)
		{
			var inDep = to.findDoorTo( from.getRid() );
			if( inDep == null )
				return;
			
			Debug.ASSERT( inDep != null ) ;
			var pad = to.getDoorPad( inDep ) ;
			var np = pad.first();
			
			Main.ship.clearPos( grid, np );
			
			setPos( np.x, np.y);
			changeDir( Dirs.inv(to.getDoorDir(inDep) ));
		}
		else
		{
			var p = grid.randomFree();
			if (p != null)
			{
				var grp =  p.getGridPos();
				Main.ship.clearPos( grid, grp );
				setPos( grp.x, grp.y);
			}
			else  setPos( 0, 0);
		}
		
		if ( IsoConst.EDITOR)
			Main.save();
	}
	
	function doMini()
	{
		var mini = Main.gui.minimap;
		if ( mini != null && grid != null && hid != null)
		{
			var grPos =  getGridPos();
			mini.setPeopleRoom( hid, grid.getRid(), {x:grPos.x,y:grPos.y},true);
		}
	}
	
	public static var DYN_VP  = [SPACESHIP_BAY, CORRIDOR, MOTOR_ROOM];
	public override function isPlayer() return true;
	/**
	 *
	 * @return whether vp should be redone
	 */
	public function useDoor(to:Tile) : Bool
	{
		var dest = to.getDoorDest();
		if ( dest == null) return false;
		
		if( Main.mem!=null)
			Main.mem.curRoom  = dest.index();
		
		var grPos = pos.toGrid();
		var dep = grid.findDoorTo( dest );
		var pad = grid.getDoorPad(  dep );
		
		var ok = false;
		for(p in pad )
			if ( p.x == grPos.x  && p.y == grPos.y )
			{
				ok = true;
				break;
			}
		
		if ( !ok )
		{
			var pr = pad.first();
			setPos( pr.x, pr.y );
			changeDir( grid.getDoorDir(dep) );
			return true;
		}
		
		ServerProcess.hideCloset();
		if( IsoConst.EDITOR)
		{
			Main.changeActiveRoom( dest,
				function() changeRoom( 	grid,
										Main.ship.getGrid(dest) )
			);
			return false;
		}
		else
		{
			ServerProcess.makeMove( grid.getRid(),dest );
			return true;
		}
	}
	
	public override function circa( to:Tile )
	{
		var p = to.getGridPos();
		var mp = getGridPos();
		var tgt = [];
		for (i in E_DIRS.array())
		{
			var lx = p.x + Dirs.LIST[i.index()].x;
			var ly = p.y + Dirs.LIST[i.index()].y;
			
			if ( grid.isPathable( lx, ly) )
				tgt.pushBack( {x:lx,y:ly} );
		}
		
		var np = tgt.random();
		if ( np != null)
		{
			jumpTile( grid.get( np.x, np.y ) );
		}
		else
		{
			Debug.MSG("no circa of " + to);
		}
	}
	
	
	
	public function jumpTile( to:Tile )
	{
		var grPos = getGridPos();
		var otherGrPos = to.getGridPos();
		
		//trace( grPos + " " + otherGrPos);
		
		var dir = null;
		
		Main.ship.kickBlocker( getGrid(), grPos,otherGrPos );
		
		if ( !to.isDoor() )
		{
			if (IsoConst.WALK)
			{
				walkTo( otherGrPos.x, otherGrPos.y);
				
				if( Player.DYN_VP.has( Protocol.roomList[ Main.ship.curRoom.index() ].type ))
					Main.focusPosition( to.getDo().x, to.getDo().y);
			}
			else
			{
				set = CS_UP;
				setPos(  otherGrPos.x, otherGrPos.y );
				Main.doVp();
			}
			
			if (Select.hasSelection())
			{
				Select.cancelAllSelection();
				ServerProcess.cancelSelection();
			}
		}
		
		if(!IsoConst.WALK)
			lookBusy();
	}
	
	
	
	
	
	public function isTileReachable( to:Tile ) : Dirs.E_DIRS
	{
		var gpos = getGridPos();
		var toGPos = to.getGridPos();
		for( e in E_DIRS.array() )
		{
			var d = Dirs.LIST[e.index()];
			var n = { x:gpos.x + d.x , y:gpos.y + d.y };
			if(n.x == toGPos.x
			&& n.y == toGPos.y)
			{
				return e;
			}
		}
		return null;
	}
}