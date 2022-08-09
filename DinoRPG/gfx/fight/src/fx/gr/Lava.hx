package fx.gr;
import mt.bumdum.Lib;

import Fight;

class Lava extends fx.GroupEffect{

	var listMc:Array<flash.MovieClip>;

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;
	}

	public override function update() {
		super.update();
		switch(step) {
			case 0:
				updateAura(0,caster.skinBox);
				for( i in 0...2) genRayConcentrate();
				if(coef == 1) {
					initLava();
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
				}

			case 1:
				for( o in list ) {
					if(  o.life == null ) continue;
					o.t.skinBox.filters= [];
					var c  = 0.5+coef;
					Filt.glow( o.t.skinBox, 5*c, 2*c, 0xBB0000, true );
				}
				
				if( coef == 1 ) {
					for( mc in listMc ) mc.gotoAndPlay("endAnim");
					for( o in list ) {
						if( o.life == null ) continue;
						o.t.damages(o.life,30);
						o.t.skinBox.filters= [];
						Col.setPercentColor(o.t.skin,0,0);
					}
					end();
				}
		}
	}

	function initLava() {
		listMc = [];
		for ( o in list ) {
			if(  o.life == null ) continue;
			var mc = o.t.bdm.attach("mcLava",Fighter.DP_BACK);
			Col.setPercentColor(o.t.skin,100,0);
			o.t.shake = 20;
			listMc.push(mc);
		}
	}
}

