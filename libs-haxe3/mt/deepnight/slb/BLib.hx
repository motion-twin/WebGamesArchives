package mt.deepnight.slb;

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

#if (h3d && !macro)
import h2d.SpriteBatch;
#end


#if !macro

//This should become a class for fast cpp rendering (typedef is slow)
typedef FrameData = {
	x			: Int,
	y			: Int,
	wid			: Int,
	hei			: Int,
	realFrame	: {x:Int, y:Int, realWid:Int, realHei:Int},
	rect		: Rectangle,
	?pX			: Float,
	?pY			: Float,
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
	NoGroupSelected;
	GroupAlreadyExists(g:String);
	//WidthMismatch(f:Int, g:String);
	//HeightMismatch(f:Int, g:String);
	InvalidFrameDuration(s:String);
	EndFrameLower(s:String);
	InvalidFrames(s:String);
	NoCurrentGroup;
	AnimFrameExceeds(id:String, anim:String, frame:Int);
	AssetImportFailed(e:Dynamic);
	NotSameSLBFromBatch;
}


/** LIBRARY ********************************************************************************************/

class BLib {
	#if !macro
	public var source			: BitmapData;
	/* TODO PERF
	 * use something like
	 * typedef StringMap<T> = #if flash
		haxe.ds.UnsafeStringMap<T>
		#else
		haxe.ds.StringMap<T>
		#end
	it will avoid many allocs
	 */
	var groups					: Map<String, LibGroup>;
	var currentGroup			: Null<LibGroup>;
	var frameRandDraw			: Map<String, Array<Int>>;
	public var defaultCenterX(default, null)	: Float;
	public var defaultCenterY(default, null)	: Float;
	var gridX					: Int;
	var gridY					: Int;
	var children				: Array<SpriteInterface>;
	var attachPoints			: Map<String, Map<Int, Map<Int, {dx:Float, dy:Float}>>>; // Usage: attachPoints.get(animId).get(frame).get(color).dx/dy

	var bdGroups				: Map<String, Array<BitmapData>>;

	#if h3d
	public var tile				: h2d.Tile;
	public var texture			: h3d.mat.Texture;
	static var GUID = 0;
	var id = 0;
	#end

	public function new(bd:BitmapData #if h3d, ?tile:h2d.Tile #end) {
		source = bd;
		groups = new Map();
		bdGroups = new Map();
		frameRandDraw = new Map();
		defaultCenterX = 0;
		defaultCenterY = 0;
		gridX = gridY = 16;
		children = [];

		#if h3d
		id =++GUID;
		if( tile == null)
			genTex();
		else {
			this.tile = tile;
			texture = tile.getTexture();
		}
		hxd.System.trace2("Blib:creating texture:" + id);
		#end
	}

	public function initBdGroups() {
		for( frames in bdGroups )
			for( bd in frames ) {
				bd.dispose();
				bd = null;
			}

		bdGroups = new Map();
		var pt0 = new Point();
		for(g in groups) {
			bdGroups.set(g.id, []);
			for(f in 0...g.frames.length) {
				var frameData = getFrameData(g.id, f);
				var bd = new BitmapData(g.maxWid, g.maxHei, true, 0x0);
				bd.copyPixels( source, frameData.rect, pt0,null,null, false );
				bdGroups.get(g.id).push(bd);
			}
		}
	}

	public inline function getCachedBitmapData(k:String, ?f=0) {
		if( bdGroups.exists(k) )
			return bdGroups.get(k)[f];
		else
			throw "SLB: You must call initBdGroups()";
	}

	#if h3d
	function genTex() {
		if ( h3d.Engine.getCurrent() != null ) {
			hxd.Profiler.begin("genTex");
			hxd.Profiler.begin("genTex.loadCpu");

			var bmd = hxd.BitmapData.fromNative(source);
			hxd.Profiler.end("genTex.loadCpu");
			hxd.Profiler.begin("genTex.loadGpu");
			tile = h2d.Tile.fromBitmap( bmd );
			hxd.Profiler.end("genTex.loadGpu");
			var tex = texture = tile.getTexture();
			tex.name = 'slb.Blib #$id';

			hxd.Profiler.end("genTex");
		}
	}

