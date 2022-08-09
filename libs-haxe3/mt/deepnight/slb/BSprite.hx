package mt.deepnight.slb;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import mt.deepnight.slb.BLib;
import mt.deepnight.slb.AnimManager;
import mt.deepnight.slb.SpriteInterface;


class BSprite extends flash.display.Sprite implements SpriteInterface {
	public var a			: AnimManager;
	public var lib			: BLib;
	public var groupName	: String;
	public var group		: LibGroup;
	public var frame		: Int;
	public var frameData	: FrameData;
	var pivot				: SpritePivot;
	public var destroyed	: Bool;
	public var filter(get,set): Bool;

	public var beforeRender	: Null<Void->Void>;
	public var onFrameChange: Null<Void->Void>;

	private var bmp				: Bitmap;
	public var bitmapVisible	: Bool;
	private var pt0				: flash.geom.Point;

	#if debug
	var debug					: flash.display.Sprite;
	#end


	public function new(?l:BLib, ?g:String, ?frame=0) {
		super();
		destroyed = false;

		bitmapVisible = true;
		this.cacheAsBitmap = false;

		pivot = new SpritePivot();
		a = new AnimManager(this);

		pt0 = new flash.geom.Point();
		bmp = new Bitmap(flash.display.PixelSnapping.NEVER, false);
		addChild(bmp);
		filter = false;

		if( l!=null )
			set(l, g, frame);
	}



	inline function get_filter() return bmp.smoothing;
	inline function set_filter(v) return bmp.smoothing = v;


	public function scale(v:Float) {
		scaleX*=v;
		scaleY*=v;
	}
	public function setScale(v) scaleX = scaleY = v;

	public function clone<T>(?s:T) : T {
		var s = new BSprite(lib, groupName, frame);
		s.pivot = pivot.clone();
		s.applyPivot();
		return cast s;
	}

	public inline function setPos(x:Float,y:Float) {
		this.x = x;
		this.y = y;
	}

	public inline function setSize(w:Float,h:Float) {
		this.width = w;
		this.height = h;
	}

	public function constraintSize(w:Float, ?h:Null<Float>, ?useFrameDataRealSize=false) {
		if( useFrameDataRealSize )
			setScale( MLib.fmin( w/frameData.realFrame.realWid, (h==null?w:h)/frameData.realFrame.realHei ) );
		else
			setScale( MLib.fmin( w/bmp.width, (h==null?w:h)/bmp.height ) );
	}

	public override function toString() {
		return "BSprite_"+groupName+"["+frame+"]";
	}

	public function set(?l:BLib, ?g:String, ?frame=0, ?stopAllAnims=false) {
		if( l!=null ) {
			if( lib!=null )
				lib.removeChild(this);
			lib = l;
			lib.addChild(this);

			if( g==null ) {
				groupName = null;
				group = null;
				frameData = null;
			}

			if( pivot.isUndefined )
				setCenterRatio(lib.defaultCenterX, lib.defaultCenterY);
		}

		if( g!=null && g!=groupName )
			groupName = g;

		if( isReady() ) {
			if( stopAllAnims )
				a.stopWithoutStateAnims();

			group = lib.getGroup(groupName);
			frameData = lib.getFrameData(groupName, frame);
			if( frameData==null )
				throw 'Unknown frame: $groupName($frame)';
			initBitmap();
			setFrame(frame);
		}
	}



	public inline function setRandom(?l:BLib, g:String, rndFunc:Int->Int) {
		set(l, g, lib.getRandomFrame(g, rndFunc));
	}

