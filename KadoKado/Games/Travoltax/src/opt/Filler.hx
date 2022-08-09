package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;


class Filler extends Option{//}

	var sx:Int;
	var sy:Int;
	var ex:Int;
	var ey:Int;

	var count:Int;
	var coef:Float;
	var list:Array<Array<Int>>;

	var mcPuce:flash.MovieClip;

	public function new(max){
		super();
		Game.me.step = Freeze;
		destroyPiece();

		coef = 1;
		count = max;

		// LIST
		list = getList();

		if(list.length==0){
			kill();
			return;
		}

		// PUCE
		sx = Std.int(Cs.XMAX*0.5);
		sy = Cs.YMAX;
		ex = sx;
		ey = sy;
		mcPuce= Game.me.dm.attach("mcSpider",Game.DP_PARTS);
		mcPuce._x = Cs.mcw*0.5;
		mcPuce._y = Cs.mch+10;
		mcPuce._xscale = mcPuce._yscale = 150;

		Filt.glow(mcPuce,2,10,0xFFFFFF);

	}

	public function update(){

		coef = Math.min(coef+0.05*mt.Timer.tmod,1);
		var cx = sx + (ex-sx)*coef;
		var cy = sy + (ey-sy)*coef;
		var ox = mcPuce._x;
		var oy = mcPuce._y;
		mcPuce._x = Cs.MX + (cx+0.5)*Cs.SIZE;
		mcPuce._y = Cs.MY + (cy+0.5)*Cs.SIZE - Math.sin(coef*3.14)*30;

		var dx = ox - mcPuce._x;
		var dy = oy - mcPuce._y;
		mcPuce._rotation = Math.atan2(dy,dx)/0.0174;

		var mc = Game.me.dm.attach("mcQueue",Game.DP_QUEUE);
		mc._x = mcPuce._x;
		mc._y = mcPuce._y;
		mc._xscale = Math.sqrt(dx*dx+dy*dy);
		mc._rotation = mcPuce._rotation;
		Col.setPercentColor(mc,100,Col.objToCol(Col.getRainbow(Game.me.rainbowCoef)));

		if(coef==1){
			var flEnd = list.length==0 || count==0;
			count--;
			var index = Std.random(list.length);
			var p = list[index];
			list.splice(index,1);
			sx = ex;
			sy = ey;
			ex = p[0];
			ey = p[1];
			coef = 0;


			Game.me.addSquare(sx,sy,null,Cs.COL_NEUTRAL);

			// FX
			var mc = Game.me.dm.attach("mcNewSquare",Game.DP_BOARD);
			mc._x = mcPuce._x;
			mc._y = mcPuce._y;

			var max = 16;
			if(count<0)max*=2;
			for( i in 0...max ){
				var p = new Phys(Game.me.dm.attach("partTwinkle",Game.DP_PARTS));

				p.timer = 10+Math.random()*18;
				p.fadeType = 0;
				p.weight = 0.05+Math.random()*0.05;
				p.setScale(100+Math.random()*100);
				p.frict = 0.95;
				p.root.gotoAndPlay(Std.random(p.root._totalframes)+1);
				if(count>=0){
					p.x = Cs.MX + (sx+Math.random())*Cs.SIZE;
					p.y = Cs.MY + (sy+Math.random())*Cs.SIZE;
				}else{
					var a = (i+Math.random())/max * 6.28;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var sp = Math.random()*4;
					p.x = mcPuce._x + ca*sp*3;
					p.y = mcPuce._y + sa*sp*3;
					p.vx = ca*sp;
					p.vy = sa*sp;

				}
				p.updatePos();

			}



			if(flEnd)kill();
		}




		super.update();

	}

	public function getList(){

		var a = [];
		for( lim in 1...4 ){
			for( py in 0...Cs.YMAX ){
				var y = Cs.YMAX-(1+py);
				var empty = [];
				for( x in 0...Cs.XMAX ){
					if( Game.me.grid[y][x]==null ) empty.push([x,y]);
				}
				if( empty.length == lim ){
					for( p in empty )a.push(p);
				}
			}
			if(a.length>count)break;
		}


		return a;
	}

	public function kill(){
		Game.me.checkLines();
		mcPuce.removeMovieClip();
		super.kill();
	}


//{
}