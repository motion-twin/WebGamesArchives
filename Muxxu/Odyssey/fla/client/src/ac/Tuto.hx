package ac;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
using mt.bumdum9.MBut;

typedef DataTuto = { id:Int, desc:String, x:Null<Int>, y:Null<Int>, rot:Null<Int> };


class Tuto extends Action {//}
	
	static var DATA = mt.data.Mods.parseODS( "client.ods", "tuto", DataTuto );
	
	var panel:DialogBox;
	var field:TF;
	var but:SP;
	var arrow:gfx.TutoArrow;
	
	public function new() {
		super();
	
	}
	
	override function init() {
		super.init();
		//
		panel = new DialogBox();
		Game.me.dm.add(panel, Game.DP_INTER);
		panel.x = 32;
		panel.y = 192;
		
		//
		arrow = new gfx.TutoArrow();
		Game.me.dm.add(arrow, Game.DP_INTER);
		
		
		//
		field = TField.get(0xBFA55A, 14, "diogenes", 0);
		panel.addChild(field);
		displayText();
		
		//
		but = new SP();
		but.graphics.beginFill(0x00FFFF, 0);
		but.graphics.drawRect(0, 0, Cs.mcw, Cs.mch);
		but.makeBut( next );
		Game.me.dm.add(but, Game.DP_INTER);
	}
	
	// UPDATE
	override function update() {
		super.update();
			
	}
	
	//
	public function next() {
		nextStep();
		if ( step == 7 ) {
			kill();
		}else {
			displayText();
		}
		
		
	}
	
	
	//
	function displayText() {
		var ma = 10;
		var data = DATA[step];
		field.multiline = field.wordWrap = true;
		field.width = 200-2*ma;
		field.height = 150;
		field.htmlText = data.desc;
		//field.x = (200 - field.textWidth) * 0.5;
		field.x = ma;
		field.y = (150 - field.textHeight) * 0.5;
		
		arrow.visible = data.x != null;
		if ( arrow.visible ) {
			if ( arrow.x != data.x ) arrow.gotoAndPlay(1);
			arrow.x = data.x;
			arrow.y = data.y;
			arrow.rotation = data.rot;
		}
		
	}
	
	
	//
	override function kill() {
		super.kill();
		panel.parent.removeChild(panel);
		but.parent.removeChild(but);
		arrow.parent.removeChild(arrow);
	}


	
	
//{
}