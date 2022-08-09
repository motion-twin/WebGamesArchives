package mt.fx;
import mt.bumdum9.Lib;
/**
 * Fade to black with optionnal blur and scale fx
 */
class Vanish extends Visibility{
	public var timer:Float;
	public var fadeLimit:Float;

	public function new(mc, ?timer=10, ?fadeLimit=10, ?fadeAlpha=false ) {
		super(mc);
		this.timer = timer;
		this.fadeLimit = fadeLimit;
		this.fadeAlpha = fadeAlpha;
		alpha = root.alpha;
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
	
	/**
	 * Adds a blur fx
	 */
	public function setFadeBlur(x,y) {
		fadeBlur = { x:x, y:y };
		return this;
	}
	
	override function update() {
		if( root.parent == null ) {
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
		if(root.parent != null) root.parent.removeChild(root);
	}
}