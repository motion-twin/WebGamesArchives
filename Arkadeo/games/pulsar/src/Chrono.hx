import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import Protocol;
import api.AKApi;

class Chrono extends mt.fx.Fx {
	
	static var WW = 46;
	static var HH = 11;
	static var LIMIT = 200;
	static var DOT_SIZE = 1;
	static var SCALE = 3;
	
	var bg:gfx.Timer;
	var field:TF;
	var print:BMD;
	var board:BMP;
	var root:SP;
	
	public var timer:Int;
	
	public function new() {
		super();
		root = new SP();
		Game.me.bg.addChild(root);
		
		bg = new gfx.Timer();
		root.addChild(bg);
		
		print = new BMD(WW, HH, true, 0);
		board = new BMP();
		board.bitmapData = new BMD(WW * SCALE, HH * SCALE, true, 0);
		root.addChild( board );
		
		board.x = (Game.WIDTH - WW * SCALE) >> 1;
		board.y = 60;
		bg.x = board.x-32;
		bg.y = board.y-12;
		
		field = TField.get(0x88FF00);
		Filt.glow(board, 4, 2, 0x00FF00);
	}
	
	override function update() {
		super.update();
		board.alpha = 1;
		if( timer < LIMIT  && timer > 0 && Game.me.timer % 12 < 4  ) board.alpha = 0.5;
	}
	
	public function display( ) {
		
		// COLORS
		var warning = timer <= LIMIT;
		field.textColor = warning?0xFF0000:0x88FF00;
		board.filters = [];
		Filt.glow(board, 4, 2, warning?0xFF0000:0x00FF00);
		
		// TIME
		var sec = Math.ceil(timer / 40);
		var a = Std.int(sec / 60) + "";
		var b = (sec % 60) + "";
		while(a.length < 2) a = "0" + a;
		while(b.length < 2) b = "0" + b;
		var str = a + ":" + b;
		
		print.lock();
		// PRINT - FIELD
		field.text = str;
		print.fillRect(print.rect, 0);
		var m = new MX();
		m.translate(0, -1);
		print.draw(field, m);
		
		// PRINT - OPTIONS
		var px = 30;
		for( pw in Game.me.hero.powers ) {
			var fr = Game.me.gfx.get(Type.enumIndex(pw.type), "powerup");
			if( pw.life != null && (pw.life < (5 * 40)) ) {
				if( Std.int(pw.life / 10) % 2 == 1 )
				{
					fr.backup();
					var ct = new flash.geom.ColorTransform();
					ct.color = 0xFF0000;
					fr.texture.colorTransform(fr.rectangle, ct);
				}
			}
			fr.drawAt(print, px, 2);
			fr.restore();
			px += 8;
		}
		
		board.x = (Game.WIDTH - px * SCALE - 18) >> 1;
		
		print.unlock();
		board.bitmapData.lock();
		board.bitmapData.fillRect(print.rect, 0);
		for( x in 0...WW ) {
			for( y in 0...HH ) {
				var col = print.getPixel32(x, y);
				for( dx in 0...DOT_SIZE ) {
					for( dy in 0...DOT_SIZE ) {
						board.bitmapData.setPixel32(x * SCALE+dx, y * SCALE+dy, col );
					}
				}
			}
		}
		board.bitmapData.unlock();
	}
}
