package inter;
import mt.bumdum.Lib;
class Module{//}


	public var mcLiner:flash.MovieClip;
	var root:flash.MovieClip;
	var dm:mt.DepthManager;

	public function new(){
		Inter.me.module = this;
		Inter.me.map.unactive();
		root = Inter.me.dm.empty(Inter.DP_MODULE);
		root.stop();
		dm = new mt.DepthManager(root);
		Inter.me.isle.instantRemove();


		var col = 0xAAAAAA;
		mcLiner = dm.empty(0);

		mcLiner.blendMode = "overlay";

		Filt.glow(mcLiner,6,1,col);

	}


	public function maj(){

	}

	public function display(){

	}
	public function update(){

	}

	//

	// LINER
	public function line(sx,sy,ex,ey){
		mcLiner.lineStyle(2,0xAAAAAA);
		mcLiner.moveTo(sx,sy);
		mcLiner.lineTo(ex,ey);
	}
	public function rect(sx,sy,ex,ey,col){
		mcLiner.lineStyle(0,0,0);
		mcLiner.beginFill(col);
		mcLiner.moveTo(sx,sy);
		mcLiner.lineTo(ex,sy);
		mcLiner.lineTo(ex,ey);
		mcLiner.lineTo(sx,ey);
		mcLiner.lineTo(sx,sy);
		mcLiner.endFill();
	}


	//
	public function remove(){
		Inter.me.module = null;
		root.removeMovieClip();

	}










//{
}