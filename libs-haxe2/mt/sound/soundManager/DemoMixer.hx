package mt.sound.soundManager;

import flash.display.MovieClip;

/**
 * ...
 */

 class DemoMixer
{
	
	public var mc : flash.display.MovieClip;
	public var sm : SoundManager;
	
	public function new()
	{
		mc = new MovieClip();
		sm = new SoundManager();
		sm.sounds.set("applause", new sound.Applause());
		sm.sounds.set("theme", new sound.Theme());
		
		//bg
		var square = new MovieClip();
		square.graphics.lineStyle(3,0x444444);
		square.graphics.beginFill(0xAAAAAA);
		square.graphics.drawRect(0,0,300,100);
		square.graphics.endFill();
		square.x = 0;
		square.y = 0;
		mc.addChild(square);
		
		//channel 1
		var volume1 = 1.0;
		var bt = getButton("theme");
		bt.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
			sm.channel(1).play("theme");
		} );
		bt.x = 40;
		bt.y = 20;
		mc.addChild(bt);
		var plus = getUpArrow();
		plus.x = 40;
		plus.y = 40;
		plus.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
			volume1+=0.1;
			sm.channel(1).setVolume(volume1);
		} );
		mc.addChild(plus);
		var moins = getDownArrow();
		moins.x = 40;
		moins.y = 60;
		moins.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
			volume1-=0.1;
			sm.channel(1).setVolume(volume1);
		} );
		mc.addChild(moins);
		
		//main volume
		var mainVolume = 1.0;
		var soundButton = new SoundButton(sm, "volume");
		soundButton.onMiddleOn = function() {
				trace("onMiddleOn");
				sm.channel(1).setVolume(0);
		}
		soundButton.onMiddleOff = function() {
				trace("onMiddleOff");
				sm.channel(1).setVolume(1);
		}
		soundButton.init();
		soundButton.mc.x = 20;
		soundButton.mc.y = 20;
		mc.addChild(soundButton.mc);
		
		var plus = getUpArrow();
		plus.x = 20;
		plus.y = 40;
		plus.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
			mainVolume+=0.1;
			sm.setVolume(mainVolume);
		} );
		mc.addChild(plus);
		var moins = getDownArrow();
		moins.x = 20;
		moins.y = 60;
		moins.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
			mainVolume-=0.1;
			sm.setVolume(mainVolume);
		} );
		mc.addChild(moins);
		
		
	}
	
	public function getUpArrow() {
		var fleche = new MovieClip();
		fleche.graphics.beginFill(0xFFFFFF);
		fleche.graphics.lineStyle(1, 0x000000);
		fleche.graphics.moveTo( 0, 0);
		fleche.graphics.lineTo( 10, 10);
		fleche.graphics.lineTo( -10, 10);
		fleche.graphics.lineTo( 0, 0);
		fleche.graphics.endFill();
		return fleche;
	}
	
	public function getDownArrow() {
		var fleche = new MovieClip();
		fleche.graphics.beginFill(0xFFFFFF);
		fleche.graphics.lineStyle(1, 0x000000);
		fleche.graphics.moveTo( 0, 0);
		fleche.graphics.lineTo( 10, -10);
		fleche.graphics.lineTo( -10, -10);
		fleche.graphics.lineTo( 0, 0);
		fleche.graphics.endFill();
		return fleche;
	}
	
	public function getButton(text:String) {
		var mc = new MovieClip();
		
		var width = 50;
		var bt = new flash.display.Sprite();
		bt.graphics.beginFill(0x333333);
		bt.graphics.drawRoundRect(0, 0, width,20, 10, 10);
		bt.graphics.endFill();
		mc.addChild(bt);
		
		var btField = new flash.text.TextField();
		btField.text = text;
		
		btField.width = width;
        btField.selectable = false;
        var tf = new flash.text.TextFormat();
		tf.color = 0xFFFFFF;
		tf.font = "Arial";
		tf.size = 10;
		tf.align = flash.text.TextFormatAlign.CENTER;
		btField.setTextFormat(tf);
		mc.addChild(btField);
		
		
		return mc;

	}
	
}

