class Entity {
	
	var kube : Kube;
	
	public var x : Float;
	public var y : Float;
	public var z : Float;

	public function new() {
		this.kube = Kube.inst;
	}
	
	public function recallZ(h:Int) {
		var ix = Std.int(x);
		var iy = Std.int(y);
		if( h < 0 ) h = 1;
		while( kube.level.collide(ix,iy,h) )
			h++;
		while( h > 1 && !kube.level.collide(ix,iy,h-1) )
			h--;
		z = h;
	}
	
	
}