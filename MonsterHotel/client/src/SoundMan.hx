import mt.MLib;
import mt.flash.Sfx;
import mt.deepnight.Lib;

class SoundMan extends mt.Process {
	public static var ME : SoundMan;
	static inline var DEBUG = false;
	public var musicVol(null,set)		: Float;
	public var sfxVol(null,set)			: Float;
	public var ambiantVol(null,set)		: Float;
	public var generalVol(null,set)		: Float;

	var music				: Null<Sfx>;
	var ambiant				: Null<Sfx>;
	var radioLoops			: Bool;
	var currentStack		: Array<String>;
	var sessionStack		: Array<String>;
	var ambiantStack		: Array<{s:Sfx, v:Float}>;
	var streamedSfx			: Map<String,Sfx>;

	#if musicIncluded
	public static var MUSIC_BANK			= mt.flash.Sfx.importFromAssets("assets/music_ogg");
	#else
	var downloading			: Bool;
	var downloads			: Array<String>;
	#end

	public function new() {
		ME = this;

		super(Main.ME);

		Sfx.SHOW_PROGRESS_BARS = #if prod false #else true #end;

		name = "SoundMan";
		ambiantStack = [];
		currentStack = [];
		sessionStack = [];
		streamedSfx = new Map();
		#if mBase
		generalVol = 1;
		musicVol = 0.5;
		#else
		generalVol = 0.6;
		musicVol = 0.3;
		#end
		ambiantVol = 0;
		sfxVol = 1;
		radioLoops = false;

		#if !musicIncluded
		downloading = false;
		downloads = [
			"music_intro",
			"ambiant",
			"music_radio1",
			"music_radio2",
			"music_radio3",
		];

		for(id in downloads)
			streamedSfx[id] = Assets.SBANK._empty();
		#else
		streamedSfx["music_intro"] = MUSIC_BANK.music_intro();
		streamedSfx["ambiant"] = MUSIC_BANK.ambiant();
		streamedSfx["music_radio1"] = MUSIC_BANK.music_radio1();
		streamedSfx["music_radio2"] = MUSIC_BANK.music_radio2();
		streamedSfx["music_radio3"] = MUSIC_BANK.music_radio3();
		#end

		applySettings();
	}

	function set_generalVol(v) {
		v = MLib.fclamp(v,0,1);
		generalVol = v;
		Sfx.setGlobalVolume(v);
		return v;
	}

	function set_ambiantVol(v) {
		v = MLib.fclamp(v,0,1);
		ambiantVol = v;
		Sfx.setChannelVolume(2,v);
		return v;
	}

	function set_sfxVol(v) {
		v = MLib.fclamp(v,0,1);
		sfxVol = v;
		Sfx.setChannelVolume(0, v);
		return v;
	}

	function set_musicVol(v) {
		v = MLib.fclamp(v,0,1);
		musicVol = v;
		Sfx.setChannelVolume(1, v);
		return v;
	}



	public function startAmbiant() {
		if ( DEBUG ) trace("startAmbiant");
		stopAmbiant();
		ambiant = streamedSfx.get("ambiant").playLoopOnChannel(2);
		cd.set("ambSound", Const.seconds(4));
		ambiantVol = 0;
	}

	public function stopAmbiant() {
		if( ambiant==null )
			return;

		Sfx.clearChannelWithFadeOut(2, 2000);
		ambiant = null;
	}


	public function stopMusic(?immediate=false) {
		if( music==null )
			return;

		if( immediate )
			music.stop();
		else {
			music.stop(2000);
		}

		music = null;
	}

	function playMusic(id:String, loop:Bool) {
		if ( DEBUG ) trace("playMusic id:"+id);
		stopMusic();

		var s = streamedSfx.get(id);

		music = loop ? s.playLoopOnChannel(1) : s.playOnChannel(1);
		music.setVolume(0);
		music.fade(1,1000);

		if( !loop )
			music.onEndOnce( function() {
				stopMusic();
				cd.set("radio", Const.seconds(rnd(10,20)));
			});
	}

	public static function mute() Sfx.muteGlobal();
	public static function unmute() Sfx.unmuteGlobal();

	#if connected
	inline function musicEnabled() return Main.ME.settings.music;
	inline function sfxEnabled() return Main.ME.settings.sfx;
	#else
	inline function musicEnabled() return Main.ME.settings.music;
	//inline function musicEnabled() return false;
	inline function sfxEnabled() return Main.ME.settings.sfx;
	#end

	public function lowerMusic() {
		if( !isPlayingMusic() )
			return;

		music.fade(0.4, 800);
	}

	public function restoreMusic() {
		if( !isPlayingMusic() )
			return;

		music.fade(1, 2000);
	}


	public function spam(s:?Float->mt.flash.Sfx, vol:Float, n:Int, ms:Float) {
		createChildProcess(function(p) {
			if( !cd.hasSet("play", Const.seconds(ms/1000)) ) {
				s().play(vol);
				n--;
			}
			if( n<=0 )
				p.destroy();
		});
	}


