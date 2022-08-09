package mt.gx;

import mt.MLib;

#if !macro
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.xml.Fast;
#end

import haxe.macro.Expr;
import haxe.macro.Context;


#if !macro

typedef FrameData = {
	x			: Int,
	y			: Int,
	wid			: Int,
	hei			: Int,
	realFrame	: {x:Int, y:Int, realWid:Int, realHei:Int},
	rect		: Rectangle,
}

typedef LibGroup = {
	id		: String,
	maxWid	: Int,
	maxHei	: Int,
	frames	: Array<FrameData>,
	anim	: Array<Int>,
};
#end

enum SLBError {
	UnknownGroup(g:String);
	NoGroupSelected;
	GroupAlreadyExists(g:String);
	NoFrameInGroup(f:Int, g:String);
	WidthMismatch(f:Int, g:String);
	HeightMismatch(f:Int, g:String);
	InvalidFrameDuration(s:String);
	EndFrameLower(s:String);
	InvalidFrames(s:String);
	NoCurrentGroup;
	AnimFrameExceeds(id:String, anim:String, frame:Int);
	AssetImportFailed(e:Dynamic);
}

/** SPRITE *******************************************************************************************
 *
 *
 *
 *
 *
 * */

#if !macro
class BSprite extends flash.display.Sprite {
	public static var ALL : List<BSprite> = new List();
	
	// Definition
	public var lib(default,null)			: SpriteLibBitmap;
	public var group(default,null)			: Null<LibGroup>;
	public var groupName(default,null)		: Null<String>;
	public var frame(default, null)			: Int;
	
	//exposed for uv stealing
	public var frameData(default,null)		: FrameData;
	
	// Misc
	var pt0				: flash.geom.Point;
	public var destroyed(default, null )	: Bool;
	
	#if debug
	var debug			: flash.display.Sprite;
	#end
	
	// Anims
	public var animCursor(default, null): Int;
	var curFrameCpt		: Float;
	var isPlaying		: Bool;
	var animFrames		: Array<Int>;
	var animPlays		: Int;
	var animChain		: Array<String>;
	var animPaused		: Bool;
	public var animPriority	: Int;
	public var onPlayAnim		: Null<Void->Void>;
	public var onEndAnim		: Null<Void->Void>;
	public var onLoopAnim		: Null<Void->Void>;
	var killAfterAnim			: Bool;
	
	var needUpdate		: Bool;
	
	// Pivots
	public var pivotCoord(default,null)		: Null<{x:Float, y:Float}>; // pixel coordinates, excluses pivotCoord
	public var pivotFactor(default,null)		: Null<{xr:Float, yr:Float}>; // homogeneous coordinates : 0-1 (based on actual width/height) excludes pivotFactor
	
	public function new(?l:SpriteLibBitmap, ?g:String, ?frame=0) {
		super();
		animChain = [];
		isPlaying = false;
		destroyed = false;
		killAfterAnim = false;
		this.cacheAsBitmap = false;
		pt0 = new flash.geom.Point();
		curFrameCpt = 0;
		animPriority = 0;
		animPaused = false;
		
		//bmp = new Bitmap(flash.display.PixelSnapping.NEVER, false);
		//addChild(bmp);
		
		if( l!=null )
			setGroup(l, g, frame);
			
	}
	
	public function clone() {
		var s = new BSprite(lib, groupName, frame);
		s.pivotCoord = pivotCoord;
		s.pivotFactor = pivotFactor;
		s.applyPivot();
		return s;
	}
	

	public override function toString() {
		return "BSprite_"+groupName+"["+frame+"]";
	}
	
	//public inline function applyFilter(f:flash.filters.BitmapFilter) {
	//	bmp.bitmapData.applyFilter(bmp.bitmapData, bmp.bitmapData.rect, pt0, f);
	//}
	
	public function setGroup(?l:SpriteLibBitmap, g:String, ?frame=0) {
		if( l!=null ) {
			lib = l;
			frameData = lib.getFrameData(g, frame);
			if( pivotCoord==null && pivotFactor==null )
				setCenter(lib.defaultCenterX, lib.defaultCenterY);
		}
		groupName = g;
		
		if( isReady() ) {
			group = lib.getGroup(groupName);
			stopAnim(); // TODO EXPERIMENTAL: ligne inversée avec initBitmap
			setFrame(frame);
		}
	}
	
	
	
