

class Sheep {//}


	public var pid:Int;

	var dir:Int;
	public var x:Int;
	public var y:Int;
	public var root:flash.MovieClip;



	public function new(x,y,playerId){
		Game.me.sheeps.push(this);
		this.x = x;
		this.y = y;


		root = Game.me.dm.attach("mcSheep",Game.DP_SHEEPS);
		Game.me.elements.push(root);

		pid = playerId;
		insertInGrid();
		dir = 0;


	}

	public function move(dir){
		this.dir = dir;
		if( !animDecal(dir) ){
			var d = Cs.DIR[dir];
			setPos( x+d[0], y+d[1] );
		}
		root.smc.gotoAndStop(dir+5);

	}
	public function endAnim(){

		if( animDecal(dir) ){
			var d = Cs.DIR[dir];
			setPos( x+d[0], y+d[1] );
			root.smc.gotoAndStop(dir+1);
		}
	}
	function setPos(nx,ny){
		removeFromGrid();
		x = nx;
		y = ny;
		insertInGrid();
	}

	//
	function insertInGrid(){
		var sq = Game.me.getSq(x,y);
		sq.sheep = this;

		root._x = Cs.getX(x)+Cs.SIZE*0.5;
		root._y = Cs.getY(y)+Cs.SIZE*0.5;
		root.gotoAndStop(pid+1);
		root.smc.stop();
		root.smc.smc.stop();

	}
	function removeFromGrid(){
		var sq = Game.me.getSq(x,y);
		sq.sheep = null;
		//root.removeMovieClip();
	}
	function animDecal(dir){
		return dir == 2 || dir == 3;
	}


	public function graze(){
		root.smc.gotoAndStop(9+dir);
	}

	// FX
	public function fxLand(){
		root.smc.gotoAndStop("spawn");
		cast (root.smc)._shake = callback(Game.me.fxShake,x,y);
	}




//{
}























