import mb2.Sound;

class mb2.Prefs {

	public static var challenge_mode_enabled = true;
	public static var classic_mode_enabled = false;
	public static var courses = [];
	public static var dungeons = [];

	public static var sound_enabled = true;
	public static var music_enabled = true;


	static function toggleMusic() {
		music_enabled = !music_enabled;
		var i;
		for(i=1;i<Sound.MUSIC_NLOOPS+3;i++)
			Sound.smanager.enable(i,music_enabled);
	}

	static function toggleSounds() {
		sound_enabled = !sound_enabled;
		Sound.smanager.enable(0,sound_enabled);
	}

}