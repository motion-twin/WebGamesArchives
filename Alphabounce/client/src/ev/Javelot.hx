package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Javelot extends Event {//}

	static var SPEED = 5 ;

	var mcJavelot:flash.MovieClip;
	var x:Int;
	var y:Int;

	public function new(){
		super();
		x = Cs.getPX(Game.me.pad.x);
		y = Cs.YMAX+4;

		mcJavelot = Game.me.dm.attach("mcJavelot",Game.DP_PAD);
		mcJavelot._x = Cs.getX(x+0.5);
		mcJavelot._y = Cs.getY(y);
		mcJavelot.blendMode = "add";

		Game.me.dm.under(mcJavelot);


	}

	override public function update(){
		super.update();

		for( i in 0...SPEED ){
			y--;
			var bl = Game.me.grid[x][y];
			if( bl!=null )bl.explode();
			Game.me.killZone(x,y);
		}

		//
		mcJavelot._y = Cs.getY(y);

		//
		var max = Std.int(3+Cs.getPerfCoef()*8);
		var hh = Cs.BH*SPEED;
		for( i in 0...max ){
			var p = new Phys(Game.me.dm.attach("partLight",Game.DP_PARTS));
			p.x = mcJavelot._x + (Math.random()*2-1)*10;
			p.y = mcJavelot._y + Math.random()*hh;
			p.vy = -Math.random()*hh*0.75;
			p.timer = 10+Math.random()*20;
		}


		if(y<-14)kill();



	}

	override public function kill(){
		mcJavelot.removeMovieClip();
		super.kill();
	}



//{
}













