package fx;

class BonusVanish extends mt.fx.Fx {

	public var scFrom : Float;
	public var scDelta : Float;
	public var fadeLimit : Float;

	public var spc:Float;

	var root:flash.display.DisplayObject;

	public function new(mc, sc = 2.5, fadeLimit = 0.3, spc = 0.13 ) {
		super();
		this.root = mc;
		this.scFrom = root.scaleX;
		this.scDelta = scFrom*(sc-1);
		this.fadeLimit = fadeLimit;
		this.spc = spc;
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + spc, 1);
		var c = curve(coef) ;

		root.scaleX = root.scaleY = scFrom + scDelta * c;

		if( c > fadeLimit )
			root.alpha = 1 - (c-fadeLimit) / (1-fadeLimit);
		
		if( coef == 1 ) kill();
	}

	override function kill(){
		if( root.parent != null )
			root.parent.removeChild(root);
	}

}
