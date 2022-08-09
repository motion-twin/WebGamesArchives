import GameData._ArtefactId ;
import GameData._GameData ;
import anim.Transition ;



typedef Sfx = {
	id		: String,
	url		: String,
	data		: flash.Sound,
	vol		: Float,
	isPlaying	: Bool
}



class SoundManager {
	
	
	static public var MUSIC_VOL = 75.0 ;
	static public var SFX_HIGH_VOL = 80.0 ;
	static public var SFX_MED_VOL = 65.0 ;
	static public var SFX_LESS_VOL = 50.0 ;

	static public var LOAD_URL = "/sfx/" ;
	static public var LOAD_URL_MUSIC = "/sfx/music/" ;
	
	static public var MODE_ONDEMAND = [{mode : "IceAttack", sounds : ["congelation"]},
								{mode : "Wind", sounds : ["vent"]},
								{mode : "Dig", sounds : ["dynamite"]},
								{mode : "Mission", sounds : ["protoplop", "inversion"]}
								] ;
	
	var mc : flash.MovieClip ;
	var dm : mt.DepthManager ;
	var haveMusic : Bool ;
	var haveSfx : Bool ;
	var userVol : Int ;
	var pause : Bool ;
	
	var sfxs : Hash<Sfx> ;
	var lastRotate : Int ;
	var lastTransmut: Int ;
	var toLoad : Hash<Int> ;
								
	var toFadeIn : Array<{s : Sfx, timer : Float, to : Float}> ;
	var toFadeOut : Array<{s : Sfx, timer : Float}> ;
	var toWait : Array<{f : Void -> Void, wait : Float}> ;
	
	var loadInitDone : Bool ;
	var musicLoad : Bool ;
	var tinyVolumeOpened : Bool ;
	var isDragging : Bool ;
	var dragPress : Bool ;
	
	var music : Sfx ;
	var falseMusic : Sfx ;
	

	public function new() {
		sfxs = new Hash() ;
		toFadeIn = new Array() ;
		toFadeOut = new Array() ;
		toWait = new Array() ;
		lastRotate = 3 ;
		lastTransmut = 0 ;
		pause = false ;
		loadInitDone = false ;
		musicLoad = false ;
		tinyVolumeOpened = false ;
		isDragging = false ;
		dragPress = false ;
		
		haveSfx = true ;
		haveMusic = true ;
		userVol = 35 ;
		
		mc = Game.me.mdm.empty(Const.DP_SOUND) ;
		dm = new mt.DepthManager(mc) ;
		
		init() ;
	}
	
	public function setUserConfig(sc : String) {
		
		if (sc == null)
			return ;
		
		var tc = sc.split(";") ;
		haveMusic = Std.parseInt(tc[0]) == 1 ;
		haveSfx = Std.parseInt(tc[1]) == 1 ;
		userVol = Std.int(Math.max(0, Math.min(Std.parseInt(tc[2]), 50))) ;
		
		if (userVol == 0)  {
			haveSfx = false ;
			haveMusic = false ;
		}
		
		setVolIcon(Game.me.gui._vol.smc) ;
	}
	
	function getNewMc() : flash.MovieClip {
		var m = dm.empty(1) ;		
		return m ;
		
	}
	
