package panel;
import Protocole;
import mt.bumdum9.Lib;


class Info extends Panel {//}
	
	
	#if dev
	static var TIME = 0;
	#else
	static var TIME = 8;
	#end
	
	var timer:Int;
	var title:String;
	var desc:String;
	var fieldTime:flash.text.TextField;
	
	public function new(title,desc,t) {
		pww = 200;
		phh = 92;
		timer = t;
		this.title = title;
		this.desc = desc;
		super();
		
		Game.me.dm.add(this, 2);
		Game.me.action = update;
		
		timer = TIME*40;
		
		
		
	}
	
	var but:But;
	override function updateDisplay() {
		super.updateDisplay();
		timer--;
		fieldTime.text = Lang.GAME_WILL_START + Std.int(timer / 40) + " "+Lang.SECONDES;
		
		if( timer < 0 ) {
			if(fieldTime.visible) {
				fieldTime.visible = false;
				but = new But(Lang.START,leave);
				box.addChild(but);
				but.y = fieldTime.y;
				but.x =  Cs.mcw * 0.5;
				
			}
			but.update();
		}
		
	}
	
	override function display() {
		super.display();
		setTitle(title);
		
		// DESC
		var fieldDesc = Snk.getField(0xDDFFAA, 8, -1, "nokia");
		fieldDesc.x = Game.MARGIN;
		fieldDesc.y = 82;
		fieldDesc.multiline = true;
		fieldDesc.wordWrap = true;
		fieldDesc.width = width;
		fieldDesc.filters = [new flash.filters.GlowFilter(Gfx.col("green_1"),1,2,2,100)];
		box.addChild(fieldDesc);
		fieldDesc.text = desc;
		centerField(fieldDesc);
		
		// TIMER
		fieldTime = Snk.getField(0xDDFFAA, 8, -1, "nokia");
		fieldTime.text = "";
		centerField(fieldTime);
		fieldTime.y = 132;
		box.addChild(fieldTime);

		
	}
	


	
	override function kill() {
		
		super.kill();
		Game.me.initIntro();
	}



}



