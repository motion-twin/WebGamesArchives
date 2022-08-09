import mt.bumdum9.Lib;
import Protocol;
import api.AKApi;
import api.AKProtocol;

class Ent 
{
	public var bounce:Bool;
	public var gy:Float;
	public var sy:Float;
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var root:SP;
	public var square:Square;
	public var shade:SP;
	
	public function new()
	{
		root = new SP();
		Game.me.ents.push(this);
		Game.me.dm.add(root, Game.DP_ENTS);
		x = y = z = gy = sy = 0;
		bounce = false;
	}
	
	public function setSquare(sq:Square) 
	{
		if( sq.ent != null ) throw("square (" + sq.x + "," + sq.y + ") not free !");
		freeSquare();
		square = sq;
		square.ent = this;
		updateSquarePos();
	}
	
	public function freeSquare() 
	{
		if( square != null ) 
		{
			square.removeActions();
			square.ent = null;
		}
		square = null;
	}
	
	public function updateSquarePos()
	{
		var p = Game.me.getPos(square.x+0.5,square.y+0.5);
		x = p.x;
		y = p.y;
		updatePos();
	}
	
	public function setPos(nx, ny, ?nz)
	{
		x = nx;
		y = ny;
		if( nz != null )
			z = nz;
		updatePos();
	}
	
	public inline function updatePos() 
	{
		root.x = x;
		root.y = y+z-gy;
		if( shade != null ) {
			shade.x = x;
			shade.y = y+sy;
		}
	}
	
	public function isBall() 
	{
		return false;
	}
	
	public function dropShadow(coef = 1.0)
	{
		shade = new SP();
		shade.graphics.beginFill(0);
		var ww = Cs.SQ * 0.35 *coef;
		var hh = Cs.SQ * 0.2 *coef;
		shade.graphics.drawEllipse( -ww, -hh, ww * 2, hh * 2);
		Game.me.shadeLayer.addChild(shade);
	}
	
	public function update() 
	{
		
	}
	
	public function kill() 
	{
		Game.me.ents.remove(this);
		freeSquare();
		if( root.parent != null ) root.parent.removeChild(root);
		if( shade != null && shade.parent != null ) shade.parent.removeChild(shade);
	}

}
