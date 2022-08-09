package mt.fx;
import mt.bumdum9.Lib;

class Spawn extends Visibility{//}


	public var spc:Float;

	//spc is the step of alpha per frame
	//WARNING alpha is faded/spawned from its current level
	public function new(mc, spc=0.1, alpha=true, grow=false ) {
		super(mc);
		this.spc = spc;
		if( alpha ) setFadeAlpha();
		if( grow ) setFadeScale(1,1);
	}
	
	public function setFadeScale(x,y) {
		fadeScale = { sx:x,	sy:y, scx:root.scaleX, scy:root.scaleY	};
		switch(x) {
			case -1 : 	root.scaleX = 100000;
			case 1 : 	root.scaleX = 0;
		}
		switch(y) {
			case -1 : 	root.scaleY = 100000;
			case 1 : 	root.scaleY = 0;
		}
	}
	public function setFadeAlpha() {
		alpha = root.alpha;
		root.alpha = 0;
		this.fadeAlpha = true;
	}
	
	public function setFadeBlur(x,y) {
		fadeBlur = { x:x, y:y };
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + spc, 1);
		setVisibility( curve(coef) );
		
		if( coef == 1 ) kill();

	}



//{
}