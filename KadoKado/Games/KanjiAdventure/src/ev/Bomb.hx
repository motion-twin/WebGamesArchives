package ev;

class Bomb extends Event {//}

	var grid:Array<Array<Bool>>;

	var flames:Array<Array<Int>>;


	public function new(){
		super();

		flames = [];
		grid = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			for( y in 0...Cs.YMAX ){
				var sq = Game.me.cfl.grid[x][y];
				grid[x][y] = sq.isGround();
			}
		}

		flames.push([Game.me.hero.x,Game.me.hero.y]);

	}



	override function update(){

		var list = flames.copy();
		flames = [];
		for( p in list ){
			for( d in Cs.DIR ){
				var nx = p[0] + d[0];
				var ny = p[1] + d[1];
				var sq = Game.me.cfl.grid[nx][ny];
				if( grid[nx][ny] && sq.isGround() ){
					grid[nx][ny] = false;
					flames.push([nx,ny]);
					sq.fxFlame();
					if(sq.ent.flBad)sq.ent.die();
				}
			}
		}

		if(flames.length==0)kill();


	}




//{
}







