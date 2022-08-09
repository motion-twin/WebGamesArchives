package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;



class Riche extends Option{//}



	public function new(){
		super();

		whiteFlash();

		for( y in 0...Cs.YMAX ){
			for( x in 0...Cs.XMAX ){
				var n = Game.me.grid[y][x];


				if( n==0 && Std.random(8)==0 ){

					Game.me.addSquare(x,y,2);

					var mc = Game.me.dm.attach("mcNewSquare",Game.DP_PARTS);
					mc._x = Cs.MX + (x+0.5)*Cs.SIZE;
					mc._y = Cs.MY + (y+0.5)*Cs.SIZE;
				}
			}

		}



		kill();
	}



//{
}