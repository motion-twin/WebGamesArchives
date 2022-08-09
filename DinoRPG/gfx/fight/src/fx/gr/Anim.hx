package fx.gr;

import mt.bumdum.Lib;

class Anim extends fx.GroupEffect {

	var anim:String;
	public function new( f, list:Array<{t : Fighter, life : Int}>, anim : String ) {
		super(f, list);
		this.anim = anim;
	}

	public override function update(){
		super.update();
		switch(step){
			case 0:
				if(coef == 1){
					caster.playAnim(anim);
					nextStep();
				}
			case 1 :
				if(coef == 1){
					nextStep();
					damageAll();
				}
			case 2:
				if(coef == 1){
					end();
				}
		}
	}
}
