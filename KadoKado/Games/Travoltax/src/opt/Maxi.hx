package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;



class Maxi extends Option{//}



	public function new(){
		super();
		destroyPiece();
		var matrix = [[
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 1,
			1, 1, 1, 1
		],[3,3],[0]];
		Game.me.pieceList.unshift(matrix);
		kill();

	}

	public function update(){
		super.update();

	}


	public function kill(){
		Game.me.initPlay();
		super.kill();
	}


//{
}