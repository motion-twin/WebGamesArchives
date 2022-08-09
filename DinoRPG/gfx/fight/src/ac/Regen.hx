package ac ;

import mt.bumdum.Lib;
import Fight;

class Regen extends State {

	var f : Fighter ;
	var life : Int ;
	var fxt : _LifeEffect ;
	
	public function new(f : Fighter, life : Int, fxt) {
		super();

		this.f = f ;
		this.fxt = fxt ;
		this.life = life ;
		f.resurect();
		addActor(f);
	}

	override function init(){
		f.backToDefault();
		f.gainLife(life,fxt) ;
		end();
	}
}