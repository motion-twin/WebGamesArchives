package fx;

import mt.bumdum.Lib;

typedef RandomClip = { > flash.MovieClip,
	var type1 : flash.MovieClip;
	var type2 : flash.MovieClip;
}

class RandomState extends fx.GroupEffect {

	var frame:String;
	var ok : Bool;
	var mc : RandomClip;
	
	public function new( f, frame:String, ok:Bool ) {
		super(f, null);
		this.frame = frame;
		this.ok = ok;
		addActor(f);
		spc = 0.025;
	}

	override function init() {
		super.init();
		mc = cast Scene.me.dm.attach("_pileouface",Scene.DP_PARTS);
		mc._x = caster.root._x - mc._width / 2;
		mc._y = caster.root._y - caster.height - mc._height;
		
		mc.type1.gotoAndStop( this.frame );
		mc.type2.gotoAndStop( this.frame );
		mc.play();
	}
	
	public override function update(){
		super.update();
		if( castingWait ) return;
		
		switch( step ) {
			case 0:
				if( coef == 1.0 ) {
					mc.gotoAndStop( ok ? "ok" : "ko" );
					nextStep();
				}
			case 1:
				if( coef == 1.0 ) {
					nextStep();
				}
			case 2:
				mc._y -= 2;
				mc._alpha -= 7;
				if( coef == 1.0 ) {
					
					mc.removeMovieClip();
					end();
				}
		}
	}
}
