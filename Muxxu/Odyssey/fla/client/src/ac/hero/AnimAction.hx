package ac.hero;
import Protocole;
import mt.bumdum9.Lib;



class AnimAction extends Action {//}
	
	var hero:Hero;
	var str:String;
	
	public function new(hero,str) {
		super();
		this.hero  = hero;
		this.str = str;		
	}
	override function init() {
		super.init();
		if ( Folk.FAKE )	kill();
		else				hero.folk.play(str, kill, true);
	}
	
	



	
	
//{
}