	public function initMusic(id : String) {
		music = {
			id		: id, 
			url		: Game.me.loader.dataDomain + LOAD_URL_MUSIC + id + ".mp3",
			data		: new flash.Sound(getNewMc()),
			vol		: MUSIC_VOL,
			isPlaying 	: true
		};
		
		falseMusic = {
			id		: id, 
			url		: null,
			data		: new flash.Sound(getNewMc()),
			vol		: MUSIC_VOL,
			isPlaying 	: true
		};
		falseMusic.data.attachSound("falseMusic") ;
		falseMusic.data.setVolume(MUSIC_VOL) ;
		
		if (!haveMusic)
			return ;
	
		music.data.loadSound(music.url, true) ;
		music.data.setVolume(0) ;
		musicLoad = true ;
		music.data.stop() ;
		
	}
	
	
	public function startMusic() {
		var me = this ;
		if (music == null || !haveMusic ||pause) {
			if (music != null)
				music.data.stop() ;
			falseMusic.data.onSoundComplete = function() { me.falseMusic.data.start() ;} ;
			falseMusic.data.start(0, 1000) ;
			
			return ;
		}
		
		if (!musicLoad)
			music.data.loadSound(music.url, true) ;
		music.data.onSoundComplete = function() { me.music.data.setVolume(me.music.vol * me.uv()) ; me.music.data.start() ;} ;
		music.data.setVolume(0.0) ;
		toFadeIn.push({s : music, timer : 0.0, to : MUSIC_VOL}) ;
		music.data.start() ;
		
	}
	
	
	function init() {
		var volMed = SFX_MED_VOL ;
		var volSmall = SFX_LESS_VOL ;
		
		addInnerSfx("clic", volMed) ;
		addInnerSfx("activation", volMed) ;
		addInnerSfx("tigidy1", volMed) ;
		addInnerSfx("tigidy2", volMed) ;
		addInnerSfx("tigidy3", volMed, "tigidy1") ;
		addInnerSfx("tigidy4", volMed, "tigidy2") ;
		addInnerSfx("tigidy5", volMed, "tigidy1") ;
		addInnerSfx("tigidy6", volMed, "tigidy2") ;
		addInnerSfx("tigidy7", volMed, "tigidy1") ;
		addInnerSfx("tigidy8", volMed, "tigidy2") ;
		addInnerSfx("tigidy9", volMed, "tigidy1") ;
		addInnerSfx("tigidy10", volMed, "tigidy2") ;
		addInnerSfx("rotation1", volMed) ;
		addInnerSfx("rotation2", volMed) ;
		addInnerSfx("rotation3", volMed) ;
		addInnerSfx("rotation4", volMed) ;
		addInnerSfx("chute", volMed) ;
		addInnerSfx("chute_choc", volMed) ;
		addInnerSfx("transmutation_destructrice", volSmall) ;
		addInnerSfx("transmutation_start", volSmall) ;
		addInnerSfx("transmutation_end1", volSmall) ;
		addInnerSfx("transmutation_end2", volSmall) ;
		addInnerSfx("transmutation_end3", volSmall) ;
		addInnerSfx("transmutation_end4", volSmall) ;
		
		
		toLoad = new Hash() ;
		toLoad.set("interface_in", 1) ;
		toLoad.set("interface_out", 1) ;
		toLoad.set("interface_endgame", 1) ;
		toLoad.set("shake", 1) ;
		toLoad.set("wombat_dent2", 1) ;
	}
	
	
	function addInnerSfx(id : String, ?vol = 70.0, ?sid : String) {
		var s = sfxs.get(id) ;
		if (s != null)
			return ;
		
		var fs = new flash.Sound(getNewMc()) ;
		fs.attachSound(if (sid == null) id else sid) ; 
		fs.setVolume(vol * uv()) ;
		//trace("init : " + id + " > " + fs.getVolume()) ;
		
		s = {
			id		: id, 
			url		: null,
			data		: fs,
			vol		: Math.max(0, Math.min(100, vol)),
			isPlaying 	: false,
		};
			
		addSound(id, s) ;
	}
	
	
	function addOuterSfx(id : String, ?vol : Float, ?sid : String) {
		if (vol == null)
			vol = SFX_MED_VOL ;
		
		if (id == "dynamite")
			vol = SFX_HIGH_VOL ;
		
		var s = sfxs.get(id) ;
		if (s != null)
			return ;
		
		var url = Game.me.loader.dataDomain + LOAD_URL + (if (sid != null) sid else id) + ".mp3" ;
		var fs = new flash.Sound(getNewMc()) ;
		fs.setVolume(vol * uv()) ;
		
		s = {
			id		: id, 
			url		: null,
			data		: fs,
			vol		: Math.max(0, Math.min(100, vol)),
			isPlaying 	: false,
		};
		
		var me = this ;
		fs.onLoad = function(success) { if (success) me.addSound(id, s) else { Game.me.traceError("fail on load : " + id) ;} } ;
		fs.loadSound(url, false) ;
	}
	
	
	function addSound(id : String, data : Sfx) {
		sfxs.set(id, data) ;
	}
	
	
	
