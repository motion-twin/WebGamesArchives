package mt.heaps.fx;
import h2d.Sprite;

/**
 * Blobish Squash'n'stretch FX
 * @param	mc displayObject to blob
 * @param	spc=0.05 step on a 0 1 scale, higher mean faster
 * @param	exp=0.5 mul of radius param
 */
class Blob extends mt.fx.Fx{

	public var exp:Float;
	public var spc:Float;
	
	var scx:Float;
	var scy:Float;
	
	public var dec:Int;
	public var speedDec:Int;
		
	var root: h2d.Sprite;
	
	/**
	 * 
	 * @param	mc displayObject to blob
	 * @param	spc=0.05 step on a 0 1 scale, higher mean faster
	 * @param	exp=0.5 mul of radius param
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
		root.scaleX = scx + Math.cos(dec*0.01)*ray;
		root.scaleY = scy + Math.sin(dec*0.01)*ray;
		
		if( coef == 1 ) kill();
		
	}
}
