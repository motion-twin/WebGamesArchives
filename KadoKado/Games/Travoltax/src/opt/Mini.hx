package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;



class Mini extends Option{//}



	public function new(){
		super();
		destroyPiece();
		var matrix = [[
			0, 0, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 0,
			0, 0, 0, 0
		],[4,4],[0xFFFFFF]];
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