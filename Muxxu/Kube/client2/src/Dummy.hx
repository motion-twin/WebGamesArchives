class Dummy extends Entity {

	public var rot : Float;
	public var block : Level.Block;
	
	public function new(x,y,z,b) {
		super();
		rot = Math.random() * Math.PI * 2;
		this.x = x;
		this.y = y;
		this.z = z;
		this.block = b;
	}
	
	public function update(dt) {
		rot += dt * 0.01;
	}
	
}