	function isPlayingMusic() {
		return musicEnabled() && music!=null && music.isPlaying();
	}

	public function introMusic() {
		playMusic( "music_intro", false );
	}

	public function enableRadioLoops() {
		radioLoops = true;
		sessionStack = [ "music_radio1", "music_radio2", "music_radio3" ];
		sessionStack = Lib.shuffle(sessionStack, Std.random);
		sessionStack.push("music_intro");
		cd.set("radio", Const.seconds(rnd(6,12)));
	}

	public function disableRadioLoops() {
		radioLoops = false;
	}


	public function stopEverything() {
		stopAmbiant();
		stopMusic();
		Sfx.clearChannel(0);
		Sfx.clearChannel(1);
		Sfx.clearChannel(2);
	}


	override function onDispose() {
		super.onDispose();

		stopEverything();

		ambiantStack = null;
		currentStack = null;
		sessionStack = null;
		streamedSfx = null;

		if( ME==this )
			ME = null;
	}

	function applySettings() {
		if( musicEnabled() && Sfx.isChannelMuted(1) )	Sfx.unmuteChannel(1);
		if( !musicEnabled() && !Sfx.isChannelMuted(1) )	Sfx.muteChannel(1);

		if( sfxEnabled() && Sfx.isChannelMuted(0) )		{ Sfx.unmuteChannel(0); Sfx.unmuteChannel(2); }
		if( !sfxEnabled() && !Sfx.isChannelMuted(0) )	{ Sfx.muteChannel(0); Sfx.muteChannel(2); }
	}

	#if !musicIncluded
	function downloadNext() {
		#if !connected
		return;
		#else
		downloading = true;
		var id = downloads.shift();
		var base = Main.ME.hdata.musicUrl;
		if( base.charAt(base.length-1)!="/" )
			base+="/";
		var url = base + id + ".mp3";

		var s = streamedSfx.get(id);
		var wasPlaying = s.isPlaying();

		Sfx.download(s, url, function(_) {
			if( destroyed )
				return;
			downloading = false;
		}, function(e) {
			if( destroyed )
				return;
			downloading = false;
			streamedSfx.set(id, Assets.SBANK._empty());
		});

		if( wasPlaying ) {
			if( id.indexOf("music")>=0 )
				s.playOnChannel(s.getChannel());
			else
				s.playLoopOnChannel(s.getChannel());
		}
		#end
	}
	#end

	function updateAmbiant() {
		if( isPlayingMusic() && ambiantVol>=0.06 )
			ambiantVol-=0.001;

		if( !isPlayingMusic() && ambiantVol<0.5 )
			ambiantVol+=0.001;

		if( !cd.has("ambSound") ) {
			if( ambiantStack.length==0 ) {
				ambiantStack = [
					{s: Assets.SBANK.a_dog(), v:1 },
					{s: Assets.SBANK.a_dog(), v:0.6 },

					{s: Assets.SBANK.a_cat1(), v:1 },
					{s: Assets.SBANK.a_cat2(), v:1 },

					{s: Assets.SBANK.a_car1(), v:0.35 },
					{s: Assets.SBANK.a_car2(), v:0.35 },
					{s: Assets.SBANK.a_car3(), v:0.35 },
					{s: Assets.SBANK.a_car4(), v:0.35 },
					{s: Assets.SBANK.a_car5(), v:0.35 },
					{s: Assets.SBANK.a_horn4(), v:0.1 },

					{s: Assets.SBANK.a_wings(), v:1 },
					{s: Assets.SBANK.a_bird(), v:1 },
					{s: Assets.SBANK.a_howl1(), v:1 },
					{s: Assets.SBANK.a_howl2(), v:1 },
					{s: Assets.SBANK.a_howl3(), v:1 },
					{s: Assets.SBANK.a_howl4(), v:1 },
					{s: Assets.SBANK.a_howl1(), v:1 },
					{s: Assets.SBANK.a_howl2(), v:1 },
					{s: Assets.SBANK.a_howl3(), v:1 },
					{s: Assets.SBANK.a_howl4(), v:1 },
				];
				ambiantStack = Lib.shuffle(ambiantStack, Std.random);
			}
			var a = ambiantStack.pop();
			a.s.playOnChannel(2, 0.6*a.v*rnd(0.8, 1.1), rnd(-0.5, 0.5) );
			var d = MLib.fmax(2000, a.s.getSoundDuration());
			cd.set("ambSound", rnd(0.8, 2.5)*(Const.FPS*d/1000));
		}
	}

	override function update() {
		super.update();

		#if( connected && !musicIncluded )
		if( Main.ME.hdata!=null && !downloading && downloads.length>0 )
			downloadNext();
		#end

		Sfx.update();

		// Radio loops
		if( musicEnabled() && radioLoops && !isPlayingMusic() && !cd.has("radio") ) {
			if( currentStack.length==0 )
				currentStack = sessionStack.copy();
			playMusic( currentStack.shift(), false );
		}

		// Ambiant
		if( ambiant!=null )
			updateAmbiant();

		// Apply settings
		applySettings();
	}
}

