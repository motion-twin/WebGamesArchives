package utils;
import Protocole;
import mt.bumdum9.Lib;
import Fruit;


class FruitExport extends SP {//}

	static var MAX = 300;
	

	public function new() {
		super();
		flash.Lib.current.addChild(this);
		
		
		
		var ecx = 220;
		var ecy = 24;
		var lines = 80;
		
		for ( i in 0...MAX ) {
			var data = DFruit.LIST[i];
			var box = new SP();
			var el = new pix.Element();
			el.drawFrame(Gfx.fruits.get(i),0,0);
			var title = Cs.getField(0, 8, -1, "nokia");
			title.text = "[" + i + "] " + Data.TEXT[i].fruit;
			title.width = 200;
			title.x = 32;
			title.y = 4;
			
			var desc = Cs.getField(0x888888, 8, -1, "nokia");
			desc.x = title.x;
			desc.y = title.y+10;
			desc.width = 300;
			desc.text = data.tags.join(",");
			
			addChild(box);
			box.addChild(el);
			box.addChild(title);
			box.addChild(desc);	
			
			box.x = ecx * Std.int(i / lines);
			box.y = ecy * (i%lines);
			
		}
		
		
		
		
	}
	
//{
}




