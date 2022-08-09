package fx.gr;
import mt.bumdum.Lib;

import Fight;

class JumpAttack extends fx.GroupEffect{//}

	var _type:String;
	
	public function new( f, list, type ) {
		super(f,list);
		if( type == null )
			_type = "shake";
		else
			_type = type;
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
					switch( _type ){
						case "shake":
							//caster.shake = 35;
							Scene.me.fxShake(18, 0.93, 1.0);
							var mc = Scene.me.dm.attach("mcSismic",Scene.DP_BG);
							mc._yscale = 60;
							mc._x = caster.root._x;
							mc._y = caster.root._y;
						default:
							var mc = Scene.me.dm.attach(_type,Scene.DP_BG);
							mc._yscale = 50;
							mc._x = caster.root._x;
							mc._y = caster.root._y;
					}
					damageAll();
					spc = 0.1;
					end();
				}
			case 1:
		}
	}
//{
}
