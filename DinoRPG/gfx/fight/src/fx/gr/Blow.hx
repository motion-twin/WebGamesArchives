package fx.gr;

import mt.bumdum.Lib;

class Blow extends fx.GroupEffect{

	public function new( f, list:Array<{t : Fighter, life : Int}> ) {
		super(f, list);
		var my = 0.0;
		for( o in list )my += o.t.y;
		my /= list.length;
		var tx = Scene.WIDTH * 0.5;
		goto(tx, my);
	}

	public override function update() {
		super.update();
		if(castingWait) return;

		switch(step) {
			case 0:
				caster.updateMove(coef);
				if(coef == 1) {
					nextStep();
					caster.playAnim("release");
				}
			case 1 :
				for( i in 0...2 ) {
					var p = new Part( Scene.me.dm.attach("partFlamer",Scene.DP_FIGHTER) );
					var sens = caster.intSide;
					p.x = caster.x + sens*20 ;
					p.y = caster.y - 5;
					p.z = caster.z - caster.height*0.5;
					p.vx = sens*(4+Math.random()*7);
					p.vy = (Math.random()*2-1)*3;
					p.timer = 15+Math.random()*10;
					p.vr = (Math.random()*2-1)*8;
					p.root._rotation = Math.random()*360;
				}

				if(coef == 1) {
					nextStep();
					caster.playAnim("run");
					spc = caster.initReturn();
					damageAll();
				}
			case 2:
				caster.updateMove(coef);
				if(coef == 1) {
					caster.backToDefault();
					end();
				}
		}
	}
}
