import Common;
import mt.bumdum.Sprite;
import mt.bumdum.Plasma;
import mt.bumdum.Lib;
import flash.geom.ColorTransform;

interface Anim {
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	public function play() : Bool;
	public function clean() : Void;
}

interface Guest {
	public function updateCoord( x: Float, y : Float ) : Void;
}

class ChakraGlow implements Anim{

	var game : Game;
	var mc : {>flash.MovieClip,text:flash.TextField};
	var plasma : Plasma;
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	var move : Float;
	var steps : Int;
	var col : Float;

	public function new(game : Game, points, cycles, ccoef) {
		this.game = game;
		mc = cast game.dm.attach( "mcPoints", Const.DP_CHAKRAS );
		mc._y = 150;
		mc._x = 150;
		mc._yscale = mc._yscale = 0;

		var sp = Std.string( points );
		mc.text.text = sp;

		plasma = new Plasma(game.dm.empty(Const.DP_SELECT),300,300);
		plasma.filters.push(new flash.filters.BlurFilter());

		var ct = new flash.geom.ColorTransform();
		ct.rgb = Const.COLORS[0xFFFFFF];
		ct.alphaOffset = -15;
		plasma.ct = ct;
		plasma.root.blendMode = "lighten";
		plasma.root._alpha = 120;

		plasma.timer = 30;
		plasma.fadeLimit = 10;
		steps = Std.int ( cycles / 2 );
		var p = ccoef / game.cycles;
		move = Const.MAX_GLOW * Math.pow( p * 1.8, 5 ) / steps;
	}

	public function play() {
		var tmod = mt.Timer.tmod;
		mc._yscale += move * tmod / 2;
		mc._xscale += move * tmod / 2;
		mc._alpha -= tmod * 2;
		plasma.drawMc(mc);
		plasma.update();

		if( steps-- <= 0 ) {
			steps =0;
			move = 0;
			return true;
		}
		return false;
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
		plasma.kill();
		plasma = null;
	}
}

class PointsAnim implements Anim {
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	var mc : flash.MovieClip;
	var mcPoints : {>flash.MovieClip,text:flash.TextField};
	var steps : Int;
	var max : Int;
	var move : Int;
	var startFade : Bool;
	var glow : flash.filters.GradientGlowFilter;
	var phys : mt.bumdum.Phys;

	public function new( game : Game, chakra : Chakra, points ) {
		mc = cast game.dm.attach( "mcLotus", Const.DP_CHAKRAS );
		mc._x = chakra.mc._x;
		mc._y = chakra.mc._y;
		mc._xscale = mc._yscale = 5;
		mc._alpha = 0;
		mc._rotation = 1;

		var ct = new flash.geom.ColorTransform();
		ct.rgb = chakra.color;
		ct.blueMultiplier = 0.3;
		ct.redMultiplier = 0.3;
		ct.greenMultiplier = 0.3;
		var t = new flash.geom.Transform( mc );
		t.colorTransform = ct;

		mcPoints = cast game.dm.attach( "mcPoints", Const.DP_CHAKRAS );
		if( !chakra.missed ) {
			mcPoints._xscale = mcPoints._yscale = mc._xscale;
			var sp = Std.string( points );
			mcPoints.text.text = sp;
			switch( sp.length ) {
				case 2 :
					mcPoints._x = mc._x + 2;
				case 3 :
					mcPoints._x = mc._x + 2.5;
				case 4 :
					mcPoints._x = mc._x;
			}
			mcPoints._y = mc._y;
		} else {
			mcPoints._visible = false;
		}

		glow = new flash.filters.GradientGlowFilter( 0, 45, [chakra.color, chakra.color], [0, 1], [0, 255], 32, 32, 1, 1, "outer" );
		phys = new mt.bumdum.Phys( mc );
		phys.fadeType = 4;
		phys.timer = 40;

		var p = new mt.bumdum.Phys( mcPoints );
		p.fadeType = 4;
		p.timer = 40;

	}

	public function play() {
		var tmod = mt.Timer.tmod;
		phys.root._rotation -= 5;

		mc.filters = [glow];
		phys.root._alpha += 10;
		mcPoints._xscale = phys.root._xscale += 7;
		mcPoints._yscale = phys.root._yscale = phys.root._xscale;

		var c = Sprite.spriteList.copy();
		for( p in Sprite.spriteList ) {
			p.update();
		}

		if( phys.timer <= 0 || phys == null) {
			return true;
		}
		return false;
	}

