package mt.fx;
import mt.bumdum9.Lib;

/**
 * Blobish Squash'n'stretch FX
 * @param	mc displayObject to blob
 * @param	spc=0.05 step on a 0 1 scale, higher mean faster
 * @param	exp=0.5 mul of radius param
 */
class Blob extends Fx{//}

	public var exp:Float;
	public var spc:Float;
	
	var scx:Float;
	var scy:Float;
	
	public var dec:Int;
	public var speedDec:Int;
		
	var root:flash.display.DisplayObject;
	
	public var blobX = true;
	public var blobY = true;
	/**
	 * 
	 * @param	mc displayObject to blob
	 * @param	spc=0.05 step on a 0 1 scale, higher mean faster
	 * @param	exp=0.5 mul of radius param, lesser mean less blobby
	 */
	public function new(mc,spc=0.05,exp=0.5) {
		super();
		root = mc;
		this.spc = spc;
		this.exp = exp;
		
		dec = 0;
		speedDec = 53;
		
		scx = root.scaleX;
		scy = root.scaleY;
	}
	
	
	override function update() {
		super.update();
		
		coef = Math.min(coef + spc, 1);
		var c = curve(coef);
		
		dec = (dec +speedDec) % 628;
		
		var ray = exp * (1 - c);
		
		if( blobX )	root.scaleX = scx + Math.cos(dec * 0.01) * ray;
		if( blobY )		root.scaleY = scy + Math.sin(dec * 0.01) * ray;
		
		if( coef == 1 ) kill();
		
		
	}



//{
}