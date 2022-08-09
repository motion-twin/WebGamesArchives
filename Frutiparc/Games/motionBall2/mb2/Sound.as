
class mb2.Sound {

	public static var BALL_CHANGE = "bonus_blip2";

	public static var MENU_ENTER = "menu_enter";
	public static var MENU_SELECT = "menu_select";

	public static var BOSS_EYE = "eye";
	public static var BOSS_JUMP = "sound_boss_saut";
	public static var BOSS_NEW_EYE = "eye_new";
	public static var POULPE = "sound_poulpe";
	public static var CASSE = "sound_casse";

	public static var WALL_HIT = "wall_bump";
	public static var BUMPER_NORMAL = "bumper_metal";
	public static var BUMPER_TIME = "wall_bump";
	public static var BUMPER_DEATH = "sound_bdeath";
	public static var BUMPER_DEATH_PROTECT = "bumper_metal";
	public static var BUMPER_MAGNET = "bumper_metal";
	public static var BUMPER_SHADOW = "bumper_metal";
	public static var GREEN_BLOCK_HIT = "wall_bump";
	public static var INTER_BLOCK_HIT = "wall_bump";
	public static var INTERUPT_HIT = "bumper_metal";
	public static var ZAPPER_HIT = "bumper_metal";
	public static var ZAPPER_ACTIVATE = "sound_zapper";
	public static var GREEN_BLOCK_DESTROY = "wall_bump";

	public static var GET_ITEM = "object_found";
	public static var GET_BALL = "object_found";
	public static var GET_RED = "bonus_blip";
	public static var GET_BLUE = "bonus_blip3";
	public static var GRELOT = "sound_grelot";
	public static var OPEN_DOOR = "door_open";
	public static var GAME_OVER = "game_over";

	public static var POWER_WIND = "wind";
	public static var POWER_FIRE = "sound_casse";
	public static var POWER_WATER = "water";
	public static var POWER_EARTH = "earth";

	public static var SERPENT_HIT = "touched";
	public static var SERPENT_COLLIDE = "wall_bump";
	public static var TB_HIT = "touched"
	public static var TB_HIDE = "hide";

	public static var MUSIC_MENU = "menu";
	public static var MUSIC_INTRO = "menu";
	public static var MUSIC_BOSS = "boss_loop";
	public static var MUSIC_GAME_OVER = "";

	public static var MIX_VOLUME = 20;
	public static var MUSIC_VOLUME = 20;
	public static var MUSIC_NLOOPS = 5;

	static var smanager = null;
	static var channel_music;
	static var time;
	static var mix_nb;
	static var last_time;
	static var last_sound;

	static function init( mc ) {
		smanager = new asml.SoundManager(mc,50000);
		smanager.setVolume(1,MUSIC_VOLUME);
		smanager.setVolume(2,MUSIC_VOLUME);
		time = 0;
		mix_nb = undefined;
		last_time = undefined;
		last_sound = undefined;
		channel_music = true;
	}

	static function destroy() {
		smanager.destroy();
	}

	static function main() {
		time += Std.deltaT;
		smanager.main();
	}

	static function play(name) {
		if( name != last_sound || time != last_time ) {
			smanager.play(name);
			last_sound = name;
			last_time = time;
		}
	}

	static function playMusic(name) {
		stopMix();
		if( !smanager.isPlaying(name,channel_music?1:2) ) {
			channel_music = !channel_music;
			smanager.setVolume(channel_music?1:2,0);
			smanager.fade(channel_music?2:1,channel_music?1:2,1);
			smanager.loop(name,channel_music?1:2);
		}
	}

	static function startMix() {
		var i;
		stopMix();
		for(i=0;i<MUSIC_NLOOPS;i++)
			smanager.setVolume(i+3,0);
		smanager.setVolume(channel_music?1:2,MIX_VOLUME);
		smanager.fade(channel_music?1:2,3);
		for(i=0;i<MUSIC_NLOOPS;i++)
			smanager.loop("loop$"+(i+1),i+3);
		mix_nb = 0;
	}

	static function nextMix() {
		if( mix_nb < 4 ) {
			smanager.setVolume(mix_nb+3,MIX_VOLUME+(mix_nb+1)*10);
			smanager.fade(mix_nb+3,mix_nb+4);
			mix_nb++;
		}
	}

	static function fadeMix(name) {
		channel_music = true;
		smanager.setVolume(mix_nb+3,MUSIC_VOLUME);
		smanager.setVolume(1,0);
		smanager.fade(mix_nb+3,1,2.0);
		smanager.loop(name,1);
	}

	static function stopMix() {
		var i;
		for(i=0;i<4;i++)
			smanager.stop(3+i);
	}
}