	public function initOnDemand(data : _GameData) {
		initMusic(data._music) ;
		
		for (m in MODE_ONDEMAND) {
			if (data._mode != m.mode)
				continue ;
			
			for (s in m.sounds)
				addToLoad(s) ;
		}
		
		
		for (o in data._artefacts) {
			var os = getOnDemandObject(o._id) ;
			if (os == null)
				continue ;
			for (s in os)
				addToLoad(s) ;
		}
			
		if (data._userobjects != null) {
			for (a in data._userobjects) {
				var os = getOnDemandObject(a) ;
				if (os == null)
					continue ;
				for (s in os)
					addToLoad(s) ;
			}
			
		}
		
		if (haveSfx) 
			startLoadingOnDemand() ;
	}
	
	
	public function startLoadingOnDemand() {		
		for (s in toLoad.keys()) {
			addOuterSfx(s) ;
			if (s == "congelation")
				addOuterSfx(s + "2", null, s) ;
		}
		
		loadInitDone = true ;
	}
	
	
	function addToLoad(sid : String) {
		var s = toLoad.get(sid) ;
		if (s != null)
			return ;
		toLoad.set(sid, 1) ;
	}
	
	
	function uv() {
		return userVol * 2 / 100 ;
	}
	
	public function update() {
		var speed = 0.01 ;
				
		for (w in toWait.copy()) {
			w.wait = Math.max(w.wait - mt.Timer.tmod, 0.0) ;
			
			if (w.wait == 0.0) {
				w.f() ;
				toWait.remove(w) ;
			}
		}
		
		for (f in toFadeIn.copy()) {
			if (!f.s.isPlaying) {
				toFadeIn.remove(f) ;
				continue ;
			}
				
			f.timer = Math.min(f.timer + speed, 1.0) ;
			var delta = anim.Anim.getValue(Quint(1), f.timer) ;
			
			f.s.data.setVolume(delta * f.to * uv()) ;
			if (f.timer == 1.0)
				toFadeIn.remove(f) ;
		}
		
		
		for (f in toFadeOut.copy()) {
			if (!f.s.isPlaying) {
				toFadeOut.remove(f) ;
				continue ;
			}
				
			f.timer = Math.min(f.timer +  speed, 1.0) ;
			var delta = anim.Anim.getValue(Quint(-1), f.timer) ;
			//trace(f.timer + " # " + Std.string(f.s.vol * (1.0 - delta))) ;

			f.s.data.setVolume(f.s.vol * (1.0 - delta) * uv()) ;
			if (f.timer == 1.0) {
				f.s.data.stop() ;
				f.s.isPlaying = false ;
				toFadeOut.remove(f) ;
			}
		}
		
	}
	
	
	
	public function play(id, ?repeat = false, ?offset = 0.0, ?byFade = false, ?wait = 0.0) {
		if (!haveSfx || pause)
			return ;
		var s = sfxs.get(id) ;
		if (s == null) {
			Game.me.traceError("sound requested not found : " + id) ;
			return ;
		}
		if (s.isPlaying) {
			return ;
		}
		
		//if (s.data.getVolume() == 0.0) {
		s.data.setVolume(s.vol * uv()) ;
		//}
		
		//Game.me.traceError("play " + id + " # " + s.data.getVolume() + " ## " + music.data.getVolume()) ;
		s.isPlaying = true ;
		//trace(id + " # " + s.data.getVolume()) ;
		s.data.onSoundComplete  =function() {s.isPlaying = false ; } ;
		if (byFade) {
			s.data.setVolume(0.0) ;
			toFadeIn.push({s : s, timer : 0.0, to : s.vol}) ;
		} 
		
		var rep = if (repeat) 1000 else 1 ;
		
		if (wait > 0.0)
			toWait.push({ f : callback(s.data.start, offset, rep), wait : wait}) ;
		else
			s.data.start(offset, rep) ;
	}
	
	
	public function isPlaying(id : String) : Bool {
		if (!haveSfx || pause)
			return false ;
		var s = sfxs.get(id) ;
		if (s == null) {
			return false ;
		}
		return s.isPlaying ;
	}
	
