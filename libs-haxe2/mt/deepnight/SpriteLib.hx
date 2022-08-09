package mt.deepnight;

import flash.display.BitmapData;



/** SPRITE ********************************************************************************************/

class DSprite extends flash.display.Sprite {
	public static var ALL : List<DSprite> = new List();
	
	public var lib		: Null<SpriteLib>;
	public var libGroup	: Null<String>;
	public var frame	: Int;
	var pt0				: flash.geom.Point;
	public var centerX	: Float;
	public var centerY	: Float;
	
	var animStep		: Int;
	var animCpt			: Float;
	var animId			: Null<String>;
	var anim			: Null<SpriteAnimation>;
	var animPlays		: Int;
	public var onEndAnim		: Null<Void->Void>;
	public var onLoopAnim		: Null<Void->Void>;
	public var fl_killOnEndPlay	: Bool;
	public var defaultAnim		: Null<String>;
	
	var fl_update		: Bool;
	
	public function new(?l:SpriteLib, ?g:String, ?frame=0) {
		super();
		lib = l;
		libGroup = g;
		if( lib!=null ) {
			centerX = lib.defaultCenterX;
			centerY = lib.defaultCenterY;
		}
		else
			centerX = centerY = 0;
		animCpt = 0;
		fl_killOnEndPlay = false;
		pt0 = new flash.geom.Point(0, 0);
		cacheAsBitmap = false;
		setFrame(frame);
	}
	
	public override function toString() {
		return "DSprite "+libGroup+"["+frame+"]";
	}
	
	public function changeSource(lib:SpriteLib, libGroup:String, ?frame=0) {
		this.lib = lib;
		this.libGroup = libGroup;
		setFrame(frame);
	}
	
	public inline function setFrame(f) {
		frame = f;
		redraw();
	}
	
	public inline function setCenter(cx,cy) {
		centerX = cx;
		centerY = cy;
		redraw();
	}
	
	public inline function redraw() {
		graphics.clear();
		if(libGroup!=null) {
			lib.drawIntoGraphics(graphics, libGroup, frame, centerX, centerY);
			graphics.endFill();
		}
	}
	
	public inline function getFrame() {
		return frame;
	}

	public inline function totalFrames() {
		return lib.getGroup(libGroup).length;
	}
	
	inline function startUpdates() {
		if(!fl_update)
			ALL.push(this);
		fl_update = true;
	}
	inline function stopUpdates() {
		if(fl_update)
			ALL.remove(this);
		fl_update = false;
	}
	
	inline public function destroy() {
		if(parent!=null)
			parent.removeChild(this);
		stopUpdates();
	}
	
	public function stopAnim(frame:Int) {
		anim = null;
		animId = null;
		setFrame(frame);
		stopUpdates();
		if( defaultAnim!=null )
			playAnim(defaultAnim);
	}
	
	public function playAnim(id:String, ?plays=999999) {
		if(id==animId)
			return;
		animId = id;
		animCpt = 0;
		animStep = 0;
		animPlays = plays;
		anim = lib.getAnim(id);
		startUpdates();
		setFrame(anim.frames[0]);
	}
	
	public inline  function offsetAnimFrame() {
		animStep = Std.random(anim.frames.length);
	}
	
	public inline function isPlaying(id) {
		return animId==id;
	}
	
	public inline function hasAnim() {
		return animId!=null;
	}
	
	public inline function nextAnimFrame() {
		animCpt = 9999999;
		updateAnim();
	}
	
	inline function getStepDuration() {
		return anim==null ? 0 : ( animStep<anim.durations.length ? anim.durations[animStep] : anim.durations[anim.durations.length-1] );
	}
	
	function updateAnim(?tmod=1.0) { // requis seulement en cas d'anim
		if( anim==null )
			return;
		animCpt+=tmod;
		
		var duration = getStepDuration();
		do {
			if(animCpt>duration) {
				animCpt-=duration;
				if(animStep+1>=anim.frames.length) {
					animStep = 0;
					animPlays--;
					if(animPlays<=0) {
						if(fl_killOnEndPlay)
							destroy();
						else
							stopAnim(0);
						if( onEndAnim!=null ) {
							var cb = onEndAnim;
							onEndAnim = null;
							cb();
						}
					}
					else {
						setFrame(anim.frames[0]);
						if( onLoopAnim!=null )
							onLoopAnim() ;
					}
				}
				else {
					animStep++;
					setFrame(anim.frames[animStep]);
				}
			}
			duration = getStepDuration();
		} while( anim!=null && animCpt > duration );
	}
	
	
	public static inline function updateAll(?tmod=1.0) {
		var all = ALL;
		for(s in all)
			s.updateAnim(tmod);
	}
}




/** LIBRARY ********************************************************************************************/


typedef SpriteAnimation = {frames:Array<Int>, durations:Array<Int>};

class SpriteLib {
	public var bmp				: BitmapData;
	var groups					: Hash<Array<flash.geom.Rectangle>>;
	var anims					: Hash<SpriteAnimation>;
	var lastGroup				: Null<String>;
	var frameRandDraw			: Hash<Array<Int>>;
	public var defaultCenterX	: Float;
	public var defaultCenterY	: Float;
	var sliceUnitX				: Int;
	var sliceUnitY				: Int;
	
	public function new(bd:BitmapData) {
		bmp = bd;
		groups = new Hash();
		anims = new Hash();
		frameRandDraw = new Hash();
		lastGroup = null;
		defaultCenterX = 0.5;
		defaultCenterY = 1;
		setUnit(1);
	}
	