	public function addBatchElement(sb:SpriteBatch, ?priority:Int=0, k:String, frame:Int, ?xr=0.0, ?yr=0.0) : Null<h2d.SpriteBatch.BatchElement> {
		if (sb.tile.getTexture() != tile.getTexture())
			throw SLBError.NotSameSLBFromBatch;

		var be = sb.alloc(tile, priority);
		var fd = getFrameData(k, frame);
		if( fd==null )
			throw 'Unknown group $k#$frame!';

		be.tile.setPos(fd.x, fd.y);
		be.tile.setSize(fd.wid, fd.hei);

		#if fixCenter
		be.tile = be.tile.center(
			Std.int(fd.realFrame.x + fd.realFrame.realWid*xr),
			Std.int(fd.realFrame.y + fd.realFrame.realHei*yr)
		);
		#else
		be.tile = be.tile.center(fd.realFrame.x, fd.realFrame.y);
		be.tile.setCenterRatio(xr,yr);
		#end

		return be;
	}

	public function addColoredBatchElement(sb:SpriteBatch, ?priority=0, k:String, col:UInt, ?alpha=1.0) {
		var e = addBatchElement(sb, priority, k, 0);
		e.color = h3d.Vector.fromColor( Color.addAlphaF(col, alpha), 1 );
		return e;
	}

	public function addBatchElementRandom(sb:SpriteBatch, k:String, ?xr=0.0, ?yr=0.0, ?rndFunc:Int->Int) : Null<h2d.SpriteBatch.BatchElement> {
		return addBatchElement(sb, k, getRandomFrame(k, rndFunc), xr,yr);
	}

	/**
	 * Experimental
	 * @param	factor of growth of the flash.display.BitmapData
	 */
	#if false
	public function scale(factor:Float) {
		if ( factor > 1.0 )
			hxd.System.trace1("WARNING : upscale not uspported because we have to process if bitmap will exceeed max engine size");

		texture.dispose();

		var oldSource = source;
		var newSource = mt.gx.Scaler.resize( source, Math.round(source.width * factor), Math.round(source.height * factor ));
		for ( g in getGroups()) {
			//g.id
			for (fd in g.frames ) {
				fd.x = Math.round( fd.x * factor );
				fd.y = Math.round( fd.y * factor );

				fd.wid = Math.round( fd.wid * factor );
				fd.hei = Math.round( fd.hei * factor );

				fd.realFrame.x = Math.round( fd.realFrame.x * factor );
				fd.realFrame.y = Math.round( fd.realFrame.y * factor );

				fd.realFrame.realWid = Math.round( fd.realFrame.realWid * factor );
				fd.realFrame.realHei = Math.round( fd.realFrame.realHei * factor );
			}
			g.maxWid = Math.round( g.maxWid * factor);
			g.maxHei = Math.round( g.maxHei * factor);
		}

		#if flash
		texture.flags.set( AlphaPremultiplied );
		#end
		texture.uploadBitmap(hxd.BitmapData.fromNative(newSource));
		oldSource.dispose();
	}
	#end
	#end


	public function destroy() {
		if( source!=null)
			source.dispose();
		source = null;

		attachPoints = null;

		while( children.length>0 )
			children[0].dispose();

		for(frames in bdGroups)
			for(bd in frames)
				bd.dispose();
		bdGroups = null;
	}


	public inline function get(k:String, ?frame=0, ?xr=0.0, ?yr=0.0, ?p:flash.display.DisplayObjectContainer) : BSprite {
		var s = new BSprite(this, k, frame);
		s.setCenterRatio(xr,yr);
		if( p!=null )
			p.addChild(s);
		return s;
	}

	#if h3d
	public inline function h_get(k:String, ?frame=0, ?xr=0., ?yr=0., ?filter:Null<Bool>, ?p:h2d.Sprite) : HSprite {
		var s = new HSprite(this, k, frame);
		if( p!=null )
			p.addChild(s);
		s.setCenterRatio(xr,yr);
		if( filter!=null )
			s.filter = filter;
		return s;
	}

	public inline function hbe_get(sb:SpriteBatch, k:String, ?frame=0, ?xr=0., ?yr=0.) : HSpriteBE {
		var e = new HSpriteBE(sb, this, k, frame);
		e.setCenterRatio(xr,yr);
		return e;
	}

	public inline function getColoredH2dBitmap(k:String, col:UInt, ?alpha=1.0, ?filter:Null<Bool>, ?parent:h2d.Sprite) {
		var e = getH2dBitmap(k, filter, parent);
		e.color = h3d.Vector.fromColor(mt.deepnight.Color.addAlphaF(col, alpha),1);
		return e;
	}

