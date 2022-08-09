
class swapou2.Sounds {

	static var smanager = null;

	public static var MUSIC_MENU = "sound_menu";
	public static var MUSIC_CHALLENGE = "sound_game";
	public static var MUSIC_DUEL = "sound_game";

	public static var SWAP = "sound_swap";
	public static var COMBO = "sound_combo";
	public static var POP1 = "sound_pop1";
	public static var POP2 = "sound_pop2";
	public static var SHOW_SCORE = "sound_show_score";
	public static var MENU_CLICK = "sound_menu_click";
	public static var MENU_ACTIVATE = "sound_menu_activate";

	public static var MUSIC_VOLUME = 100;
	public static var channel_music = true;

	static var music_enabled = true;
	static var sound_enabled = true;

	static function init( mc ) {
		smanager = new asml.SoundManager(mc,50000);
		smanager.setVolume(1,MUSIC_VOLUME);
		smanager.setVolume(2,MUSIC_VOLUME);
	}

	static function destroy() {
		smanager.destroy();
	}

	static function main() {
		smanager.main();
	}

	static function play(name) {
		smanager.play(name);
	}

	static function playMusic(name) {
		if( !smanager.isPlaying(name,channel_music?1:2) ) {
			channel_music = !channel_music;
			smanager.setVolume(channel_music?1:2,0);
			smanager.fade(channel_music?2:1,channel_music?1:2,1);
			smanager.loop(name,channel_music?1:2);
		}
	}

	static function stopMusic() {
		smanager.stop(1);
		smanager.stop(2);
	}

	static function soundEnabled() {
		return sound_enabled;
	}

	static function musicEnabled() {
		return music_enabled;
	}

	static function enableSoundMusic(sflag,mflag) {
		sound_enabled = !sflag;
		music_enabled = !mflag;
		toggleMusic();
		toggleSound();
	}

	static function toggleMusic() {
		music_enabled = !music_enabled;
		smanager.enable(1,music_enabled);
		smanager.enable(2,music_enabled);
	}

	static function toggleSound() {
		sound_enabled = !sound_enabled;
		smanager.enable(0,sound_enabled);
	}

}