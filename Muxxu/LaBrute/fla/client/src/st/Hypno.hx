package st;
import Data;
import mt.bumdum.Lib;

class Hypno extends State{//}


	var spirale:flash.MovieClip;
	var mcFlash:flash.MovieClip;

	var list:Array<Fighter>;
	var att:Fighter;


	public function new(aid,a:Array<Int>) {
		super();

		att = Game.me.getFighter(aid);
		list = [];
		for( fid in a )list.push( Game.me.getFighter(fid) );

		setMain();

		coef = 0;
		cs = 0.015;
		step = 0;

		att.playAnim("show");

		genSpirale();


	}



	override function update() {
		super.update();

		switch(step){
			case 0:
				//if(coef>0.75)genVoice();
				if(coef>=1){
					step++;
					for( f in list ){

						f.recal();
						f.playAnim("run");
						f.flRecal = false;
						f.setTeam(att.team);
						f.setSens(-1);

					}
					spirale.removeMovieClip();
					//att.playAnim("throw");
					att.setSens(1);
					att.backToNormal();
				}

				if(coef>0.1)spirale._alpha += 10;

				var lim = 0.8;
				if( coef>0.9 && mcFlash == null ){
					mcFlash = Game.me.dm.attach("mcFlash",Game.DP_INTER);
					mcFlash.blendMode = "add";
				}

			case 1:

				//genVoice();
				var m = 60;
				var a = list.copy();
				for( f in a ){
					f.x += 16*f.side;
					var m = f.ray + 100;
					//if( (f.x-att.x)*att.side > 0 )
					if( Math.abs(f.x-att.x) < Std.random(100) ){
						list.remove(f);
						f.setSens(1);
						f.backToNormal();
						//f.kill();
					}
				}
				if( list.length == 0 ){

					step = 2;
					coef = 0;
					cs = 0.1;
				}
			case 2:
				if(coef>=1){
					end();
					kill();
				}

		}

		spirale._rotation -= 10;

	}


	function genSpirale(){


		var h = Cs.mch;

		spirale = Game.me.dm.empty(Game.DP_PARTS);
		spirale._x = Cs.mcw*0.5;
		spirale._y = Cs.mch*0.5;
		spirale._alpha = 0;

		var mmc = new mt.DepthManager(spirale).empty(0);
		mmc._x = -h;
		mmc._y = -h;

		var bmp = new flash.display.BitmapData(h*2,h*2,true,0x30FF0000);
		mmc.attachBitmap(bmp,0);

		var brush = Game.me.dm.attach("mcLineSpiral",0);
		var x = h*1.0;
		var y = h*1.0;
		var a = 0.0;
		var dist = 1.0;
		var max = 240;
		var scy = 1.0;
		for( i in 0...max ){

			dist += 0.25;
			a += 0.2 +(1-i/max)*0.2;
			scy *= 1.01;

			brush.smc.filters = [];
			var bl = (1-i/max)*12;
			Filt.blur(brush.smc,bl,bl);


			var m = new flash.geom.Matrix();
			m.scale( dist*0.01, scy );
			m.rotate(a);
			m.translate(x,y);
			bmp.draw(brush, m);

			x += Math.cos(a)*dist;
			y += Math.sin(a)*dist;
		}
		brush.removeMovieClip();

		//
		spirale.blendMode = "invert";




		/*
		var fl = new flash.filters.BlurFilter();
		fl.blurX = 8;
		fl.blurY = 8;
		bmp.applyFilter(bmp,bmp.rectangle,new flash.geom.Point(0,0),fl);
		*/



	}


//{
}
















