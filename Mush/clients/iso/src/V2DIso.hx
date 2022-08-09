package ;

/**
 * ...
 * @author de
 */

//always input in grid, and store in  pixels
class V2DIso
{
	public var x : Float;
	public var y : Float;
	
	public static inline var R : Int= 16;
	
	//input is in grid space
	public function new(vx:Float=0,vy:Float=0)
	{
		set(vx, vy);
	}
	
	public function set(vx:Float=0,vy:Float=0)
	{
		x = 0;
		y = 0;
		add2(vx, vy);
	}
	
	public function clone()
	{
		var v = new V2DIso();
		v.x = x;
		v.y = y;
		return v;
	}
	
	//statics
	public inline static function grid2px(x : Float, y : Float) : V2D
	{
		return new V2D(
			(x - y) * R,
			(x + y) * (R * 0.5)
		);
	}
	
	//takes pixels, returns grid pos
	public inline static function pix2Grid(x:Float, y:Float) : V2D
	{
		return
			new V2D( 	(y + x * 0.5) / R,
						(y - x * 0.5) / R
		);
	}
	
	public inline static function pix2GridI(x:Float, y:Float) : V2I
	{
		return
			new V2I( 	Std.int((y + x * 0.5) / R),
						Std.int((y - x * 0.5) / R)
		);
	}
	
	
	//operators
	public function add( vec : V2DIso )
	{
		return add2(vec.x,vec.y);
	}
	
	
	
	public function add2( vx : Float,vy : Float)
	{
		x += (vx - vy) * R;
		y += (vx + vy) * (R * 0.5);
		return this;
	}
	
	
	//cast
	public inline function toGrid()
	{
		var f = pix2Grid( x, y);
		return new V2I( Std.int( f.x),Std.int( f.y) );
	}
	
	public inline function toGridF() : V2D
	{
		return pix2Grid(x, y);
	}
	
	//utils
	public function toString()
	{
		var grid = toGrid();
		return "pix:{" + x + ","+ y + "} grid:{" +grid.x + "," + grid.y+"}";
	}
	
}