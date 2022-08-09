package mt.heaps.fx;


/**
 * Fade to black with optionnal scale fx
 */
class Vanish extends Visibility
{
	public var timer:Float;
	public var fadeLimit:Float;
	
	public static var DEFAULT_DISPOSE = false;
	
	public function new(mc:h2d.Sprite, ?timer = 10, ?fadeLimit = 10, ?fadeAlpha = false ) {
		super(mc);
		this.timer = timer;
		this.fadeLimit = fadeLimit;
		this.fadeAlpha = fadeAlpha;
		
		if ( Std.is( mc, h2d.Drawable ))
			alpha = cast(mc,h2d.Drawable).alpha;
		else 
			alpha = 1.0;
			
		setAlpha = Lib.setAlpha;
	}
	
	/**
	 * adds a scale fx
	 * x : [-1,0,1]
	 * y : [-1,0,1]
	 * other values discarded
	 */
	public function setFadeScale(x, y) {
		fadeScale = { sx:x,	sy:y, scx:root.scaleX, scy:root.scaleY	};
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
			if (root.parent != null) {
				root.parent.removeChild(root);
				if ( DEFAULT_DISPOSE )
					root.dispose();
			}
			root = null;
		}
	}
}