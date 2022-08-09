import Protocole;
import mt.bumdum9.Lib;


class Panel extends flash.display.Sprite {//}
	
	public var pww:Int;
	public var phh:Int;
	
	var step:Int;
	var coef:Float;
	var box:flash.display.Sprite;
	var win:flash.display.Sprite;

	
	static public var me:Panel;
	
	public function new() {
		me = this;
		super();
		step = 0;
		coef = 0;
		flash.ui.Mouse.show();
	}
	
	public function update() {
		switch(step) {
			case 0:
				coef = Math.min(coef + 0.1, 1);
				setWindow(coef);
				if( coef == 1 ) {
					display();
					step++;
				}
				
			case 1:
				updateDisplay();
				
			case 2:
				coef = Math.min(coef + 0.1, 1);
				setWindow(1-coef);
				if( coef == 1 ) kill();
		}
	}
	function updateDisplay() {
		
	}
	
	
	//
	
	function setWindow(coef:Float) {
		
		coef = Math.pow(coef, 2);
		
		// WINDOW
		var ww = Std.int(pww*0.5 * coef);
		var hh = Std.int(phh*0.5 * coef);
		
		if( win == null ) {
			win = new flash.display.Sprite();
			addChild(win);
		}
		win.x = Cs.mcw * 0.5;
		win.y = Cs.mch * 0.5;
		var ma = 2;
		win.graphics.clear();
		win.graphics.beginFill(0xFFFFFF);
		win.graphics.drawRect( -(ww + ma), -(hh + ma), (ww + ma) * 2, (hh + ma) * 2);
		ma--;
		win.graphics.beginFill(Gfx.col("green_1"));
		win.graphics.drawRect(-(ww+ma),-(hh+ma),(ww+ma)*2,(hh+ma)*2);
		win.graphics.beginFill(Gfx.col("green_0"));
		win.graphics.drawRect( -ww, -hh, ww * 2, hh * 2);
		
		win.graphics.beginFill(0xFFFFFF);
		win.graphics.drawRect( -(ww+ma),-(hh+ma),(ww+ma)*2, Std.int(14*coef));
		
		
		
	}
	
	function display() {
		
		box = new flash.display.Sprite();
		addChild(box);

	}
	
	function setTitle(str) {
		var f = Snk.getField(Gfx.col("green_1"), 8, -1, "nokia");
		f.text = str;
		f.y = Cs.mch*0.5-(phh*0.5);
		f.width = f.textWidth + 3;
		f.x = Std.int((Cs.mcw - f.width) * 0.5);
		box.addChild(f);
	}
	
	public function fadeOut() {
		if( step != 1 ) return;
		step = 2;
		coef = 0;
		box.visible = false;
	}
	
	function centerField(f:flash.text.TextField, ?widthMax) {
	
		f.width = f.textWidth + 3;
		if( widthMax!= null && f.width > widthMax ) f.width = widthMax;
		f.x = Game.MARGIN + Std.int((Cs.mcw - ( f.textWidth + Game.MARGIN * 2)) * 0.5);
	}
	

	// LEAVE
	public function kill() {
		me = null;
		if( parent!=null ) parent.removeChild(this);
		
	}
	
	public function leave() {
		coef = 0;
		step = 2;
		box.visible = false;
	}
	
//{
}







