package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;
import mt.bumdum.Part;



class Cut extends Option{//}


	var bmp:flash.display.BitmapData;
	var mcPart:flash.MovieClip;
	var mcSlash:flash.MovieClip;


	public function new(){
		super();
		Game.me.step = Freeze;
		destroyPiece();

		var sy = null;
		for( y in 0...Cs.YMAX ){
			for( x in 0...Cs.XMAX ){
				if(Game.me.grid[y][x]!=null){
					sy = y;
					break;
				}

			}
			if(sy!=null)break;
		}

		var ey = Std.int(Math.min(sy+3,Cs.YMAX));

		for( y in sy...ey )Game.me.grid[y] = [];

		//trace(sy+"->"+ey+" /"+Cs.YMAX);

		var w = Std.int(Cs.XMAX*Cs.SIZE);
		var h = Std.int((ey-sy)*Cs.SIZE);


		var rect = new flash.geom.Rectangle(0,sy*Cs.SIZE,w,h);
		bmp = new flash.display.BitmapData(w,h,true,0x00000000);
		bmp.copyPixels(Game.me.board,rect,new flash.geom.Point(0,0));
		Game.me.board.fillRect(rect,0);


		mcPart = Game.me.dm.empty(Game.DP_PARTS);
		mcPart.attachBitmap(bmp,0);
		mcPart._x = Cs.MX;
		mcPart._y = Cs.MY+sy*Cs.SIZE;

		//Game.me.piece.checkState();


		mcSlash =  Game.me.dm.attach("mcSlash",Game.DP_INTER);
		mcSlash._x = 0;
		mcSlash._y = Cs.MY + ey*Cs.SIZE;

		var max = 16;
		for( i in 0...max ){
			var p = new Part(Game.me.dm.attach("partPix",Game.DP_PARTS));
			p.x = Cs.MX + Math.random()*Cs.XMAX*Cs.SIZE;
			p.y = Cs.MY + ey*Cs.SIZE;
			p.vx = Math.random()*15;
			p.bhl = [BhHoriLine];
			p.timer = 20+p.vx;
			p.setScale(50);
		}



	}


	public function update(){
		super.update();
		//mcSlash._x += 50;
		if(mcSlash._visible)return;


		mcPart._x += 1*mt.Timer.tmod;
		mcPart._y += 0.2*mt.Timer.tmod;
		mcPart._alpha -= 2*mt.Timer.tmod;


		/*
		trace("alpha:"+mcPart._alpha);
		trace(":"+(Game.me.step  == Play));
		trace("me:"+(Game.me.currentOption == this));
		*/

		if(mcPart._alpha<50 && Game.me.currentOption == this ){
			Game.me.currentOption = null;
			Game.me.initPlay();
		}

		if(mcPart._alpha<=0){
			mcPart.removeMovieClip();
			bmp.dispose();
			kill();
		}


	}


//{
}