	public inline function getH2dBitmap(k:String, ?frame=0, ?xr=0.0, ?yr=0.0, ?filter:Null<Bool>, ?parent:h2d.Sprite, ?sh:h2d.Drawable.DrawableShader) : h2d.Bitmap {
		if( !exists(k,frame) )
			throw "Unknown group "+k+"#"+frame;
		var b = new h2d.Bitmap( getTile(k,frame), sh );
		if( parent!=null )
			parent.addChild(b);

		var fd = getFrameData(k,frame);
		#if fixCenter
		b.tile = b.tile.center(
			Std.int(fd.realFrame.x + fd.realFrame.realWid*xr),
			Std.int(fd.realFrame.y + fd.realFrame.realHei*yr)
		);
		#else
		b.tile.setCenterRatio(xr,yr);
		#end

		if( filter!=null )
			b.filter = filter;
		return b;
	}
	#end


	public function getAndPlay(k:String, ?plays=99999, ?killAfterPlay=false) : BSprite {
		var s = new BSprite(this);
		s.a.play(k, plays);
		if( killAfterPlay )
			s.a.killAfterPlay();
		return s;
	}

	#if h3d
	public inline function h_getAndPlay(k:String, ?plays=99999, ?killAfterPlay=false, ?p:h2d.Sprite) : HSprite {
		var s = h_get(k, p);
		s.a.play(k, plays);
		if( killAfterPlay )
			s.a.killAfterPlay();
		return s;
	}

	public inline function hbe_getAndPlay(sb:SpriteBatch, k:String, plays=99999, ?killAfterPlay=false) : HSpriteBE {
		var s = hbe_get(sb, k);
		s.a.play(k, plays);
		if( killAfterPlay )
			s.a.killAfterPlay();
		return s;
	}
	#end



	public inline function getRandom(k:String, ?rndFunc:Int->Int) : BSprite {
		return get(k, getRandomFrame(k, rndFunc));
	}

	#if h3d
	public inline function h_getRandom(k, ?rndFunc, ?p:h2d.Sprite) : HSprite {
		return h_get(k, getRandomFrame(k, rndFunc), p);
	}
	public inline function hbe_getRandom(sb:SpriteBatch, k, ?rndFunc) : HSpriteBE {
		return hbe_get(sb, k, getRandomFrame(k, rndFunc));
	}
	#end



	#if h3d
	#if !debug inline #end
	public function getTileRandom(g:String, ?px:Float=0.0,?py:Float=0.0, ?rndFunc) : h2d.Tile {
		return getTile(g, getRandomFrame(g,rndFunc), px, py);
	}

	public function getTile(g:String, ?frame=0, ?px:Float=0.0,?py:Float=0.0) : h2d.Tile {
		var fd = getFrameData(g, frame);
		#if debug
		if ( fd == null)
			throw 'Unknown group $g#$frame!';
		#end
		var t = tile.clone();
		t.setPos(fd.x, fd.y);
		t.setSize(fd.wid, fd.hei);

		t.dx = -Std.int( (fd.realFrame.realWid + fd.realFrame.x)*px );
		t.dy = -Std.int( (fd.realFrame.realHei + fd.realFrame.y)*py );

		return t;
	}

	public function getTileWithPivot(g:String, ?frame = 0) : h2d.Tile {
		var fd = getFrameData(g, frame);
		if ( fd.pX == null && fd.pY == null ) return getTile(g, frame);

		#if debug
		if ( fd == null)
			throw 'Unknown group $g#$frame!';
		#end
		var t = tile.clone();
		t.setPos(fd.x, fd.y);
		t.setSize(fd.wid, fd.hei);
		t.setCenterRatio( fd.pX==null?0:fd.pX, fd.pX==null?0:fd.pY );

		return t;
	}

	public inline function getRandomTile(g:String, ?rndFunc:Int->Int, px:Float=0.0,py:Float=0.0) : h2d.Tile {
		var fd = getFrameData(g, getRandomFrame(g, rndFunc));
		var t = tile.clone();
		t.setPos(fd.x, fd.y);
		t.setSize(fd.wid, fd.hei);
		t.dx = -Std.int( (fd.realFrame.realWid + fd.realFrame.x)*px );
		t.dy = -Std.int( (fd.realFrame.realHei + fd.realFrame.y)*py );
		return t;
	}
	#end

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
			if(k==null )
				currentGroup;
			else
				groups.get(k);
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


	public function getRectangle(k:String, ?frame=0) : Null<flash.geom.Rectangle> {
		var g = getGroup(k);
		if( g==null )
			return null;

		var fr = g.frames[frame];
		if ( fr == null)
			return null;

		return new flash.geom.Rectangle(fr.x, fr.y, fr.wid, fr.hei);
	}

	public inline function getFrameData(k:String, ?frame = 0) : Null<FrameData> {
		var g = getGroup(k);
		if( g==null )
			return null;
		else
			return g.frames[frame];
	}

