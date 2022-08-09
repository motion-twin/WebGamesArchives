import Protocole;
import mt.bumdum9.Lib;


class But extends flash.display.Sprite {//}
	

	public var ww:Int;
	public var hh:Int;
	var box:flash.display.Sprite;
	var action:Void->Void;
	public var actionOver:Void->Void;
	public var actionOut:Void->Void;
	var field:flash.text.TextField;
	var icon:pix.Sprite;

	public function new(name,f,img="icon_play") {
		action  = f;
		super();
		
		
		var mx = 6;
		
		//
		box = new flash.display.Sprite();
		
		// TITLE
		field = Main.getField(0xFFFFFF, 8, -1, "nokia");
		field.text = name;
		field.width = field.textWidth + 3;
		field.height = field.textHeight + 3;
		field.x = mx+8;
		field.y = -1;
		
		
		// ICON
		icon = new pix.Sprite();
		icon.drawFrame( Gfx.main.get(0,img));
		icon.x = mx+4;
		icon.y = 6;
		
		box.addChild(field);
		box.addChild(icon);
		addChild(box);
		
		// BG
		ww = Std.int(field.width + 8 + 2 * mx);
		hh = 12;
		box.x = -Std.int(ww * 0.5);
		
		// BEHAVIOURS
		addEventListener( flash.events.MouseEvent.CLICK, click );
		addEventListener( flash.events.MouseEvent.MOUSE_OVER, over );
		addEventListener( flash.events.MouseEvent.MOUSE_OUT, out );
		
		//
		out(null);
		
		
	}
	
	
	function over(e) {
		if( actionOver != null ) actionOver();
		box.y = 1;
		box.graphics.clear();
		box.graphics.beginFill(Gfx.col("green_1"));
		box.graphics.drawRect(0, 0, ww, hh );
	}
	function out(e) {
		if( actionOut != null ) actionOut();
		box.y = 0;
		box.graphics.clear();
		box.graphics.beginFill(Gfx.col("green_1"));
		box.graphics.drawRect(0, 0, ww, hh );
		box.graphics.beginFill(Gfx.col("green_2"));
		box.graphics.drawRect(0, hh, ww, 1 );
		
	}
	function click(e) {

		over(null);
		action();
	}
	
	public function kill() {
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.CLICK, click );
		if( parent != null ) parent.removeChild(this);
	}
	
	

	
//{
}












