package mt.gx.h2d;

import flash.text.TextField;
import flash.text.TextFormat;
import h2d.Font;
import h2d.Interactive;
import h2d.Sprite;
import hxd.res.FontBuilder;
import mt.deepnight.Color;

@:publicFields
class Proto {
	
	public static inline var defaultFontName = "verdana";
	
	static function sqr(x,y,sz,?col=0xFFcdcdcd,?alpha=1.0,?p:h2d.Sprite) {
		var gfx = new h2d.Graphics();
		gfx.x = x; gfx.y = y;
		gfx.beginFill(col,alpha);
		gfx.drawRect( 0,0,sz, sz); 
		gfx.endFill();
		if ( p != null ) p.addChild(gfx);
		return gfx;
	}
	
	static function rect(x,y,szx,szy,?col=0xcdcdcd,?alpha=1.0,?p:h2d.Sprite) {
		var gfx = new h2d.Graphics();
		gfx.x = x; gfx.y = y;
		gfx.beginFill(col,alpha);
		gfx.drawRect( 0,0,szx, szy); 
		gfx.endFill();
		if ( p != null ) p.addChild(gfx);
		return gfx;
	}
	
	static function rectOutline(szx,szy,?col=0xFF3515,?p:h2d.Sprite) {
		var outlineSize = mt.Metrics.vpx2px( 1.0 );
		var gfx = new h2d.Graphics();
		gfx.lineStyle(outlineSize);
		gfx.beginFill(col);
		gfx.drawRect( 0,0,szx, szy); 
		gfx.endFill();
		if ( p != null ) p.addChild(gfx);
		return gfx;
	}
	
	static function centeredRectOutline(szx:Int,szy:Int,?col=0xFF3515,?p:h2d.Sprite) {
		var outlineSize = mt.Metrics.vpx2px( 1.0 );
		var gfx = new h2d.Graphics();
		
		gfx.x = Std.int(-(szx>>1)); 
		gfx.y = Std.int(-(szy>>1));
		
		gfx.lineStyle(outlineSize);
		gfx.beginFill(col);
		gfx.drawRect( 0,0,szx, szy); 
		gfx.endFill();
		if ( p != null ) p.addChild(gfx);
		return gfx;
	}
	
	static function txt(x, y, sz, msg:String, ?col = 0xFFFFFF, ?fnt:h2d.Font, ?p:h2d.Sprite) {
		if ( fnt == null) fnt=hxd.res.FontBuilder.getFont( defaultFontName, Math.round(sz));
		var txt = new h2d.Text(fnt);
		txt.x = x;
		txt.y = y;
		txt.text = msg;
		txt.textColor = col;
		txt.dropShadow = { dx:1,dy:1,color:0xFF000000,alpha:1.0 };
		if ( p != null ) p.addChild(txt);
		return txt;
	}
	
	static function htmlTxt(x, y, sz, msg:String, ?col = 0xFFFFFFFF, ?fnt:h2d.Font,?p:h2d.Sprite) {
		if ( fnt == null) fnt=hxd.res.FontBuilder.getFont( defaultFontName, sz);
		var txt = new h2d.HtmlText(fnt);
		txt.x = x;
		txt.y = y;
		txt.textColor = col;
		txt.htmlText = msg;
		if ( p != null ) p.addChild(txt);
		return txt;
	}
	
	static function circle(x,y,sz,?col=0xFFcdcdcd,?p:h2d.Sprite) {
		var gfx = new h2d.Graphics();
		gfx.x = x;
		gfx.y = y;
		gfx.beginFill(col);
		gfx.drawCircle( 0,0,sz); 
		gfx.endFill();
		if ( p != null ) p.addChild(gfx);
		return gfx;
	}
	
	static function dot(x,y,?p:h2d.Sprite) {
		var c = circle(x, y, 1, 0xFFFF0000);
		if( p !=null ) p.addChild(c);
		haxe.Timer.delay( function() c.parent.removeChild(c), 2000);
		return c;
	}
	
	static function bt(w, h, msg:String, cbk:Void->Void,?p:h2d.Sprite) {
		var root = new h2d.Sprite(p);
		var r = rectOutline( w, h, mt.deepnight.Color.randomColor(0.3), root );
		var s = txt( 0, 0, h * 0.8, msg, 0x0 , root);
		s.x = r.width * 0.5 - s.width* 0.5;
		var i = new h2d.Interactive( r.width, r.height, r );
		i.backgroundColor = 0xFFFF0000;
		i.onClick = function(_) {
			cbk();
		};
		return root;
	}
}