	public function getAnimDuration() {
		var a = getAnim();
		return a!=null ? a.length : 0;
	}
	
	inline function getAnim() {
		return isReady() && group.anim.length>=0 ? group.anim : null;
	}
	
	inline function hasAnim() {
		return getAnim()!=null;
	}
	
	/*
	public inline function getBitmap() {
		return bmp;
	}
	
	public inline function getBitmapData() {
		return bmp.bitmapData;
	}
	*/
	
	public inline function isPlayingAnim(?k:String) {
		return isPlaying && (k==null || isGroup(k));
	}
	
	public inline function isGroup(k) {
		return groupName==k;
	}
	
	/*
	function initBitmap() {
		if( !isReady() )
			return;
			
		if( bmp.bitmapData==null || group.maxWid>bmp.bitmapData.width || group.maxHei>bmp.bitmapData.height ) {
			var oldW = 0;
			var oldH = 0;
			if( bmp.bitmapData!=null ) {
				#if debug
				trace('WARNING($groupName): re-allocation of bitmapdata occured (new size: ${group.maxWid}x${group.maxHei})');
				#end
				oldW = bmp.bitmapData.width;
				oldH = bmp.bitmapData.height;
				bmp.bitmapData.dispose();
			}
			bmp.bitmapData = new BitmapData(MLib.max(oldW, group.maxWid), MLib.max(oldH, group.maxHei), true, 0x0);
		}
		bmp.visible = bitmapVisible;
		applyPivot();
	}
	*/
	
	public inline function randomFrame(?rndFunc:Int->Int) {
		if( isReady() ) {
			if( rndFunc==null )
				rndFunc = Std.random;
			setFrame( rndFunc(lib.countFrames(groupName)) );
		}
	}
	
	public inline function setFrame(f:Int) {
		var old = frame;
		frame = f;
		if( isReady() && (old!=frame || frame==0) ) { // TODO frame 0 pas terrible...
			var prev = frameData;
			
			frameData = lib.getFrameData(groupName, frame);
			
			//if( frameData.wid<prev.wid || frameData.hei<prev.hei )bmp.bitmapData.fillRect( bmp.bitmapData.rect, 0 );
			//bmp.bitmapData.copyPixels( lib.source, frameData.rect, pt0,null,null, false );
			
			//if( frameData.realFrame.x!=prev.realFrame.x || frameData.realFrame.y!=prev.realFrame.y ) {
				//bmp.x += prev.realFrame.x  - frameData.realFrame.x;
				//bmp.y += prev.realFrame.y  - frameData.realFrame.y;
			//}
			
			applyPivot();
		}
	}
	
	public inline function setPivotCoord(x:Float, y:Float) {
		pivotCoord = {x:x, y:y}
		pivotFactor = null;
		applyPivot();
	}
	
	public inline function setCenter(xRatio:Float, yRatio:Float) {
		pivotCoord = null;
		pivotFactor = {xr:xRatio, yr:yRatio};
		applyPivot();
	}
	
	inline function applyPivot() {
		
	}
	
	public function totalFrames() {
		return group.frames.length;
	}
	
	inline function startUpdates() {
		if( !needUpdate )
			ALL.push(this);
		needUpdate = true;
	}
	
	inline function stopUpdates() {
		if( needUpdate )
			ALL.remove(this);
		needUpdate = false;
	}
	
	public function destroy() {
		if( !destroyed ) {
			destroyed = true;
			if(parent!=null)
				parent.removeChild(this);
			/*
			if( bmp.bitmapData!=null )
				bmp.bitmapData.dispose();
				*/
			stopUpdates();
		}
	}
	
	public function restartAnim(?plays=9999999) {
		stopAnim();
		playAnim(groupName, plays);
	}
	
	public function pauseAnim() {
		animPaused = true;
	}
	public function resumeAnim() {
		animPaused = false;
	}
	
	
	public function stopAnim(?frame:Int) {
		animPriority = 0;
		animFrames = new Array();
		isPlaying = false;
		if( frame!=null )
			setFrame(frame);
		stopUpdates();
	}
	
	inline function isReady() {
		return !destroyed && groupName!=null;
	}
	
