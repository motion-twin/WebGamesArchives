package mt.heaps.fx;

class Spawn3D extends Visibility3D{
	public var spc:Float;

	//spc is the step of alpha per frame
	//WARNING alpha is faded/spawned from its current level
	public function new(mc:h3d.scene.Object, ?spc=0.1, alpha=true, grow=false ) {
		super(mc);
		this.spc = spc;
		if( alpha ) setFadeAlpha();
		if ( grow ) setFadeScale(1, 1, 1);
		setAlpha = Lib.setAlpha3D;
	}
	
	public function setFadeScale(x,y,z) {
		fadeScale = { sx:x,	sy:y, sz:z, scx:root.scaleX, scy:root.scaleY, scz:root.scaleZ };
		switch(x) {
			case -1 : 	root.scaleX = 100000;
			case 1 : 	root.scaleX = 0;
		}
		switch(y) {
			case -1 : 	root.scaleY = 100000;
			case 1 : 	root.scaleY = 0;
		}
		
		switch(z) {
			case -1 : 	root.scaleZ = 100000;
			case 1 : 	root.scaleZ = 0;
		}
	}
	
	public function setFadeAlpha() {
		alpha = 1.0;
		Lib.setAlpha3DMin(root, 0.0);
		this.fadeAlpha = true;
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + spc, 1);
		setVisibility( curve(coef) );
		
		if( coef == 1 ) kill();
	}
}
