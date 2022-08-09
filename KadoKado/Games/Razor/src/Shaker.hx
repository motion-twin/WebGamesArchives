class Shaker extends mt.bumdum.Phys{


	public var shake:Float;

	public function new(mc){
		super(mc);
		shake = 3;
	}

	override function updatePos(){
		root._x = x + (Math.random()*2-1)*shake;
		root._y = y + (Math.random()*2-1)*shake;
	}

}