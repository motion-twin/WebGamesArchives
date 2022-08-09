package fx.morph;
import mt.bumdum9.Lib;

class Impact extends fx.Morpher{//}

	var base:flash.display.BitmapData;
	var spc:Float;
	var power:Float;
	
	public function new(cx:Float, cy:Float, power = 100.0, spc = 0.1 ) {
		this.spc = spc;
		this.power = power;
		super(1);
		
		//var cx = morph.width * 0.5;
		//var cy = morph.height * 0.5;
		
		
		
		//drawMorph(cx, cy);
		
		var mo = new MorphImpact(0,0);
		var m = new flash.geom.Matrix();
		m.translate(cx-Cs.mcw, cy-Scene.HEIGHT);
		morph.draw(mo, m);

		
		base = bmp.clone();
		
		//showMorph();
		
		
	}
	
	function drawMorph(cx:Float, cy:Float) {
		var cycle = 60;
		for( x in 0...morph.width ) {
			for( y in 0...morph.height ) {
			
				var dx = x - cx;
				var dy = y - cy;
				var a = Math.atan2(dy, dx);
				
				var dist = Math.sqrt(dx * dx + dy * dy);
				var c = Math.sin(a * cycle);
				dist *= 0.5 + c * 0.5;
				if( dist > 128 ) dist = 128;
				
				var d = (dist / (Cs.mcw * 0.5)) * 128;
				var r = 128 + Std.int(Math.cos(a) * d);
				var g = 128 + Std.int(Math.sin(a) * d);
				var b = 128;
				var color = Col.objToCol( { r:r, g:g, b:b } );
				morph.setPixel(x, y, color);
			}
		}
	}
			
	override function update() {
		
		
		coef = Math.min(coef + spc, 1);
		var co = curve(coef);
	
		dis.scaleX = dis.scaleY = (1 - co) * power;
		bmp.applyFilter(base, base.rect, new flash.geom.Point(0, 0), dis);
		
		
		super.update();
	}
	

	override function kill() {
		super.kill();
	}
	
	// DEV
	/*
	override function showMorph() {
		morph = new flash.display.BitmapData(Cs.mcw * 2, Scene.HEIGHT * 2, 0xFF0000);
		drawMorph(morph.width * 0.5, morph.height*0.5 );
		Game.me.dm.add( new flash.display.Bitmap(morph), Game.DP_FX );
	}
	*/
	
	
	
//{
}










