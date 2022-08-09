import Protocole;
import mt.bumdum9.Lib;


class But extends flash.display.Sprite {//}
	

	public var ww:Int;
	public var hh:Int;
	var box:flash.display.Sprite;
	var action:Void->Void;
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
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, click );
		
		//
		out();
		
		
	}
	
	var active:Bool;
	public function update() {
		var pos = Main.getMousePos(this);
		var isActive = Math.abs(pos.x) < ww * 0.5 && pos.y > 0 && pos.y < hh;
		if( active && !isActive ) out();
		if( !active && isActive ) over();
	}
	
	function over() {
		active = true;
		box.y = 1;
		box.graphics.clear();
		box.graphics.beginFill(Gfx.col("green_1"));
		box.graphics.drawRect(0, 0, ww, hh );
	}
	function out() {
		active = false;
		box.y = 0;
		box.graphics.clear();
		box.graphics.beginFill(Gfx.col("green_1"));
		box.graphics.drawRect(0, 0, ww, hh );
		box.graphics.beginFill(Gfx.col("green_2"));
		box.graphics.drawRect(0, hh, ww, 1 );
	}
	function click(e) {
		if(!active) return;
		over();
		action();
	}
	
	public function kill() {
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.CLICK, click );
		if( parent != null ) parent.removeChild(this);
	}
	
	

	
//{
}












