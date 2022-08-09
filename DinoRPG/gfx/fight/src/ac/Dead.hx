package ac ;
import Fighter.Mode ;

class Dead extends State {
	var f : Fighter ;
	
	public function new(f: Fighter) {
		super();
		this.f = f ;
		addActor(f);
	}
	
	override function init() {
		var spirit = new part.Spirit(Scene.me.dm.empty(Scene.DP_FIGHTER));
		spirit.x = f.x;
		spirit.y = f.y-f.height;
		spirit.updatePos();

		f.removeStatus();
		f.playAnim("dead") ;
		f.mode = Dead ;
		f.shade.removeMovieClip() ;
		Sprite.forceList.remove(f);
		spc = 0.1;
	}

	override function update(){
		super.update();
		if(coef == 1) end();
	}
}