	public inline function exists(k:String,?frame=0) {
		return k!=null && frame>=0 && groups.exists(k) && groups.get(k).frames.length>frame;
	}

	public function getRandomFrame(k:String, ?rndFunc:Int->Int) {
		if(rndFunc==null)
			rndFunc = Std.random;

		return
			if(frameRandDraw.exists(k)) {
				var a = frameRandDraw.get(k);
				a[ rndFunc(a.length) ];
			}
			else
				rndFunc(countFrames(k));
	}

	public inline function countFrames(k:String) {
		return getGroup(k).frames.length;
	}

	public inline function getMovieClip(k:String, ?frame=0, ?centerX, ?centerY) : flash.display.MovieClip {
		var mc = new flash.display.MovieClip();
		drawIntoGraphics(mc.graphics, k, frame, centerX, centerY);
		return mc;
	}

	public inline function drawIntoGraphics(g:flash.display.Graphics, k:String, ?frame=0, ?centerX, ?centerY) {
		if(centerX==null)	centerX = defaultCenterX;
		if(centerY==null)	centerY = defaultCenterY;

		var fdata = getFrameData(k,frame);
		var m = new flash.geom.Matrix();
		m.translate( -fdata.realFrame.x-Std.int(fdata.realFrame.realWid*centerX), -fdata.realFrame.y-Std.int(fdata.realFrame.realHei*centerY) );
		g.beginBitmapFill(source, m, false, false);
		g.drawRect(Std.int(-centerX*fdata.rect.width), Std.int(-centerY*fdata.rect.height), fdata.rect.width, fdata.rect.height);
		g.endFill();
	}

	public function drawIntoBitmap(bd:flash.display.BitmapData, x:Float,y:Float, k:String, ?frame=0, ?centerX, ?centerY) {
		if(centerX==null)	centerX = defaultCenterX;
		if(centerY==null)	centerY = defaultCenterY;

		var fdata = getFrameData(k,frame);
		bd.copyPixels(
			source, fdata.rect,
			new flash.geom.Point(x-fdata.realFrame.x-Std.int(fdata.realFrame.realWid*centerX), y-fdata.realFrame.y-Std.int(fdata.realFrame.realHei*centerY)),
			true
		);
	}

	public inline function drawIntoBitmapRandom(bd:flash.display.BitmapData, x:Float,y:Float, k:String, ?rndFunc:Int->Int, ?centerX, ?centerY) {
		drawIntoBitmap(bd, x,y,k, getRandomFrame(k, rndFunc), centerX, centerY);
	}

	#if !h3d
	public function getBitmapData(k:String, ?frame=0, ?padding=0) {
		var fdata = getFrameData(k, frame);
		var bd = new BitmapData(Std.int(fdata.realFrame.realWid+padding*2), Std.int(fdata.realFrame.realHei+padding*2), true, 0x0);
		drawIntoBitmap(bd, padding,padding, k,frame, 0,0);
		return bd;
	}

	public function getBitmapDataRandom(k:String, ?padding=0, ?rndFunc:Int->Int) {
		if( rndFunc==null )
			rndFunc = Std.random;
		var frame = getRandomFrame(k, rndFunc);
		var fdata = getFrameData(k, frame);
		var bd = new BitmapData(Std.int(fdata.realFrame.realWid+padding*2), Std.int(fdata.realFrame.realHei+padding*2), true, 0x0);
		drawIntoBitmap(bd, padding,padding, k,frame, 0,0);
		return bd;
	}

	public function getAllBitmapDatas(k:String, ?padding=0) {
		var all = [];
		for( i in 0...countFrames(k) )
			all.push( getBitmapData(k, i, padding) );
		return all;
	}
	#end



