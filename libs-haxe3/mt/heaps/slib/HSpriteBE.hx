package mt.heaps.slib;

import h2d.Drawable;
import h2d.SpriteBatch;
import mt.heaps.slib.SpriteLib;
import mt.heaps.slib.SpriteInterface;
import mt.MLib;

class HSpriteBE extends BatchElement implements SpriteInterface {
	public var anim			: AnimManager;
	public var lib			: SpriteLib;
	public var groupName	: String;
	public var group		: LibGroup;
	public var frame		: Int;
	public var frameData	: FrameData;
	public var pivot		: SpritePivot;
	public var destroyed	: Bool;

	public var beforeRender	: Null<Void->Void>;
	public var onFrameChange: Null<Void->Void>;

	public function new(sb:SpriteBatch, l:SpriteLib, g:String, ?f=0) {
		super( l.tile.clone() );
		destroyed = false;

		pivot = new SpritePivot();
		anim = new AnimManager(this);

		sb.add(this);
		set(l,g,f);
	}

	public function toString() return "HSpriteBE_"+groupName+"["+frame+"]";

	public inline function set( ?l:SpriteLib, ?g:String, ?f=0, ?stopAllAnims=false ) {
		var changed = false;
		if( l!=null && lib!=l ) {
			changed = true;
			// Reset existing frame data
			if( g==null ) {
				groupName = null;
				group = null;
				frameData = null;
			}

			// Register SpriteLib
			if( lib!=null )
				lib.removeChild(this);
			lib = l;
			lib.addChild(this);
			if( pivot.isUndefined )
				setCenterRatio(lib.defaultCenterX, lib.defaultCenterY);
		}

		if( g!=null && g!=groupName ) {
			changed = true;
			groupName = g;
		}

		if( f!=null && f!=frame ) {
			changed = true;
			frame = f;
		}

		if( isReady() && changed ) {
			if( stopAllAnims )
				anim.stopWithoutStateAnims();

			group = lib.getGroup(groupName);
			frameData = lib.getFrameData(groupName, f);
			if( frameData==null )
				throw 'Unknown frame: $groupName($f)';

			updateTile();

			if( onFrameChange!=null )
				onFrameChange();
		}
	}



	public inline function setRandom(?l:SpriteLib, g:String, rndFunc:Int->Int) {
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

	public inline function is(k, ?f=-1) return groupName==k && (f<0 || frame==f);

	public inline function isReady() {
		return !destroyed && groupName!=null;
	}

	public function constraintSize(w:Float, ?h:Null<Float>, ?useFrameDataRealSize=false) {
		if( useFrameDataRealSize )
			setScale( MLib.fmin( w/frameData.realFrame.realWid, (h==null?w:h)/frameData.realFrame.realHei ) );
		else
			setScale( MLib.fmin( w/t.width, (h==null?w:h)/t.height ) );
	}

	public inline function setScale(v:Float) scale = v;
	public inline function setPos(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}

	public function setFrame(f:Int) {
		var changed = f!=frame;
		frame = f;

		if( isReady() && changed ) {
			frameData = lib.getFrameData(groupName, frame);
			if( frameData==null )
				throw 'Unknown frame: $groupName($frame)';

			if( onFrameChange!=null )
				onFrameChange();

			updateTile();
		}
	}

	public inline function setPivotCoord(x:Float, y:Float) {
		pivot.setCoord(x, y);
		updateTile();
	}

	public inline function setCenterRatio(xRatio:Float, yRatio:Float) {
		pivot.setCenterRatio(xRatio, yRatio);
		updateTile();
	}

	public function totalFrames() {
		return group.frames.length;
	}


	public inline function uncolorize() {
		mt.deepnight.Color.uncolorizeBatchElement(this);
	}
	public inline function colorize(c:UInt, ?ratio=1.0) {
		mt.deepnight.Color.colorizeBatchElement(this, c, ratio);
	}



	//public function colorize(col:UInt, ?alpha=1.0, ?scale=1.0) {
		//color = h3d.Vector.fromColor( mt.deepnight.Color.addAlphaF(col, alpha), scale );
	//}


	public function clone<HSpriteBE>(?s:HSpriteBE) : HSpriteBE {
		var e = lib.hbe_get(batch, groupName, frame);
		e.setPos(x,y);
		e.rotation = rotation;
		e.scaleX = scaleX;
		e.scaleY = scaleY;
		e.pivot = pivot.clone();

		e.alpha = alpha;
		//e.visible = visible;
		//e.changePriority(priority);

		//e.color = color.clone();

		return cast e;
	}

	function updateTile() {
		if( !isReady() )
			return;


		var fd = frameData;
		lib.updTile(t, groupName, frame);

		if ( pivot.isUsingCoord() ) {
			t.dx = MLib.round(-pivot.coordX - fd.realFrame.x);
			t.dy = MLib.round(-pivot.coordY - fd.realFrame.y);
		}

		if ( pivot.isUsingFactor() ){
			t.dx = -Std.int(fd.realFrame.realWid * pivot.centerFactorX + fd.realFrame.x);
			t.dy = -Std.int(fd.realFrame.realHei * pivot.centerFactorY + fd.realFrame.y);
		}
	}

	public inline function dispose() remove();
	override function remove() {
		super.remove();

		if( !destroyed ) {
			if( lib!=null )
				lib.removeChild(this);

			destroyed = true;
			anim.destroy();
		}
	}
}
