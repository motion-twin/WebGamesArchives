import Protocole;
import mt.bumdum9.Lib;


class But extends flash.display.Sprite {//}
	
	//static var mx = 6;

	public var ww:Int;
	public var hh:Int;
	public var mx:Int;
	public var box:flash.display.Sprite;
	public var action:Void->Void;
	public var actionOver:Void->Void;
	public var actionOut:Void->Void;
	var field:flash.text.TextField;
	var icon:pix.Element;
	var icon2:pix.Element;
	var colors:Array<Int>;

	public function new(name="", ?f, ?c, ico:Null<String>="icon_play",mx=6 ) {
		colors = [Gfx.col("green_1"),Gfx.col("green_2")];
		if( c != null ) colors = c;
		action  = f;
		super();
		
		hh = 12;
		this.mx = mx;
		
		// BOX
		box = new flash.display.Sprite();
		addChild(box);
		
		// FIELD
		field = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		
		field.y = -1;
		box.addChild(field);
		
		// ICON
		icon = new pix.Element();
		icon.x = mx+4;
		icon.y = 6;
		box.addChild(icon);
		
		// ICON 2

		
		
		// TITLE
		setTitle(name, ico);
		
	
		// BEHAVIOURS
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, click );
		
	
			
	}
	public function setTitle( name, ?ico ) {
		
		ww = 2*mx;
		
		// TITLE
		
		field.text = name;
		field.width = field.textWidth + 3;
		field.x = mx-1;
		ww += Std.int(field.textWidth);
		
		// ICON
		icon.visible = false;
		if( ico != null ){
			icon.drawFrame( Gfx.main.get(0, "icon_play"));
			icon.visible = true;
			ww += 8;
			field.x += 8+1;
		}
		
		//
		box.x = -Std.int(ww * 0.5);
		//
		out();
	}
	
	var active:Bool;
	
	public function update() {
		var pos = Cs.getMousePos(this);
		var isActive = Math.abs(pos.x) < ww * 0.5 && pos.y > 0 && pos.y < hh;
		if( active && !isActive ) out();
		if( !active && isActive ) over();
	}
	public function checkOut() {
		var pos = Cs.getMousePos(this);
		var isActive = Math.abs(pos.x) < ww * 0.5 && pos.y > 0 && pos.y < hh;
		if( active && !isActive ) out();
	}
	public function checkIn() {
		var pos = Cs.getMousePos(this);
		var isActive = Math.abs(pos.x) < ww * 0.5 && pos.y > 0 && pos.y < hh;
		if( !active && isActive ) over();
	}
	
	function over() {
		active = true;
		box.y = 1;
		box.graphics.clear();
		box.graphics.beginFill(colors[0]);
		box.graphics.drawRect(0, 0, ww, hh );
		if( actionOver != null ) actionOver();
	}
	function out() {
		active = false;
		box.y = 0;
		box.graphics.clear();
		box.graphics.beginFill(colors[0]);
		box.graphics.drawRect(0, 0, ww, hh );
		box.graphics.beginFill(colors[1]);
		box.graphics.drawRect(0, hh, ww, 1 );
		if( actionOut != null ) actionOut();
	}
	function click(e) {
		if(!active) return;
		out();
		if( action!=null )action();
		//active = false;
	}
	
	//
	var fieldNote:flash.text.TextField;
	public function addNote(str,token=false) {
		
		var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		f.text = str;
		f.width = f.textWidth + 3;
		f.x = Std.int(box.width*0.5) + 4;
		f.y = -1;
		addChild(f);
		
		if( token ){
			icon2 = new pix.Element();
			icon2.drawFrame(Gfx.main.get("icon_token"),0,0);
			icon2.x = f.x+f.width;
			icon2.y = f.y+2;
			addChild(icon2);
		}
	}
	
	//
	public function kill() {
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.CLICK, click );
		if( parent != null ) parent.removeChild(this);
	}
	
	//
	public function setTransp(width,height) {
		ww = width;
		hh = height;
		visible = false;
	}
	

	
//{
}












