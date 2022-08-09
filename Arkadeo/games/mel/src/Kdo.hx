import flash.geom.ColorTransform;
import fx.SMS;
import haxe.Public;
import DefaultImport;
import mt.gx.Debug;
using mt.gx.Ex;

class Kdo extends Entity, implements Public
{
	var me : KdoDef;
	function new(n:Int,def:KdoDef) 
	{
		super();
		page = n;
		this.me = def;
		this.mc = me.mc;
		
		if(Dice.percent( Game.me.getRandom(),10) )
			new SMS( Data.getSmsVar());
	}
	
	
	override function onProc() 
	{
		super.onProc();
		
		var pd = game.level.pagesData.get(page);
		for ( p in pd.kdo)
			if ( p.ent == this )
			{
				pd.kdo.remove(p);
				pd.dl.remove(p.ent );
			}
		
		if( me != null )
			game.char.onTakeKdo(me);
		me = null;
		mc.detach();
	}
	
}