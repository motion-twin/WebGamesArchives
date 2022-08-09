package mt.fx;

class Arrow<T:flash.display.Sprite> extends Part<T>{

	public var an:Float;
	public var aspFrict:Float;
	public var aspAcc:Float;
	public var avx:Float;
	public var avy:Float;
	public var asp:Float;
	public var orient:Bool;
	
	public function new(mc:T) {
		super(mc);
		
		an = 0;
		orient = false;
		asp = 0;
		aspFrict = 1;
		aspAcc = 0;
	}

	override function update() {
		
		if( orient) root.rotation = an / 0.0174;
		
		asp += aspAcc;
		asp *= aspFrict;
		avx = Math.cos(an) * asp;
		avy = Math.sin(an) * asp;
		x += avx;
		y += avy;
		
		super.update();
		
	}
}
