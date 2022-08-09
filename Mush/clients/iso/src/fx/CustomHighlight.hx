package fx;

using Ex;

import Types;
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;



@:publicFields
class CustomHighlight  extends mt.fx.Fx
{
	var grid:Grid;
	var te:TileEntry;
	var bindPos:V2I;
	
	var parent : DisplayObjectContainer;

	public var progressive(default, set) : Bool;
	public var degressive(default, set) : Bool;
	
	public var filt : flash.filters.GlowFilter;
	
	public function new( 	grid:Grid,bPos:V2I,setup : PixSetup,
							parent : DisplayObjectContainer,
							col : Int, zeroMask=false) 
	{
		super();
		this.grid = grid;
		this.bindPos = bPos.clone();
		
		var f = new flash.filters.GlowFilter();
		f.color = col;
		f.blurX = 4;
		f.blurY = 4;
		f.strength = 16;
		f.knockout = true;
		
		filt = f;
		var copyTe = Data.fromScratch( setup );
		te = copyTe;
		
		var slice : PixSlice  = Data.slices.get( copyTe.setup.index );

		var tpos = V2DIso.grid2px( bindPos.x, bindPos.y );
		te.el.x = Std.int( slice.ofsX);
		te.el.y = Std.int( slice.ofsY + grid.getGroundOffsetY( bindPos.x,bindPos.y ));
		te.el.visible = true;
		te.el.filters = [f];
		te.el.mouseEnabled = false;
		
		this.parent = parent;
		
		//Debug.MSG("creating");
		add();
		
		grid.dirtSort();
		
		if (zeroMask)
		{
			te.el.x = 0;
			te.el.y = 0;
		}
		
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
		if ( te == null) return;
		
		te.el.filters = [filt];
	}
	
	public static var perUpdate = 0.12;
	
	public override function update()
	{
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
			
			tick();
		}
	}
	
	//public function add() grid.postFx.add( te.el )
	//public function rem() grid.postFx.remove( te.el )
	
	public function add() parent.addChild( te.el );
	public function rem() parent.removeChild( te.el );
	
	public override function kill()
	{
		//Debug.MSG("killing");
		
		Debug.ASSERT( bindPos != null);
		te.el.filters = [];
		te.el.visible = false;
		
		rem();
		te = null;
		
		super.kill();
	}
}