package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;
import mt.bumdum.Part;
import mt.bumdum.Bmp;



class Faille extends Option{//}


	var coef:Float;
	var parts:Array<Bmp>;

	public function new(){
		super();

		Game.me.step = Freeze;
		destroyPiece();

		coef = 0;
		parts = [];
		var w = Std.int(Cs.SIZE*Cs.XMAX*0.5);
		var h = Std.int(Cs.SIZE*Cs.YMAX);
		for( i in 0...2 ){
			var mc = Game.me.dm.empty(Game.DP_PARTS);
			var bmp = new Bmp(mc,w,h,0x00000000);
			bmp.setPos( Cs.MX + w*i, Cs.MY );
			bmp.copyPixels( Game.me.board, new flash.geom.Rectangle(w*i,0,w,h), new flash.geom.Point(0,0) );
			parts.push(bmp);
		}
		Game.me.board.fillRect(Game.me.board.rectangle,0);



		for( i in 0...2 ){
			var sens = -Std.int(i*2-1);
			var sx = (Cs.XMAX-1)*i;
			var max = Std.int(Cs.XMAX*0.5);
			for( n in 0...max ){
				var nx = sx+sens;
				for( y in 0...Cs.YMAX ){
					Game.me.grid[y][sx] = Game.me.grid[y][nx];
					if(n==max-1)Game.me.grid[y][sx] = null;
				}
				sx = nx;
			}
		}

		//Game.me.initPlay();
	}


	public function update(){
		super.update();
		coef = Math.min(coef+0.15*mt.Timer.tmod,1);


		var w = Std.int(Cs.SIZE*Cs.XMAX*0.5);
		for( i in 0...2 ){
			var sens = Std.int(i*2-1);
			var bmp = parts[i];
			bmp.root._x = Cs.MX + (Cs.SIZE*Cs.XMAX*0.5)*i + coef*sens*Cs.SIZE;
			Game.me.drawRainbowShade(bmp.root);

			if(coef==1){
				Game.me.board.copyPixels(bmp,bmp.rectangle, new flash.geom.Point( w*i+sens*Cs.SIZE ,0)  );
				bmp.kill();
			}

		}

		if(coef==1){
			Game.me.initPlay();
			kill();
		}


	}





//{
}