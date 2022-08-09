import Common;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;

class Square{//}

	public var type:Int;
	public var color:Int;
	public var root:flash.MovieClip;

	public function new(mc,?type,?color){
		//if(color == 0)color = Std.random(0xFFFFFF);
		root = mc;
		this.type = type;
		this.color = color;


		initSkin(root);
	}

	public function update(){

	}

	public function initSkin(mc){
		mc.gotoAndStop(type+1);
		//mc.smc.gotoAndStop(color+1);
		Col.setPercentColor(mc.smc,30,color);

	}

	public function kill(){
		root.removeMovieClip();
	}



//{
}

// COL
// REVOIR LES LUCIOLES