	public function setUnit(ux:Int, ?uy:Null<Int>) {
		sliceUnitX = ux;
		sliceUnitY = if(uy==null) ux else uy;
	}
	
	public function setDefaultCenter(cx,cy) {
		defaultCenterX = cx;
		defaultCenterY = cy;
	}
	
	public inline function getGroup(?k:String) {
		if(k==null) {
			k = lastGroup;
			if(lastGroup==null)
				throw "No group selected previously";
		}
		return
			if(groups.exists(k))
				groups.get(k);
			else
				throw "Unknown group "+k;
	}
	
	public inline function getGroups() {
		return groups;
	}
	
	public inline function getAnim(id) {
		return anims.get(id);
	}
	
	public inline function getAnimDuration(id) {
		var a = getAnim(id);
		var d = 0;
		for(f in 0...a.frames.length)
			d+=f>=a.durations.length ? a.durations[a.durations.length-1] : a.durations[f];
		return d;
	}
	
	public inline function setGroup(k:String) {
		lastGroup = k;
		if(!groups.exists(k))
			groups.set(k, new Array());
		return getGroup();
	}
	
	public function setAnim(animId:String, ?baseFrame:Int, frames:Array<Int>, durations:Array<Int>) {
		var frames = frames.copy();
		var durations = durations.copy();
		if( baseFrame!=null )
			for(i in 0...frames.length)
				frames[i]+=baseFrame;
		anims.set(animId, {
			frames		: frames,
			durations	: durations,
		});
	}
	
	public inline function setWeights(?k:String, weights:Array<Int>) {
		if(k==null)
			k = lastGroup;
		if(!frameRandDraw.exists(k))
			frameRandDraw.set(k, new Array());
		
		var a = frameRandDraw.get(k);
		for(f in 0...weights.length)
			for(i in 0...weights[f])
				a.push(f);
	}
	
	public inline function getRectangle(k:String, ?frame=0) {
		return getGroup(k)[frame];
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
		return getGroup(k).length;
	}
	
	public inline function exists(k, ?frame=0) {
		if( !groups.exists(k) )
			return false;
		else if( frame>=getGroup(k).length )
			return false;
		else
			return true;
	}
	
	public inline function getSprite(k:String, ?frame=0) : DSprite {
		return new DSprite(this, k, frame);
	}
	
	public inline function getSpriteAnimated(k:String, animId:String, ?plays=9999999) : DSprite {
		var s = new DSprite(this, k);
		s.playAnim(animId, plays);
		return s;
	}
	
	public inline function getSpriteRandom(k:String, ?randFunc:Int->Int) : DSprite {
		return getSprite(k, getRandomFrame(k, randFunc));
	}
	
	public inline function getMC(k:String, ?frame=0, ?centerX, ?centerY) : flash.display.MovieClip {
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
		g.beginBitmapFill(bmp, m, false, false);
		g.drawRect(Std.int(-centerX*rect.width), Std.int(-centerY*rect.height), rect.width, rect.height);
		g.endFill();
	}
	
	public inline function drawIntoBitmap(bd:flash.display.BitmapData, x:Int,y:Int, k:String, ?frame=0, ?centerX, ?centerY) {
		if(centerX==null)	centerX = defaultCenterX;
		if(centerY==null)	centerY = defaultCenterY;
		var r = getRectangle(k, frame);
		bd.copyPixels(
			bmp, r,
			new flash.geom.Point(x-Std.int(r.width*centerX), y-Std.int(r.height*centerY)),
			true
		);
	}
	
	public function getBitmapData(k:String, ?frame=0, ?padding=0) {
		var r = getRectangle(k, frame);
		var bd = new BitmapData(Std.int(r.width+padding*2), Std.int(r.height+padding*2), true, 0x0);
		drawIntoBitmap(bd, padding,padding, k,frame, 0,0);
		return bd;
	}
	
	public inline function paintIntoBitmap(k:String, ?idx:Null<Int>=0, bd:BitmapData, pt:flash.geom.Point) {
		bd.copyPixels( bmp, getGroup(k)[idx], pt, true );
	}
	
	public function slice(?group:String, x:Int, y:Int, w:Int, h:Int, ?repeatX=1, ?repeatY=1) {
		var g = if( group==null ) getGroup() else setGroup(group);
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.push( new flash.geom.Rectangle(x+ix*w, y+iy*h, w, h) );
	}
	
	public function sliceUnit(?group:String, xu:Int,yu:Int, ?repeatX=1, ?repeatY=1) {
		var g = if( group==null ) getGroup() else setGroup(group);
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.push( new flash.geom.Rectangle(xu*sliceUnitX + ix*sliceUnitX, yu*sliceUnitY + iy*sliceUnitY, sliceUnitX, sliceUnitY) );
	}
	
	public function sliceUnitCustom(?group:String, xu:Int,yu:Int, w:Int, h:Int, ?repeatX=1, ?repeatY=1) {
		var g = if( group==null ) getGroup() else setGroup(group);
		for(iy in 0...repeatY)
			for(ix in 0...repeatX)
				g.push( new flash.geom.Rectangle(xu*sliceUnitX + ix*w, yu*sliceUnitY + iy*h, w, h) );
	}
	
	public function sliceWithMultipleKeys(keys:Array<String>, x:Int, y:Int, w:Int, h:Int, ?repeatX=1, ?repeatY=1) {
		if(keys.length!=repeatX*repeatY)
			throw "Invalid number of keys";
		for(iy in 0...repeatY)
			for(ix in 0...repeatX) {
				var k = keys.shift();
				setGroup(k);
				getGroup().push( new flash.geom.Rectangle(x+ix*w, y+iy*h, w, h) );
			}
	}
}

