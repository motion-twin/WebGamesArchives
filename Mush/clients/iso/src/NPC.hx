import Protocol;
import Types;

using Ex;
/**
 * ...
 * @author de
 */

class NPC extends Entity
{
	public var data : ClientNPC;
	public var sel:Select;
	public var mark : Bool;
	
	public function new(g,d:ClientNPC) 
	{
		super( g, CHARACTER );
		data = d;
		
		makeGfx();
		Main.allNPC.set( data.uid , this);
		
		refresh(d);
		
		sel = new Select(grid, null, null, this);
				
		mark = false;
		doInput();
	}
	
	public function getName()
	{
		switch(data.id)
		{
			case Cat: return Protocol.txtDb( "cat_name" );
		}
	}
	
	public function makeGfx()
	{
		switch(data.id)
		{
			case Cat:
				init( Data.mkSetup( "CAT" ));
				var rdPos = grid.randomFree();
				if (rdPos != null) 
				{
					var r = rdPos.getGridPos();
					setPos( r.x, r.y );
				}
				else 
				{
					Debug.MSG("no free pos");
					setPos( 0, 0 );
				}
		}
	}
	
	public function catSit( d : DepInfos )
	{
		
	}
	
	public override function undoInput()
	{
		grid.input.clean( te.el );
		sel.grid = null;
	}
	
	public override function doInput()
	{
		sel.grid = grid;
		grid.input.register( ON_ENTER, te.el, sel.NPC_onEnter );
		grid.input.register( ON_RELEASE, te.el, sel.NPC_onRelease );
		grid.input.register( ON_OUT, te.el, sel.NPC_onOut );
	}
	
	public function refresh( d : ClientNPC)
	{
		switch(d.id)
		{
			case Cat:
				Debug.MSG("freshing cat");
				if ( d.room != data.room )
					changeRoom( Main.getGrid(data.room), Main.getGrid(d.room));
		}
		
		data = d;
		mark = true;
	}
	
}