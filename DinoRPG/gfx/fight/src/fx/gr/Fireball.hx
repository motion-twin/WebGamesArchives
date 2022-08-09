package fx.gr;
import mt.bumdum.Lib;

import Fight;

class Fireball extends fx.GroupEffect{

	var shots:Array<Part>;

	public function new( f, list:Array<{t : Fighter, life : Int}> ) {
		super(f,list);
		caster.playAnim("cast");
		spc = 0.03;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				updateAura(0,caster.skinBox);
				for( i in 0...2)genRayConcentrate();
				if(coef==1){
					initShots();
					caster.skinBox.filters = [];
					caster.playAnim("release");
				}
			case 1:
				for( i in 0...shots.length ){
					var p = shots[i];
					var o = list[i];
					var dist = p.getDist(o.t);
					if( dist < 30 ){
						// PARTS
						o.t.fxBurst("fxFireSpark",24);
						// HIT
						if(  o.life != null )
							o.t.damages( o.life, 30, _LBurn(12) );
						//
						p.kill();
						shots.splice(i,1);
						list.splice(i,1);
						//i--;
					}
				}
				if(shots.length==0)end();
		}
	}

	public function initShots(){
		shots = [];
		for( o in list ){
			var p = new part.Homing( Scene.me.dm.attach("fxFireBall", Scene.DP_FIGHTER) );
			p.x = caster.x;
			p.y = caster.y;
			p.z = caster.z-caster.height*0.5;
			p.angle = 1.57 - caster.intSide*1.57;
			p.trg = o.t;
			p.speed = 15;
			p.frict = 0.98;
			p.flOrient = true;
			p.updatePos();
			shots.push(p);
			p.jumper = { max:p.getDist(p.trg), z:-80.0, bz:p.z };
		}
		step = 1;
	}
}
