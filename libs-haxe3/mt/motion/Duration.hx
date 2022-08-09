package mt.motion;

abstract Duration(Float)
{
	public static var FPS:Int = 30;
	static function getDefaultFrameRate() : Float {
		#if heaps
		return hxd.System.getDefaultFrameRate();
		#elseif h3d
		return hxd.Stage.getInstance().getFrameRate();
		#elseif flash
		return flash.Lib.current.stage.frameRate;
		#else
		FPS
		#end
	}
	
	public inline function new(v:Float) {
		this = v;
	}
	
	public static function isValid(v:String)
	{
		var suff = ~/[a-z%]+/;
		if ( !suff.match( v ) ) return false;
		var matched = suff.matched( 0 );
		return  switch(matched) {
			case "f", "fr", "frame"		:	true;
			case "ms"					:	true;
			case "s", "sec", "second"	:	true;
			case "min", "mins"			:	true;
			default: false;
		}
	}
	
	@:from
	#if !debug inline #end
	public static function fromFloat( f : Float )
	{
		return new Duration(f);
	}
	
	@:to
	#if !debug inline #end
	public function toFloat() : Float {
		return this;
	}
	
	@:from
	#if !debug inline #end
	public static function fromString( str:String ):Duration
	{
		var fr = getDefaultFrameRate();
		var suff = ~/[a-z%]+/;
		var matched = suff.match( str ) ? suff.matched( 0 ) : "f";
		return new Duration(
			switch(matched) {
				case "f", "fr", "frame"		:	Std.parseFloat(str);
				case "ms"					:	0.001 * fr * Std.parseFloat(str);
				case "s", "sec", "second"	:			fr * Std.parseFloat(str);
				case "min", "mins"			:	   60 * fr * Std.parseFloat(str);
				default:
					#if debug
					throw '$matched is not a valid format for duration expect %f  or %ms or %s or %min';
					#end
					Std.parseFloat(str);
			}
		);
	}
	
	@:commutative @:op(A + B) 	public static inline function add(r:Duration, l:Float) : Duration 	return new Duration( r.toFloat() + l );
	@:op(A - B) 				public static inline function sub(r:Duration, l:Float) : Duration 	return new Duration( r.toFloat() - l );
	@:commutative @:op(A * B) 	public static inline function mul(r:Duration, l:Float) : Duration 	return new Duration( r.toFloat() * l );
	@:op(A / B) 				public static inline function div(r:Duration, l:Float) : Duration 	return new Duration( r.toFloat() / l );

	@:op(A > B) 				public static inline function gt(r:Duration, l:Float) : Bool 	return r.toFloat() > l;
	@:op(A < B) 				public static inline function lt(r:Duration, l:Float) : Bool 	return r.toFloat() < l;
	@:op(A >= B) 				public static inline function gte(r:Duration, l:Float) : Bool return r.toFloat() >= l;
	@:op(A <= B) 				public static inline function lte(r:Duration, l:Float) : Bool return r.toFloat() <= l;
	@:op(A == B) 				public static inline function eq(r:Duration, l:Float) : Bool 	return r.toFloat() == l;
	
}
