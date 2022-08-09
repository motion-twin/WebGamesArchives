package mt.deepnight;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

#if flash
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.media.SoundChannel;
import mt.deepnight.Tweenie;
#end

/*
 USAGE :
	static var BANK = Sfx.importDirectory("assets/sfx");  // will import every WAV/MP3 found in folder ./assets/sfx
	
	function main() {
		Sfx.setGlobalVolume(1);
		
		var m = BANK.myMusic();
		m.playLoop(999);
		
		m.setChannel(1);
		Sfx.setChannelVolume(1, 0.5);
		
		BANK.myFx().play();
		
	}
*/


private typedef ChannelInfos = {
	var volume	: Float;
	var muted	: Bool;
}

class Sfx {
	public static var SHOW_PROGRESS_BARS = true; // displayed during sound downloads
	
	#if flash
	static var PLAYING : Array<Sfx> = [];
	static var MUTED = false;
	static var DISABLED = false;
	static var GLOBAL_VOLUME = 1.0;
	static var TW = new Tweenie();
	static var CHANNELS : IntHash<ChannelInfos> = new IntHash();
	
	var loadingBar			: flash.display.Sprite;
	var sound				: Sound;
	var volume				: Float;
	var panning				: Float;
	var curPlay				: Null<SoundChannel>;
	var channel				: Int;
	var muted				: Bool;
	
	var onEnd				: Null<Void->Void>;
	
	var mp3Fix				: Bool;
	
	public function new(s:Sound) {
		volume = 1;
		panning = 0;
		channel = 0;
		sound = s;
		muted = false;
		mp3Fix = false;
	}
	
	public function toString() {
		return Std.string(sound);
	}
	
	public function play(?vol:Float, ?pan:Float) {
		if( vol==null )
			vol = volume;
			
		if( pan==null )
			pan = panning;
			
		start(1, vol, pan, 0);
		return this;
	}
	
	public inline function getSoundDuration() {
		return sound.length;
	}
	
	public function playOnChannel(channelId:Int, ?vol:Float, ?pan:Float) {
		if( vol==null )
			vol = volume;
			
		if( pan==null )
			pan = panning;
			
		channel = channelId;
		start(1, vol, pan, 0);
		return this;
	}
	
	public function playLoopOnChannel(channelId:Int, ?loops=9999, ?vol:Float, ?pan:Float, ?startOffset=0.) {
		if( vol==null )
			vol = volume;
			
		if( pan==null )
			pan = panning;
			
		channel = channelId;
		start(loops, vol, pan, startOffset);
		return this;
	}
	
	public function playLoop(?loops=9999, ?vol:Float, ?startOffset=0.) {
		if( vol==null )
			vol = volume;
			
		start(loops, vol, 0, startOffset);
		return this;
	}
	
	public function setChannel(channelId:Int) {
		channel = channelId;
		refresh();
	}
	
	function start(loops:Int, vol:Float, pan:Float, startOffset:Float) {
		#if disableSfx
		return;
		#end
		if( DISABLED )
			return;
			
		if( curPlay!=null )
			stop();
		
		volume = vol;
		panning = pan;

		var st = new SoundTransform( getRealVolume(), normalizePanning(panning) );
		
		PLAYING.push(this);
		curPlay = sound.play( startOffset, loops, st);
		curPlay.addEventListener(flash.events.Event.SOUND_COMPLETE, onComplete);
	}
	
	public inline function isPlaying() {
		return curPlay!=null;
	}
	
	function onComplete(_) {
		stop();
		if( onEnd!=null ) {
			var cb = onEnd;
			onEnd = null;
			cb();
		}
	}
	
	public inline function getRealVolume() {
		var chan = getChannelInfos(channel);
		return normalizeVolume(
			volume * GLOBAL_VOLUME * chan.volume * (DISABLED?0:1) * (MUTED?0:1) * (muted?0:1) * (chan.muted?0:1)
		);
	}

