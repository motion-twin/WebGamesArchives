package fx;

using Ex;

import Types;
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;


@:publicFields
class SimpleHighlight extends mt.fx.Fx
{
	public var progressive(default, set) : Bool;
	public var degressive(default, set) : Bool;
	
	public var filt : flash.filters.GlowFilter;
	var el:mt.pix.Element;
	public function new( 	el : mt.pix.Element,
							col : Int) 
	{
		super();
		
		var f = new flash.filters.GlowFilter();
		f.color = col;
		f.blurX = 4;
		f.blurY = 4;
		f.strength = 16;
		filt = f;
		
		this.el  = el;
		el.filters = [filt];
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
		if ( el == null) return;
		
		el.filters = [filt];
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
			else tick();
		}
	}
	
	public override function kill()
	{
		el.filters = [];
		super.kill();
	}
}