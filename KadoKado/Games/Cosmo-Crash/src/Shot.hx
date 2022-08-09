import mt.bumdum.Lib;

class Shot extends Element {//}

	var flDeath:Bool;
	var timer:Int;

	var px:Int;
	var py:Int;

	public function new(){
		super(Game.me.dm.attach("mcShot",Game.DP_FX)) ;
		timer = 200;

	}

	override function update(){

		if(timer--<0  || y < -10 )kill();

		super.update();
		updateGridPos();
	}

	// GRID
	function updateGridPos(){
		if( flDeath )return;
		var npx = Cs.getPX(x);
		var npy = Cs.getPY(y);
		if( npx!=px || npy!=py ){
			removeFromGrid();
			px = npx;
			py = npy;
			insertInGrid();
		}
	}
	function insertInGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				if( gx<0 )gx += Cs.XMAX;
				if( gx>=Cs.XMAX )gx -= Cs.XMAX;

				Game.me.sgrid[gx][gy].push(this);
			}
		}
	}
	function removeFromGrid(){
		for( x in 0...3 ){
			for( y in 0...3 ){
				var gx = px+x-1;
				var gy = py+y-1;
				Game.me.sgrid[gx][gy].remove(this);
			}
		}
	}

	//
	override function kill(){
		super.kill();
		flDeath = true;
		removeFromGrid();
	}


//{
}











