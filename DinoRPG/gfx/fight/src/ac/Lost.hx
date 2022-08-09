package ac ;

import Fight;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import Fighter;

class Lost extends State {

	var f : Fighter ;
	var life : Int ;
	var fxt:_LifeEffect;

	public function new(f : Fighter, life : Int, fxt:_LifeEffect) {
		super();
		this.f = f ;
		this.life = life ;
		this.fxt = fxt;
		addActor(f);
	}
	
	override function checkCasting() {
		if( f.mode == Mode.Dead ) {
			casting.remove(f);
			f = null;
		}
		super.checkCasting();
	}
	
	override function init() {
		super.init();
		if( f != null )	f.damages(life, 20, fxt) ;
		end();
	}
}
