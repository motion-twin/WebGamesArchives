package blit;
import Lib;

import blit.BitmapLayer;

enum LayerKind {
	LKBitmap;
	LKSprite;
}

class BitmapViewport
{
	public var bitmap (default, null) : BitmapData;
	
	var layers : IntHash<BitmapLayer>;
	public var rect (default, null): Rectangle;
	public var transparent (default, null):Bool;
	public var backgroundColor( default, null):Int;
	
	var invalidated : Bool;
	var fxList : Array<blit.fx.ViewportFx>;
	
	var scale : Int;
	
	public function new( width : Int, height : Int, transparent : Bool, scale : Int = 1, backgroundColor : Int = 0x7FFFFF )
	{
		this.transparent = transparent;
		this.backgroundColor = backgroundColor;
		this.invalidated = true;
		this.scale = scale;
		//
		var w = Std.int( (width + .5) / scale ), h = Std.int( (height + .5) / scale );
		layers = new IntHash();
		rect = new Rectangle( 0, 0, w, h);
		bitmap = new BitmapData( w, h, transparent, backgroundColor );
		fxList = [];
	}
	
	public function addFx( fx:blit.fx.ViewportFx)
	{
		fxList.push(fx);
	}
	
	public function removeFx( fx:blit.fx.ViewportFx )
	{
		fxList.remove(fx);
	}
	
	public function createLayer( depth:Int ) : BitmapLayer
	{
		var layer = new BitmapLayer( this );
		layers.set( depth, layer );
		return layer;
	}
	
	public function getLayerByDepth( depth : Int ) : Null<BitmapLayer>
	{
		return layers.get( depth );
	}
	
	public function invalidate()
	{
		invalidated = true;
	}
	
	public function render()
	{
		if( invalidated == false ) return;
		//
		bitmap.lock();
		//
		for( fx in fxList )
			fx.before(this);
		//
		for( layer in layers )
			if( layer.visible )
				layer.render(scale);
		//
		for( fx in fxList )
			fx.after(this);
		//
		bitmap.unlock();
		//
		invalidated = false;
	}
}