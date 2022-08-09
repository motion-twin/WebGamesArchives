import Game;
import mt.bumdum9.Lib;


class Background extends McBackground
{//}

	var depth:Float;


	public function new() {
		super();
		depth  = 0;
	}
	
	public function scroll(inc:Float) {
		depth += inc;
		
		par0.y = -depth % 510;
		par1.y = -(depth * 0.75) % 300;
		par2.y = -(depth * 0.5) % 300;
		
		//Col.setColor(bg, 0, -20000);
		var coef = Num.mm(0, depth / 2000,1);
		
		Col.setPercentColor(bg, coef , 0);
		
		var a = [ par0, par1, par2 ];
		var id = 0;
		
		var color = Col.mergeCol(0x00407E, 0, 1 - coef);
		var cc = coef * 0.75;
		for( mc in a ) {
			var c = [0.25, 0.5, 0.75][id];
			c = cc + c * (1 - cc);
			Col.setPercentColor(mc, c , color);
			id++;
		}
		
		
		//var a  = [McForest, McMoutain];
		//var k = new a[Std.random(a.length)]();
		
		
	}
	


//{
}