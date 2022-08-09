package ev;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Dragon extends Event {//}

	static var SPEED = 1 ;

	var mcDragon:flash.MovieClip;
	var x:Int;
	var y:Int;
	var sens:Int;

	public function new(bl,sens){
		super();
		x = bl.x;
		y = bl.y;
		this.sens = sens;

		mcDragon = Game.me.dm.attach("mcDragon",Game.DP_FRONT_PARTS);
		mcDragon._x = Cs.getX(x+0.5);
		mcDragon._y = Cs.getY(y+0.5);
		//mcDragon._rotation += 90*sens;
		mcDragon._xscale = 100*sens;

		Filt.glow(mcDragon,10,1,0xFFFFFF);
		mcDragon.blendMode = "add";



	}

	override public function update(){
		super.update();

		for( i in 0...SPEED ){
			x+=sens;
			var bl = Game.me.grid[x][y];
			if( bl!=null )bl.explode();
			Game.me.killZone(x,y);
		}

		//
		mcDragon._x = Cs.getX(x+0.5);


		//
		var max = Std.int(3+Cs.getPerfCoef()*8);
		var ww = Cs.BW*SPEED;
		for( i in 0...max ){
			var p = new Phys(Game.me.dm.attach("partLight",Game.DP_PARTS));
			p.x = mcDragon._x + Math.random()*ww ;
			p.y = mcDragon._y + (Math.random()*2-1)*10;
			p.vx = Math.random()*ww*0.75*sens;
			p.timer = 10+Math.random()*20;
		}


		var ma = 10;
		if(x<-ma || x>=Cs.XMAX+ma)kill();



	}

	override public function kill(){
		mcDragon.removeMovieClip();
		super.kill();
	}



//{
}













