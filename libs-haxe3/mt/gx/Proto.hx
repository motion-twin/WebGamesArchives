package mt.gx;

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import mt.fx.Flash;

@:publicFields
class Proto {
	
	static function centeredText(?txt="", ?x=0.0, ?y=0.0, ?sz=40, ?col:Int=0xFF530D, ?p:flash.display.DisplayObjectContainer) {
		var word = new TextField();
		word.text = txt;
		
		var tf = new TextFormat("arial", sz);
		tf.color = col;
		
		word.setTextFormat( word.defaultTextFormat = tf );
		word.selectable  = false;
		word.mouseEnabled = false;
		word.background = false;
		word.wordWrap = false;
		word.filters = [ new flash.filters.GlowFilter( 0,1,1.5,1.5,255 )];
		
		word.width = word.textWidth + 5;
		word.height = word.textHeight + 5;
		
		word.x = x;
		word.y = y;
		
		word.x -= word.width * 0.5;
		word.y -= word.height * 0.5;
		
		if ( p != null ) p.addChild(word);
		
		return word;
	}
	
	static function leftText(txt, x, y, ?sz=40, ?col:Int=0xFF530D, ?p:flash.display.DisplayObjectContainer) {
		var w = centeredText(txt, x, y, sz, col, p);
		w.x = x;
		w.y = y;
		return w;
	}
	
	static function rect(x,y,szx,szy,?col:Int=0xFFcdcdcd,?p:flash.display.DisplayObjectContainer) {
		var sq = new flash.display.Sprite();
		sq.x = x;
		sq.y = y;
		var gfx = sq.graphics;
		gfx.beginFill(col);
		gfx.drawRect( 0,0,szx, szy); 
		gfx.endFill();
		sq.filters = [ new flash.filters.GlowFilter( 0, 1, 2, 2, 12 )];
		if ( p != null ) p.addChild(sq);
		return sq;
	}
	
	static function sqr(x,y,sz,?col=0xFFcdcdcd,?p:flash.display.DisplayObjectContainer) {
		var sq = new flash.display.Sprite();
		sq.x = x;
		sq.y = y;
		var gfx = sq.graphics;
		gfx.beginFill(col);
		gfx.drawRect( 0,0,sz, sz); 
		gfx.endFill();
		sq.filters = [ new flash.filters.GlowFilter( 0, 1, 2, 2, 12 )];
		if ( p != null ) p.addChild(sq);
		return sq;
	}
	
	static function circle(x,y,sz,?col=0xFFcdcdcd,?p:flash.display.DisplayObjectContainer) {
		var sq = new flash.display.Sprite();
		sq.x = x;
		sq.y = y;
		var gfx = sq.graphics;
		gfx.beginFill(col);
		gfx.drawCircle( 0,0,sz); 
		gfx.endFill();
		sq.filters = [ new flash.filters.GlowFilter( 0, 1, 2, 2, 12 )];
		if ( p != null ) p.addChild(sq);
		return sq;
	}
	
	static function dot(x,y,?p) {
		var c = circle(x, y, 1, 0xFFFF0000);
		(p==null?flash.Lib.current.stage:p).addChild(c);
		haxe.Timer.delay( function() c.parent.removeChild(c), 2000);
		return c;
	}
	
	static function ramp( ?c0:Int=0xFFffffff,?c1:Int=0x0,?w=256,?h=8 ) : flash.display.Sprite{
		var sp = new flash.display.Sprite();
		var m = new flash.geom.Matrix();
		m.identity();
		m.createGradientBox(w,h);
		sp.graphics.beginGradientFill(flash.display.GradientType.LINEAR, 
			[c0 & 0x00ffffff, c1 & 0x00ffffff], 
			[Math.round((c0 >>> 24) / 2.5), Math.round((c1 >>> 24) / 2.5)], 
			[0, 255], m );
		sp.graphics.drawRect(0, 0, w, h);
		sp.graphics.endFill();
		return sp;
	}
}