	public function chainAnims(animList:Array<String>) {
		if( animList.length>0 ) {
			animChain = animList;
			popChainedAnim();
		}
	}
	
	function popChainedAnim() {
		if( animChain.length==1 )
			_playAnim( animChain.shift() ) ;
		else
			_playAnim( animChain.shift(), 1 ) ;
	}
	
	public function playAnimWithPriority(a:String, priority:Int, ?plays=99999) {
		if( !isPlayingAnim() || animPriority<=priority ) {
			playAnim(a, plays);
			animPriority = priority;
		}
	}
	
	
	public function playStateAnim(hasThisState:Bool, a:String, priority:Int) {
		if( !hasThisState && isPlayingAnim(a) )
			stopAnim();
		else if( hasThisState && (!isPlayingAnim() || priority>animPriority) ) {
			playAnim(a);
			animPriority = priority;
		}
	}
	
	public function playAnim(g:String, ?plays=99999, ?killAfterPlay=false) {
		if( animChain.length>0 )
			animChain = [];
		_playAnim(g, plays, killAfterPlay);
		animPriority = 99999;
	}
	
	function _playAnim(g:String, ?plays=99999, ?killAfterPlay=false) {
		if( groupName==g && isPlaying )
			return;
			
		setGroup(g);
		
		var a = getAnim();
		
		if( a==null )
			return;
			
		killAfterAnim = killAfterPlay;
		
		animPaused = false;
		isPlaying = true;
		curFrameCpt = 0;
		animCursor = 0;
		animPlays = plays;
		animFrames = a;
		startUpdates();
		setFrame(animFrames[0]);
		
		if( onPlayAnim!=null )
			onPlayAnim();
	}
	
	public inline function offsetAnimFrame(?randFunc:Int->Int) {
		if( randFunc==null )
			animCursor = Std.random(animFrames.length);
		else
			animCursor = randFunc(animFrames.length);
	}
	
	inline function updateAnim(?tmod = 1.0) { // requis seulement en cas d'anim
		if( animFrames.length>0 && !animPaused ) {
			curFrameCpt += tmod;
			
			while( !destroyed && curFrameCpt>1 ) {
				curFrameCpt--;
				animCursor++;
				if( animCursor>=animFrames.length ) {
					animCursor = 0;
					animPlays--;
					if(animPlays<=0) {
						if( killAfterAnim )
							destroy();
						else
							stopAnim();
							
						if( onEndAnim!=null ) {
							var cb = onEndAnim;
							onEndAnim = null;
							cb();
						}
						
						if( animChain.length>0 )
							popChainedAnim();
					}
					else {
						setFrame(animFrames[animCursor]);
						if( onLoopAnim!=null )
							onLoopAnim() ;
					}
				}
				else
					setFrame(animFrames[animCursor]);
			}
		}
	}
	
	//DE : deprecate this to get it into module's main class
	public static inline function updateAll(?tmod=1.0) {
		for(s in ALL)
			s.updateAnim(tmod);
	}

	
}
#end




/** LIBRARY ********************************************************************************************/

class SpriteLibBitmap {
	#if !macro
	public var source			: BitmapData;
	var groups					: Map<String, LibGroup>;
	var currentGroup			: Null<LibGroup>;
	var frameRandDraw			: Map<String, Array<Int>>;
	public var defaultCenterX(default, null)	: Float;
	public var defaultCenterY(default, null)	: Float;
	var gridX					: Int;
	var gridY					: Int;
	
	#if h3d
	public var tile				: h2d.Tile;
	#end
	
	public function new(bd:BitmapData) {
		source = bd;
		groups = new Map();
		frameRandDraw = new Map();
		defaultCenterX = 0;
		defaultCenterY = 0;
		gridX = gridY = 16;
		
		#if h3d
		genTex();
		#end
	}
	
	#if h3d
	public function genTex() {	
		tile = h2d.Tile.fromBitmap( hxd.BitmapData.fromNative(source) );
	}
	#end
	
	public function destroy() {
		source.dispose();
	}
	
	
	public function get(k:String, ?frame=0) : BSprite {
		return new BSprite(this, k, frame);
	}
	
