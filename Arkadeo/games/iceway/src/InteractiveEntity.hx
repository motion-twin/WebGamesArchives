package;

import Lib;
import mt.deepnight.SpriteLib;
import mt.deepnight.Particle;
import Entity.EntityKind;
import gfx.Arrows;
import gfx.Arrows2;
import gfx.Selection;

using GridTools;
using mt.kiroukou.motion.Tween;
class InteractiveEntity extends Entity, implements mt.kiroukou.events.Signaler
{
	public var arrows : Array<gfx.Arrows>;
	
	@:signal
	public function onSelected(e : InteractiveEntity );
	
	@:as3signal( flash.events.MouseEvent.CLICK, gfx )
	function onClick() {}
	
	@:as3signal( flash.events.MouseEvent.ROLL_OVER, gfx )
	function onOver() {}

	@:as3signal( flash.events.MouseEvent.ROLL_OUT, gfx )
	function onOut() {}

	public function new( kind : EntityKind, gfxSprite:DSprite, cell )
	{
		super(kind, gfxSprite, cell);
		//
		arrows = [];
		var moves = Lib.MOVES_DIRS;
		for( i in 0...4 )
		{
			var dir = Lib.getDir( moves[i] );
			
			var mc = 	if( kind == EK_Dog ) new Arrows2(this, moves[i]);
						else new Arrows(this, moves[i]);
			mc.gotoAndStop(i + 1);
			//Game.me.dm.add( mc, Game.DM_GAME );
			arrows.push(mc);
		}
		hideArrows();
		
		//
		this.gfx.buttonMode = true;
	}
	
	override public function dispose()
	{
		for( arrow in arrows )
			arrow.dispose();
		arrows = [];
		this.unbindAll();
		super.dispose();
	}
	
	public function getSelectFilters() : Array<flash.filters.BitmapFilter>
	{
		var color = kind == EK_Dog ? 0x44B9EB : 0xF7BC0A;
		var f = new flash.filters.GlowFilter(color, 0.5, 8, 8, 4, 1, false);
		return [f];
	}
	
	public function selected()
	{
		return gfx.filters.length > 0;
	}
	
	public function select()
	{
		gfx.filters = getSelectFilters();
	}
	
	public function unselect()
	{
		gfx.filters = [];
	}
	
	public function showArrow( moveDir : MoveDir )
	{
		return;
		if( !GridCellTools.isValidMove( Game.me.grid, cell, moveDir, true ) ) return;
		var arrow = Lambda.filter(arrows, function(a) return a.isDir(moveDir)).first();
		if( !arrow.visible )
		{
			Tween.removeTarget(arrow);
			var dir = Lib.getDir( arrow.dir );
			var tcell = Game.me.grid.getAt( cell.x + dir[0], cell.y + dir[1] );
			var coord = Lib.getCoord( tcell, false );
			arrow.x = coord.x;
			arrow.y = coord.y;
			arrow.show();
			arrow.deactivate();
			arrow.clearHitArea();
			//
			var bounds = arrow.getBounds(arrow);
			var l = GridCellTools.getEntityMoveLength( Game.me.grid, cell, arrow.dir ) - 0.5;
			mt.kiroukou.geom.RectangleTools.addPoint(bounds, { x : dir[0] * l * Lib.TILE_SIZE + Lib.TILE_MID_SIZE, y : dir[1] * l * Lib.TILE_SIZE + Lib.TILE_MID_SIZE} );
			arrow.updateHitArea( bounds );
		}
		Game.me.dm.over(arrow);
		arrow.unbindAllOnClick();
		arrow.bindOnClick( function() {
			if( Game.me.control.isLocked() ) return;
			//
			if( !api.AKApi.isReplay() )
			{
				Game.me.control.useKeyboard = false;
				api.AKApi.emitEvent( Game.AK_EVENT_MOVE_DIR );
				api.AKApi.emitEvent(Lambda.indexOf(Game.me.allEntities, this));
				api.AKApi.emitEvent(Lambda.indexOf(Lib.MOVES_DIRS, arrow.dir));
			}
			arrow.animate( function() Game.me.control.useKeyboard = false );
		} );
	}
	
	public function showArrows(force:Bool = false)
	{
		return;
		if( api.AKApi.isReplay() ) return;
		if( !force && Game.me.step != SInteractive ) return;
		for( arrow in arrows )
		{
			arrow.clean();
			arrow.reset();
			showArrow( arrow.dir );
		}
	}
	
	public function fadeOutArrows()
	{
		return;
		for( arrow in arrows )
		{
			arrow.alpha = 0;
			arrow.visible = false;
			arrow.deactivate();
		}
	}
	
	public function hideArrows()
	{
		return;
		for( arrow in arrows )
		{
			arrow.deactivate();
			arrow.hide();
		}
	}
	
	override public function move(dir:MoveDir, dest:GridCell)
	{
		unbindAllOnOver();
		super.move(dir, dest);
		if( follower != null )
			follower.move(dir, dest);
	}

}