package mt.heaps.fx;
import h3d.scene.Object;

/**
 * Blobish Squash'n'stretch FX
 * @param	spc=0.05 step on a 0 1 scale, higher mean faster
 * @param	exp=0.5 mul of radius param
 */
class Blob3D extends mt.fx.Fx {

	public var exp:Float;
	public var spc:Float;
	
	var scx:Float;
	var scy:Float;
	var scz:Float;
	
	public var dec:Int;
	public var speedDec:Int;
		
	var root : h3d.scene.Object;
	
	/**
	 * 
	 * @param	mc displayObject to blob
	 * @param	spc=0.05 step on a 0 1 scale, higher mean faster
	 * @param	exp=0.5 mul of radius param
	 */
	public function new(mc, spc = 0.05, exp = 0.5) {
		super();
		root = mc;
		
		if ( root == null) {
			kill();
			return;
		}
		
		this.spc = spc;
		this.exp = exp;
		
		dec = 0;
		speedDec = 53;
		
		scx = root.scaleX;
		scy = root.scaleY;
		scz = root.scaleZ;
	}
	
	public override function kill() {
		super.kill();
		if( root != null){
			root.scaleX = scx;
			root.scaleY = scy;
			root.scaleZ = scz;
		}
	}
	
	override function update() {
		super.update();
		
		coef = Math.min(coef + spc, 1);
		var c = curve(coef);
		
		dec = (dec +speedDec) % 628;
		
		var ray = exp * (1 - c);
		var c = Math.cos(dec * 0.01);
		var s = Math.sin(dec * 0.01);
		var z = Math.sqrt(c * c + s * s) * Math.PI;
		root.scaleX = scx + c*ray;
		root.scaleY = scy + s*ray;
		root.scaleZ = scz + z*ray;
		
		if( coef == 1 ) kill();
		
	}
}
