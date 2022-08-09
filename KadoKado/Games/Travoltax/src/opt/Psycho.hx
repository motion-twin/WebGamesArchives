package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;



class Psycho extends Option{//}

	var brush:flash.MovieClip;
	var decal:Float;
	var decal2:Float;

	public function new(){
		super();
		Game.me.step = Freeze;
		destroyPiece();

		Game.me.flInverse = true;
		decal = 0;
		decal2 = 0;

		brush = Game.me.dm.attach("mcGrim",Game.DP_PLASMA);
		brush._visible = false;

		Game.me.initPlay();
	}

	public function update(){
		super.update();


		var m = 30;
		for( i in 0...2 ){
			brush._x = Cs.MX + m + Math.random()*(Cs.XMAX*Cs.SIZE-2*m);
			brush._y = Cs.MY + m + Math.random()*(Cs.YMAX*Cs.SIZE-2*m);
			brush._xscale = brush._yscale = 150;

			var c = (Game.me.rainbowCoef+Math.random()*0.2)%1;
			Game.me.drawRainbowShade(brush,Col.getRainbow(c));
		}


		decal = (decal+23*mt.Timer.tmod)%628;
		decal2 = (decal2+5*mt.Timer.tmod)%628;
		var sp = 5+Math.cos(decal2*0.01)*3;
		var vx = Std.int(Math.cos(decal*0.01)*sp);
		var vy = Std.int(Math.sin(decal*0.01)*sp);

		Game.me.plasma.scroll(vx,vy);



	}

	public function onLine(){
		brush.removeMovieClip();
		Game.me.flInverse = false;
		kill();
	}





//{
}