	public function getAndPlay(k:String, ?plays=99999, ?killAfterPlay=false) : BSprite {
		var s = new BSprite(this);
		s.playAnim(k, plays, killAfterPlay);
		return s;
	}
	
	
	public inline function setDefaultCenter(cx,cy) {
		defaultCenterX = cx;
		defaultCenterY = cy;
	}
	
	public function setSliceGrid(w,h) {
		gridX = w;
		gridY = h;
	}
	
	public inline function getGroup(?k:String) {
		return
			if(k==null ) {
				if( currentGroup==null )
					throw SLBError.NoGroupSelected;
				else
					currentGroup;
			}
			else
				if(groups.exists(k))
					groups.get(k);
				else
					throw SLBError.UnknownGroup(k);
	}
	
	public inline function getGroups() {
		return groups;
	}
	
	public inline function getAnim(k) {
		return getGroup(k).anim;
	}
	
	public inline function getAnimDuration(k) {
		return getAnim(k).length;
	}
	
	public function createGroup(k:String) {
		if( groups.exists(k) )
			throw SLBError.GroupAlreadyExists(k);
		groups.set(k, {
			id		: k,
			maxWid	: 0,
			maxHei	: 0,
			frames	: new Array(),
			anim	: new Array(),
		});
		return setCurrentGroup(k);
	}
	
	inline function setCurrentGroup(k:String) {
		currentGroup = getGroup(k);
		return getGroup();
	}
	
	
	public inline function getRectangle(k:String,?frame:Int=0) {
		var g = getGroup(k);
		var fr = g.frames[frame];
		if ( fr == null) throw SLBError.NoFrameInGroup(frame, k);
		return new flash.geom.Rectangle(fr.x, fr.y, fr.wid, fr.hei);
	}
	
	public inline function getFrameData(k:String,?frame:Int=0) {
		var fr = getGroup(k).frames[frame];
		if ( fr == null) throw SLBError.NoFrameInGroup(frame, k);
		return fr;
	}
	
	public inline function exists(k:String,?frame:Int=0) {
		return groups.exists(k) && groups.get(k).frames.length>frame;
	}
	
	public inline function getRandomFrame(k:String, ?randFunc:Int->Int) {
		if(randFunc==null)
			randFunc = Std.random;
			
		return
			if(frameRandDraw.exists(k)) {
				var a = frameRandDraw.get(k);
				a[ randFunc(a.length) ];
			}
			else
				randFunc(countFrames(k));
	}
	
	public inline function countFrames(k:String) {
		return getGroup(k).frames.length;
	}
	
	public inline function getRandom(k:String, ?randFunc:Int->Int) : BSprite {
		return get(k, getRandomFrame(k, randFunc));
	}
	
	public inline function getMovieClip(k:String, ?frame=0, ?centerX, ?centerY) : flash.display.MovieClip {
		var mc = new flash.display.MovieClip();
		drawIntoGraphics(mc.graphics, k, frame, centerX, centerY);
		return mc;
	}
	
	public inline function drawIntoGraphics(g:flash.display.Graphics, k:String, ?frame=0, ?centerX, ?centerY) {
		if(centerX==null)	centerX = defaultCenterX;
		if(centerY==null)	centerY = defaultCenterY;
		var rect = getRectangle(k, frame);
		var m = new flash.geom.Matrix();
		m.translate(Std.int(-rect.x - centerX*rect.width), Std.int(-rect.y - centerY*rect.height));
		g.beginBitmapFill(source, m, false, false);
		g.drawRect(Std.int(-centerX*rect.width), Std.int(-centerY*rect.height), rect.width, rect.height);
		g.endFill();
	}
	
	public inline function drawIntoBitmap(bd:flash.display.BitmapData, x:Float,y:Float, k:String, ?frame=0, ?centerX, ?centerY) {
		if(centerX==null)	centerX = defaultCenterX;
		if(centerY==null)	centerY = defaultCenterY;
		var r = getRectangle(k, frame);
		bd.copyPixels(
			source, r,
			new flash.geom.Point(x-Std.int(r.width*centerX), y-Std.int(r.height*centerY)),
			true
		);
	}
	
	public inline function drawIntoBitmapRandom(bd:flash.display.BitmapData, x:Float,y:Float, k:String, ?randFunc:Int->Int, ?centerX, ?centerY) {
		drawIntoBitmap(bd, x,y,k, getRandomFrame(k, randFunc), centerX, centerY);
	}
	