	public function setVolume(v:Float) {
		volume = v;
		refresh();
	}
	
	
	public inline function getRealPanning() {
		return panning;
	}
	
	public function setPanning(p:Float) {
		panning = p;
		refresh();
	}
	
	public function onEndOnce(cb:Void->Void) {
		onEnd = cb;
	}
	
	
	public function stop() {
		if( curPlay!=null ) {
			curPlay.stop();
			curPlay = null;
			PLAYING.remove(this);
		}
	}
	
	public function toggleMute() {
		muted = !muted;
		setVolume(volume);
	}
	public function mute() {
		muted = true;
		setVolume(volume);
	}
	public function unmute() {
		muted = false;
		setVolume(volume);
	}
	
	inline function refresh() {
		if( curPlay!=null )
			curPlay.soundTransform = new SoundTransform(getRealVolume(), getRealPanning());
	}
	
	public function tweenVolume(v:Float, ?easeType:TType, milliseconds:Float) : Tween {
		var cur = volume;
		TW.terminate(this, "volume");
		volume = cur;
		var t = TW.create(this, "volume", v, TEase, milliseconds);
		t.onUpdate = refresh;
		return t;
	}
	
	
	public function tweenPanning(p:Float, ?easeType:TType, milliseconds:Float) : Tween {
		var cur = volume;
		TW.terminate(this, "panning");
		volume = cur;
		var t = TW.create(this, "panning", p, TEase, milliseconds);
		t.onUpdate = refresh;
		return t;
	}
	
	
	
	
	/* STATIC FUNCTIONS ****************/
	
	static inline function refreshAll() {
		for(s in PLAYING)
			s.refresh();
	}
	
	public static function muteGlobal() {
		MUTED = true;
		refreshAll();
	}
	
	public static function unmuteGlobal() {
		MUTED = false;
		refreshAll();
	}
	
	public static function setChannelVolume(channel:Int, vol:Float) {
		getChannelInfos(channel).volume = vol;
		refreshAll();
	}
	
	public static function muteChannel(channel:Int) {
		getChannelInfos(channel).muted = true;
		refreshAll();
	}
	
	public static function unmuteChannel(channel:Int) {
		getChannelInfos(channel).muted = false;
		refreshAll();
	}
	
	public static inline function playOne( randList:Array<?Float->Sfx>, ?volume=1.0) {
		randList[Std.random(randList.length)]().play(volume);
	}
	
	static inline function normalizeVolume(f:Float) {
		return Math.max(0, Math.min(1,f));
	}
	
	
	static inline function normalizePanning(f:Float) {
		return Math.max(-1, Math.min(1, f));
	}

	public static inline function getGlobalVolume() {
		return GLOBAL_VOLUME;
	}
	
	public static function setGlobalVolume(vol:Float) {
		GLOBAL_VOLUME = normalizeVolume(vol);
		refreshAll();
	}
	
	public static function disable() {
		DISABLED = true;
		refreshAll();
	}
	
	public static function enable() {
		DISABLED = false;
		refreshAll();
	}
	
	static inline function getChannelInfos(cid:Int) : ChannelInfos {
		if( CHANNELS.exists(cid) )
			return CHANNELS.get(cid);
		else {
			CHANNELS.set(cid, {volume:1, muted:false});
			return CHANNELS.get(cid);
		}
	}
	
	
	
	
	/* IMPORT TOOLS ********************/
	
