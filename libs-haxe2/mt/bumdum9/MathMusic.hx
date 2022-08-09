package mt.bumdum9;

import flash.media.Sound;
import flash.media.SoundChannel;
import flash.events.SampleDataEvent;

class MathMusic {//}
	
	public var sound:Sound;
	public var channel:SoundChannel;
	public var k:Int;
	public var func:Int->Int;
	
	public function new() {

		sound = new Sound();
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		
	}

	public function play(func) {
		this.func = func;
		k = 0;
		if (channel!=null) channel.stop();
		channel = sound.play();
	}	
	
	public function stop() {
		channel.stop();
	}
	
	function onSampleData(e:SampleDataEvent) {
		var t:Int, tt:Int, val:Float;
		
		tt = 0;
		for ( i in 0...8192  ) {
			
			t = Std.int(k * 4 / 44.1);
			tt = func(t);
			
			tt &= 0xff;
			val = tt / 0xff;
			e.data.writeFloat(val);
			
			k++;
		}
		
	}
		
//{
}


















