package panel;
import Protocole;
import mt.bumdum9.Lib;


class Control extends Panel {//}
	
	public var buts:Array<ControlBut>;
	public static var me:Control;
	public var fieldDesc:flash.text.TextField;
	public var illus:pix.Element;
	public var next:Void->Void;

	public function new(f) {
		next = f;
		pww = 200;
		phh = 150;
		me = this;
		super();
		Game.me.dm.add(this, 10);
		Game.me.action = update;
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, validate );
	
		
	}
	override function update() {
		super.update();
	//	trace("!!"+step);
		//trace(">"+coef);

	}
	override function updateDisplay() {
		for( b in buts ) b.update();
	}
	

	override function display() {
		super.display();
	
		setTitle(Lang.CHOOSE_CONTROL);



		
		// ILLUS
		illus = new pix.Element();
		illus.x = Cs.mcw * 0.5;
		illus.y = 80;
		box.addChild(illus);
		illus.filters = [new flash.filters.DropShadowFilter(3, 45,Gfx.col("green_1"), 1, 0, 0, 10)];

		// BUTS
		buts = [];
		var ma = 6;
		for( id in 0...3 ) {
			var but = new ControlBut(id);
			but.x = Cs.mcw * 0.5 + (id - 1.5) * (ControlBut.WIDTH+2) +1;
			but.y = illus.y + 40;
			
			/*
			but.x = 2+Cs.mcw*0.5 + ((id % 2)*2-2) * (ControlBut.WIDTH*0.5+2);
			but.y = 100 + Std.int(id / 2) * (ControlBut.HEIGHT + 4);
			if( id == 2 ) {
				but.x = Cs.mcw*0.5 - ControlBut.WIDTH * 0.5;
			}
			*/
			box.addChild(but);
			buts.push(but);
		}
		
		// FIELD DESC
		fieldDesc = Snk.getField(0xDDFFAA, 8, -1, "nokia");
		fieldDesc.x = Game.MARGIN;
		fieldDesc.y = illus.y+60;
		fieldDesc.multiline = true;
		fieldDesc.wordWrap = true;
		fieldDesc.width = width;
		//fieldDesc.filters = [new flash.filters.DropShadowFilter(1, 90,Gfx.col("green_1"), 1, 0, 0, 10)];
		fieldDesc.filters = [new flash.filters.GlowFilter(Gfx.col("green_1"),1,2,2,100)];
		box.addChild(fieldDesc);
		
		//
		var so = flash.net.SharedObject.getLocal("snake");
		var auto:Null<Int> = so.data.controlType;
		if( auto == null ) auto = 0;
		buts[auto].select();
		
	}
	
	//
	var descId:Null<Int>;
	public function showDesc(id) {
		descId = id;
		displayDesc(id);
	}
	public function hideDesc(id) {
		if( descId != id ) return;
		displayDesc();
		descId = null;
		illus.visible = false;
	}
	function displayDesc(?id) {
		var str = "";
		if( id!=null ) str = Lang.DESC_CONTROL[descId];
		fieldDesc.htmlText = str;
		centerField(fieldDesc,width);
		illus.visible = true;
		illus.drawFrame(Gfx.main.get([2, 3, 0][id], "art_control"));
		if( id == 3 ) illus.visible = false;
	}
	
	function validate(e) {
		if( descId == null ) return;
		//
		var so = flash.net.SharedObject.getLocal("snake");
		if(so.data.controlType == descId )	so.data.controlRepeat++;
		else								so.data.controlRepeat = 0;
		so.data.controlType = descId;
		so.flush();
	
		//
		leave();
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.CLICK, validate );
		
		//
		
		
	}
	
	override function kill() {
		super.kill();
	
		next();
	}
	
//{
}


class ControlBut extends flash.display.Sprite {//}
	
	public static var WIDTH = 60;
	public static var HEIGHT = 12;
	
	var id:Int;
	var selected:Bool;
	var	light:flash.display.Sprite;
	
	public function new(id) {
		this.id = id;
		super();
		
		selected = false;
		
		// GFX
		var gfx = graphics;
		gfx.beginFill(0xFFFFFF);
		gfx.drawRect(0, 0, WIDTH, HEIGHT);
		var ma = 1;
		gfx.beginFill(Gfx.col("red_0"));
		gfx.drawRect(ma,ma,WIDTH-2*ma,HEIGHT-2*ma);
		
		// TEXT
		//var color = Gfx.col("red_0");
		var f = Snk.getField(0xFFFFFF, 8, -1, "nokia");
		f.text = Lang.CONTROL_NAMES[id];
		f.y = -1;
		f.width = f.textWidth + 3;
		f.x = Std.int((WIDTH - f.width) * 0.5);
		f.blendMode = flash.display.BlendMode.OVERLAY;
		addChild(f);
		
		// LIGHT
		var ma = 2;
		light = new flash.display.Sprite();
		light.graphics.lineStyle(2, 0xFFFFFF,1);
		light.graphics.beginFill(0xFFFFFF);
		light.graphics.drawRect( -ma, -ma, WIDTH + 2 * ma, HEIGHT + 2 * ma);
		light.alpha = 0.25;
		light.blendMode = flash.display.BlendMode.ADD;
		light.visible = false;
		addChild(light);
		

	}
	
	public function update() {
		var xm = (mouseX - x) * 0.5;
		var ym = (mouseY - y) * 0.5;
		var over = xm > 0 && xm < WIDTH && ym > 0 && ym < HEIGHT;
		
		
		if( over && !selected ) select();
		//if( !over && selected ) unselect();

		//ControlSelector.me.displayDesc(id);
		
	}

	public function select() {
		for( but in Control.me.buts ) {
			if( but == this ) continue;
			but.unselect();
		}
		
		selected = true;
		Control.me.showDesc(id);
		
		//
		//blendMode = flash.display.BlendMode.OVERLAY;
		light.visible = true;
	}
	public function unselect() {
		selected = false;
		Control.me.hideDesc(id);
		light.visible = false;
		//
		//blendMode = flash.display.BlendMode.NORMAL;
	}

//{
}









