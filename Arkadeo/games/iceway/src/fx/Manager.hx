package fx;

import blit.BitmapLayer;
import Lib;

class Manager
{
	public var fxs:Array<Fx>;
	public var layer(default, null):BitmapLayer;
	public var root(default, null):Sprite;
	
	public function new( ?root : Sprite, ?layer : BitmapLayer )
	{
		fxs = [];
		this.layer = layer;
		this.root = root;
	}

	public function isBitmap() : Bool
	{
		return layer != null;
	}
	
	public function update()
	{
		var a = fxs.copy();
		for( fx in a )
		{
			fx.update();
		}
	}
	
	public function add(fx:Fx)
	{
		if( fx.manager != null )
			fx.manager.remove(fx);
		fx.manager = this;
		fxs.push(fx);
	}
	
	public function remove(fx:Fx)
	{
		fxs.remove(fx);
		fx.manager = null;
	}
	
	public function clean()
	{
		while( fxs.length > 0 )
			fxs[0].kill();
	}
	
	public function over(fx:Fx)
	{
		remove(fx);
		add(fx);
	}
	
	public function under(fx:Fx)
	{
		remove(fx);
		fxs.unshift(fx);
	}
}
