package mt.gx;

class Rand {
	
	var status : haxe.ds.Vector<Int>;
	var mat1:Int = 0;
	var mat2:Int = 0;
	var tmat:Int = 0;
	
	inline static var tinyMask = 0x7FffFFff;
	inline static var tinySh0 = 1;
	inline static var tinySh1 = 10;
	inline static var tinySh8 = 8;
	public static var uid = 0;
	
	#if debug
	public var nbNextState : Int = 0;
	public var startSeed : Int = 0;
	public var id : Int = 0;
	public var debug = false;
	#end
	
	public inline function new( ?seed :Int) {	
		if ( seed == null ) seed = Std.random(1024 * 1024 * 256);
		
		status = new haxe.ds.Vector(4);
		
		status[0] = seed;
		status[1] = mat1;
		status[2] = mat2;
		status[3] = tmat;
		
		for ( i in 1...8) {
			status[i & 3] ^= i + 1812433253
			* (status[(i - 1) & 3]
				^ 	(status[(i - 1) & 3] >> 30));
		}
		
		for ( i in 0...8)
			nextState();
		
		#if debug
		startSeed = seed;
		id = ++uid;
		#end
	}
	
	
	@:noDebug
	public inline function random(r) : Int {
		nextState();
		return mt.gx.MathEx.posMod(temper() , r);
	}
	
	@:noDebug
	public inline function getSeed() {
		return status[0];
	}
	
	@:noDebug
	public inline function clone() {
		var n = new Rand(0);
		
		n.status = new haxe.ds.Vector(status.length);
		haxe.ds.Vector.blit( status, 0, n.status, 0, n.status.length);
		
		n.mat1 = mat1;
		n.mat2 = mat2;
		n.tmat = tmat;
		
		#if debug
		n.startSeed = startSeed;
		n.nbNextState = nbNextState;
		#end
		
		return n;
	}
	
	@:noDebug
	public inline function rand()  : Float{
		return random(1024<<20)*1.0 / (1024<<20);
	}
	
	@:noDebug
	public inline function dice( min,max) : Int{
		return random( max - min + 1 ) + min;
	}
	
	@:noDebug
	public inline function diceF( min:Float,max:Float) : Float{
		return rand() * ( max - min ) + min;
	}
	
	@:noDebug
	public inline function toss() : Bool{
		return percent(50);
	}
	
	@:noDebug
	public inline function percent( val : Float ) : Bool {
		if (val <= 0.5 ) return false;
		return dice(1, 100) <= val;
	}
	
	@:noDebug
	inline function nextState()  {
		var y : UInt;
		var x : UInt;
		
		y = status[3];
		x = (status[0] & tinyMask)
		^ status[1]
		^ status[2];
		
		x ^= (x << tinySh0);
		y ^= (y >> tinySh1) ^ x;
		
		status[0] = status[1];
		status[1] = status[2];
		
		status[2] = x ^ ( y << tinySh1);
		status[3] = y;
		
		var ly : Int = cast (y&1);
		status[1] ^= -ly & mat1;
		status[2] ^= -ly & mat2;
		
		#if debug
		if( debug )
			trace(toString());
			
		nbNextState++;
		#end
		
	}
	
	#if debug
	public function toString() {
		var s = "";
		if( debug ){
			//var c = haxe.CallStack.callStack();
			s+= "ns:" + nbNextState+" startSeed:"+startSeed+" id: "+id +" seed:"+getSeed()+"\n";
			//s+= "rdStack:" + haxe.CallStack.toString(c)+"\n";
		}
		return s;
	}
	#end
	
	@:noDebug
	inline function temper() {
		var t0:UInt;
		var t1:UInt;
		
		t0 = status[3];
		t1 = status[0] + status[2] >> tinySh8;
		
		t0 ^= t1;
		
		var t1s : Int = cast (t1 & 1);
		t0 ^= ( -t1s) & tmat;
		return t0;
	}
	
	@:noDebug
	public static inline function fromArray( arr:Array<Int> ) {
		var curSeed = 0;
		for( i in 0...arr.length){
			var r = new mt.gx.Rand(arr[i]+curSeed);
			curSeed += r.random(1024 * 1024 * 1024);
		}
		return new mt.gx.Rand(curSeed);
	}
}