	public static function downloadAndCreate(url:String) : Sfx {
		var snd = new Sound();
		var sfx = new Sfx(snd);
		
		var w = flash.Lib.current.stage.stageWidth;
		var h = flash.Lib.current.stage.stageHeight;
		var bar : flash.display.Sprite = null;
		if( SHOW_PROGRESS_BARS ) {
			bar = new flash.display.Sprite();
			flash.Lib.current.addChild(bar);
			bar.filters = [
				new flash.filters.DropShadowFilter(2,90, 0xFFFFFF,0.5, 0,0,1, 1,true),
				new flash.filters.GlowFilter(0x5C6F8D,1, 2,2,10, 1,true),
			];
			bar.y = h-5;
		}
		function _setBar(ratio:Float) {
			if( bar!=null ) {
				bar.graphics.beginFill(0x343F50, 0.5);
				bar.graphics.drawRect(0,0,w,5);
				bar.graphics.beginFill(0xE0E4EB, 0.5);
				bar.graphics.drawRect(0,0,5 + (w-5)*Math.max(0, Math.min(1,ratio)), 5);
			}
		}
		
		snd.addEventListener(flash.events.Event.COMPLETE, function(_) {
			if( bar!=null )
				bar.parent.removeChild(bar);
		});
		snd.addEventListener(flash.events.ProgressEvent.PROGRESS, function(e:flash.events.ProgressEvent) {
			if( bar!=null )
				_setBar(e.bytesLoaded/e.bytesTotal);
		});
		snd.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e) trace("Error loading SFX: "+e));
		
		var request = new flash.net.URLRequest(url);
		snd.load(request);
		
		return sfx;
	}
	
	#end
	
	
	@:macro public static function importDirectory( dir : String ) {
		var p = Context.currentPos();
		var sounds = [];
		var r_names = ~/[^A-Za-z0-9]+/g;
		var found = false;
		for( cp in Context.getClassPath() ) {
			var path = cp+dir;
			if( !sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path) )
				continue;
			found = true;
			for( f in sys.FileSystem.readDirectory(path) ) {
				var ext = f.split(".").pop().toLowerCase();
				if( ext != "wav" && ext != "mp3" ) continue;
				var name = f.substr(0,f.length-4);
				name = r_names.replace(name,"_");
				
				#if disableSfx
				var soundType = {
					pos : p,
					pack : [],
					name : "_SFX_"+name,
					meta : [],
					params : [],
					isExtern : false,
					fields : [],
					kind : TDClass({ pack : ["flash","media"], name : "Sound", params : [] }),
				};
				#else
				var soundType = {
					pos : p,
					pack : [],
					name : "_SFX_"+name,
					meta : [{ name : ":sound", pos : p, params : [{ expr : EConst(CString(dir+"/"+f)), pos : p }] }],
					params : [],
					isExtern : false,
					fields : [],
					kind : TDClass({ pack : ["flash","media"], name : "Sound", params : [] }),
				};
				#end
				Context.defineType(soundType);

				var newSoundExpr = { expr : ENew({pack:soundType.pack, name:soundType.name, params:[]}, []), pos:p }
				var newSfxExpr = { expr : ENew( { pack:["mt","deepnight"], name:"Sfx", params:[]}, [newSoundExpr] ), pos:p }
				
				//var tbool = TPath({pack:[],name:"Bool",params:[]});
				var tfloat = TPath({pack:[],name:"Float",params:[]});
				
				var f : haxe.macro.Function = {
					ret : null,
					args : [{name:"quickPlayVolume", opt:true, type:tfloat}],
					//expr : { pos:p, expr: EReturn(newSfxExpr) },
					expr : macro {
						if( quickPlayVolume!=null ) {
							#if disableSfx
							return $newSfxExpr;
							#else
							var s = $newSfxExpr;
							return s.play(quickPlayVolume);
							#end
						}
						else
							return $newSfxExpr;
					},
					params : [],
				}
				var wrapperExpr : Expr = { pos:p, expr:EFunction(name, f) }
				sounds.push({ field:name, expr:wrapperExpr });
			}
		}
		if( !found ) Context.error("File not found "+dir, p);
		return { pos : p, expr : EObjectDecl(sounds) };
	}
	
	
	
	/* MAIN LOOP (only required if using tweens) ******************/
	
	#if flash
	public static function update() {
		TW.update();
	}
	#end
}



