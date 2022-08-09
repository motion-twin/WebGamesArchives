package mt.deepnight;

import flash.display.Sprite;
import flash.text.TextField;

class TipSprite extends Sprite {
	public var bg		: Sprite;
	public var stf		: SuperText;
	
	public function new(?bgColor=0x545B6D, ?alpha=1.0, ?textColor=0xFFFFFF) {
		super();
		
		bg = new Sprite();
		addChild(bg);
		
		stf = new SuperText();
		addChild(stf.wrapper);
		stf.setFont(textColor);
		stf.setSize(200,200);
		
		var g = bg.graphics;
		g.beginFill(bgColor, alpha);
		g.drawRect(0,0,100,100);
	}
}

class Tip {
	public var spr			: TipSprite; // à ajouter à la displaylist
	
	public var maxWidth		: Int;
	public var padding		: Int;
	public var css			: flash.text.StyleSheet;
	public var bgFilters	: Array<flash.filters.BitmapFilter>;
	public var limits		: flash.geom.Rectangle;
	
	var fixedPos			: Null<flash.geom.Point>;
	public var alignCenter	: Bool;
	public var xOffset		: Int;
	public var yOffset		: Int;
	public var popDelay		: Int;
	var timer				: Float;
	public var fadeIn		: Bool;
	var lastContent			: Null<String>;
	
	public function new(?tspr:TipSprite) {
		if(tspr==null)
			tspr = new TipSprite();
		spr = tspr;
		spr.visible = false;
		spr.mouseChildren = spr.mouseEnabled = false;
		spr.cacheAsBitmap = true;
		padding = 5;
		xOffset = 15;
		alignCenter = false;
		yOffset = 0;
		maxWidth = 200;
		fadeIn = true;
		popDelay = 0;
		timer = 0;
		fixedPos = null;
		bgFilters = [
			new flash.filters.GlowFilter(0xffffff,0.2, 2,2,10, 1,true),
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
		];
		limits = new flash.geom.Rectangle(0,0, flash.Lib.current.stage.stageWidth, flash.Lib.current.stage.stageHeight);
		css = new flash.text.StyleSheet();
	}
	
	public function setFont(?name:String, ?size:Int) {
		spr.stf.setFont(0xFFFFFF, name, size);
	}
	
	public inline function showAt(x,y, msg:String, ?bgColor:Null<Int>) {
		fixedPos = new flash.geom.Point(x,y);
		show(msg,bgColor);
	}
	
	public inline function showAbove(o:flash.display.DisplayObject, msg:String, ?bgColor:Null<Int>) {
		var b = o.getBounds(o);
		var pt = o.localToGlobal( b.topLeft );
		var pt = spr.parent.globalToLocal( pt );
		setText(msg);
		fixedPos = new flash.geom.Point(pt.x, pt.y-spr.stf.textHeight-10);
		if( alignCenter )
			fixedPos.x += o.getBounds(spr.parent).width*0.5;
		show(msg,bgColor);
	}
	
	public inline function showUnder(o:flash.display.DisplayObject, msg:String, ?bgColor:Null<Int>) {
		var b = o.getBounds(o);
		var pt = o.localToGlobal( b.topLeft );
		var pt = spr.parent.globalToLocal( pt );
		setText(msg);
		fixedPos = new flash.geom.Point(pt.x, pt.y+b.height);
		if( alignCenter )
			fixedPos.x += o.getBounds(spr.parent).width*0.5;
		show(msg,bgColor);
	}
	
	inline function setText(msg:String) {
		var filler = "  "+String.fromCharCode(255)+" ";

		spr.stf.clear(maxWidth-padding*2, 200);
		spr.stf.setText(msg);
		spr.stf.autoResize();
	}
	
	public inline function show(msg:String, ?teint:Null<Int>) {
		if( !isVisible() || lastContent!=msg ) {
			lastContent = msg;
			spr.visible = popDelay<=0;
			timer = popDelay;
			if( fadeIn )
				spr.alpha = 0;
			spr.stf.wrapper.x = padding;
			spr.stf.wrapper.y = Math.ceil(padding*0.5);
			setText(msg);
			
			spr.bg.width = spr.stf.width + padding*2;
			spr.bg.height = Std.int( spr.stf.height + padding*1.5 );
			

			if(teint!=null)
				spr.bg.filters = cast [
					Color.getColorizeMatrixFilter(teint, 1, 0)
				].concat(cast bgFilters);
			else
				spr.bg.filters = bgFilters;
			
			updatePos();
		}
	}
	
	public inline function isVisible() {
		return spr.visible;
	}
	
	inline function updatePos() {
		var mx = flash.Lib.current.mouseX;
		var my = flash.Lib.current.mouseY;
		var x = if(fixedPos!=null) fixedPos.x else mx + xOffset;
		var y = if (fixedPos!=null) fixedPos.y else my + yOffset;
		if (alignCenter)
			x-=spr.width*0.5;
		
		if (fixedPos==null) {
			if ( x+spr.width>=limits.right )		x = mx-Math.abs(xOffset)-spr.width;
			if ( x<limits.left )				x = limits.left;
			if ( y+spr.height>=limits.bottom)	y = my-Math.abs(yOffset)-spr.height;
			if ( y<limits.top)				y = limits.top;
		}
		else {
			if( x>=limits.right-spr.width )		x = limits.right-spr.width;
			if( y>=limits.bottom-spr.height )	y = limits.bottom-spr.height;
		}
		
		spr.x = Std.int(x);
		spr.y = Std.int(y);
	}
	
	public inline function hide() {
		lastContent = null;
		timer = 0;
		spr.visible = false;
		spr.stf.clear();
		fixedPos = null;
	}
	
	public inline function update(?tmod=1.0) {
		if( timer>0 ) {
			timer-=tmod;
			if( timer<=0 )
				spr.visible = true;
		}
		
		if( isVisible() ) {
			if( spr.alpha<1 ) {
				spr.alpha+=tmod*0.17;
				if( spr.alpha>1 )
					spr.alpha = 1;
			}
			updatePos();
		}
	}
}

