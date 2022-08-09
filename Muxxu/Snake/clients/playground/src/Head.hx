import Protocole;
import mt.bumdum9.Lib;

class Head extends Module
{//}
	
	static var HORIZON = 0.4;

	var bgColor:Int;
	
	public function new() {
		width = 440;
		height = 33;
		super();

		bgColor = Gfx.col("green_0");
		
		// BG
		var gfx = root.graphics;
		gfx.beginFill(bgColor);
		gfx.drawRect(0, 0, width, height );
		
		// FRUITS
		var max = 200;
		for( i in 0...max ) {
			var fr = new pix.Element();
			fr.drawFrame( Gfx.fruits.get(Std.random(300)));
			fr.x = Std.random(width);
			fr.y = height * (HORIZON+(i/max)*(1-HORIZON));
			dm.add(fr, 1);
			fr.pxx();
			
			Filt.glow(fr, 2, i/max,0);
			
			
			var c = 0.5 - (i / max) * 0.6;
			c = Math.max( c, 0);
			Col.setPercentColor(fr, c, bgColor);
			
		}
		
		// TITLE
		var title = new pix.Element();
		title.drawFrame(Gfx.el.get(0, "title"));
		title.x = width * 0.5;
		title.y = 16;
		dm.add(title, 2);
		
		// STARS
		genStars(300);
		
		// LIGHT
		var title = new pix.Element();
		title.drawFrame(Gfx.el.get(0, "title"));
		title.x = width * 0.5;
		title.y = 36;
		dm.add(title, 1);
		Col.setColor(title, 0xFFFFFF,255);
		title.filters = [ new flash.filters.BlurFilter(256, 12) ];
		title.blendMode = flash.display.BlendMode.ADD;
		
		
	}
	
	override function update() {
	
		//genStars(4, -(0.01 + Math.random() * 0.05));
		
		var a = pix.Sprite.all.copy();
		for( sp in a ) sp.update();
	
		super.update();
	}

	function genStars(max, w = 0) {
		
		for( i in 0...max ) {
			var ww = Std.int(150+Math.pow(Math.random(),2)*30);
			
			var p = new Part();
			p.setAnim(Gfx.el.getAnim("stars"));
			p.weight = w;
			p.x = (width-ww)*0.5 +Std.random(ww);
			p.y = Std.random(height);
			p.anim.gotoRandom();
			p.anim.stop();
			
			var depth = 1;
			if( Std.random(4) == 0 ) depth = 3;
			dm.add(p, depth);
			
			
			Filt.glow(p, 8, 1, 0xFFFF88);
			
			p.blendMode = flash.display.BlendMode.ADD;
			
		}
	}
	
	
//{
}












