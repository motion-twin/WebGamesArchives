package pix.tools;
import mt.bumdum9.Lib;
import mt.bumdum9.Hint;

class Viewer extends SP {
	
	var scale:Int;
	var store:Store;
	var pageSprite:SP;
	var pageAnim:SP;
	var buts:SP;
	
	public function new( s:Store ) {
		super();
		store = s;
		if ( Hint.me == null ) {
			var hint = new mt.bumdum9.Hint();
			var tf = new flash.text.TextFormat("verdana", 10, 0,true);
			hint.field.defaultTextFormat = tf;
			flash.Lib.current.addChild(hint);
		}
		
		setScale(2);
		this.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, mouseWheel);
		initSpriteSheet();
		initAnims();
		
		pageAnim.visible = false;
		// INTERRACTION
		var me = this;
		addEventListener(flash.events.MouseEvent.MOUSE_DOWN, down );
		addEventListener(flash.events.MouseEvent.MOUSE_UP, up );
	}
	
	var clickTime:Float;
	function down(e) {
		clickTime = Date.now().getTime();
		startDrag();
	}
	
	function up(e) {
		if ( Date.now().getTime() - clickTime < 160 ) swapPages();
		stopDrag();
	}
	
	function swapPages() {
		pageAnim.visible = !pageAnim.visible;
		pageSprite.visible = !pageSprite.visible;
	}

	function initSpriteSheet() {
		var bg = new flash.display.Bitmap( store.texture );
		buts =  new SP();
		var colors = [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF];
		var colorId = 0;
		var ids = store.getIds();
		var id = 0;
		for( fr in store.frames ) {
			if( ids[0] == id ) {
				ids.shift();
				colorId++;
			}
			var col = colors[colorId % colors.length];
			var but = new SP();
			buts.addChild(but);
			but.graphics.lineStyle(null, col,1);
			but.graphics.beginFill(0, 0);
			but.graphics.drawRect(0, 0, fr.width, fr.height);
			var n = 8;
			but.graphics.lineTo(n, 0);
			but.x = fr.x;
			but.y = fr.y;
			id++;
		}
		pageSprite = new SP();
		pageSprite.addChild(bg);
		pageSprite.addChild(buts);
		addChild(pageSprite);

	}
	
	function clickFrame(id,e) {
	}
	
	function mouseWheel(e) {
		var ow = width;
		var oh = height;
		if ( e.delta > 0 && scale < 16 ) setScale(scale << 1);
		if ( e.delta < 0 && scale > 1  ) setScale(scale >> 1);
		var dw = width - ow;
		var dh = height - oh;
		x -= dw*0.5;
		y -= dh*0.5;
	}
	
	public function setScale(n) {
		scale = n;
		scaleX = scaleY = n;
	}

	public function initAnims() {
		var ww = store.texture.width;
		var hh = store.texture.height;
		pageAnim = new SP();
		var keys = store.timelines.keys();
		var x = 0;
		var y = 0;
		var h = 0;
		for( str in keys ) {
			var el = new pix.Element();
			pageAnim.addChild(el);
			el.setAlign(0, 0);
			el.store = store;
			if( !store.timelines.exists(str) ) continue;
			el.play(str);
			var first = el.currentFrame;
			if ( x + first.width > ww ) {
				x = 0;
				y += h;
				h = 0;
			}
			el.x = x-first.ddx;
			el.y = y-first.ddy;
			h = Std.int(Math.max(first.height, h));
			x += first.width;
			Hint.me.addItem(el, str);
		}
		addChild(pageAnim);
	}
}
