import Datas;


class Cns{//}


	public static var GRID_MAX = 40;
	public static var ISLE_DIST_MIN = 160;
	public static var ISLE_DIST_MAX = 300;

	public static var DIR =  [[1,0],[0,1],[-1,0],[0,-1]];


	public static function isIn(x,y){
		var ec = 9;
		if(x+y<20) ec -= 20-(x+y);
		return x+y >13 && x-y < ec && x-y >-ec && x+y<34;

	}
	public static function randomPos(seed:mt.Rand){
		while(true){
			var x = seed.random(Cns.GRID_MAX);
			var y = seed.random(Cns.GRID_MAX);
			if(isIn(x,y))return {x:x,y:y};
		}
		return null;
	}


//{
}
