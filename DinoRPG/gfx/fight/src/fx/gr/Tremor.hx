package fx.gr;
import mt.bumdum.Lib;

import Fight;

class Tremor extends fx.GroupEffect{//}

	public function new( f, list ) {
		super(f,list);
		caster.playAnim("jump");
		spc = 0.1;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				caster.z = -Math.sin(coef*3.14)*100;
				if( coef==1 ){
					caster.playAnim("land");
					var mc = Scene.me.dm.attach("mcSismic",Scene.DP_BG);
					mc._yscale = 50;
					mc._x = caster.root._x;
					mc._y = caster.root._y;
					damageAll();
					spc = 0.1;
					end();
				}
			case 1:
		}
	}
//{
}
