package mt.sound.soundManager;
import mt.deepnight.Tweenie;

/**
 * SoundManager
 *
 * dependencies :
 *  - mt.deepnight.Tweenie
 *
 */

class SoundManager
{

	// channel ids (just a proposal)
	static public var CHANNEL_BG1 = 0;
	static public var CHANNEL_BG2 = 1;
	static public var CHANNEL_BG3 = 2;
	static public var CHANNEL_GAME1 = 3;
	static public var CHANNEL_GAME2 = 4;
	static public var CHANNEL_GAME3 = 5;
	static public var CHANNEL_EVENTS1 = 6;
	static public var CHANNEL_EVENTS2 = 7;
	static public var CHANNEL_EVENTS3 = 8;
	
	public var channels : Array<Channel>;
	public var sounds : Hash<flash.media.Sound>;
	//var linkage : Array<String> ; //remember wich sound is attached on wich channel
	public static var t : Tweenie;
	public var volume : Float; //master volume
	
	
	public function new() {
		sounds = new Hash<flash.media.Sound>();
		channels = new Array<Channel>();
		
		setVolume(1);
		
		//init tweener
		t = new Tweenie();
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
	}
	
	
	/**
	 * get/auto-add channel
	 */
	public function channel(channelId:Int) : Channel {
		if (channels[channelId] == null) {
			channels[channelId] = new Channel(this);
			channels[channelId].sounds = sounds;
			channels[channelId].id = channelId;
			channels[channelId].transform.volume = volume; //transmit the master volume as default
		}
		return channels[channelId];
	}
	
	
	function update(_) {
		//trace(  channel(1).transform.volume );
		t.update();
	}
	
	public function setVolume(volume:Float) {
		
		/*for (c in channels) {
			if(c!=null){
				c.setVolume(volume);
			}
		}*/
		var st = new flash.media.SoundTransform();
		st.volume = this.volume = volume;
		flash.media.SoundMixer.soundTransform = st;
		//trace("global volume : "+flash.media.SoundMixer.soundTransform.volume);
		
	}
	
	
	
}