class Selection {

	public var x : Int;
	public var y : Int;
	public var z : Int;
	
	public var b : Null<Block>;
	
	public var pt : h3d.Point;
	public var dir : h3d.Vector;
	
	public var allowBreak : Bool;
	public var power : Float;
	public var requireCharge : Bool;
	public var powerFactor : Float;
	public var ignoreMagnets : Bool;
	
	public function new(x, y, z) {
		this.x = x;
		this.y = y;
		this.z = z;
		requireCharge = true;
		allowBreak = true;
		power = 0;
		powerFactor = 1;
	}
	
}