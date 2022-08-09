package mt.deepnight;

import mt.MLib;

#if macro
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;
#end

enum TType {
	TLinear;
	TLoop; // loop : valeur initiale -> valeur finale -> valeur initiale
	TLoopEaseIn; // loop avec départ lent
	TLoopEaseOut; // loop avec fin lente
	TEase;
	TEaseIn; // départ lent, fin linéaire
	TEaseOut; // départ linéaire, fin lente
	TBurn; // départ rapide, milieu lent, fin rapide,
	TBurnIn; // départ rapide, fin lente,
	TBurnOut; // départ lente, fin rapide
	TZigZag; // une oscillation et termine sur Fin
	TRand; // progression chaotique de début -> fin. ATTENTION : la durée ne sera pas respectée (plus longue)
	TShake; // variation aléatoire de la valeur entre Début et Fin, puis s'arrête sur Début (départ rapide)
	TShakeBoth; // comme TShake, sauf que la valeur tremble aussi en négatif
	TJump; // saut de Début -> Fin
	TElasticEnd; // léger dépassement à la fin, puis réajustment
	TBackOut;
}

// GoogleDoc pour tester les valeurs de Bézier
// ->	https://spreadsheets.google.com/ccc?key=0ArnbjvQe8cVJdGxDZk1vdE50aUxvM1FlcDAxNWRrZFE&hl=en&authkey=CLCwp8QO


class Tween {
	var tw					: Tweenie;
	public var done(default,null)	: Bool;
	public var paused		: Bool;

	public var getter 		: Void->Float;
	public var setter 		: Float->Void;
	public var n			: Float;
	public var ln			: Float;
	public var speed		: Float;
	public var from			: Float;
	public var to			: Float;
	public var type(default,set): TType;
	public var plays		: Int; // -1 = infini, 1 et plus = nombre d'exécutions (1 par défaut)
	var pixelSnap			: Bool; // arrondi toutes les valeurs si TRUE (utile pour les anims pixelart)
	public var delay		: Int; // frame based

	public function new(tw) {
		this.tw = tw;
		paused = false;
		done = false;
		n = ln = 0;
		delay = 0;
		speed = 1;
		type = TEase;
		plays = 1;
		pixelSnap = false;
	}

	public inline function toString() {
		return '$from => $to ($type): ${ln*100}%';
	}

	function set_type(t:TType) {
		type = t;
		interpolate = switch(type) {
			case TLinear		: function(step) return step;
			case TRand			: function(step) return step;
			case TEase			: function(step) return bezier(step, 0,		0,		1,		1);
			case TEaseIn		: function(step) return bezier(step, 0,		0,		0.5,	1);
			case TEaseOut		: function(step) return bezier(step, 0,		0.5,	1,		1);
			case TBurn			: function(step) return bezier(step, 0,		1,	 	0,		1);
			case TBurnIn		: function(step) return bezier(step, 0,		1,	 	1,		1);
			case TBurnOut		: function(step) return bezier(step, 0,		0,		0,		1);
			case TZigZag		: function(step) return bezier(step, 0,		2.5,	-1.5,	1);
			case TLoop			: function(step) return bezier(step, 0,		1.33,	1.33,	0);
			case TLoopEaseIn	: function(step) return bezier(step, 0,		0,		2.25,	0);
			case TLoopEaseOut	: function(step) return bezier(step, 0,		2.25,	0,		0);
			case TShake			: function(step) return bezier(step, 0.5,	1.22,	1.25,	0);
			case TShakeBoth		: function(step) return bezier(step, 0.5,	1.22,	1.25,	0);
			case TJump			: function(step) return bezier(step, 0,		2,		2.79,	1);
			case TElasticEnd	: function(step) return bezier(step, 0,		0.7,	1.5,	1);

			case TBackOut : function(step) {

				            var s = 1.70158;
				            return (step=step/1-1)*step*((s+1)*step + s) + 1 ;

                        }
		}
		return type;
	}

	public dynamic function onUpdate() {}
	public dynamic function onUpdateT(t:Float) {}
	public dynamic function onEnd() {}
	public dynamic function onStart() {}

	public function end(cb:Void->Void) {
		onEnd = cb;
		return this;
	}

	public function start(cb:Void->Void) {
		onStart = cb;
		return this;
	}