	public function getBitmapData(k:String, ?frame=0, ?padding=0) {
		var r = getRectangle(k, frame);
		var bd = new BitmapData(Std.int(r.width+padding*2), Std.int(r.height+padding*2), true, 0x0);
		drawIntoBitmap(bd, padding,padding, k,frame, 0,0);
		return bd;
	}
	
	
	
	public function sliceCustom(groupName:String, frame:Int, x:Int, y:Int, wid:Int, hei:Int, ?realFrame:{x:Int, y:Int, realWid:Int, realHei:Int}) {
		var g = if( exists(groupName) ) getGroup(groupName) else createGroup(groupName);
		g.maxWid = MLib.max( g.maxWid, wid );
		g.maxHei = MLib.max( g.maxHei, hei );
		
		//if( wid!=g.wid )
			//throw SLBError.WidthMismatch(frame, groupName);
			//
		//if( hei!=g.hei )
			//throw SLBError.HeightMismatch(frame, groupName);
		if( realFrame==null )
			realFrame = {x:0, y:0, realWid:wid, realHei:hei}
			
		g.frames[frame] = { x:x, y:y, wid:wid, hei:hei, realFrame:realFrame, rect:new Rectangle(x,y,wid,hei) };
	}
	
	public function slice(groupName:String, x:Int, y:Int, wid:Int, hei:Int, ?repeatX=1, ?repeatY=1) {
		var g = createGroup(groupName);
		setCurrentGroup(groupName);
		g.maxWid = MLib.max( g.maxWid, wid );
		g.maxHei = MLib.max( g.maxHei, hei );
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.frames.push({ x : x+ix*wid, y : y+iy*hei, wid:wid, hei:hei, realFrame:{x:0,y:0,realWid:wid,realHei:hei}, rect:new Rectangle(x+ix*wid,y+iy*hei,wid,hei) });
	}
	
	public function sliceGrid(groupName:String, gx:Int, gy:Int, ?repeatX=1, ?repeatY=1) {
		var g = createGroup(groupName);
		setCurrentGroup(groupName);
		g.maxWid = MLib.max( g.maxWid, gridX );
		g.maxHei = MLib.max( g.maxHei, gridY );
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.frames.push({ x : gridX*(gx+ix), y : gridY*(gy+iy), wid:gridX, hei:gridY, realFrame:{x:0,y:0,realWid:gridX,realHei:gridY}, rect:new Rectangle(gridX*(gx+ix), gridY*(gy+iy), gridX, gridY) });
	}

	//public function sliceMore(x:Int, y:Int, ?repeatX=1, ?repeatY=1) {
		//var g = getGroup();
		//for(iy in 0...repeatY)
			//for(ix in 0...repeatX)
				//g.frames.push({ x : x+ix*g.wid, y : y+iy*g.hei, wid:g.wid, hei:g.hei });
	//}

	public function applyPermanentFilter(k:String, filter:flash.filters.BitmapFilter) {
		for( frame in 0...countFrames(k) ) {
			var r = getRectangle(k, frame);
			source.applyFilter(source, r, r.topLeft, filter);
		}
	}
	
	
	public function multiplayAllAnimDurations(factor:Int) {
		for(g in getGroups())
			if( g.anim.length>0 ) {
				var old = g.anim.copy();
				g.anim = [];
				for(f in old)
					for(i in 0...factor)
						g.anim.push(f);
			}
	}
	
	
	//public function offsetOneBasedFrames() {
		//for(g in groups) {
			//for(i in 1...g.frames.length)
				//g.frames[i-1] = g.frames[i];
			//g.frames.pop();
				//
			//for(i in 0...g.anim.length)
				//g.anim[i] = g.anim[i]-1;
		//}
	//}
	
	public function toString() {
		var l = [];
		for( k in getGroups().keys() ) {
			var g = getGroup(k);
			l.push(k+" ("+g.maxWid+"x"+g.maxHei+") : "+g.frames.length+" frame(s), "+(g.anim.length==0 ? "noAnim" : "animated("+g.anim.length+"f)" ));
		}
		return l.join("\n");
	}
		
	#end
	
