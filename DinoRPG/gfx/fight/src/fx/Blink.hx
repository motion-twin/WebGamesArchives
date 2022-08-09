package fx;

import mt.bumdum.Lib;
class Blink extends fx.GroupEffect {

	var color : Int;
	var alpha : Int;

	public function new( f, color, alpha ) {
		super(f, null);
		this.caster = f;
		this.color = color;
		this.alpha = alpha;
	}
	
	override function init() {
		super.init();
		spc = 0.1;
	}
	
	public override function update() {
		super.update();
		if( castingWait ) return;
		// --
		switch( step ) {
			case 0, 2, 4 :
				Col.setPercentColor( caster.root, coef * 100, color, this.alpha );
			case 1, 3, 5 :
				Col.setPercentColor( caster.root, (1 - coef)*100, color, this.alpha );
		}
		// --
		if( coef == 1 ) {
			if( step == 5 ) finish();
			else	nextStep();
		}
	}
	
	function finish() {
		Col.setPercentColor(caster.root, 0, color );
		end();
	}
	
}
