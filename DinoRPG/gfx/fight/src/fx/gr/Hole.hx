package fx.gr;
import mt.bumdum.Lib;

import Fight;


typedef BlackHole = {>flash.MovieClip, mask:flash.MovieClip, f:Fighter}

class Hole extends fx.GroupEffect {//}

	var holes:Array<BlackHole>;

	public function new( f, list ) {
		super(f,list);

		caster.playAnim("cast");
		spc = 0.03;
	}

	public override function update(){
		super.update();

		switch(step){
			case 0:
				updateAura(4, caster.skinBox);
				for(i in 0...2) genRayConcentrate();
				if(coef == 1) {
					caster.skinBox.filters = [];
					caster.playAnim("release");
					//
					var a = list.copy();
					var b = [];
					for( o in a ) {
						if( o.t.haveProp(_PBoss) ) {
							this.list.remove(o);
							b.push(o.t);
						} else if( o.life == null ) {
							this.list.remove(o);
							b.push(o.t);
						}
					}
					for( f in b ) {
						f.lockTimer = 40;
						f.shake = 30;
					}
					if( this.list.length == 0 ) {
						end();
						return;
					}
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
					initHoles();
					spc = 0.05;
				}

			case 1:
				for( mc in holes ){
					mc._xscale = mc._yscale = coef*(mc.f.ray*2+50);

					if(coef == 1){
						mc.mask = Scene.me.dm.attach("mcHoleMask",Scene.DP_FIGHTER);
						mc.f.root.setMask( mc.mask );
						mc.mask._x = mc._x;
						mc.mask._y = mc._y;
						mc.mask._xscale = mc.mask._yscale = mc._xscale;
						mc.f.shade.removeMovieClip();
						mc.f.playAnim("fall");
						Sprite.forceList.remove(mc.f);
					}
					mc.smc.smc._rotation += 23;
				}

				if(coef == 1) {
					spc = 0.04;
					nextStep();
				}

			case 2:
				for( mc in holes ) {
					mc.f.y += coef * mc.f.height * 0.5;
					mc.smc.smc._rotation += 23;
					Filt.glow( mc.f.root, 20*coef, 1+2*coef, 0x53136F, true );
				}
				if(coef == 1) nextStep();

			case 3:
				for( mc in holes ) {
					mc._xscale = mc._yscale = (1-coef)*(mc.f.ray*2+10);
					mc.smc.smc._rotation += 23;
				}
				if(coef == 1) {
					end();
					while(holes.length > 0) {
						var mc = holes.pop();
						mc.f.kill();
						mc.mask.removeMovieClip();
						mc.removeMovieClip();
					}
				}
		}
	}

	function initHoles(){
		holes = [];
		for( o in list ){
			var mc:BlackHole = cast Scene.me.dm.attach("mcHole",Scene.DP_SHADE);
			mc._x = o.t.x;
			mc._y = Scene.getY(o.t.y);
			mc._xscale = mc._yscale = 0;
			mc.f = o.t;
			holes.push(mc);
		}

	}

}

