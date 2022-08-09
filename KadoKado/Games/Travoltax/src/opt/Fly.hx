package opt;
import Common;
import mt.bumdum.Lib;
import mt.bumdum.Phys;




class Fly extends Option{//}


	var timer:Float;
	var count:Int;

	public function new(max){
		super();

		Game.me.step = Freeze;
		destroyPiece();
		count = max;
		timer = 0;

	}


	public function update(){
		super.update();

		timer+=mt.Timer.tmod;
		var n = 3;

		while(timer>n){
			timer-=n;

			// GET LIST
			var a = [];
			for( x in 0 ...Cs.XMAX ){
				for( y in 0 ...Cs.YMAX ){
					if( Game.me.grid[y][x] !=null ){
						a.push([x,y]);
						break;
					}
				}
			}
			var f = function(a,b){
				if(a[1]<b[1])return -1;
				return 1;
			}
			a.sort(f);

			//
			if( count--<0 || a.length == 0){
				Game.me.initPlay();
				kill();
				return;
			};

			//
			var index = Std.random( Std.int(Math.min(3,a.length)) );
			var pos = a[index];

			var type = Game.me.grid[pos[1]][pos[0]];
			Game.me.removeSquare(pos[0],pos[1]);


			var mc = Game.me.dm.empty(Game.DP_PARTS);
			var sq = new Square( new mt.DepthManager(mc).attach("mcSquare",0), type, Cs.COL_NEUTRAL);
			sq.root._x -= Cs.SIZE*0.5;
			sq.root._y -= Cs.SIZE*0.5;

			var p = new Particule( mc );
			p.x = Cs.MX + (pos[0]+0.5)*Cs.SIZE;
			p.y = Cs.MY + (pos[1]+0.5)*Cs.SIZE;
			p.weight = -(0.3+Math.random()*0.1);
			p.vr = (Math.random()*2-1)*0.5;
			p.timer = 100+Math.random()*20;
			//p.fadeType = 0;
			p.bhl = [2,3];
			p.updatePos();
			//trace(p.x+","+p.y);





		}



	}






//{
}








