package mt.deepnight;

import h2d.SpriteBatch;

interface ParticleInterface {
	private var stamp			: Float;
	public var dx				: Float;
	public var dy				: Float;
	public var da				: Float; // alpha
	public var ds				: Float; // scale
	public var dsx				: Float; // scaleX
	public var dsy				: Float; // scaleY
	public var scaleMul			: Float;
	public var dr				: Float;
	public var frict(never,set)	: Float;
	public var frictX			: Float;
	public var frictY			: Float;
	public var gx				: Float;
	public var gy				: Float;
	public var bounceMul		: Float;
	public var life(never,set)	: Float;
	private var rlife			: Float;
	private var maxLife			: Float;
	public var groundY			: Null<Float>;
	public var groupId			: Null<String>;
	public var fadeOutSpeed		: Float;
	public var time(get,never)	: Float;
	public var maxAlpha(default,set): Float;
	public var delay(default, set)	: Float;

	public var onStart			: Null<Void->Void>;
	public var onBounce			: Null<Void->Void>;
	public var onUpdate			: Null<Void->Void>;
	public var onKill			: Null<Void->Void>;

	public var pixel			: Bool;
	public var killOnLifeOut	: Bool;
	public var killed			: Bool;
	public var pooled			: Bool;


	public function kill() : Void;
	private function toString() : String;
	public function dispose() : Void;
	public function update( #if !HPartTMod rendering : Bool #else tmod : Float #end ) : Void;
	public function isAlive() : Bool;

	public function setPos(x:Float,y:Float) : Void;

	public function getSpeed() : Float;
	public function getMoveAng() : Float;

	public function rnd(min:Float, max:Float, ?sign:Bool=false) : Float;
	public function irnd(min:Int, max:Int, ?sign:Bool=false) : Int;
	public function sign() : Float; // -1 / 1
	public function randFloat(f:Float) : Float; // 0->1

	public function moveAng(a:Float, spd:Float) : Void;
	public function moveTo(x:Float,y:Float, spd:Float) : Void;
	public function moveAwayFrom(x:Float,y:Float, spd:Float) : Void;

}
