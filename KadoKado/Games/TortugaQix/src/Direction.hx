import geom.Pt;

class Direction extends geom.PVector {
	public static var NORTH = new Direction(0, -1);
	public static var SOUTH = new Direction(0, 1);
	public static var WEST = new Direction(-1, 0);
	public static var EAST = new Direction(1, 0);
	public static var DIRECTIONS = [ NORTH, WEST, SOUTH, EAST ];

	function new(x,y){
		super(x,y);
	}

	override function toString() : String {
		if (this == NORTH) return "N";
		else if (this == SOUTH) return "S";
		else if (this == WEST) return "W";
		else return "E";
	}

	public function left() : Direction {
		if (this == NORTH) return WEST;
		else if (this == WEST) return SOUTH;
		else if (this == SOUTH) return EAST;
		else if (this == EAST) return NORTH;
		return null;
	}

	public function right() : Direction {
		if (this == NORTH) return EAST;
		else if (this == EAST) return SOUTH;
		else if (this == SOUTH) return WEST;
		else if (this == WEST) return NORTH;
		return null;
	}

	public static function leftOf( p:Pt ) : Direction {
		for (d in DIRECTIONS)
			if (d.equals(p))
				return d.left();
		return null;
	}

	public static function rightOf( p:Pt ) : Direction {
		for (d in DIRECTIONS)
			if (d.equals(p))
				return d.right();
		return null;
	}

	public static function d2ii( d:{x:Int, y:Int} ){
		return (d.x + 1) + (3 * (d.y + 1));
	}

	public static function d2i( d:Pt ) : Int {
		return (Math.round(d.x) + 1) + (3 * (Math.round(d.y)+1));
	}
}