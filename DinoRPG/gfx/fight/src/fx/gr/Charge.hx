package fx.gr;

import mt.bumdum.Lib;
import Fighter;

class Charge extends fx.GroupEffect {

	var trg:Fighter;

	public function new( f, list:Array<{t : Fighter, life : Int}> ) {
		super(f,list);
		trg = list[0].t;
	}
	var flHit:Bool;

	public override function update(){
		super.update();
		if(castingWait) return;
		switch(step) {
			case 0 :
				if(flHit==null) {
					caster.playAnim("attack");
					damageAll();
					trg.vx = caster.intSide*6;
					trg.vz = -14;
					trg.weight = 1.5 ;
					//trg.vr = 6;
					trg.mode = Dodge;
					flHit = true;
					//
					var p = new Phys(Scene.me.dm.attach("fxChargeImpact",Scene.DP_FIGHTER));
					p.x = caster.x+46*caster.intSide;
					p.y = trg.y+1;
					p.z = -30;
					p.root.blendMode = "add";
					p.root._xscale = caster.side?100:-100;
					//
					for( i in 0...20 ){
						var x =  (trg.x+caster.x)*0.5 + Math.random()*20;//(Math.random()*2-1)*5;
						var y =  (trg.y+caster.y)*0.5 + (Math.random()*2-1)*20;
						var p = Scene.me.genGroundPart(x,y);
						p.vx = caster.intSide*(Math.random()*6);
						p.z = -Math.random()*40;
						p.vr = (Math.random()*2-1)*10;
						p.timer += Math.random()*5;
						p.friction = 0.97;
						p.setScale(p.scale*1.5);
					}
					Scene.me.fxShake(8);
				}
				if(coef==1){
					nextStep();
					caster.playAnim("run");
					spc = caster.initReturn();
				}
			case 1:
				caster.updateMove(coef);
				if(coef==1){
					caster.backToDefault();
					end();
				}
		}
	}
}
