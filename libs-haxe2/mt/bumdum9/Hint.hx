package mt.bumdum9;
import mt.bumdum9.Lib;

private typedef Item = {
	sp:SP,
	over:Dynamic->Void,
	out:Dynamic->Void,
}

class Hint extends SP{//}
	
	public static var MARGIN = 2;
	public static var ECX = 14;
	public static var ECY = 0;
	public static var DEFAULT_WIDTH = 200;

	var mcw:Int;
	var mch:Int;
	public var field:TF;
	
	var items:Array<Item>;
	
	var ddy:Int;
	public static var me:Hint;

	public function new() {
		super();
		ddy = 0;
		
		me = this;
		mcw = 100;
		mch = 100;
		
		visible = false;
		field = new TF();//Cs.getField(0x444444, 8, -1, "nokia");		
		field.multiline = true;
		field.wordWrap = true;
		field.x = MARGIN;
		field.y = MARGIN;
		addChild(field);
		drawBg();
		
		mouseEnabled = false;
		mouseChildren = false;
		items = [];
	
		
		//field.blendMode = flash.display.BlendMode.OVERLAY;
		this.addEventListener( flash.events.Event.ENTER_FRAME, update );
	}
	

	
	public function update(e) {
		if( !visible ) return;
		x += this.mouseX+ECX;
		y += this.mouseY+ECY;
		
		var ma = 4;
		if( x  > Cs.mcw - (mcw + ma) ) x = Cs.mcw - (mcw + ma);
		if( y  > Cs.mch - (mch + ma) ) y = Cs.mch - (mch + ma);
	}
	
	public function show(str, ?bw, ?dy = 0 ) {
		visible = true;
		ddy = dy;
		setText(str, bw);
	}
	public function hide() {
		visible = false;
	}
	
	function setText(str, ?bw) {
		if ( str == null ) str = "";
		if ( bw == null ) bw = DEFAULT_WIDTH;
		field.y = MARGIN + ddy;
		field.width = bw;
		field.htmlText = str;
		field.width = field.textWidth + 5;
		field.height = field.textHeight + 4;
		mcw = Std.int(field.width + MARGIN * 2);
		mch = Std.int(field.height + MARGIN * 2)+ddy;
		graphics.clear();
		drawBg();

	}

	function drawBg() {
		var gfx = graphics;
		gfx.beginFill(0xDDDDDD);
		gfx.drawRect(0, 0, mcw, mch);
		gfx.endFill();
		
		var ma = 2;
		gfx.beginFill(0xCCCCCC);
		gfx.drawRect(ma, ma, mcw-2*ma, mch-2*ma);
		gfx.endFill();
		
		
	}
	
	// ITEM
	public function addItem(sp:SP,str:String) {
		var over = function(e) { me.show(str); };
		var out = function(e) { me.hide(); };
		sp.addEventListener( flash.events.MouseEvent.ROLL_OVER, over );
		sp.addEventListener( flash.events.MouseEvent.ROLL_OUT, out );
		items.push( { sp:sp, over:over, out:out } );
	}
	
	public function removeItem(sp:SP) {
		for( it in items ) {
			if( it.sp == sp ) {
				sp.removeEventListener( flash.events.MouseEvent.ROLL_OVER, it.over );
				sp.removeEventListener( flash.events.MouseEvent.ROLL_OUT, it.out );
				break;
			}
		}
	}
	
	

//{
}



