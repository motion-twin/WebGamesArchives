package fx;

import Types;
import Data;

/**
 * ...
 * @author de
 */

class PathHighlight extends Entity
{
	public function new(g)
	{
		super(g,FX);

		init( g, Data.mkSetup("FX_TILE_HIGHLIGHT_GREEN"));
		engine = UsePostFx;
	}
	
	public override function setPos(x,y)
	{
		super.setPos(x,y);
		te.el.y -= 2;
		
		if( Main.ship == null || Main.ship.player == null ) return;
		
		var grp = Main.ship.player.getGridPos();
		te.el.visible = grid.isPathable( x, y) && !( grp.x == x && grp.y == y );
		
	}
	
	
}