	public function stopMusic(?byFade = false) {
		if (!haveMusic)
			return ;
		if (!byFade) {
			music.data.stop() ;
			music.isPlaying = false ;
		} else
			fadeOut(music) ;
	}
	
	
	public function stop(id : String, ?byFade = false) {
		var s = sfxs.get(id) ;
		if (s == null) {
			Game.me.traceError("sound requested not found : " + id) ;
			return ;
		}
		if (!s.isPlaying)
			return ;
		
		if (!byFade) {
			s.data.stop() ;
			s.isPlaying = false ;
		} else
			fadeOut(s) ;
	}
	
	
	public function fadeOut(s : Sfx) {
		if (Lambda.exists(toFadeOut, function(x) {return x.s == s ;}))
			return ;
		
		toFadeOut.push({s : s, timer : 0.0}) ;
		
		
	}
	
	public function playRotate() {
		if (!haveSfx || pause)
			return ;
		
		lastRotate = (lastRotate + 1) % 4 ;
		
		var id = "rotation" + Std.string(lastRotate + 1) ;
		play(id) ;
		
	}
	
	
	public function playTransmutEnd() {
		if (!haveSfx || pause)
			return ;
		
		var comb = Game.me.stage.comboCount ;
		lastTransmut = Std.int(Math.min(comb + 1, 4)) ;
		//trace(lastTransmut) ;
		
		play("transmutation_end" + lastTransmut) ;
	}
	
	
	
	public static function getOnDemandObject(o : _ArtefactId) : Array<String> {
		
		if (Const.FL_DEBUG)
			return ["special_loop", "special_start", "dynamite", "protoplop", "inversion", "inversion_chorus", "wombat_dent1", "wombat_dent2", "wombat_loop", "chute_accentue", "arcelectrique", "congelation", "vent"] ;
		
		switch (o) {
			case _Elt(e) : return null ;
			// artefacts 
			case _Alchimoth : return ["wombat_dent2"] ;
			case _Destroyer(e) : return ["wombat_dent2"] ; 
			case _Dynamit(v) : return ["dynamite"] ;
			case _Protoplop(level) : return ["protoplop"] ;
			case _PearGrain(level) : if (level == 0)
									return  ["inversion"] ;
								else 
									return  ["inversion_chorus"] ;
			case _Jeseleet(level) : return ["special_loop", "special_start"] ;
			case _Dalton : return ["special_loop", "special_start"] ;
			case _Wombat : return ["wombat_dent1", "wombat_dent2", "wombat_loop"] ;
			case _MentorHand : return ["wombat_dent1"] ;
			case _Patchinko : return null ;
			case _RazKroll : return null ;
			case _Delorean(level) : return ["special_loop", "special_start"] ;
			case _Dollyxir(level) : return ["special_loop", "special_start"] ;
			case _Detartrage : return ["chute_accentue"] ;
				
			case _Teleport : return ["special_loop", "special_start", "wombat_dent1"] ;
			case _Tejerkatum : return ["special_loop", "special_start"] ;
			case _PolarBomb : return ["arcelectrique"] ;
			case _Pistonide : return null ;
			case _Grenade(level) : return ["dynamite"] ;
			case _Slide(level) : return ["wombat_dent2"] ;
			case _Skater : return ["wombat_dent2", "protoplop"] ;
				
			//auto falls 
			case _Block(level),_CountBlock(level) : return null ;
			case _Neutral : return null ;
			case _Catz : return null ;
			case _Pumpkin(id) : return null ;
			case _NowelBall : return null ;
			case _Empty : return null ;
			case _Surprise(level) : return null ;
				
			case _Pa, _Stamp, _Unknown, _Joker, _GodFather, _SnowBall, _Gift, _Choco : return null ;
			case _QuestObj(id) : return null ;
			case _DigReward(o) : return null ;
			
			case _Elts(e, p) : return null ;
			case _Sct(sid) : return null ;
		}
	}
	
	
	//############## SWITCHES
	
