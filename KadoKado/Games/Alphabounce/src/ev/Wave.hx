package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Wave extends Event {//}

	var mcWave:flash.MovieClip;
	var y :Int;

	public function new(){
		super();

		y = Cs.YMAX-1;

		mcWave = Game.me.dm.attach("mcWave",Game.DP_PARTS);

	}

	override public function update(){
		super.update();


		for( i in 0...2 ){
			y--;
			for( x in 0...Cs.XMAX ){
				var bl = Game.me.grid[x][y];
				if(bl!=null){
					bl.damage(cast {type:0,damage:1});
				}
			}

		}


		mcWave._y = Cs.getY(y);
		if(y<-2)kill();
	}

	override public function kill(){
		mcWave.removeMovieClip();
		super.kill();
	}


//{
}