	public inline function setRandomFrame(?rndFunc:Int->Int) {
		if( isReady() )
			setRandom(groupName, rndFunc==null ? Std.random : rndFunc);
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

	public inline function isGroup(k) {
		return groupName==k;
	}

	public inline function is(k, f) {
		return groupName==k && frame==f;
	}

	public inline function isReady() {
		return !destroyed && groupName!=null;
	}

	public function setFrame(f:Int) {
		var old = frame;
		frame = f;

		if( isReady() ) {
			var prev = frameData;
			frameData = lib.getFrameData(groupName, frame);
			if( frameData==null )
				throw 'Unknown frame: $groupName($frame)';

			bmp.bitmapData = lib.getCachedBitmapData(groupName, frame);
			bmp.smoothing = true;
			applyPivot();

			if( onFrameChange!=null )
				onFrameChange();
		}
	}

	public inline function setPivotCoord(x:Float, y:Float) {
		pivot.setCoord(x, y);
		applyPivot();
	}

	public inline function setCenterRatio(xRatio:Float, yRatio:Float) {
		pivot.setCenterRatio(xRatio, yRatio);
		applyPivot();
	}


	inline function applyPivot() {
		if( !isReady() )
			return;

		if( pivot.isUsingCoord() ) {
			bmp.x = MLib.round(-pivot.coordX - frameData.realFrame.x);
			bmp.y = MLib.round(-pivot.coordY - frameData.realFrame.y);
		}
		else if( pivot.isUsingFactor() ) {
			bmp.x = Std.int(-frameData.realFrame.realWid*pivot.centerFactorX - frameData.realFrame.x);
			bmp.y = Std.int(-frameData.realFrame.realHei*pivot.centerFactorY - frameData.realFrame.y);
		}

		#if debug
		updateDebug();
		#end
	}


	public function totalFrames() {
		return group.frames.length;
	}





	/* BSprite-specific internal implementation ***************************/

	public inline function getBitmapDataReadOnly() return bmp.bitmapData;

	function set_bitmapVisible(v) {
		bitmapVisible = v;
		if( bmp!=null )
			bmp.visible = bitmapVisible;
		return v;
	}

	function initBitmap() {
		if( !isReady() )
			return;

		bmp.visible = bitmapVisible;
		applyPivot();
	}


	#if debug
	public function enableDebug() {
		if( debug!=null )
			debug.parent.removeChild(debug);

		debug = new flash.display.Sprite();
		addChild(debug);
	}

	inline function updateDebug() {
		if( debug!=null ) {
			var g = debug.graphics;
			g.clear();

			// Pivot
			g.lineStyle(1,0xFFFF00,0.8, true, flash.display.LineScaleMode.NONE);
			g.moveTo(0,-3);
			g.lineTo(0,3);
			g.moveTo(-3,0);
			g.lineTo(3,0);

			// Real frame bounds
			g.lineStyle(1,0xFF77FF,0.8, true, flash.display.LineScaleMode.NONE);
			g.drawRect(bmp.x+frameData.realFrame.x, bmp.y+frameData.realFrame.y, frameData.realFrame.realWid, frameData.realFrame.realHei);

			// Bitmap bounds
			g.lineStyle(0,0,0);
			g.beginFill(0x00FFFF,0.3);
			g.drawRect(bmp.x, bmp.y, bmp.width, bmp.height);
			g.endFill();

			// Current frame bounds
			g.lineStyle(1,0x00FFFF,0.8, true, flash.display.LineScaleMode.NONE);
			g.drawRect(bmp.x, bmp.y, frameData.wid, frameData.hei);
		}
	}
	#end

	override function removeChildren(f=0, t=2147483647) {
		var i = 0;
		while( i<numChildren ) {
			var e = getChildAt(i);
			if( Std.is(e, SpriteInterface) )
				cast(e, SpriteInterface).dispose();
			else
				i++;
		}

		super.removeChildren(f,t);
	}

	public function dispose() {
		if( !destroyed ) {
			destroyed = true;

			if( lib!=null )
				lib.removeChild(this);

			if(parent!=null)
				parent.removeChild(this);

			bmp.parent.removeChild(bmp);
			bmp.bitmapData = null; // do not dispose!
			bmp = null;

			removeChildren();

			destroyed = true;
			a.destroy();
			a = null;
			lib = null;
			frameData = null;
			group = null;
			groupName = null;
			pivot = null;
			beforeRender = null;
			onFrameChange = null;
		}
	}
}