	public function switchSfx(?updateMc = false) {
		haveSfx = !haveSfx ;
		
		if (!haveSfx) {
			for (s in sfxs) {
				if (!s.isPlaying) 
					continue ;
					
				s.data.stop() ;
				s.isPlaying = false ;
			}
		} else {
			if (!loadInitDone)
				startLoadingOnDemand() ;
		}
		
		if (!updateMc) 
			return ;
		var mc = Game.me.pausePanel ;
		if (mc == null)
			return ;
		
		mc._sfx.smc.gotoAndStop(if (haveSfx) 1 else 4) ;
		mc._sfx.gotoAndStop(1) ;
		if (haveSfx)
			play("clic") ;
	}
	
	
	public function switchMusic(?updateMc = false) {
		haveMusic = !haveMusic ;
		
		startMusic() ;
		
		if (!updateMc) 
			return ;
		var mc = Game.me.pausePanel ;
		if (mc == null)
			return ;
		
		mc._music.smc.gotoAndStop(if (haveMusic) 1 else 4) ;
		mc._music.gotoAndStop(1) ;
		if (haveMusic)
			play("clic") ;
	}
	
	
	public function setTinyVolume(?forcedState : Bool) {
		if (tinyVolumeOpened || (forcedState != null && !forcedState)) {
			Game.me.gui._volMc._visible = false ;
			isDragging = false ;
			dragPress = false ;
			
			tinyVolumeOpened = false ;
			Game.me.gui._volMc.onRelease = null ;
			Game.me.gui._volMc.onPress = null ;
			Game.me.gui._volMc.onReleaseOutside = null ;
			Game.me.gui._volMc.onMouseMove = null ;
			
			
		} else if ((!tinyVolumeOpened || (forcedState != null && forcedState)) && !Game.me.pause) {
			Game.me.gui._volMc._cursor._x = userVol ;
			Game.me.gui._volMc._visible = true ;
			
			
			tinyVolumeOpened = true ;
			Game.me.gui._volMc.onRelease = setClickVolume ;
			Game.me.gui._volMc.onPress = callback(function(s : SoundManager) {s.dragPress = true ;}, this) ;
			Game.me.gui._volMc.onReleaseOutside = Game.me.gui._volMc.onRelease ;
			Game.me.gui._volMc.onMouseMove = setDragVolume ;
		}
	}
	
	
	public function setClickVolume() {
		dragPress = false ;
		adjustTinyVol() ;
		
		if (isDragging)
			setTinyVolume(false) ;
	}
	
	
	public function setDragVolume() {
		if (!isDragging) {
			if (dragPress)
				isDragging = true ;
			else 
				return ;
		}
		
		adjustTinyVol() ;
	}
	
	
	function adjustTinyVol() {
		var mc = Game.me.gui._volMc ;
		var x = Std.int(Math.max(0, Math.min(mc._xmouse, 50)))  ;
		mc._cursor._x = x ;
		var old = userVol ;
		userVol = x ;
		 if (haveMusic)
			 music.data.setVolume(music.vol * uv()) ;
		setVolIcon(Game.me.gui._vol.smc) ;
		 
		if (old == 0 && userVol >0 && !haveMusic && !haveSfx) {
			 switchSfx() ;
			 switchMusic() ;
		 }
	}
	
	
	public function setPauseClickVolume() {
		dragPress = false ;
		adjustPauseVol() ;
		
		isDragging = false ;
	}
	
	
	public function setPauseDragVolume() {
		if (!isDragging) {
			if (dragPress)
				isDragging = true ;
			else 
				return ;
		}
		
		adjustPauseVol() ;
	}
	
