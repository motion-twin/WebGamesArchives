import Protocole;
import mt.bumdum9.Lib;


typedef FallFruit = { sp:pix.Sprite, speed:Float, y:Float, life:Int };

class FruitFaller extends flash.display.Sprite {//}
	
	var ww:Int;
	var hh:Int;
	var fl:flash.filters.GlowFilter;
	
	var stop:Int;
	var fruits:Array<FallFruit>;
	var board:flash.display.Bitmap;
	public var menu:Array<Int>;
	
	var dm : mt.DepthManager;

	public function new(w, h) {
		ww = w;
		hh = h;
		super();
		stop = -10;
		dm = new mt.DepthManager(this);
		
		board = new flash.display.Bitmap( );
		board.bitmapData = new flash.display.BitmapData(ww, hh, true, 0);
		dm.add(board,1);
		
		fruits = [];
		
		//fl = new flash.filters.GlowFilter(0, 0.5, 2, 2, 4);
		
		fl = null;
		if( Game.me.have(POTION_PINK) && Game.me.have(REGLISSE) ) fl = new flash.filters.GlowFilter(0, 0.02, 2, 2, 4);
		
		
		if( fl != null ) board.filters = [fl];
		
		//Filt.glow(board, 2, 2, 0);
		
	}
	
	public function update() {
		if( stop > 40 ) return;

		if(Game.me.mtimer%6==0 ) spawnFruit();
			
		stop += 2;
		
		var a = fruits.copy();
		for( fr in a ) {
			fr.y += fr.speed;
			fr.sp.y = fr.y;
			fr.life++;
			if( fr.life > 5 ) stop--;
			if( fr.sp.y > hh || hit(fr.sp.x, fr.sp.y) ) {
				//fr.sp.filters = [];
				var bmp = board.bitmapData.clone();
				var m = new flash.geom.Matrix();
				m.translate(fr.sp.x, fr.sp.y);
				board.bitmapData.draw(fr.sp, m);
				board.bitmapData.draw(bmp);
				bmp.dispose();
				fruits.remove(fr);
				removeChild(fr.sp);
			}
		}
		if( stop < 0 ) stop = 0;
		
		
		
	}
	
	function hit(x:Float,y:Float) {
		var px = Std.int(x);
		var py = Std.int(y);
		var col = board.bitmapData.getPixel32(px, py);
		var o = Col.colToObj32(col);
		return o.a > 0;
	}
	
	function spawnFruit() {
		var sp = new pix.Sprite();
		var fid = Std.random(DFruit.MAX);
		if( menu != null ) fid = menu[Std.random(menu.length)];
		sp.drawFrame(Gfx.fruits.get(fid));
		sp.x = Std.random(Cs.mcw);
		sp.y = -32;
		dm.add(sp, 0);
		fruits.push( { sp:sp, speed:0.5 + Math.random(), y: -16.0, life:0 } );
		
		
		if( fl != null ) sp.filters = [fl];
	}



	
//{
}












