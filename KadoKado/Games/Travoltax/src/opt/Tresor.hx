package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;



class Tresor extends Option{//}



	public function new(n){
		super();
		destroyPiece();

		var matrix = [[
			0, 1, 1, 1,
			0, 1, n, 1,
			0, 1, 1, 1,
			0, 0, 0, 0
		],[4,4],[Cs.COL_NEUTRAL]];
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