	public static function parseAnimDefinition(animDef:String,?timin=1) {
		animDef = StringTools.replace(animDef, ")", "(");
		var frames : Array<Int> = new Array();
		var parts = animDef.split(",");
		for (p in parts) {
			var curTiming = timin;
			if( p.indexOf("(")>0 ) {
				var t = Std.parseInt( p.split("(")[1] );
				if( Math.isNaN(t) )
					throw SLBError.InvalidFrameDuration(p);
				curTiming = t;
				p = p.substr( 0, p.indexOf("(") );
			}
			if( p.indexOf("-")<0 ) {
				var f = Std.parseInt(p);
				for(i in 0...curTiming)
					frames.push(f);
				continue;
			}
			if( p.indexOf("-")>0 ) {
				var from = Std.parseInt(p.split("-")[0]);
				var to = Std.parseInt(p.split("-")[1])+1;
				if( to<from )
					throw SLBError.EndFrameLower(p);
				while( from<to ) {
					for(i in 0...curTiming)
						frames.push(from);
					from++;
				}
				continue;
			}
			throw SLBError.InvalidFrames(p);
		}
		return frames;
	}
	
			
	public function __defineAnim(?group:String, anim:Array<Int>) {
		#if !macro
		if( currentGroup==null && group==null )
			throw SLBError.NoCurrentGroup;
		
		if( group!=null )
			setCurrentGroup(group);
			
		var a = [];
		for(f in anim) {
			if( f>=currentGroup.frames.length )
				throw SLBError.AnimFrameExceeds(currentGroup.id, "["+anim.join(",")+"] "+currentGroup.frames.length, f);
			a.push(f);
		}
			
		currentGroup.anim = a;
		#end
	}
	
	
	
	
	#if macro
	static function error( ?msg="", p : Position ) {
		haxe.macro.Context.error(msg, p);
	}
	#end
	
	
	/* MACRO : Animation declaration ********************************************************************************************
	 *
	 * SYNTAX 1: frame[(optional_duration)], frame[(optional_duration)], ...
	 * SYNTAX 2: begin-end[(optional_duration)], begin-end[(optional_duration)], ...
	 *
	 * EXAMPLE: defineAnim( "walk", "0-5, 6(2), 7(1)" );
	 */
	public macro function defineAnim(ethis:Expr, ?groupName:String, ?baseFrame:Int, ?animDefinition:Expr) : Expr {
		var p = ethis.pos;
		var def = animDefinition;
		
		function parseError(str:String) {
			error(str + "\nSYNTAX: frame[(duration)], frame[(duration)], begin-end([duration]), ...", def.pos);
		}
		
		// Parameters
		if( isNull(def) && groupName==null )
			error("missing anim declaration", p);
			
		if( isNull(def) && groupName!=null ) {
			def = {expr:EConst(CString(groupName)), pos:p};
			groupName = null;
		}
			
		if( baseFrame==null )
			baseFrame = 0;
			
		if( isNull(def) )
			parseError("animation definition is required");
			
		var str = switch(def.expr) {
			case EConst(c) :
				switch( c ) {
					case CString(s) : s;
					default :
						parseError("a constant string is required here");
						null;
				}
			default :
				parseError("a constant string is required here");
				null;
		}
		
		var frames : Array<Int> = try{ parseAnimDefinition(str); } catch(e:Dynamic) { parseError(e); null; }
		
		var eframes = Lambda.array(Lambda.map(frames, function(f) return { pos:p, expr:EConst( CInt(Std.string(f)) ) } ));
		var arrayExpr = { pos:p, expr:EArrayDecl(eframes) };
		
		if( groupName==null )
			return macro $ethis.__defineAnim($arrayExpr);
		else {
			var groupExpr = { pos:p, expr:EConst(CString(groupName)) };
			return macro $ethis.__defineAnim($groupExpr, $arrayExpr);
		}
	}
	
	
	#if macro
	static function isNull(e:Expr) {
		switch(e.expr) {
			case EConst(c) :
				switch( c ) {
					case CIdent(v) : return v=="null";
					default :
						return false;
				}
			default :
				return false;
		}
	}
	#end
	
	#if !macro
	public static inline function updateAll(?tmod=1.0) {
		BSprite.updateAll( tmod );
	}
	#end
}



