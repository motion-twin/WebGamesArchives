package mt.deepnight.slb;

import mt.deepnight.slb.BLib;

interface SpriteInterface {

	public var destroyed			: Bool;
	public var lib					: BLib;
	public var group				: Null<LibGroup>;
	public var groupName			: Null<String>;
	public var frame				: Int;
	private var pivot				: SpritePivot;
	public var a					: AnimManager;
	private var frameData			: FrameData;

	// Callbacks
	public var beforeRender			: Null<Void->Void>;
	public var onFrameChange		: Null<Void->Void>;

	public function clone<T>(?t:T) : T;
	public function toString() : String;
	public function dispose() : Void;
	public function isReady() : Bool;

	public function set(?l:BLib, ?g:String, ?frame:Int, ?stopAllAnims:Bool) : Void;
	public function setFrame(f:Int) : Void;
	public function setRandom(?l:BLib, g:String, rndFunc:Int->Int) : Void;
	public function setRandomFrame(?rndFunc:Int->Int) : Void;

	public function isGroup(k:String) : Bool;
	public function is(k:String, f:Int) : Bool;

	public function scale(#if h2d v:hxd.Float32 #else v:Float #end) : Void;
	public function setScale(#if h2d v:hxd.Float32 #else v:Float #end) : Void;
	public function setPos(x: #if h2d hxd.Float32 #else Float #end, y: #if h2d hxd.Float32 #else Float #end) : Void;
	public function setSize(w:Float, h:Float) : Void;
	public function setPivotCoord(x:Float, y:Float) : Void;
	public function setCenterRatio(xr:Float, yr:Float) : Void;
	public function constraintSize(w:Float, ?h:Null<Float>, ?useFrameDataRealSize:Bool=false) : Void;

	public function getAnimDuration() : Int;
	public function totalFrames() : Int;
}
