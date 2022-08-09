package mt.flash;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

#if !macro
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.media.SoundChannel;
import mt.deepnight.Tweenie;
import mt.deepnight.Lib;
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

	#if !macro
	static var PLAYING : Array<Sfx> = [];
	static var MUTED = false;
	static var DISABLED = false;
	static var GLOBAL_VOLUME = 1.0;
	@:noCompletion public static var TW = new Tweenie();
	static var CHANNELS : Map<Int,ChannelInfos> = new Map();

	static var LISTENER_X = 0.0;
	static var LISTENER_Y = 0.0;
	static var SPATIAL_PANNING_RANGE2 : Float = 100 * 100;
	static inline var DEBUG = false;

	var loadingBar			: flash.display.Sprite;
	public var sound		: Sound;
	var volume				: Float;
	var panning				: Float;
	var curPlay				: Null<SoundChannel>;
	var channel				: Int;
	var muted				: Bool;

	var onEnd				: Null<Void->Void>;

	var mp3Fix				: Bool;
	var vtween				: Null<Tween>;
	var ptween				: Null<Tween>;

	var spatialized			: Bool;
	var spatialX			: Float;
	var spatialY			: Float;
	var spatialMaxDist		: Float;

	var beatT				: Float;
	var beatDuration		: Float;
	var beatFrame			: Bool;

	public function new(s:Sound) {
		volume = 1;
		panning = 0;
		channel = 0;
		beatT = 0;
		beatDuration = -1;
		beatFrame = false;
		sound = s;
		muted = false;
		mp3Fix = false;

		spatialized = false;
		spatialX = spatialY = spatialMaxDist = 0;
	}

	public function initBeatTimer(beatDurationSec:Float, ?startOffsetSec=0.0) {
		beatDuration = beatDurationSec;
		beatT = haxe.Timer.stamp() + startOffsetSec - beatDuration;
	}

	public function updateBeatCounter() {
		if( beatDuration>0 && haxe.Timer.stamp()-beatT>=beatDuration ) {
			beatT += beatDuration;
			beatFrame = true;
		}
		else
			beatFrame = false;
	}

	public inline function isBeatFrame() {
		return beatDuration>0 && isPlaying() && !isChannelMuted(channel) && beatFrame;
	}

	public function toString() {
		return Std.string(sound);
	}

	public function play(?vol:Float, ?pan:Float, ?startOffsetSec=0.) {
		if( vol==null )
			vol = volume;

		if( pan==null )
			pan = panning;

		var loops = #if (openfl && cpp) 0 #else 1 #end;
		start(loops, vol, pan, startOffsetSec);
		return this;
	}

	public inline function getSoundDuration() {
		return sound.length;
	}

	public function playSpatial(x:Float, y:Float, maxDist:Float, ?vol:Float) {
		if ( DEBUG ) trace("playSpatial");
		spatialize(x, y, maxDist);
		return play(vol);
	}

	public function spatialize(x:Float, y:Float, maxDist:Float) {
		spatialized = true;
		spatialX = x;
		spatialY = y;
		spatialMaxDist = maxDist;
		refresh();
		return this;
	}

	public function cancelSpatialization() {
		spatialized = false;
	}

	public function playOnChannel(channelId:Int, ?vol:Float, ?pan:Float) {
		if ( DEBUG ) trace("playOnChannel");
		if( vol==null )
			vol = volume;

		if( pan==null )
			pan = panning;

		channel = channelId;
		var loops = #if (openfl && mobile) 0 #else 1 #end;
		start(loops, vol, pan, 0);
		return this;
	}

	public function playLoopOnChannel(channelId:Int, ?loops = 9999, ?vol:Float, ?pan:Float, ?startOffsetSec = 0.) {
		if ( DEBUG ) trace("playLoopOnChannel");
		if( vol==null )
			vol = volume;

		if( pan==null )
			pan = panning;

		channel = channelId;
		#if (openfl && mobile)
		loops = loops-1;
		#end
		start(loops, vol, pan, startOffsetSec);
		return this;
	}

	public function playLoop(?loops = 9999, ?vol:Float, ?startOffsetSec = 0.) {
		if ( DEBUG ) trace("playLoop");
		if( vol==null )
			vol = volume;
		#if (openfl && mobile)
		loops = loops-1;
		#end
		start(loops, vol, 0, startOffsetSec);
		return this;
	}

	public inline function getChannel() return channel;
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

		if( isPlaying() )
			stop();

		volume = vol;
		panning = pan;
		var st = new SoundTransform( getRealVolume(), getRealPanning() );
		PLAYING.push(this);
		curPlay = sound.play( startOffset, loops, st);
		if( curPlay != null )
			curPlay.addEventListener(flash.events.Event.SOUND_COMPLETE, onComplete);
	}

	public inline function isPlaying() {
		return curPlay!=null;
	}

	public inline function getPlayCursor() {
		return curPlay.position;
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
		var v = volume * GLOBAL_VOLUME * chan.volume * (DISABLED?0:1) * (MUTED?0:1) * (muted?0:1) * (chan.muted?0:1);

		if( spatialized )
			v *= 1 - MLib.fmin(1, Lib.distance(spatialX,spatialY, LISTENER_X,LISTENER_Y) / spatialMaxDist );

		return normalizeVolume(v);
	}

	public inline function getTheoricalVolume() {
		return volume;
	}

	public function setVolume(v:Float) {
		volume = v;
		refresh();
	}

	inline function getPanningFromPosition(sourceX:Float, sourceY:Float, listenerX:Float, listenerY:Float) : Float {
		return (listenerX>sourceX?-1:1) * MLib.fmin( 0.9, Lib.distanceSqr(listenerX,listenerY, sourceX,sourceY) / SPATIAL_PANNING_RANGE2 );
	}

	public inline function getRealPanning() {
		return normalizePanning( !spatialized ? panning : getPanningFromPosition(spatialX, spatialY, LISTENER_X, LISTENER_Y) );
	}

	public function setPanning(p:Float) {
		panning = p;
		refresh();
	}

	public function removeEndCallback() {
		onEnd = null;
	}

	public function onEndOnce(cb:Void->Void) {
		onEnd = cb;
	}


	public function stop(?fadeOutMs=0.0) {
		if( isPlaying() ) {
			if( fadeOutMs<=0 ) {
				curPlay.stop();
				curPlay = null;
				PLAYING.remove(this);
			}
			else
				fade(0, fadeOutMs).onEnd = stop.bind(0);
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
		if( isPlaying() )
			curPlay.soundTransform = new SoundTransform(getRealVolume(), getRealPanning());
	}

	@:noCompletion public function twVolume(?from:Float, to:Float, milliseconds:Float) : Tween {
		if( vtween!=null )
			vtween.endWithoutCallbacks();

		if( from!=null )
			setVolume(from);

		vtween = TW.create(volume, to, milliseconds);
		vtween.onUpdate = refresh;
		return vtween;
	}


	@:noCompletion public function twPanning(?from:Float, to:Float, milliseconds:Float) : Tween {
		if( ptween!=null )
			ptween.endWithoutCallbacks();
		if( from!=null )
			panning = from;

		ptween = TW.create(panning, to, milliseconds);
		ptween.onUpdate = refresh;
		return ptween;
	}



	/* STATIC FUNCTIONS ****************/

	static inline function refreshAll() {
		for(s in PLAYING)
			s.refresh();
	}

	public static function toggleMuteGlobal() {
		if( MUTED )
			unmuteGlobal();
		else
			muteGlobal();
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

	public static function clearChannel(channel:Int) {
		for( s in getByChannel(channel) )
			s.stop();
	}

	public static function clearChannelWithFadeOut(channel:Int, fadeDuration:Float) {
		for( s in getByChannel(channel) )
			s.fade(0, fadeDuration).onEnd = function() { // TODO
				s.stop();
			}
	}

	public static function getByChannel(channel:Int) {
		return PLAYING.filter( function(s) return s.channel==channel );
	}

	public static function toggleMuteChannel(channel:Int) {
		if( getChannelInfos(channel).muted ) {
			unmuteChannel(channel);
			return true;
		}
		else {
			muteChannel(channel);
			return false;
		}
	}

	public static inline function isChannelMuted(channel:Int) {
		return getChannelInfos(channel).muted;
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
		return randList[Std.random(randList.length)]().play(volume);
	}

	public static inline function getOne( randList:Array<?Float->Sfx> ) {
		return randList[Std.random(randList.length)]();
	}

	static inline function normalizeVolume(f:Float) return MLib.fclamp(f, 0, 1);
	static inline function normalizePanning(f:Float) return MLib.fclamp(f, -1, 1);

	public static inline function getGlobalVolume() {
		return GLOBAL_VOLUME;
	}

	public static function setGlobalVolume(vol:Float) {
		GLOBAL_VOLUME = normalizeVolume(vol);
		refreshAll();
	}

	public static function disable() {
		if( DISABLED )
			return;

		DISABLED = true;
		refreshAll();
	}

	public static function enable() {
		if( !DISABLED )
			return;

		DISABLED = false;
		refreshAll();
	}

	public static function setSpatialSettings(listenerX:Float, listenerY:Float, ?spatialPanningRange:Null<Float>) {
		if( spatialPanningRange!=null )
			SPATIAL_PANNING_RANGE2 = spatialPanningRange*spatialPanningRange;
		LISTENER_X = listenerX;
		LISTENER_Y = listenerY;
		//MAX_SPATIAL_DIST_VOLUME = maxDistForVolume*maxDistForVolume;
		//MAX_SPATIAL_DIST_PANNING = maxDistForPanning*maxDistForPanning;
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

	public static function download(?target:Sfx, url:String, ?onComplete:Sfx->Void, ?onError:String->Void) : Sfx {
		if( target==null )
			target = new Sfx( new Sound() );
		else
			target.sound = new Sound();

		var w = flash.Lib.current.stage.stageWidth;
		var h = flash.Lib.current.stage.stageHeight;
		var bh = 3;
		var bar : flash.display.Sprite = null;
		if( SHOW_PROGRESS_BARS ) {
			bar = new flash.display.Sprite();
			flash.Lib.current.addChild(bar);
			bar.filters = [
				new flash.filters.DropShadowFilter(2,90, 0xFFFFFF,0.15, 0,0,1, 1,true),
				new flash.filters.GlowFilter(0x343F50,0.7, 2,2,10, 1,true),
			];
			bar.y = h-bh;
		}
		function _setBar(ratio:Float) {
			if( bar!=null ) {
				bar.graphics.clear();
				bar.graphics.beginFill(0x14181F, 1);
				bar.graphics.drawRect(0,0,w,bh);
				bar.graphics.beginFill(0xE0E4EB, 1);
				bar.graphics.drawRect(0,0,5 + (w-5)*MLib.fclamp(ratio,0,1), bh);
			}
		}

		target.sound.addEventListener(flash.events.Event.COMPLETE, function(_) {
			if( bar!=null )
				bar.parent.removeChild(bar);
			if( onComplete!=null )
				onComplete(target);
		});
		target.sound.addEventListener(flash.events.ProgressEvent.PROGRESS, function(e:flash.events.ProgressEvent) {
			if( bar!=null )
				_setBar(e.bytesLoaded/e.bytesTotal);
		});
		target.sound.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e:flash.events.IOErrorEvent) {
			if( onError==null )
				trace("Error loading SFX: "+e.text)
			else
				onError(e.text);
		});

		var request = new flash.net.URLRequest(url);
		target.sound.load(request);

		return target;
	}

	#end

	#if openfl
	/**
	* Parses the @systemPath directory to create methods to instanciate easily the sounds.  Sounds are instanciated with openfl Assets.
	*/

	#if !macro
	static var assetsCache : Map<String,flash.media.Sound> = new Map();
	public static function getAsset( n : String ){
		if( assetsCache.exists(n) )
			return assetsCache.get(n);
		var s = openfl.Assets.getSound(n);
		assetsCache.set(n,s);
		return s;
	}

	static function loadAsset( n : String, onLoaded:Sound->Void ){
		if( assetsCache.exists(n) ) {
			onLoaded(assetsCache.get(n));
		} else {
			openfl.Assets.loadSound(n, function(s) {
				assetsCache.set(n, s);
				onLoaded(s);
			});
		}
	}
	#end

	macro public static function importFromAssets( systemPath:String, assetsPrefix : String="" ) {
		var p = Context.currentPos();
		var sounds = [];
		var r_names = ~/[^A-Za-z0-9]+/g;
		var n = 0;
		for( cp in Context.getClassPath() ) {
			var path = cp+systemPath;
			if( !sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path) )
				continue;

			for( f in sys.FileSystem.readDirectory(path) ) {
				var ext = f.split(".").pop().toLowerCase();
				if( Context.defined("mobile") ){
					if( ext=="mp3" )
						Context.fatalError("File format "+ext.toUpperCase()+" unsupported for mobile target: "+f, p);
					if( ext != "wav" && ext != "ogg" ) continue;
				}else if( Context.defined("cpp") ){
					if ( ext != "wav" && ext != "mp3" && ext != "ogg" ) continue;
				}else{
					if ( ext != "wav" && ext != "mp3" ) continue;
				}

				n++;

				var name = f.substr(0,f.length-4);
				name = r_names.replace(name,"_");

				var newSfxExpr = 	#if debug
									macro {
										var p :String = $v{assetsPrefix+""+f};
										var s = mt.flash.Sfx.getAsset(p);
										if( s == null ) throw 'The sound '+p+' is not embeded properly. Check openfl assets path !';
										var sfx = new mt.flash.Sfx(s);
										sfx;
									}
									#else
									macro new mt.flash.Sfx(mt.flash.Sfx.getAsset($v{assetsPrefix+""+f}));
									#end
				//trace the expression in order to check it is a valid expression
				//var printer = new haxe.macro.Printer();
				//trace(printer.printExpr(newSfxExpr));

				//Null is better for CPP target
				var tfloat = macro : Null<Float>;
				var f : haxe.macro.Function = {
					ret : null,
					args : [{name:"quickPlayVolume", opt:true, type:tfloat, value:null}],
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
			if( n>0 ) break;
		}
		if ( n==0 ) Context.error("No sound file in " + systemPath, p);
		Sys.println("[Sfx] Imported "+n+" file(s) from OpenFL assets");
		return { pos : p, expr : EObjectDecl(sounds) };
	}
	#end



	macro public static function importDirectory( dir : String ) {
		var p = Context.currentPos();
		var sounds = [];
		var r_names = ~/[^A-Za-z0-9]+/g;
		var n = 0;
		for( cp in Context.getClassPath() ) {
			var path = cp+dir;
			if( !sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path) )
				continue;

			for( f in sys.FileSystem.readDirectory(path) ) {
				var ext = f.split(".").pop().toLowerCase();
				#if mobile
				if( ext != "wav" && ext != "mp3" && ext != "ogg" ) continue;
				#else
				if( ext != "wav" && ext != "mp3" ) continue;
				#end

				n++;
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
				var newSfxExpr = 	macro new mt.flash.Sfx($e{newSoundExpr});

				//trace the expression in order to check it is a valid expression
				//var printer = new haxe.macro.Printer();
				//trace(printer.printExpr(newSfxExpr));

				//Null is better for CPP target
				var tfloat = macro : Null<Float>;
				var f : haxe.macro.Function = {
					ret : null,
					args : [{name:"quickPlayVolume", opt:true, type:tfloat, value:null}],
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
			if( n>0 ) break;
		}

		if ( n==0 ) Context.error("Invalid directory (not found or empty): " + dir, p);
		#if !disableSfx
		Sys.println("[Sfx] Imported "+n+" file(s)");
		#end

		return { pos : p, expr : EObjectDecl(sounds) };
	}


	/**
	 * Tween volume
	 * @param	?toExpr either a Float (target value) or an expression like 0>1 (tween value from 0 to 1)
	 * @param	duration_ms tween duration
	 * @return a mt.deepnight.Tweenie.Tween instance
	 */
	public macro function fade(ethis:Expr, toExpr:ExprOf<Float>, duration_ms:ExprOf<Float>) {
		var p = Context.currentPos();
		var from = macro null;
		var to = toExpr;
		switch( toExpr.expr ) {
			case EBinop(OpGt, e1, e2) :
				from = e1;
				to = e2;

			case EBinop(_), EField(_), EConst(_), EParenthesis(_), ECall(_), EUnop(_), ETernary(_) :

			default:
				Context.error("Invalid tweening expression ("+toExpr.expr.getName()+"). Please ask Seb :)", toExpr.pos);
		}

		return macro $ethis.twVolume( $from, $to, $duration_ms);
	}


	/**
	 * Tween panning
	 * @param	?toExpr either a Float (target value) or an expression like 0>1 (tween value from 0 to 1)
	 * @param	duration_ms tween duration
	 * @return a mt.deepnight.Tweenie.Tween instance
	 */
	public macro function pan(ethis:Expr, toExpr:ExprOf<Float>, duration_ms:ExprOf<Float>) {
		var p = Context.currentPos();
		var from = macro null;
		var to = toExpr;
		switch( toExpr.expr ) {
			case EBinop(OpGt, e1, e2) :
				from = e1;
				to = e2;

			case EBinop(_), EField(_), EConst(_), EParenthesis(_), ECall(_), EUnop(_), ETernary(_) :

			default:
				Context.error("Invalid tweening expression ("+toExpr.expr.getName()+"). Please ask Seb :)", toExpr.pos);
		}

		return macro $ethis.twPanning( $from, $to, $duration_ms);
	}


	/* MAIN LOOP (only required if using tweens or beat counter) ******************/

	#if !macro

	public static function terminateTweens() {
		TW.completeAll();
	}
	public static function update() {
		TW.update();
	}
	#end
}
