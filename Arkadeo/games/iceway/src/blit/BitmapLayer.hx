package blit;

import Lib;

import flash.display.IBitmapDrawable;

private enum ElementKind {
	EKTile;
	EKBitmapDrawable;
}

private typedef RenderItem = {
	var depth : Int;
	var tile : Null<blit.Tile>;
	var bmpDrawable : Null<IBitmapDrawable>;
	var kind :ElementKind;
	var infos : Null<{ matrix : flash.geom.Matrix, colorTransform : flash.geom.ColorTransform }>;
}

class BitmapLayer
{
	public var viewport(default, null) : BitmapViewport;
	public var bitmap(default, null):BitmapData;
	public var visible:Bool;
	
	var renderList : Array<RenderItem>;
	
	public function new( viewport : BitmapViewport )
	{
		this.viewport = viewport;
		this.bitmap = viewport.bitmap;
		this.visible = true;
		this.renderList = [];
	}
	
	public function addTile( tile : Tile, ?depth : Int = 0 )
	{
		renderList.push( { depth: depth, tile : tile, kind: EKTile, bmpDrawable: null, infos: null } );
		viewport.invalidate();
	}
	
	public function addDrawable( gfx : IBitmapDrawable, ?matrix:flash.geom.Matrix, ?colorTransform:flash.geom.ColorTransform, ?depth = 0 )
	{
		renderList.push( { depth: depth, bmpDrawable : gfx, kind: EKBitmapDrawable, tile: null, infos : { matrix:matrix, colorTransform:colorTransform } } );
		viewport.invalidate();
	}
	
	public function render(scaleFactor:Int = 1)
	{
		renderList.sort( function( r1, r2 )  return r1.depth - r2.depth );
		for( e in renderList )
		{
			switch( e.kind )
			{
				case EKTile :
					e.tile.render(bitmap, scaleFactor);
				case EKBitmapDrawable:
					var m = e.infos.matrix.clone();
					m.scale( 1 / scaleFactor, 1 / scaleFactor );
					bitmap.draw( e.bmpDrawable, m, e.infos.colorTransform );
			}
		}
		renderList = [];
	}
}

