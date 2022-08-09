package actor;

import Protocol;
import Types;
using Ex;
/**
 * ...
 * @author de
 */
class ItemActor extends Spr3D
{
	var itemDesc : _ItemDesc;
	var dep : DepInfos;
	var extra : haxe.xml.Fast;
	
	public var mark:Bool;	
	public function new(g : Grid, id : _ItemDesc) 
	{
		super(g, CHARACTER);
		itemDesc = id;
		mark = false;
		createDep();
		
		var sel = Main.ship.selectables.pushBack( new Select(grid, dep) );
		
		grid.input.register( ON_ENTER, te.el, sel.Equipment_onEnter );
		grid.input.register( ON_RELEASE, te.el, sel.Equipment_onRelease );
		grid.input.register( ON_OUT, te.el, sel.Equipment_onOut );
	}
	
	public function item()				return itemDesc;
	function getXmlExtra()
	{
		if (extra == null)
			extra = Main.data.getExtra().node.autoBind.nodes.eq.filter( function(e) return e.has.id && IsoProtocol.trackbackIid(e.att.id) == itemDesc.id ).random();
		return extra;
	}
	
	function createDep()
	{
		var xml =  getXmlExtra();
		init( Data.frame( xml.att.tile ) );
		dep = { 
			tile:grid.tile(0, 0),
			data:[], 
			te:te, 
			gameData:Equipment( itemDesc.id ), 
			flags: Flags.ofInt(0), 
			ent:cast this,
			baseSetup: te.setup,
			iid:itemDesc.id,
			rectCache:[ new V2I(0, 0), new V2I(0, 0)],
			pad:[],
			key:itemDesc.customInfos.locate( function(ci) return switch(ci) { default:null; case _Key(k):k; } ),
		};
		grid.dependancies.push( dep );
	}
	
	public function onData( idesc )
	{
		//DO IT
	}
	
	public override function kill()
	{
		grid.input.clean( te.el );
		grid.dependancies.remove( dep );
		super.kill();
	}
	
	public static inline function factory( id : _ItemDesc ) : Grid -> ItemActor
	{
		if (id == null) return null;
		else return
		switch(id.id)
		{
			case HELP_DRONE: 	function(g) return new Drone(g, id);
			default: 			null;
		}
	}
}