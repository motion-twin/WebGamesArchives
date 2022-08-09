package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Indigestion extends Event {//}



	public function new(){
		super();

		var grid = [];
		for( x in 0...Cs.XMAX )grid[x] = [];

		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				if( Game.me.grid[x][y] != null ){
					for( d in Cs.DIR ){
						var nx = x+d[0];
						var ny = y+d[1];

						if( Game.me.grid[nx][ny] == null ){
							grid[nx][ny] = true;

						}
					}
				}
			}
		}

		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				if( grid[x][y] ){
					new Block(x,y,0);
				}
			}
		}



		kill();

	}

	override public function update(){
		super.update();

	}



//{
}













