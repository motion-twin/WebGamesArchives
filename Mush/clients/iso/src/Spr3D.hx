
class Spr3D extends Entity
{
	public var prio : Int;
	
	var pos3 : V3D;
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set) : Float;
	
	public inline function get_x()	return pos3.x;
	public inline function get_y() 	return pos3.y;
	public inline function get_z() 	return pos3.z;
	
	public inline function set_x(v) { pos3.x = v; return v; }
	public inline function set_y(v) { pos3.y = v; return v; }
	public inline function set_z(v) { pos3.z = v; return v; }
	
	public function new(grid,t)
	{
		super(grid,t);
		prio = IsoConst.CHAR_PRIO;
		pos3 = new V3D();
		z = 0;
		te.el.mouseEnabled = false;
		prioOverride = function() return prio;
	}
	
	
	public override function getZ()
	{
		if ( Math.abs(z) > MathEx.EPSILON )
		{
			//could enhance here by applying Z ratio to R to depth
			var ofs = z > 0;
			return pos.x + pos.y + ((ofs) ? -0.9 : 0.9);
		}
		else return super.getZ();
	}
	
	public function getPos3() return pos3;
	
	//in grid space
	public function setPos3(x:Float,y:Float,z:Float,?grOfs:Float=null,dirt=true)
	{
		pos3.set(x, y, z);
		pos.set(x, y);
		if ( te.setup == null || grid == null)
		{
			Debug.MSG( "data isnt setup, it stinks" );
			return;
		}
		
		var ofs = Data.spriteOfs( te.setup.index );
		
		te.el.x = Std.int(pos.x + ofs.x);
		te.el.y = Std.int(pos.y + ofs.y - z * V2DIso.R  * 0.5);
		
		if(grOfs==null)
			te.el.y -= grid.getGroundOffsetY( Std.int(x), Std.int(y));
		else 
			te.el.y -= grOfs;
		
		if (dirt) grid.dirtSort();
	}
	
	
}