	function adjustPauseVol() {
		var mc = Game.me.pausePanel._volMc ;
		if (mc == null) 
			return ;
		
		var x = Std.int(Math.max(0, Math.min(mc._xmouse, 50)))  ;
		mc._cursor._x = x ;
		var old = userVol ;
		userVol = x ;
		 if (haveMusic)
			 music.data.setVolume(music.vol * uv()) ;
		setVolIcon(Game.me.pausePanel._vol) ;
		setVolIcon(Game.me.gui._vol.smc) ;
		 
		 if (old == 0 && userVol >0 && !haveMusic && !haveSfx) {
			 switchSfx() ;
			 switchMusic() ;
		 }
	}
	
	public function setVolIcon(icon : flash.MovieClip) {
		if (userVol == 0)
			icon.gotoAndStop(4) ;
		else if (userVol <= 16)
			icon.gotoAndStop(3) ;
		else if (userVol <= 32)
			icon.gotoAndStop(2) ;
		else
			icon.gotoAndStop(1) ;
	}
	
	
	
	public function initSoundSettings() {
		var mc = Game.me.pausePanel ;
		if (mc == null)
			return ;
		
		setTinyVolume(false) ;
		
		mc._volMc._cursor._x = userVol ;
		setVolIcon(mc._vol) ;
		
		
		
		mc._music.smc.gotoAndStop(if (haveMusic) 1 else 4) ;
		mc._sfx.smc.gotoAndStop(if (haveSfx) 1 else 4) ;
		
		mc._quit.onRollOver = function() { mc._quit.gotoAndStop(2) ; } ;
		mc._quit.onRollOut = function() { mc._quit.gotoAndStop(1) ; } ;
		mc._quit.onReleaseOutside = mc._quit.onRollOut ;
		mc._quit.onRelease = Game.me.setPause ;
		
		mc._music.gotoAndStop(1) ;
		mc._music.onRollOver = callback(function(m : flash.MovieClip) {m.gotoAndStop(2) ;}, mc._music) ;
		mc._music.onRollOut = callback(function(m : flash.MovieClip) {m.gotoAndStop(1) ;}, mc._music) ;
		mc._music.onReleaseOutside = mc._music.onRollOut ;
		mc._music.onRelease = callback(switchMusic, true) ;
		
		mc._sfx.gotoAndStop(1) ;
		mc._sfx.onRollOver = callback(function(m : flash.MovieClip) {m.gotoAndStop(2) ;}, mc._sfx) ;
		mc._sfx.onRollOut = callback(function(m : flash.MovieClip) {m.gotoAndStop(1) ;}, mc._sfx) ;
		mc._sfx.onReleaseOutside = mc._sfx.onRollOut ;
		mc._sfx.onRelease = callback(switchSfx, true) ;
		
		
		mc._volMc.onRelease = setPauseClickVolume ;
		mc._volMc.onPress = callback(function(s : SoundManager) {s.dragPress = true ;}, this) ;
		mc._volMc.onReleaseOutside = mc._volMc.onRelease ;
		mc._volMc.onMouseMove = setPauseDragVolume ;
	}
	
	
	public function setPauseVolume() {
		
		//######" TODO
		
	}
	
	
	
	public function switchPause() {
		pause = !pause ;
		Game.me.gui._pause.smc.gotoAndStop(if (pause) 2 else 1) ;
		Game.me.gui._pause.gotoAndStop(1) ;
		
		if (haveMusic) { 
			if (pause)
				music.data.stop() ;
			else
				startMusic() ;
		}
		
		
		for (s in sfxs) {
			if (!s.isPlaying) 
				continue ;
				
			s.data.stop() ;
			s.isPlaying = false ;
		}
	}
	
	
	public function getStringConfig() : String {
		return (if (haveMusic) "1" else "0") + ";" + (if (haveSfx) "1" else "0") + ";" + Std.string(userVol) ;
	}
	
	
}