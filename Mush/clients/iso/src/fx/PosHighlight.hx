package fx;

import Data;
import Types;

/**
 * ...
 * @author de
 */
class PosHighlight extends Entity
{
	public function new(g,fx="FX_TILE_HIGHLIGHT_BLUE")
	{
		super(g,FX);
		
		init( grid, Data.mkSetup(fx));
		
		engine = UseTile;
	}
	
	//public override dynamic function getPrio() return IsoConst.DECAL_PRIO - 1
	
	public override function setPos(x,y)
	{
		super.setPos(x,y);
		te.el.y -= 2;
	}
	
	public override function update()
	{
		//el.alpha = MathEx.clamp( 0.2 + 0.5 + Math.sin( Main.time * 8) * (0.5), 0, 1);
	}
	
}