	public function sliceCustom(groupName:String, frame:Int, x:Int, y:Int, wid:Int, hei:Int, ?realFrame:{x:Int, y:Int, realWid:Int, realHei:Int}, ?pX:Float,?pY:Float) {
		var g = if( exists(groupName) ) getGroup(groupName) else createGroup(groupName);
		g.maxWid = MLib.max( g.maxWid, wid );
		g.maxHei = MLib.max( g.maxHei, hei );

		if( realFrame==null )
			realFrame = {x:0, y:0, realWid:wid, realHei:hei}

		g.frames[frame] = { x:x, y:y, wid:wid, hei:hei, realFrame:realFrame, rect:new Rectangle(x,y,wid,hei),pX:pX,pY:pY };
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

	public function sliceAnim(groupName:String, frameDuration:Int, x:Int, y:Int, wid:Int, hei:Int, ?repeatX=1, ?repeatY=1) {
		slice(groupName, x, y, wid, hei, repeatX, repeatY);
		var frames = [];
		for(f in 0...repeatX*repeatY)
			for(i in 0...frameDuration)
				frames.push(f);
		__defineAnim(groupName, frames);
	}

	public function sliceAnimGrid(groupName:String, frameDuration:Int, gx:Int, gy:Int, ?repeatX=1, ?repeatY=1) {
		sliceGrid(groupName, gx, gy, repeatX, repeatY);
		var frames = [];
		for(f in 0...repeatX*repeatY)
			for(i in 0...frameDuration)
				frames.push(f);
		__defineAnim(groupName, frames);
	}

	//public function sliceMore(x:Int, y:Int, ?repeatX=1, ?repeatY=1) {
		//var g = getGroup();
		//for(iy in 0...repeatY)
			//for(ix in 0...repeatX)
				//g.frames.push({ x : x+ix*g.wid, y : y+iy*g.hei, wid:g.wid, hei:g.hei });
	//}

	public function applyPermanentFilter(k:String, filter:flash.filters.BitmapFilter) {
		for( frame in 0...countFrames(k) ) {
			var fdata = getFrameData(k, frame);
			source.applyFilter(source, fdata.rect, fdata.rect.topLeft, filter);
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



	public function parseAttachPoints(colors:Array<UInt>, dotSpriteSuffix:String) { // TODO classes plutôt qu'objets anonymes
		attachPoints = new Map();
		var dots = new BSprite(this);

		// Usage: attachPoints.get(animId).get(frame).get(color).x/y

		for( g in getGroups() ) {
			var animId = g.id;
			if( animId.indexOf("Dots")>0 )
				continue;

			if( !exists(animId+"Dots") )
				continue;

			attachPoints.set(animId, new Map());

			for( af in 0...getAnim(animId).length ) {
				var sprFrame = getAnim(animId)[af];
				var dotFrame = getAnim(animId+"Dots")[af];
				attachPoints.get(animId).set(sprFrame, new Map());

				// Apply frame
				dots.set(animId+"Dots", dotFrame);
				var dotsFData = getFrameData(dots.groupName, dots.frame);

				// Parse colors positions (delta relative to the pivot [0.5,1.0])
				for(col in colors) {
					var bounds = dots.getBitmapDataReadOnly().getColorBoundsRect(0xFFffffff, Color.addAlphaF(col), true);
					var dx = -dotsFData.realFrame.realWid*0.5 + (bounds.x - dotsFData.realFrame.x);
					var dy = -dotsFData.realFrame.realHei + (bounds.y - dotsFData.realFrame.y);
					if( (bounds.width==0 || bounds.height==0) && dots.getBitmapDataReadOnly().getPixel(0,0)!=col )  // getColorBounds bug fix
						dx = dy = 999;

					attachPoints.get(animId).get(sprFrame).set(col, { dx:dx, dy:dy });
				}
			}
		}

		dots.dispose();
		//for( k in attachPoints.keys() )
			//for( f in attachPoints.get(k).keys() )
				//for( col in attachPoints.get(k).get(f).keys() ) {
					//if( k.indexOf("zombie")==0 && col==0xf63ef6 )
					//trace( k+" frame="+f+" color="+Color.intToHex(col)+" pt="+attachPoints.get(k).get(f).get(col) );
				//}
	}

	public function getAttachPoint(s:SpriteInterface, col:UInt) {
		return attachPoints.get(s.groupName).get(s.frame).get(col);
	}



	public function toString() {
		var l = [];
		for( k in getGroups().keys() ) {
			var g = getGroup(k);
			l.push(k+" ("+g.maxWid+"x"+g.maxHei+") : "+g.frames.length+" frame(s), "+(g.anim.length==0 ? "noAnim" : "animated("+g.anim.length+"f)" ));
		}
		l.sort(function(a,b) return Reflect.compare(a,b));
		return l.join("\n");
	}


	public function addChild(s:SpriteInterface) {
		children.push(s);
	}

	public function removeChild(s:SpriteInterface) {
		children.remove(s);
	}

	public inline function countChildren() {
		return children.length;
	}

	public function updateChildren() {
		for(bs in children)
			if( !bs.destroyed ) {
				bs.a.update();
				if( bs.beforeRender!=null )
					bs.beforeRender();
			}
	}

	#end // End of #if !macro




	/**********************************************
	 * MACRO SECTION
	 **********************************************/

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
}



