package wave;
import Protocol;
import mt.bumdum9.Lib;


class Point extends fx.Wave {//}


	var pos: { x:Int, y:Int };

	public function new(data,?pos) {
		super(data);
		if ( pos == null ) pos = Game.me.getRandomPointFarFromHero(80);
		this.pos = pos;
		//trace(pos.x + "," + pos.y);
	}
	
	override function spawn(type) {

		var ox = (rnd(100) / 100) * 2 - 1;
		var oy = (rnd(100) / 100) * 2 - 1;
		
		new fx.Spawn(type,pos.x+ox,pos.y+oy);
		
	}
	

	
	
//{
}












