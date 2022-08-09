import Protocole;
import mt.bumdum9.Lib;

class Pub500 extends Module
{//}
	
	var list:Array<pix.Element>;

	public function new() {
		width = 500;
		height = 500;
		super();
		
		// BG
		var bg = new pix.Element();
		dm.add(bg, 0);
		bg.drawFrame(Gfx.bg500.get(0),0,0);
				
		// FRUITS
		var fruits = new flash.display.Sprite();
		dm.add(fruits, 1);
		var fdm = new mt.DepthManager(fruits);
		list = [];
		var max = 1200;
		var diag = Math.sqrt(width * width + height * height);
		var min = 50;
		for( i in 0...max ) {
			var el = new pix.Element();
			el.drawFrame(Gfx.fruits.get(Std.random(300)));
			fdm.add(el, 0);
			var an = i / max * 6.28;
			var ray = min+Math.pow(Math.random(), 0.4) * (diag * 0.5 - min);
			el.x = width*0.5+Snk.cos(an) * ray;
			el.y = height * 0.5 + Snk.sin(an) * ray;
			list.push(el);
		}
		
		fruits.filters = [new flash.filters.DropShadowFilter(2,45,Gfx.col("green_1"),1,0,0,200) ];
		
		//
		list.sort(ySort);
		for( mc in list ) fdm.over(mc);
		
	}
	function ySort(a:pix.Element,b:pix.Element) {
		if( a.y < b.y ) return -1;
		return 1;
	}
	
	override function update() {
		super.update();
	}


	
//{
}