	public function clean() {
		mc.removeMovieClip( );
		mc = null;
	}
}

class EnergyAnim implements Anim {

	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	var mc : flash.MovieClip;
	var steps : Int;
	var max : Int;
	var move : Float;
	var minus : Bool;

	public function new(mc, points, minus = true) {
		this.mc = mc;
		steps = 0;
		max = 20;
		move = points / max;
		this.minus = minus;
	}

	public function play() {
		if( mc._y >= 0 ) return true;

		if( minus ) {
			mc._y += move;
		}
		else {
			mc._y -= move;
		}

		if( steps++ > max ) {
			return true;
		}

		return false;
	}

	public function clean() {
	}
}

class BonusAnim implements Anim {
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	var mc : flash.MovieClip;
	var mcPoints : {>flash.MovieClip,text:flash.TextField};
	var steps : Int;
	var max : Int;
	var move : Int;
	var startFade : Bool;
	var glow : flash.filters.GradientGlowFilter;
	var phys : mt.bumdum.Phys;
	var idx : Int;
	var t : flash.geom.Transform;

	public function new( game : Game, points ) {
		idx = 0;
		mc = cast game.dm.attach( "mcLotus", Const.DP_CHAKRAS );
		mc._x = 150;
		mc._y = 150;
		mc._xscale = mc._yscale = 5;
		mc._alpha = 0;
		mc._rotation = 1;

		var ct = new flash.geom.ColorTransform();
		ct.rgb = Const.COLORS[Std.random( Const.COLORS.length )];
		ct.blueMultiplier = 0.3;
		ct.redMultiplier = 0.3;
		ct.greenMultiplier = 0.3;
		t = new flash.geom.Transform( mc );
		t.colorTransform = ct;

		mcPoints = cast game.dm.attach( "mcPoints", Const.DP_CHAKRAS );
		mcPoints._xscale = mcPoints._yscale = mc._xscale;
		var sp = Std.string( points );
		mcPoints.text.text = sp;
		mcPoints._x = mc._x;
		mcPoints._y = mc._y;

		phys = new mt.bumdum.Phys( mc );
		phys.timer = 40;
		phys.vsc = 1.14;
		var p = new mt.bumdum.Phys( mcPoints );
		p.timer = 40;
		p.vsc = 1.14;

		idx = 0;
	}

	public function play() {
		var tmod = mt.Timer.tmod;
		phys.root._rotation -= 5;

		phys.root._alpha += 2;

		var c = Sprite.spriteList.copy();
		for( p in Sprite.spriteList ) {
			p.update();
		}

		if( phys.timer <= 0 || phys == null) {
			return true;
		}
		return false;
	}

	public function clean() {
		mc.removeMovieClip( );
		mc = null;
	}
}

class BonusPointsAnim implements Anim {
	public var onEnd : Void -> Void;
	public var onUpdate : flash.MovieClip -> Float -> Void;
	var mc : flash.MovieClip;
	var mcBonus : flash.MovieClip;
	var mcPoints : {>flash.MovieClip,text:flash.TextField};
	var steps : Int;
	var max : Int;
	var move : Int;
	var startFade : Bool;
	var glow : flash.filters.GradientGlowFilter;
	var phys : mt.bumdum.Phys;
	var game : Game;

	public function new( game : Game, chakra : Chakra, points ) {
		mc = cast game.dm.attach( "mcLotus", Const.DP_CHAKRAS );
		mc._x = chakra.mc._x;
		mc._y = chakra.mc._y;
		mc._xscale = mc._yscale = 5;
		mc._alpha = 0;
		mc._rotation = 1;

		mcBonus = cast game.dm.attach( "mcBonus", Const.DP_CHAKRAS );
		mcBonus._x = mc._x;
		mcBonus._y = mc._y - 5;
		mcBonus._xscale = mcBonus._yscale = mc._xscale;

		var ct = new flash.geom.ColorTransform();
		ct.rgb = chakra.color;
		ct.blueMultiplier = 0.3;
		ct.redMultiplier = 0.3;
		ct.greenMultiplier = 0.3;
		var t = new flash.geom.Transform( mc );
		t.colorTransform = ct;

		mcPoints = cast game.dm.attach( "mcPoints", Const.DP_CHAKRAS );
		if( !chakra.missed ) {
			mcPoints._xscale = mcPoints._yscale = mc._xscale;
			var sp = Std.string( points );
			mcPoints.text.text = sp;
			switch( sp.length ) {
				case 2 :
					mcPoints._x = mc._x + 2;
				case 3 :
					mcPoints._x = mc._x + 2.5;
				case 4 :
					mcPoints._x = mc._x;
			}
			mcPoints._y = mc._y + 10;
		} else {
			mcPoints._visible = false;
		}

		glow = new flash.filters.GradientGlowFilter( 0, 45, [chakra.color, chakra.color], [0, 1], [0, 255], 32, 32, 1, 1, "outer" );
		phys = new mt.bumdum.Phys( mc );
		phys.fadeType = 4;
		phys.timer = 40;

		var p = new mt.bumdum.Phys( mcPoints );
		p.fadeType = 4;
		p.timer = 40;

		var b = new mt.bumdum.Phys( mcBonus );
		b.fadeType = 4;
		b.timer = 40;
		b.vy = -1;

	}