	public function update(cb:Void->Void) {
		onUpdate = cb;
		return this;
	}

	public function updateT(cb:Float->Void) {
		onUpdateT = cb;
		return this;
	}

	dynamic function chainedEvent() {}
	dynamic function interpolate(v:Float) :Float { return v; }

	public function pixel() {
		pixelSnap = true;
		return this;
	}

	inline function bezier(t:Float, p0:Float, p1:Float,p2:Float, p3:Float) {
		return
			fastPow3(1-t)*p0 +
			3*t*fastPow2(1-t)*p1 +
			3*fastPow2(t)*(1-t)*p2 +
			fastPow3(t)*p3;
	}

	inline function fastPow2(n:Float):Float {
		return n*n;
	}
	inline function fastPow3(n:Float):Float {
		return n*n*n;
	}

	public function delayFrames(d:Int) {
		delay = d;
	}

	public function delayMs(d:Float) {
		delay = MLib.round( d*tw.baseFps/1000 );
	}

	public function chainMs(to:Float, ?ease:TType, ?duration_ms:Float) {
		var t = @:privateAccess tw.create_(getter, setter, null, to, ease, duration_ms, true);
		t.paused = true;
		chainedEvent = function() {
			t.paused = false;
			t.from = t.getter();
		}
		return t;
	}

	public function endWithoutCallbacks() {
		done = true;
	}

	@:allow(mt.deepnight.Tweenie) function complete(?fl_allowLoop=false) {
		var v = from + (to-from)*interpolate(1);
		if( pixelSnap )
			v = MLib.round(v);
		setter( v );
		onUpdate();
		onUpdateT(1);
		onEnd();
		chainedEvent();
		if( fl_allowLoop && ( plays==-1 || plays>1 ) ) {
			if( plays!=-1 )
				plays--;
			n = ln = 0;
		}
		else
			done = true;
	}

	@:allow(mt.deepnight.Tweenie) function internalUpdate(dt:Float) : Bool { // returns true if complete
		if( done )
			return true;

		if( paused )
			return false;

		if( delay>0 ) {
			delay--;
			return false;
		}

		if( onStart!=null ) {
			var cb = onStart;
			onStart = null;
			cb();
		}

		var dist = to-from;
		if (type==TRand)
			ln+=if(Std.random(100)<33) speed * dt else 0;
		else
			ln+=speed * dt;
		n = interpolate(ln);
		if ( ln<1 ) {
			// en cours...
			var val =
				if( type!=TShake && type!=TShakeBoth )
					from + n*dist ;
				else if ( type==TShake )
					from + Math.random() * MLib.fabs(n*dist) * (dist>0?1:-1);
				else
					from + Math.random() * n*dist * (Std.random(2)*2-1);
			if( pixelSnap )
				val = MLib.round(val);
			setter( val );
			onUpdate();
			onUpdateT(ln);
		}
		else // fini !
			complete(true);

		return done;
	}
}

class Tweenie {
	static var DEFAULT_DURATION = DateTools.seconds(1);

	var tlist						: Array<Tween>;
	public var baseFps(default,null): Float;

	public function new(fps:Float) {
		baseFps = fps;
		tlist = new Array();
	}

	public inline function count() {
		return tlist.length;
	}


	#if macro
	static function getGetterSetter(field:ExprOf<Dynamic>) {
		var p = Context.currentPos();
		var tdynamic : ComplexType = TPath({ pack:[], name:"Dynamic" });

		return {
			getter :
				{
					pos:p,
					expr:EFunction(null, {
						args		: [],
						ret			: tdynamic,
						expr		: macro return $field,
					})
				},

			setter :
				{
					pos:p,
					expr:EFunction(null, {
						args		: [{name:"_setV", type:tdynamic}],
						ret			: null,
						expr		: macro $field = _setV,
					})
				},
		}
	}
	#end

	public macro function terminateWithoutCallbacks(ethis:Expr, field:ExprOf<Dynamic>) {
		var gs = getGetterSetter(field);
		return macro @:privateAccess $ethis.terminate_( ${gs.getter}, ${gs.setter}, false );
	}

	public macro function complete(ethis:Expr, field:ExprOf<Dynamic>) {
		var gs = getGetterSetter(field);
		return macro @:privateAccess $ethis.terminate_( ${gs.getter}, ${gs.setter}, true );
	}


