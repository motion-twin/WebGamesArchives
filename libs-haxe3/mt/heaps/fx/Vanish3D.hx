package mt.heaps.fx;
import h3d.scene.Object;

/**
 * Fade to black with optionnal scale fx
 */
class Vanish3D extends Visibility3D {
	
	public var timer:Float;
	public var fadeLimit:Float;

	public function new(mc : h3d.scene.Object, ?timer = 10, ?fadeLimit = 10, ?fadeAlpha = true,?fadeScale = false ) {
		super(mc);
		this.timer = timer;
		this.fadeLimit = fadeLimit;
		this.fadeAlpha = fadeAlpha;
		
		if ( Std.is( mc, h2d.Drawable ))
			alpha = cast(mc,h2d.Drawable).alpha;
		else 
			alpha = 1.0;
			
		setAlpha = Lib.setAlpha3D;
		
		if ( fadeScale )
			setFadeScale(1, 1, 1);
	}
	
	/**
	 * adds a scale fx
	 * x : [-1,0,1]
	 * y : [-1,0,1]
	 * other values discarded
	 */
	public function setFadeScale(x, y ,z) {
		fadeScale = { sx:x,	sy:y, sz:z, scx:root.scaleX, scy:root.scaleY, scz:root.scaleZ };
		
		return this;
	}
	
	override function update() {
		if( root==null || root.parent == null ) {
			kill();
			return;
		}
		
		if ( timer-- < fadeLimit ) {
			setVisibility( curve(timer / fadeLimit));
			if( timer == 0 )
				kill();
		}
	}
	
	override function kill() {
		super.kill();
		if( root!=null){
			if (root.parent != null) root.parent.removeChild(root);
			root = null;
		}
	}
}