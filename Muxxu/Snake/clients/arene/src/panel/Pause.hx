package panel;
import Protocole;
import mt.bumdum9.Lib;


class Pause extends Panel {//}
	
	var buts:Array < But>;

	public function new() {
		pww = 100;
		phh = 110;
		super();
		Game.me.dm.add(this, 10);

	}
	
	override function update() {
		super.update();
	}
	
	// DISPLAY
	var butControl:But;
	var butGore:But;
	override function display() {
		super.display();
		setTitle(Lang.PAUSE_TITLE);
		buts = [];
		
		var y = (Cs.mch-phh)*0.5 + 20 ;
		
		// CONTROL
		var f = getSect(Lang.CONTROL);
		f.y = y;
		y += 14;
		
		var but = new But("", toggleControls,null,null);
		but.x = Cs.mcw * 0.5;
		but.y = y;
		box.addChild(but);
		buts.push(but);
		butControl = but;
		displayControlType();
		y += 16;
		
		// GORE
		var f = getSect(Lang.GORE);
		f.y = y;
		y += 14;
		
		var but = new But("", toggleGore,null,null);
		but.x = Cs.mcw * 0.5;
		but.y = y;
		box.addChild(but);
		buts.push(but);
		butGore = but;
		displayGore();
		
		
		// UN PAUSE
		var but = new But(Lang.PAUSE_OFF, fadeOut, null);
		but.x = Cs.mcw * 0.5;
		but.y = (Cs.mch + phh) * 0.5 - 16;
		buts.push(but);
		box.addChild(but);
		
	}
	
	function toggleControls() {
	
		var so = flash.net.SharedObject.getLocal("snake");
		var type = so.data.controlType;
		var newType = (type + 1) % 3;
		so.data.controlType = newType;
		Game.me.setControl( Snk.getEnum(ControlType, newType) );
		so.flush();
		displayControlType();
	}
	function displayControlType() {
		var so = flash.net.SharedObject.getLocal("snake");
		var type = so.data.controlType;
		butControl.setTitle(Lang.CONTROL_NAMES[type],null);
	}
	
	function toggleGore() {
		var so = flash.net.SharedObject.getLocal("snake");
		var flag:Null<Bool> = so.data.gore;
		if( flag == null ) flag = true;
		flag = !flag;
		so.data.gore = flag;
		so.flush();
		Game.me.setGore( flag );
		displayGore();
		
		//
		
		var a = [];
		for( i in 0...628 )a.push(Math.round(Math.cos(i*0.01)*1000));
		flash.system.System.setClipboard(a.join(","));
		
	}
	function displayGore() {
		var so = flash.net.SharedObject.getLocal("snake");
		var flag:Null<Bool> = so.data.gore;
		if( flag == null ) flag = true;
		butGore.setTitle(flag?Lang.YES:Lang.NO,null);
	}
	
		
	
	function getSect(str) {
		var f = Cs.getField(0xFFFFFF,8,-1,"nokia");
		f.text = str;
		f.width = f.textWidth+3;
		f.x = Std.int((Cs.mcw - f.width) * 0.5);
		box.addChild(f);
		return f;
	}
	
	
	override function updateDisplay() {
		super.updateDisplay();
		for( b in buts ) b.update();
	}
	


	override function kill() {
		butControl.kill();
		butGore.kill();
		super.kill();
		Game.me.pause =  null;
	}
	
//{
}








