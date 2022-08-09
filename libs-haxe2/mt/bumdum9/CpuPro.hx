package mt.bumdum9;
import mt.bumdum9.Lib;

class CpuPro implements haxe.Public{//}

	static var COLORS = [0xFF0000, 0x00FF00, 0xFF8800, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF ];
	
	static var log:Array<Array<Float>> = [];
	static var times:Array<Float>;
	
	static function init() {
		
	
		
	}
	
	
	static function frame() {
		if ( times != null ) pushLog();
		times = [];
		step();
	}
	static function step() {
		times.push(Date.now().getTime());
	}
	
	static function pushLog() {
		step();
		
		var tot = times[times.length-1] - times[0];
		var cur = times.shift();
		
		var a = [];
		for ( t in times ) {
			var c = (t-cur) / tot;
			cur = t;
			a.push(c);
		}
		
		log.push(a);
	}
	
	static function show(width,height, names:Array<String>) {
		var bmp = new BMD(width,height,false,0);
		var inc = Math.ceil(log.length / width);
		
		var i = 0;
		var rect = new flash.geom.Rectangle(0,0,1,1);
		rect.width = 1;
		
		while ( i < log.length ) {
			var a = log[i];
			rect.y = 0;
			var id = 0;
			for ( coef in a ) {
				rect.height = Math.ceil(height * coef);
				bmp.fillRect(rect, COLORS[id]);
				rect.y += rect.height;
				
				id++;
			}
			rect.x++;
			i += inc;
		}
		
		var box = new SP();
		var mc = new flash.display.Bitmap(bmp);
		box.addChild(mc);
		flash.Lib.current.addChild(box);
		
		
		// LEGEND
		var x = width - 100;
		var y = height - 20;
		var id = 0;
		names.push("display");
		
		for ( str in names ) {
			var base = new SP();
			box.addChild(base);
			var f = new TF();
	
			f.text = str;
			f.width = f.textWidth+4;
			f.x = 12;
			f.y = -5;
			f.textColor = 0xFFFFFF;
			base.addChild(f);
			base.graphics.beginFill(0);
			base.graphics.drawRect( -2, -2, 100, 14);
			base.graphics.endFill();
			base.graphics.beginFill(COLORS[id++]);
			base.graphics.drawRect(0, 0, 10, 10);
			
			base.x = x;
			base.y = y;
			y -= 14;
		}
		

		
		
		
		
		
	}
	
	
	
	
//{
}

