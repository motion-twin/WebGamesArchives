package mt.heaps.slib;

import h2d.Drawable;
import mt.heaps.slib.*;
//import mt.heaps.slib.AnimManager;
//import mt.slib.SpriteInterface;
import mt.heaps.slib.SpriteLib;
import mt.MLib;

#if !heaps
#error "Heaps required"
#end

class HSprite extends h2d.Drawable implements SpriteInterface {
	public var anim			: AnimManager;
	public var lib			: SpriteLib;
	public var groupName	: String;
	public var group		: LibGroup;
	public var frame		: Int;
	public var frameData	: FrameData;
	public var pivot		: SpritePivot;
	public var destroyed	: Bool;

	public var beforeRender : Null<Void->Void>; // deprecated
	public var onFrameChange: Null<Void->Void>;

	var rawTile : h2d.Tile;
	public var tile(get,never) : h2d.Tile;


	public function new(?l:SpriteLib, ?g:String, ?f=0, ?parent:h2d.Sprite) {
		super(parent);
		destroyed = false;

		pivot = new SpritePivot();
		anim = new AnimManager(this);

		if( l!=null )
			set(l, g, f);
		else
			setEmptyTexture();
	}

	override function toString() return "HSprite_"+groupName+"["+frame+"]";


	public function setEmptyTexture() {
		rawTile = h2d.Tile.fromColor(0x80FF00,4,4);
	}

	public inline function set( ?l:SpriteLib, ?g:String, ?frame=0, ?stopAllAnims=false ) {
		if( l!=null ) {
			// Update internal tile
			if ( l.tile==null )
				throw "sprite sheet has no backing texture, please generate one";

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

		if( g!=null && g!=groupName )
			groupName = g;

		if( isReady() ) {
			rawTile = lib.tile.clone();

			if( stopAllAnims )
				anim.stopWithoutStateAnims();

			group = lib.getGroup(groupName);
			frameData = lib.getFrameData(groupName, frame);
			if( frameData==null )
				throw 'Unknown frame: $groupName($frame)';
			setFrame(frame);
		}
		else
			setEmptyTexture();
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
		return !destroyed && lib!=null && groupName!=null;
	}

	public function setFrame(f:Int) {
		var old = frame;
		frame = f;

		if( isReady() ) {
			var prev = frameData;
			frameData = lib.getFrameData(groupName, frame);
			if( frameData==null )
				throw 'Unknown frame: $groupName($frame)';

			if( onFrameChange!=null )
				onFrameChange();
		}
	}

	public function constraintSize(w:Float, ?h:Null<Float>, ?useFrameDataRealSize=false) {
		if( useFrameDataRealSize )
			setScale( MLib.fmin( w/frameData.realFrame.realWid, (h==null?w:h)/frameData.realFrame.realHei ) );
		else
			setScale( MLib.fmin( w/tile.width, (h==null?w:h)/tile.height ) );
	}

	public inline function setPivotCoord(x:Float, y:Float) {
		pivot.setCoord(x, y);
	}

	public inline function setCenterRatio(xRatio:Float, yRatio:Float) {
		pivot.setCenterRatio(xRatio, yRatio);
	}

	public function totalFrames() {
		return group.frames.length;
	}

	public inline function colorize(col:UInt, ?alpha=1.0, ?scale=1.0) {
		color = h3d.Vector.fromColor( mt.deepnight.Color.addAlphaF(col, alpha), scale );
	}
	public inline function uncolorize() {
		color = new h3d.Vector(1, 1, 1, 1);
	}


	override function onDelete() {
		super.onDelete();

		if( !destroyed ) {
			destroyed = true;

			if( lib!=null )
				lib.removeChild(this);

			anim.destroy();
		}
	}


	override function getBoundsRec( relativeTo, out, forSize ) {
		super.getBoundsRec(relativeTo, out, forSize);
		addBounds(relativeTo, out, tile.dx, tile.dy, tile.width, tile.height);
	}

	inline function get_tile() {
		if( isReady() ) {
			var fd = frameData;
			rawTile.setPos(fd.x, fd.y);
			rawTile.setSize(fd.wid, fd.hei);

			// Apply pivot
			if( pivot.isUsingCoord() ) {
				rawTile.dx = -Std.int(pivot.coordX + fd.realFrame.x);
				rawTile.dy = -Std.int(pivot.coordY + fd.realFrame.y);
			}
			else if( pivot.isUsingFactor() ) {
				rawTile.dx = -Std.int(fd.realFrame.realWid*pivot.centerFactorX + fd.realFrame.x);
				rawTile.dy = -Std.int(fd.realFrame.realHei*pivot.centerFactorY + fd.realFrame.y);
			}
		}
		return rawTile;
	}

	override function draw( ctx : h2d.RenderContext ) {
		emitTile(ctx, tile);
	}
}
