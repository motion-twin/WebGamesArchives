package mt.m3d;

class Cube extends Polygon {

	public function new( x = 1, y = 1, z = 1 )
	{
		var p = [
			new Vector(0, 0, 0),
			new Vector(x, 0, 0),
			new Vector(0, y, 0),
			new Vector(0, 0, z),
			new Vector(x, y, 0),
			new Vector(x, 0, z),
			new Vector(0, y, z),
			new Vector(x, y, z),
		];
		var idx : Array<UInt> = [
			0, 1, 5,
			0, 5, 3,
			1, 4, 7,
			1, 7, 5,
			3, 5, 7,
			3, 7, 6,
			0, 6, 2,
			0, 3, 6,
			2, 7, 4,
			2, 6, 7,
			0, 4, 1,
			0, 2, 4,
		];
		super(p, idx);
	}
	
	override function addTCoords() {
		unindex();
		
		var z = new UV(0, 0);
		var x = new UV(1, 0);
		var y = new UV(0, 1);
		var o = new UV(1, 1);
		
		tcoords = [
			z, x, o,
			z, o, y,
			x, z, y,
			x, y, o,
			z, x, o,
			z, o, y,
			z, o, x,
			z, y, o,
			x, y, z,
			x, o, y,
			z, o, x,
			z, y, o,
		];
	}
	
}
