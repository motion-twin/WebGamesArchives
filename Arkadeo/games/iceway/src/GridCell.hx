package ;
import Lib;

using GridTools;
class GridCell
{
	public var id : Int;
	public var x : Int;
	public var y : Int;
	public var gfx : Sprite;
	public var pathLevel : Int;//used by generator only !
	public var pathRequires : Array<GridCell>;

	public var flags : haxe.EnumFlags<CellFlags>;
	public var collisionFlags : haxe.EnumFlags<CollisionFlags>;
	public var reflection: Null<DisplayObject>;
	
	
	public function new( x:Int, y:Int )
	{
		this.x = x;
		this.y = y;
		pathRequires = [];
		flags = haxe.EnumFlags.ofInt(0);
		collisionFlags = haxe.EnumFlags.ofInt(0);
	}

	inline public function hasCollide()
	{
		return collisionFlags != null && collisionFlags.toInt() > 0;
	}

	public function hasCollision( grid : Grid<GridCell>, col : CollisionFlags )
	{
		if( collisionFlags.has(col) ) return true;
		var n = switch( col )
		{
			case CLeft 		: grid.getAt(x - 1, y);
			case CRight 	: grid.getAt(x + 1, y);
			case CTop 		: grid.getAt(x, y - 1);
			case CBottom 	: grid.getAt(x, y + 1);
		}
		if( n == null ) return true;
		return n.collisionFlags.has( Lib.getOppositeCol(col) );
	}
	
	inline public function countCollisions(grid : Grid<GridCell>, ?full=true)
	{
		var count = 0;
		if( hasCollide() )
		{
			if( collisionFlags.has(CLeft) ) count ++;
			if( collisionFlags.has(CRight) ) count ++;
			if( collisionFlags.has(CBottom) ) count ++;
			if( collisionFlags.has(CTop) ) count ++;
		}
		if( full )
		{
			var n = GridTools.getNeighbours(grid, x, y);
			if( !collisionFlags.has(CRight) && n.right != null && n.right.collisionFlags.has(CLeft) ) count ++;
			if( !collisionFlags.has(CLeft) && n.left != null && n.left.collisionFlags.has(CRight) ) count ++;
			if( !collisionFlags.has(CTop) && n.top != null && n.top.collisionFlags.has(CBottom) ) count ++;
			if( !collisionFlags.has(CBottom) && n.bottom != null && n.bottom.collisionFlags.has(CTop) ) count ++;
		}
		return count;
	}
	
	inline public function setBlock()
	{
		collisionFlags.set(CTop);
		collisionFlags.set(CLeft);
		collisionFlags.set(CBottom);
		collisionFlags.set(CRight);
		flags.set(Block);
	}
	
	inline public function isBlock()
	{
		return flags.has(Block);
	}
	
	inline public function countBlocksAround(grid : Grid<GridCell>)
	{
		var count = 0;
		var n = GridTools.getNeighbours(grid, x, y);
		//
		if( n.top != null && n.top.isBlock() ) count++;
		if( n.left != null && n.left.isBlock() ) count++;
		if( n.right != null && n.right.isBlock() ) count++;
		if( n.bottom != null && n.bottom.isBlock() ) count++;
		if( n.topLeft != null && n.topLeft.isBlock() ) count++;
		if( n.topRight != null && n.topRight.isBlock() ) count++;
		if( n.bottomLeft != null && n.bottomLeft.isBlock() ) count++;
		if( n.bottomRight != null && n.bottomRight.isBlock() ) count++;
		//
		return count;
	}
	
	public function cellDist( to )
	{
		return MLib.max( MLib.abs(x - to.x), MLib.abs(y - to.y) );
	}
	
	public function cellDistXY( lx: Float, ly: Float )
	{
		var pos = Lib.getCoord_XY( this.x, this.y, true );
		pos.x -= lx;
		pos.y -= ly;
		return Vec2.norm(pos);
	}
	
	public function toString()
	{
		return "{" + x + ";" + y + "}";
	}
	
	public function copyContent( cell:GridCell )
	{
		this.gfx = cell.gfx;
		this.flags = haxe.EnumFlags.ofInt( cell.flags.toInt() );
		this.collisionFlags = haxe.EnumFlags.ofInt( cell.collisionFlags.toInt() );
	}
	
	public function clone():GridCell
	{
		var clone = new GridCell(x, y);
		clone.gfx = gfx;
		clone.id = id;
		clone.pathLevel = pathLevel;
		clone.flags = flags;
		clone.collisionFlags = collisionFlags;
		return clone;
	}

	public function dispose()
	{
		if( gfx != null && gfx.parent != null ) gfx.parent.removeChild(gfx);
		flags = haxe.EnumFlags.ofInt(0);
		collisionFlags = haxe.EnumFlags.ofInt(0);
	}
}
