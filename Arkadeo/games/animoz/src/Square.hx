import mt.bumdum9.Lib;
using mt.bumdum9.MBut;
import Protocol;
import api.AKApi;
import api.AKProtocol;

class Square 
{
	public var tag:Int;
	public var selectable:Int;
	
	public var x:Int;
	public var y:Int;
	public var nei:Array<Square>;
	public var dnei:Array<Square>;
	
	public var ent:Ent;
	public var bonus:fx.Bonus;
	public var kdo:fx.PK;
	public var but:SP;
	
	public function new(px, py) 
	{
		x = px;
		y = py;
		nei = [];
		dnei = [];
		tag = 0;
	}
	
	public function isFree() 
	{
		return ent == null;
	}
	
	public function getCenter() 
	{
		return Game.me.getPos(x + 0.5, y + 0.5);
	}
	
	public function getBall():ent.Ball 
	{
		if( ent != null && ent.isBall() )	return cast ent;
		return 								null;
	}
	
	// ACTIONS
	public function setAction(act, over, out) 
	{
		but = new SP();
		but.graphics.beginFill(0xFF0000, 0);
		but.graphics.drawRect(0, 0, Cs.SQ, Cs.SQ);
		Game.me.dm.add(but, Game.DP_INTER);
		
		var pos = Game.me.getPos(x, y);
		but.x = pos.x;
		but.y = pos.y;
		
		but.onClick( act );
		but.onOver( over );
		but.onOut( out );
	}
	
	public function removeActions() 
	{
		if( but == null ) return;
		but.removeEvents();
		but.parent.removeChild(but);
		but = null;
	}
	
	public inline function getId()
	{
		return x * Game.YMAX + y;
	}
	
	// TRIG
	public function trig()
	{
		if( bonus != null ) bonus.trig();
	}
	
	public function splash()
	{
		var b = getBall();
		if( b != null ) b.burst();
	}
}
