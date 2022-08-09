package fx;

using Ex;
import Data;
import Types;
/**
 * ...
 * @author de
 */

 //i kno its lot of craps but it is easier this way
class SpriteHighlight extends mt.fx.Fx
{
	public var bindPos : V2I;
	public var te : TileEntry;
	public var grid : Grid;
	
	public var filt : flash.filters.GlowFilter;
	public var progressive(default, set ) : Bool;
	public var degressive(default, set ) : Bool;
	
	public function new( grid,bindPos : V2I, ote, color=0x00FF00)
	{
		super();
		this.grid = grid;
		this.bindPos = bindPos.clone();
		
		var f = new flash.filters.GlowFilter();
		f.color = color;
		f.blurX = 4;
		f.blurY = 4;
		f.strength = 16;
		f.knockout = true;
		filt = f;
		
		var copyTe = IsoUtils.teCopy( ote);
		this.te = copyTe;
		
		var slice : PixSlice  = Data.slices.get( copyTe.setup.index );
		var tpos  = V2DIso.grid2px( bindPos.x,bindPos.y );
		te.el.x = Std.int(tpos.x + slice.ofsX);
		te.el.y = Std.int(tpos.y + slice.ofsY + grid.getGroundOffsetY( bindPos.x,bindPos.y ));
		te.el.visible = true;
		
		te.el.filters = [f];
		te.el.mouseEnabled = false;
		
		grid.postWall.add( te.el );
		grid.dirtSort();
		
		progressive = false;
		degressive = false;
	}
	
	function set_progressive(b)
	{
		progressive = b;
		if ( progressive )
		{
			filt.alpha = 0.3;
			tick();
		}
		return b;
	}
	
	function set_degressive(b)
	{
		degressive = b;
		if ( degressive )
		{
			filt.alpha = 1.0;
			tick();
		}
		return b;
	}
	
	public function tick()
	{
		if ( te.el == null) return;
		te.el.filters = [filt];
	}
	
	public static var perUpdate = 0.12;
	public override function update(){
		
		if ( progressive&&!degressive)
		{
			filt.alpha += perUpdate;
			if (filt.alpha>=1)
			{
				filt.alpha = 1;
				progressive = false;
			}
			tick();
		}
		
		if ( degressive )
		{
			filt.alpha -= perUpdate;
			if (filt.alpha<=0.3)
			{
				filt.alpha = 0.3;
				degressive = false;
				kill();
			}
			else tick();
		}
	}
	
	public override function kill()
	{
		Debug.ASSERT( bindPos != null);
		te.el.filters = [];
		te.el.visible = false;
		grid.postWall.remove( te.el );
		te = null;
		grid = null;
		
		super.kill();
	}
	
}