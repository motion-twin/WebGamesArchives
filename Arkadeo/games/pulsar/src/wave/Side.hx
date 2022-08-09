package wave;
import Protocol;
import mt.bumdum9.Lib;


class Side extends fx.Wave {//}

	

	var pos:Array<Int>;

	public function new(data ) {
		super(data);

		pos = [];
		
		var mx = 16 + Game.BORDER_X;
		var my = 16 + Game.BORDER_Y;
		
		var a = rnd(2);
		var b = rnd(2);
		
		switch(a) {
			case 0 :
				var tot = (Game.WIDTH - 2 * mx);
				for ( i in 0...data.max ) {
					pos.push( mx + Std.int((i / (data.max - 1)) * tot));
					pos.push( my + (Game.HEIGHT - 2 * my) * b);
				}
			
			case 1 :
				var tot = (Game.HEIGHT - 2 * my);
				for ( i in 0...data.max ) {
					pos.push( mx + (Game.WIDTH - 2 * mx) * b);
					pos.push( my + Std.int((i / (data.max - 1)) * tot));
				}
			
		}
		
		
	}
	
	override function spawn(type) {
		
		new fx.Spawn(type,pos.shift(),pos.shift());
		
		
	}
	

	
	
//{
}












