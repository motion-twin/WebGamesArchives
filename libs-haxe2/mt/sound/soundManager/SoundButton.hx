package mt.sound.soundManager;

/**
 * Sound Button manager
 *
 * Use this with a movieclip called gfx.SoundButton() with 3 frames.
 * frame 1 : sound on,
 * frame 2 : only fx / low volume
 * frame 3 : sound off
 *
 * USAGE :
	soundButton = new mt.sound.soundManager.SoundButton(App.sm, "sq2volume");
	soundButton.onMiddleOn = function() {
			App.sm.channel(1).setVolume(0);
	}
	soundButton.onMiddleOff = function() {
			App.sm.channel(1).setVolume(1);
	}
	soundButton.init();
	dm.add(soundButton.mc , 1);
 *
 */

class SoundButton
{
	public var mc 	: gfx.SoundButton;
	
	var sm 			: SoundManager; //ref to the game sound manager
	public var so 			: flash.net.SharedObject; //shared object to save button state
	var name 		: String;
	var state 		: Int; //1 on, 2 middle, 3 off
	
	//callbacks
	public var onMiddleOn : Void->Void; //Middle state to implement. i.e : only FX or low volume.
	public var onMiddleOff : Void->Void;
	
	public function new(soundmanager,name)
	{
		sm = soundmanager;
		mc = new gfx.SoundButton();
		mc.stop();
		mc.addEventListener(flash.events.MouseEvent.CLICK, toggle);
		this.name = name;
	
	}
	
	/**
	 * init from shared object
	 */
	public function init() {
		
		//haxe.Timer.delay(function(){
			
		so = flash.net.SharedObject.getLocal("sounManager"+name);
		if (so.data.state != null ) {
			switch(so.data.state) {
				case 1:
					on();
				case 2 :
					middle();
				case 3 :
					off();
			}
		}else {
			on();
		}
		//},1000);
		
	}
	
	public function toggle(_) {
		switch(so.data.state) {
			case 1:
				middle();
			case 2 :
				off();
			case 3 :
				on();
		}
	}
	
	public function on() {
		
		so.data.state = 1;
		sm.setVolume(1);
		mc.gotoAndStop(1);
		onMiddleOff();
		
	}
	
	public function off() {
		
		so.data.state = 3;
		sm.setVolume(0);
		mc.gotoAndStop(3);
		onMiddleOff();
	}
	
	public function middle() {
		//trace("off");
		so.data.state = 2;
		onMiddleOn();
		mc.gotoAndStop(2);
	}
	
	public function hide() { mc.visible = false; }
	public function show() { mc.visible = true;  }
	
}


