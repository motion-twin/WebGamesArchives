package mt.heaps.slib;

import mt.heaps.slib.SpriteLib;

interface SpriteInterface {

	public var destroyed			: Bool;
	public var lib					: SpriteLib;
	public var group				: Null<LibGroup>;
	public var groupName			: Null<String>;
	public var frame				: Int;
	public var pivot				: SpritePivot;
	public var anim					: AnimManager;
	private var frameData			: FrameData;

	// Callbacks
	public var beforeRender			: Null<Void->Void>;
	public var onFrameChange		: Null<Void->Void>;

	//public function clone<T>(?t:T) : T;
	private function toString() : String;
	public function remove() : Void;
	public function isReady() : Bool;

	public function set(?l:SpriteLib, ?g:String, ?frame:Int, ?stopAllAnims:Bool) : Void;
	public function setFrame(f:Int) : Void;
	public function setRandom(?l:SpriteLib, g:String, rndFunc:Int->Int) : Void;
	public function setRandomFrame(?rndFunc:Int->Int) : Void;

	public function isGroup(k:String) : Bool;
	public function is(k:String, ?f:Int) : Bool;

	public function setScale(#if h2d v:hxd.Float32 #else v:Float #end) : Void;
	public function setPos(x: #if h2d hxd.Float32 #else Float #end, y: #if h2d hxd.Float32 #else Float #end) : Void;
	//public function setSize(w:Float, h:Float) : Void;
	public function setPivotCoord(x:Float, y:Float) : Void;
	public function setCenterRatio(xr:Float, yr:Float) : Void;
	public function constraintSize(w:Float, ?h:Null<Float>, ?useFrameDataRealSize:Bool=false) : Void;

	public function getAnimDuration() : Int;
	public function totalFrames() : Int;
}
