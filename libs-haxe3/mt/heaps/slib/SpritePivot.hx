package mt.heaps.slib;

class SpritePivot {
	public var isUndefined(default,null)	: Bool;
	var usingFactor				: Bool;

	public var coordX			: Float;
	public var coordY			: Float;

	public var centerFactorX	: Float;
	public var centerFactorY	: Float;

	public function new() {
		isUndefined = true;
	}

	public inline function toString() {
		return if( isUndefined ) "None";
			else if( isUsingCoord() ) "Coord_"+Std.int(coordX)+","+Std.int(coordY);
			else "Factor_"+Std.int(centerFactorX)+","+Std.int(centerFactorY);
	}

	public inline function isUsingFactor() return !isUndefined && usingFactor;
	public inline function isUsingCoord() return !isUndefined && !usingFactor;

	public inline function setCenterRatio(xr,yr) {
		centerFactorX = xr;
		centerFactorY = yr;
		usingFactor = true;
		isUndefined = false;
	}

	public inline function setCoord(x,y) {
		coordX = x;
		coordY = y;
		usingFactor = false;
		isUndefined = false;
	}

	public function makeUndefined() {
		isUndefined = true;
	}

	public function copyFrom(from:SpritePivot) {
		if( from.isUsingCoord() )
			setCoord(from.coordX, from.coordY);

		if( from.isUsingFactor() )
			setCenterRatio(from.centerFactorX, from.centerFactorY);
	}

	public function clone() {
		var p = new SpritePivot();
		p.copyFrom(this);
		return p;
	}
}
