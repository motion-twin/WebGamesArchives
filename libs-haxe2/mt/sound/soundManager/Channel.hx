package mt.sound.soundManager;
import mt.deepnight.Tweenie;

/**
 * ...
 */

class Channel
{

	public var sound 		: flash.media.Sound;//attached sound to this channel
	public var transform 	: flash.media.SoundTransform;
	public var id 			: Int;
	public var sounds 		: Hash<flash.media.Sound>;//ref to the sound library
	public var sm 			: SoundManager; //ref to the sound manager
	public var monoSound 	: Bool; //should play only one sound at the same time or not
	
	var backupedVolume : Float; //backuped volume for mute feature
	var isMute 		: Bool; //mute channel
	var channel 	: flash.media.SoundChannel;
	var tween 		: Tween;

	public function new(sm)
	{
		this.sm = sm;
		transform = new flash.media.SoundTransform();
		monoSound = true;
		isMute = false;
		setVolume(1);
		backupedVolume = 1;
	}
	
	public function play(?soundId:String = null, ?loops:Int = 0 , ?startTime:Int = 0) {
		//if (mute) return;
		
		//cut the previous sound
		if (channel != null && monoSound) {
			channel.stop();
		}
		
		if (soundId != null) {
			sound = sounds.get(soundId);
		}
		channel = sound.play(startTime, loops, transform);
		//channel.soundTransform = transform;
		//trace("play "+soundId+"@"+channel.soundTransform.volume);
		
		return this;
	}
	
	public function stop() {
		if (channel != null) {
			channel.stop();
		}
	}
	
	public function muteOn() {
		backupedVolume = transform.volume;
		setVolume(0);
		isMute = true;
	}
	
	public function muteOff() {
		isMute = false;
		setVolume(backupedVolume); //restore initial volume
	}
	
	public function fadeOut(?ms:Int=2000) {
		return setVolume(1).fadeTo(0, ms);
	}
	
	public function fadeIn(?ms:Int=2000) {
		return setVolume(0).fadeTo(1, ms);
	}
	
	public function fadeTo(volume:Float, ?ms:Int = 2000) {
		tween = SoundManager.t.create(transform, "volume", volume, TLinear, ms);
		var me = this;
		tween.onUpdate = function() {
			//reassign the transform each time
			if (me.channel != null) {
				me.channel.soundTransform = me.transform;
			}
			
		}
		return this;
	}
	
	public function setVolume(volume:Float) {
		if(tween!=null)
			SoundManager.t.delete(tween); //remove previous volume fade
		
		if(isMute) {
			transform.volume = 0;
		}else {
			transform.volume = volume*sm.volume; //also apply the main volume to this channel.
		}
		
		if (channel!=null) {
			channel.soundTransform = transform;
		}
		
		//trace("set volume channel#"+id+" : "+transform.volume+" ("+volume+"*"+sm.volume+")");
		return this;
	}
	
	
	
}