	function terminate_(getter:Void->Float, setter:Float->Void, withCallbacks:Bool) {
		if( tlist==null )
			return;

		var v = getter();
		for(t in tlist) {
			if( t.done )
				continue;
			var old = t.getter();
			t.setter(old+1);
			if( getter()!=v ) {
				t.setter(old);
				if( withCallbacks ) {
					t.ln = 1;
					t.complete(false);
				}
				else
					t.endWithoutCallbacks();
			}
			else
				t.setter(old);
		}
	}



	#if macro
	static function buildCreateExpr(ethis:Expr, field:ExprOf<Dynamic>, toExpr:ExprOf<Float>, ?tp:ExprOf<TType>, ?ms:ExprOf<Float>) {
		var gs = getGetterSetter(field);

		var p = Context.currentPos();
		var delay : Expr = null;
		var from : Expr = null;
		var to = toExpr;
		switch( toExpr.expr ) {
			case EBinop(OpGt, e1, e2) :
				switch( e1.expr ) {
					case EBinop(OpOr, d,f) :
						delay = d;
						from = f;
						to = e2;

					default :
						from = e1;
						to = e2;
				}

			case EBinop(OpOr, d,t) :
				delay = d;
				to = t;

			case EBinop(_), EField(_), EConst(_), EParenthesis(_), ECall(_), EUnop(_), ETernary(_) :

			default:
				Context.error("Invalid tweening expression ("+toExpr.expr.getName()+"). Please ask Seb :)", toExpr.pos);
		}

		var blockContent : Array<Expr> = [];

		if( from==null )
			from = macro null;

		switch( Context.typeExpr(tp).t ) {
			case TEnum(_) :
				blockContent.push( macro var _tween = @:privateAccess $ethis.create_( ${gs.getter}, ${gs.setter}, $from, $to, $tp, $ms) );

			default :
				blockContent.push( macro var _tween = @:privateAccess $ethis.create_( ${gs.getter}, ${gs.setter}, $from, $to, null, $tp) );
		}

		if( delay!=null )
			blockContent.push( macro _tween.delayMs($delay) );

		blockContent.push( macro _tween );

		return { pos:p, expr:EBlock(blockContent) }
	}

	static function isNull(e:Expr) {
		return switch( e.expr ) {
			case EConst(CIdent(v)) : v=="null";
			default : false;
		}
	}
	#end


	public macro function createS(ethis:Expr, field:ExprOf<Dynamic>, toExpr:ExprOf<Float>, ?tp:ExprOf<TType>, ?sec:ExprOf<Float>) {
		var ms = {
			expr : EBinop(OpMult, isNull(sec) ? tp : sec, macro 1000),
			pos : sec.pos,
		}
		if( isNull(sec) )
			return buildCreateExpr(ethis, field, toExpr, ms);
		else
			return buildCreateExpr(ethis, field, toExpr, tp, ms);
	}

	public macro function createMs(ethis:Expr, field:ExprOf<Dynamic>, toExpr:ExprOf<Float>, ?tp:ExprOf<TType>, ?ms:ExprOf<Float>) {
		return buildCreateExpr(ethis, field, toExpr, tp, ms);
	}


	function create_(getter:Void->Float, setter:Float->Void, from:Null<Float>, to:Float, ?tp:TType, ?duration_ms:Float, ?allowDuplicates=false) {
		if ( duration_ms==null )
			duration_ms = DEFAULT_DURATION;

		if( !allowDuplicates )
			@:privateAccess terminate_(getter, setter, false);

		var t = new Tween(this);
		t.getter = getter;
		t.setter = setter;
		t.from = from==null ? getter() : from;
		t.speed = 1 / ( duration_ms*baseFps/1000 ); // 1 sec
		t.to = to;
		if( tp!=null )
			t.type = tp;

		if( from!=null )
			setter(from);
		tlist.push(t);

		return t;
	}


	public function destroy() {
		tlist = null;
	}


	public function completeAll() {
		for(t in tlist)
			t.ln = 1;
		update();
	}


	public function update(?dt=1.0) {
		for (t in tlist)
			if( t.internalUpdate(dt) )
				tlist.remove(t);
	}
}