	public function play() {
		var tmod = mt.Timer.tmod;
		phys.root._rotation -= 5  * tmod;

		mc.filters = [glow];
		phys.root._alpha += 10  * tmod;
		mcBonus._xscale = mcPoints._xscale = phys.root._xscale += 7 * tmod;
		mcBonus._yscale = mcPoints._yscale = phys.root._yscale = phys.root._xscale;

		var c = Sprite.spriteList.copy();
		for( p in Sprite.spriteList ) {
			p.update();
		}

		if( phys.timer <= 0 || phys == null) {
			return true;
		}
		return false;
	}

	public function clean() {
		mc.removeMovieClip( );
		mc = null;
	}
}

enum TransitionParam {
	In;
	Out;
	InOut;
}

enum Transition {
	Linear;
	Quad();		// Quadratic
	Cubic();	// Cubicular
	Quart();	// Quartetic
	Quint();	// Quintetic
	Pow(pa:Float);
	Expo();
	Circ();
	Sine();
	Back(pa:Float);
	Bounce();
	Elastic(pa:Float);
}

class TransitionFunctions {

	static function transitionParam(p:TransitionParam, f:Float -> Float) : Float -> Float {
		return switch (p){
			case In:f;
			case Out:function(pos:Float){ return 1 - f(1-pos); }
			case InOut:function(pos:Float){ return if (pos <= 0.5) f(2 * pos) / 2 else (2 - f(2 * (1-pos)) / 2); }
		}
	}

	public static function get( t:Transition ){

		return switch (t){
			case Linear: linear;
			case Quad: transitionParam(Out, quad);
			case Cubic: transitionParam(Out, cubic);
			case Quart: transitionParam(Out, quart);
			case Quint: transitionParam(Out, quint);
			case Pow( pa): transitionParam(Out, callback(pow,pa) );
			case Expo: transitionParam(Out, expo);
			case Circ: transitionParam(Out, circ);
			case Sine: transitionParam(Out, sine);
			case Back(pa): transitionParam(Out, callback(back,pa));
			case Bounce: transitionParam(Out, bounce);
			case Elastic(pa): transitionParam(Out, callback(elastic,pa));
		}
	}

	public static function linear( p:Float ){
		return p;
	}

	public static function pow( x:Float=6.0, p:Float ){
		return Math.pow(p, x);
	}

	public static function expo( p:Float ){
		return Math.pow(2, 8 * (p-1));
	}

	public static function circ( p:Float ){
		return 1 - Math.sin(Math.acos(p));
	}

	public static function sine( p:Float ){
		return 1 - Math.sin((1-p) * Math.PI / 2);
	}

	public static function back( pa:Float=1.618, p:Float ){
		return Math.pow(p, 2) * ((pa+1) * p - pa);
	}

	public static function bounce( p:Float ){
		var value = null;
		var a = 0.0;
		var b = 1.0;
		while (true){
			if (p >= (7 - 4 * a) / 11){
				value = -Math.pow((11- 6*a - 11*p) / 4, 2) + b*b;
				break;
			}
			a += b;
			b /= 2;
		}
		return value;
	}

	public static function elastic( pa:Float=1.0, p:Float ){
		return Math.pow(2, 10 * --p) * Math.cos(20 * p * Math.PI * pa / 3);
	}

	public static function quad(p:Float){
		return Math.pow(p, 2);
	}

	public static function cubic(p:Float){
		return Math.pow(p, 3);
	}

	public static function quart(p:Float){
		return Math.pow(p, 4);
	}

	public static function quint(p:Float){
		return Math.pow(p, 5);
	}
}

