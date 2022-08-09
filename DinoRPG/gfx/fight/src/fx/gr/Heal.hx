package fx.gr;
import mt.bumdum.Lib;
import Fight;

class Heal extends fx.GroupEffect {

	var type:Int;

	public function new( f, list, type ) {
		this.type = type;
		super(f,list);
		spc =  0.02;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				updateAura(1,caster.skinBox);
				for( i in 0...2 )
					genRayConcentrate();
				switch(type){
					case 0 :
						var ec = 1.2;
						for( o in list ) if(Math.random() < coef) o.t.fxLeaf(1,(Math.random()*2-1)*ec,(Math.random()*2-1)*ec,-Math.random()*8);
					case 1:
				}

				if(coef == 1) {
					caster.skinBox.filters = [];
					caster.playAnim("release");
					nextStep();
					spc = 0.03;
					for( o in list ) {
						o.t.lifeEffect(_LHeal);
						o.t.gainLife(o.life);
						switch(type){
							case 0 :
							case 1:
						}
					}
				}
			case 1:
				if(coef == 1) end();
		}
	}
}
