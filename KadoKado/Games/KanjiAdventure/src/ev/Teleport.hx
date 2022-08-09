package ev;

class Teleport extends Event {//}




	public function new(){
		super();

		spc = 0.05;
		Game.me.hero.sq.fxSmoke();
		Game.me.hero.root.removeMovieClip();

	}



	override function update(){
		super.update();
		if(coef==1){
			var h = Game.me.hero;
			var list = [];
			for( x in 0...Cs.XMAX ){
				for( y in 0...Cs.YMAX ){
					var sq = Game.me.cfl.grid[x][y];
					if( sq.isHeroFree() && ( x!=h.x || y!=h.y ) ) list.push(sq);
				}
			}
			if (list.length == 0)
				list.push(Game.me.cfl.grid[h.x][h.y]);
			var sq = list[Std.random(list.length)];
			h.setPos(sq.x,sq.y);
			h.display();
			Game.me.cfl.scroll(h);
			kill();
			sq.fxSmoke();

		}
	}




//{
}







