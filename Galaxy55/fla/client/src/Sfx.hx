class Sfx {
	static var ENABLE = false;
	public static var LIB = mt.data.Sounds.directory("sfx");
	public static var VOLUME = 0.3;
	
	public static function play(snd:flash.media.Sound, ?vol=1.0, ?repeat=1) {
		if( !ENABLE )
			return new flash.media.SoundChannel();
		var chan = snd.play(0, repeat);
		if( chan != null )
			chan.soundTransform = new flash.media.SoundTransform(vol*VOLUME);
		return chan;
	}
}