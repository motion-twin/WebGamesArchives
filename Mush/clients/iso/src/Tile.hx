package ;

import Data;
import Types;

using Ex;
/**
 * ...
 * @author de
 */

enum TileStage
{
	Root;
	Ground;
	Wall;
	Props;
}


class Tile implements Z
{
	var	l : EnumHash< TileStage, TileEntry>;
	public var pos(default,null) : V2I;
	var grid : Grid;
	
	public var toFront(default,set_toFront) : Bool;
	
	//returns a cell pos
	public function getGridPos() 	: V2I return pos;
	public function getPixelPos() 	: { x:Float, y:Float } return V2DIso.grid2px( pos.x, pos.y );
	public function getGrid()		return grid;
	
	public function new(grid)
	{
		this.grid = grid;
		l = new EnumHash(TileStage);
		var rt = new ElementEx();
		rt.visible = true;
		
		var te : TileEntry= { setup:null, el: cast new ElementEx() };
		l.set( Root, te );
		te.el.mouseEnabled = false;
		te.el.mouseChildren = false;
		toFront = false;
		pos = new V2I(0, 0);
	}
	
	function set_toFront(v:Bool)
	{
		toFront = v;
		grid.dirtSort();
		return v;
	}
	
	public inline function isPathable() return grid.isPathable( pos.x, pos.y );
	public inline function isSpawnable() return grid.isSpawnable( pos.x, pos.y );
	public inline function isWalkable() return grid.isWalkable( pos.x, pos.y );
	
	public function getZ() : Float
	{
		if( toFront ) return 1000;
		return pos.x + pos.y;
	}
	
	public function getPrio() : Int
	{
		return IsoConst.BG_PRIO;
	}
	
	public function getDo() : flash.display.Sprite
	{
		return root().el;
	}
	
	public inline function root() return l.get(Root);
	
	
	public function tiles()
	{
		return l;
	}
	
	public function get( ts : TileStage, create:Bool =false ) : TileEntry
	{
		var o = l.get(ts);
		if(o == null && create)
		{
			o = { setup:null, el:null };
			o.el = new ElementEx();
			o.el.x = 0;
			o.el.y = 0;
			o.el.visible = true;
			root().el.addChild( o.el );
			l.set(ts, o);
		}
		return o;
	}
	
	
	public dynamic function onOver()
	{
		
	}
	
	public dynamic function onOut()
	{
	}
	
	public dynamic function onClick()
	{
		
	}
	
	//check dooritude against deps
	public function isDoor()
	{
		var gpos = getGridPos();
		
		return grid.getDeps( gpos.x, gpos.y).test(function(d)
		{
			if( d.gameData == null ) return false;
			
			switch(d.gameData)
			{
				case Door( _, _ ): return true;
				default: //skip
			}
			return false;
		}
		);
	}
	
	public function isDoorPad()
	{
		var gpos = getGridPos();
		var pad = grid.getDoorPadXY(gpos.x, gpos.y);
		
		return pad != null;
	}
	
	public function getDoorDep() : DepInfos
	{
		var gpos = getGridPos();
		return grid.getDeps( gpos.x, gpos.y).find(function(d)
		{
			if( d.gameData == null ) return false;
			
			switch(d.gameData)
			{
				case Door( _, _ ): 
					for ( d in d.pad)
						if ( gpos.isEq( d )) 
							return true;
						else return false;
				default: //skip
			}
			return false;
		}
		);
	}
	
	public function getDoorDest()
	{
		var gpos = getGridPos();
		var pad = grid.getDoorPadXY(gpos.x, gpos.y);
		
		switch( pad.gameData)
		{
			case Door(_, t): return t;
			default: //skip
		}
		return null;
	}
	
	public function set( ts : TileStage, elem : TileEntry, activate:  Bool )
	{
		elem.el.visible = true;
		
		var old = l.get( ts );
		if( old != null )
		{
			if( old.el.parent == root().el )
				root().el.removeChild( old.el );
			old.el.visible = false;
		}
		
		l.set( ts, elem );
		if(activate)
			root().el.addChild( elem.el );
	}
	
	public function fixPos() setPos( pos.x, pos.y);
	
	//input in grid pos
	public function setPos(x,y)
	{
		pos.set(x, y);
		var pix = V2DIso.grid2px(x, y);
		l.get( Root ).el.x = pix.x;
		l.get( Root ).el.y = pix.y - grid.getGroundOffsetY(x,y);
		return this;
	}
	
	public function toString()
		return 'tile: $pos ';
		
}