package fx.gr;

import mt.bumdum.Lib;
import Fight;

typedef Racine = { sx:Float, sy:Float, ex:Float, ey:Float };

class Vigne extends fx.GroupEffect {

	var racines:Array<Racine>;

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				updateAura(1,caster.skinBox);
				for( i in 0...2) genRayConcentrate();
				if(coef == 1){
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
					spc = 0.03;
					launchSpell();
				}

			case 1:
				var id = 0;
				for( o in racines ){
					if(coef == 1){
						var t = list[id].t;
						if(!t.haveStatus(_SFly)){
							t.shake = 40;
							t.lockTimer = 50;
							for( i in 0...7 ){
								var sp = new Part( Scene.me.dm.attach("mcVigneGround", Scene.DP_FIGHTER) );
								sp.x = t.x + (Math.random()*2-1)*t.ray;
								sp.y = t.y + ((Math.random()*2-1)*t.ray)*0.5;
								sp.updatePos();
								sp.root.smc.smc.gotoAndStop(Std.random(sp.root.smc.smc._totalframes)+1);
								sp.root.gotoAndPlay(Std.random(15)+1);
								sp.timer = 100+Math.random()*30;
								sp.fadeType = 0;
								sp.root.smc.smc._xscale = (Std.random(2)*2-1)*100;
							}
						}

					} else if( Std.random(3) == 0 ){
						var x = o.sx*(1-coef) + o.ex*coef;
						var y = o.sy*(1-coef) + o.ey*coef;

						var sp = new Sprite( Scene.me.dm.attach("mcVigneAnim", Scene.DP_FIGHTER) );
						sp.x = x + (Math.random()*2-1)*10;
						sp.y = y + (Math.random()*2-1)*10;	// CHECK^^
						sp.updatePos();
						sp.root.smc.gotoAndStop(Std.random(sp.root.smc._totalframes)+1);
						sp.root._yscale = 50+Math.random()*50;
						sp.root._xscale = sp.root._yscale*caster.intSide;
					}

					id++;
				}
				if( coef == 1 ){
					end();
				}
		}
	}

	public function launchSpell(){
		racines = [];
		for ( o in list ) {
			if(  o.life == null ) continue;
			var racine = {
				sx:caster.x,
				sy:caster.y,
				ex:o.t.x,
				ey:o.t.y
			}
			racines.push(racine);
		}
	}
}

