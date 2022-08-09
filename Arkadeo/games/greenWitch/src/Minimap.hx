import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Color;

class Minimap {
	static var COLOR = 0xc4bd82;
	
	public var wrapper	: Sprite;
	var game			: mode.Play;
	var padding			: Int;
	var walls			: Bitmap;
	var spots			: Bitmap;
	
	var odd				: Bool;
	
	public var visible	: Bool;
	
	public function new() {
		game = mode.Play.ME;
		
		odd = true;
		padding = 8;
		
		wrapper = new Sprite();
		wrapper.mouseChildren = wrapper.mouseEnabled = false;
		wrapper.visible = visible = false;
		wrapper.alpha = 0;
		
		var tf = game.createField(Lang.Map, COLOR, true);
		wrapper.addChild(tf);
		tf.x = Std.int(-tf.textWidth*0.5);
		tf.y = 6;
	}
	
	public function setLevel(l:Level) {
		if( walls!=null ) {
			walls.bitmapData.dispose();
			walls.parent.removeChild(walls);
			spots.bitmapData.dispose();
			spots.parent.removeChild(spots);
		}
		walls = new Bitmap( new BitmapData(l.wid+padding*2, l.hei+padding*2, true, 0x0), flash.display.PixelSnapping.NEVER, false );
		wrapper.addChild(walls);
		walls.scaleX = walls.scaleY = 3;
		walls.x = Std.int(-walls.width*0.5);
		walls.alpha = 0.9;
		
		spots = new Bitmap( new BitmapData(l.wid+padding*2, l.hei+padding*2, true, 0x0), flash.display.PixelSnapping.NEVER, false );
		wrapper.addChild(spots);
		spots.scaleX = spots.scaleY = 3;
		spots.x = Std.int(-spots.width*0.5);
		
		walls.bitmapData.fillRect(walls.bitmapData.rect, 0x0);
		for(x in 0...l.wid)
			for(y in 0...l.hei)
				if( l.getCollision(x,y) )
					walls.bitmapData.setPixel32(x+padding, y+padding, Color.addAlphaF( !l.getCollision(x,y+1)  ? COLOR : Color.brightnessInt(COLOR, 0.09) ));
				else
					walls.bitmapData.setPixel32(x+padding, y+padding, Color.addAlphaF( Color.brightnessInt(COLOR, -0.20) ) );
					
		walls.bitmapData.applyFilter( walls.bitmapData, walls.bitmapData.rect, new flash.geom.Point(0,0), new flash.filters.DropShadowFilter(2,90, COLOR,1, 0,0) );
		walls.bitmapData.applyFilter( walls.bitmapData, walls.bitmapData.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0x0, 0.8, 4,4,2) );
	}
	
	public function show() {
		wrapper.x = Std.int( Const.WID*0.5 );
		wrapper.y = Std.int( Const.HEI-wrapper.height );
		
		visible = true;
		var a = wrapper.alpha;
		game.tw.terminate(wrapper);
		wrapper.alpha = a;
		wrapper.visible = true;
		game.tw.create(wrapper, "alpha", 1, TEase, 200);
	}

	public function hide(?fast=false) {
		visible = false;
		var a = wrapper.alpha;
		game.tw.terminate(wrapper);
		if( !fast ) {
			wrapper.alpha = a;
			game.tw.create(wrapper, "alpha", 0, TEase, 400).onEnd = function() {
				wrapper.visible = false;
			}
		}
		else {
			wrapper.alpha = 0;
			wrapper.visible = false;
		}
	}
	
	inline function addSpot(x,y, col, ?w=1, ?h=1) {
		if( w==1 && h==1 )
			spots.bitmapData.setPixel32( x+padding,y+padding, Color.addAlphaF(col) );
		else
			spots.bitmapData.fillRect( new flash.geom.Rectangle(x+padding, y+padding, w,h), Color.addAlphaF(col) );
	}
	
	public function update() {
		spots.bitmapData.lock();
		spots.bitmapData.fillRect(spots.bitmapData.rect, 0x0);
		
		// Portes
		var c = 0x843420;
		for( e in en.Door.ALL )
			if( !e.broken )
				if( e.horizontal )
					addSpot(e.cx, e.cy, c, 2,1);
				else
					addSpot(e.cx, e.cy, c, 1,2);
				
		// Distributeurs
		//for( e in en.Dispenser.ALL ) {
			//addSpot(e.cx, e.cy-1, 0x76E1E7);
			//addSpot(e.cx, e.cy, 0x22B8BF);
		//}
		
		// Sorties
		for( e in en.Exit.ALL )
			addSpot(e.cx, e.cy, 0x1C212F, 2,2);
				
		// Héros
		if( odd )
			addSpot( game.hero.cx, game.hero.cy, 0x80FF00, 2,2 );
		
		// Civils
		for( e in en.it.Civilian.ALL )
			addSpot(e.cx, e.cy, 0xFFFF00, 2,2);
		
		spots.bitmapData.unlock();
		odd = !odd;
	}
}

