package mt;

import haxe.Json;

/**
 * Pixel abstract, internally stores pixels
 */
abstract Px(Float) {

	public inline function new(v:Float){
		this = v;
	}

	@:from
	#if !debug inline #end
	public static function fromFloat( f : Float )
	{
		return new Px(f);
	}

	@:from
	#if !debug inline #end
	public static function fromString( str:String )
	{
		var suff = ~/[a-z%]+/;
		var matched = suff.match( str ) ? suff.matched( 0 ) : "px";
		return new Px( mt.Metrics.convert( Std.parseFloat(str), matched ) );
	}

	/** This one can trick the compiler for variable arguments
	@:to public inline function  toString() : String{}
	*/

	@:to
	#if !debug inline #end
	public function toFloat() : Float {
		return this;
	}

	@:to
	public inline function  toInt() : Int {
		return Std.int( this );
	}


	@:commutative @:op(A + B) 	public static inline function add(r:Px, l:Float) : Px 	return new Px( r.toFloat() + l );
	@:op(A - B) 				public static inline function sub(r:Px, l:Float) : Px 	return new Px( r.toFloat() - l );
	@:op(A - B) 				public static inline function rsub(r:Float, l:Px) : Px 	return new Px( r - l.toFloat() );
	@:commutative @:op(A * B) 	public static inline function mul(r:Px, l:Float) : Px 	return new Px( r.toFloat() * l );
	@:op(A / B) 				public static inline function div(r:Px, l:Float) : Px 	return new Px( r.toFloat() / l );

	@:op(A > B) 				public static inline function gt(r:Px, l:Float) : Bool 	return r.toFloat() > l;
	@:op(A < B) 				public static inline function lt(r:Px, l:Float) : Bool 	return r.toFloat() < l;
	@:op(A >= B) 				public static inline function gte(r:Px, l:Float) : Bool return r.toFloat() >= l;
	@:op(A <= B) 				public static inline function lte(r:Px, l:Float) : Bool return r.toFloat() <= l;
	@:op(A == B) 				public static inline function eq(r:Px, l:Float) : Bool 	return r.toFloat() == l;

	@:op(A % B) 				public static inline function mod(r:Px, l:Float) : Px 	return r.toFloat() % l;
}


/**
 * dp is hereby a density independent pixel
 * meaning a square defined in dp will allways get same screen size
 *
 */
class Metrics {

	/**
	 * stage height
	 */
	public static inline function h() {
		var stageH =#if(flash||openfl) flash.Lib.current.stage.stageHeight
					#elseif(heaps) hxd.Stage.getInstance().height
					#else
						#error "Metrics.h() cannot be found on that target/platform"
					#end;
		
		#if deviceEmulator
		return Math.round( stageH / DeviceEmulator.ratio );
		#else
		return stageH;
		#end
	}

	/**
	 * stage width
	 */
	public static inline function w() {
		var stageW =#if(flash||openfl) flash.Lib.current.stage.stageWidth
					#elseif(heaps) hxd.Stage.getInstance().width
					#else
						#error "Metrics.w() cannot be found on that target/platform"
					#end;
		
		#if deviceEmulator
		return Math.round( stageW / DeviceEmulator.ratio );
		#else
		return stageW;
		#end
	}

	public static inline function wcm() return px2cm( w() );
	public static inline function hcm() return px2cm( h() );

	public static inline function isPortrait() return w() < h();
	public static inline function isLandscape() return w() >= h();

	public static inline function pixelDensity() {
		#if !standalone
			#if gameBase
				return Device.pixelScale();
			#elseif mBase
				return Device.pixelDensity();
			#elseif deviceEmulator
				return DeviceEmulator.density;
			#else
				return 1.0;
			#end
		#else
			return 1.0;
		#end
	}
	
	public static inline function dpi() : Float {
		#if !standalone
		return Device.dpi();
		#elseif deviceEmulator
		return DeviceEmulator.dpi;
		#else
			#if flash
			return flash.system.Capabilities.screenDPI;
			#else
			return 150.0;
			#end
		#end
	}
	
	public static inline function dp2px( dp : Float ) : Float {
		return dp * (dpi() / INCH2DP);
	}
	
	public static inline function px2dp( px : Float ) :Float {
		return px / (dpi() / INCH2DP);
	}
	
	public static inline function cm2px( cm : Float)
	{
		var inch = cm * CM2INCH;
		var px = inch * dpi();
		return px;
	}
	
	public static inline function px2cm( px : Float) {
		return px / cm2px( 1.0 );
	}
	
	public static inline var CM2INCH = 1.0 / 2.54;
	public static inline var INCH2CM = 2.54;
	
	public static inline var PT2INCH = 1.0 / 72;
	public static inline var INCH2PT = 72;
	
	public static inline var DP2INCH = 1.0 / 160;
	public static inline var INCH2DP = 160;
	
	public static inline var M2CM = 0.001;
	public static inline var CM2M = 1000.0;
	
	public static function dump() : Dynamic {
		var o : Dynamic = { };
		o.w = w();
		o.h = h();
		o.dpi = dpi();
		#if flash
		o.pr = flash.system.Capabilities.pixelAspectRatio;
		#end
		o.density = pixelDensity();
		o.shortDP = o.w < o.h ? px2dp(o.w) : px2dp(o.h);
		o.longDP = o.w < o.h ? px2dp(o.h) : px2dp(o.w);
		return o;
	}

	public static inline function px(str:String):Px {
		return Px.fromString(str);
	}

	/**
	 * This should change to
	 * return Math.round(Px.fromString(str));
	 * to stay coherent with other methods
	 */
	public static inline function pxi(str:String):Int {
		return Std.int(Px.fromString(str));
	}

	public static inline function a2px( v : Float ){
		// minimum 1a = 1dp
		// goal 1a = 500th of smallest side
		// maximum 1a = 1.8dp
		var t = h() > w() ? v*w()/500 : v*h()/500;
		var dp = dp2px(v);
		if( t > 0 )
			return Math.min( 1.8 * dp, Math.max( dp, t ) );
		else
			return Math.max( 1.8 * dp, Math.min( dp, t ) );
	}

	public static inline function vpx2px( v : Float ){
		return isPortrait() ? v * Math.min( h()/480, w()/320 ) : v * Math.min( w()/480, h()/320 );
	}
	
	public static inline function vpx2pxi( v : Float ){
		return Math.round(vpx2px(v));
	}

	public static inline function convert( v : Float, u : String ) : Float {
		return switch(u) {
		// relative to native device pixel
		case "px":			v;

		// relative to device width or height
		case "%h":			h() * v * 0.01;
		case "%w":			w() * v * 0.01;

		// relative to real length
		case "cm":			cm2px( v );
		case "m":			cm2px( Metrics.M2CM * v );
		case "in":			cm2px( Metrics.INCH2CM * v );
		case "pt":			cm2px( Metrics.INCH2CM * Metrics.PT2INCH * v );
		case "dp":			dp2px( v );

		// adaptative
		case "a":			a2px( v );

		//the screen is always at least 320 lines,the unit is calced to reflect that
		//if screen is 640 lines, 1vpx value is 2
		case "vpx":			vpx2px( v );
		case "x", "vpxi":	Math.round(vpx2px( v ));

		#if (h3d)
		case "%":
			//can not be evaluated, but let it pass to caller for h2d.css
			//TODO : clean here ?
			v;
		#end

		default:
			#if debug
			throw '$u is not a valid MT unit';
			#end
			v;
		}
	}
}
