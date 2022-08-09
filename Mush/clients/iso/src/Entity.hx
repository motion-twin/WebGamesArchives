package ;

import Data;
import Types;
/**
 * ...
 * @author de
 */


class Entity implements Z
{
	var pos : V2DIso;
	public var te : TileEntry;
	public var type(default,null) : Entities;
	public var engine : Engine;
	public var visible(get, set) : Bool;
	public var el(get, null) : ElementEx;
	
	public static var guid : Int = 0;
	public var  uid : Int;
	public var	curGrdOfs : Float = 0.0;
	
	var grid : Grid;
	
	public function new(grid,t : Entities)
	{
		this.grid = grid;
		pos = new V2DIso();
		te = 
		{
			el:cast new ElementEx(),
			setup:null,
		};
		type = t;
		
		setPos(0, 0);
		
		uid = guid++;
		engine = UseEntity;
	}
	
	public inline function get_visible() { return te.el.visible; }
	public inline function set_visible(v) { return te.el.visible=v; }
	
	inline function get_el() return cast te.el;
	
	public inline function getGrid() return grid;
	public inline  function bindGrid( grid )
	{
		this.grid = grid;
	}
	
	public inline function getGridPos() : V2I return pos.toGrid();
	public inline function getPos() : V2DIso
	{
		return pos;
	}
	public dynamic function getRect() : Array<V2I>
	{
		var grPos = getGridPos();
		return [grPos, grPos];
	}
	
	public function update() return;
	
	public function resetPos()
	{
		var grPos = getGridPos();
		setPos( grPos.x, grPos.y );
	}
	
	public function setPosv(v:V2I)
		setPos( v.x, v.y);
		
	public function setPosf(v:V2D)
	{
		pos.set(v.x, v.y);
		if( te.setup == null) return;
		
		var ofs = Data.spriteOfs( te.setup.index );
		
		te.el.x = Std.int(pos.x + ofs.x);
		te.el.y = Std.int(pos.y + ofs.y) - (curGrdOfs=grid.getGroundOffsetY( Std.int(v.x), Std.int(v.y)));
		
		grid.dirtSort();
	}
		
	public function setPos(x:Int,y:Int)
	{
		var ox = x; 
		var oy = y;
		
		pos.set(x, y);
		if( te.setup == null) return;
		
		var ofs = Data.spriteOfs( te.setup.index );
		
		te.el.x = Std.int(pos.x + ofs.x);
		te.el.y = Std.int(pos.y + ofs.y) - (curGrdOfs=grid.getGroundOffsetY(x,y));
		
		if ( ox != x || oy != y)
			grid.dirtSort();
	}
	
	public function getEntitySet() : Array<Entity>
	{
		return [this];
	}
	
	public function changeRoom( fromGrid:Grid, toGrid:Grid)
	{
		undoInput();
		
		onGridChange( fromGrid,toGrid );
		
		doInput();
	}
	
	//override me
	public function onGridChange( from:Grid, to:Grid )
	{
		var set = getEntitySet();
		for( x in set)		from.removeEntity(x);
		for( x in set)		to.addEntity( x );
	}
	
	public var prioOverride : Null<Void->Int> = null;
	
	public function getPrio() : Int
	{
		return prioOverride==null?IsoConst.CHAR_PRIO:prioOverride();
	}
	
	public function getZ() : Float
	{
		var gr = pos.toGrid();
		return gr.x+gr.y;
	}
	
	public function getDo() : flash.display.Sprite
	{
		return te.el;
	}
	
	
	public function doKill()
	{
		new mt.fx.Shake( el, 3, 3);
		new fx.RedSeq( "fx", el );
		new fx.Tween( "fx", 0.175, 1.0, 0.0, function(v) el.alpha = v )
			.interp( MathEx.lerp )
			.onKill = kill;
	}
	
	public function kill()
	{
		undoInput();
		grid.removeEntity( this );
	}
	
	public function init( ?gr : Grid, setup : PixSetup,add=true )
	{
		if(gr != null) grid = gr;
		if ( setup != null)
		{
			te.setup = setup;
			Data.setup( te.el, te.setup.sheet, te.setup.frame, te.setup.index);
			var slice = Data.slices.get( te.setup.index );
			if( slice.engine != null )
				engine = slice.engine;
		}
		te.el.visible = true;
		if(add)grid.addEntity( this);
		return this;
	}
	
	public function doSetup( ps : PixSetup)
	{
		te.setup = ps;
		var slice = Data.slices.get( te.setup.index);
		Data.setup( te.el, te.setup.sheet, te.setup.frame, te.setup.index);
		
		if ( IsoConst.BG_ANIM )
		{
			if ( slice.animable && slice.autoAnim)
				play();
		}
	}
	
	public function undoInput()
	{
		
	}
	
	public function doInput()
	{
		
	}
	
	public function onHurt()
	{
		new mt.fx.Shake( el, 3, 3);
		new fx.RedSeq( "fx", el );
	}
	
	public function play( ?num : Int )
	{
		if ( num == null) 	te.el.play(te.setup.index);
		else 				te.el.play(te.setup.index+"#"+num);
							
		return this;
	}
	
	public function toString()
	{
		return te.setup.index +" " + getGridPos();
	}
}