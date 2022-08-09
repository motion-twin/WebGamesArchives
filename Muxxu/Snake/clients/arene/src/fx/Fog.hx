package fx;
import Protocole;
import mt.bumdum9.Lib;

class Fog extends CardFx {//}
	
	var ray:Int;
	var board:SP;
	var bmp:BMD;
	var display:BMD;
	var light:SP;
	//var light:BMP;
	
	
	
	public function new(ca) {
		super(ca);
		board = new SP();
		Stage.me.dm.add(board,Stage.DP_FX);
		
		
		display = new BMD(Stage.me.width, Stage.me.height, true, 0xFFFFFFFF);
		bmp = new BMD(Stage.me.width, Stage.me.height, true, 0x00FFFFFF);
		board.addChild(new flash.display.Bitmap(display));
		
		//Filt.blur(board, 8, 8);
		
		
		ray = 32;
		ray += Game.me.numCard(HORN)*20;
		
		
		light =  new SP();
		light.graphics.beginFill(0xFF0000);
		light.graphics.drawCircle(0, 0, ray);
		
		
	}
	

	override function update() {
		super.update();
	
		var m = new MX();
		m.translate(sn.x, sn.y);
		bmp.draw( light, m, null, flash.display.BlendMode.ERASE );
		display.draw( light, m, null, flash.display.BlendMode.ERASE );
		//var p = new PT(sn.x-ray,sn.y-ray);
	//	bmp.copyPixels(light,light.rect,p);
		
		if ( Game.me.gtimer % 2 == 0 ) {	
			
			var m = [
				0,0,0,0,255,
				0,0,0,0,255,
				0,0,0,0,255,
				0,0,0,1,2,
			];
			
			var mt = new flash.filters.ColorMatrixFilter(m);
			bmp.applyFilter(bmp, bmp.rect, new PT(0, 0), mt);
			
			majDisplay();
			
			
			
			//trace(  Col.colToObj32( bmp.getPixel32(100, 100) ).a );
			//var ct = new CT(1, 1, 1, 1, -10, 0, 0, 10);
			//trace(  Col.colToObj32( bmp.getPixel32(100, 100) ).a );
			//bmp.colorTransform(bmp.rect, ct);
		}
		
	}
	
	function majDisplay() {
		
		var test = bmp.clone();
		var fl = new flash.filters.BlurFilter(16, 16);
		test.applyFilter( test, test.rect, new PT(),fl);
		
		for ( x in 0...bmp.width ) {
			for ( y in 0...bmp.height) {
				var alpha = test.getPixel32(x, y) >>> 24;				
				var ok = pw(x, y)*32 > alpha-10;				
				display.setPixel32(x, y, ok?0:0xFFFFFFFF);
				
			}
		}
		
		test.dispose();
		
	}
	
	inline function pw(x,y) {
		return x % 4 + y % 4;
	}
	
	
	override function kill() {
		super.kill();
		new mt.fx.Vanish(board,5,5);
		//board.parent.removeChild(board);
	}

	
	

	
//{
}












