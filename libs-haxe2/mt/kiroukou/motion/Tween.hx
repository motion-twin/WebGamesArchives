package mt.kiroukou.motion;

#if macro
import haxe.macro.Expr;
import mt.MLib;
#end

/**
 * Librarie de tweening qui essaie de satisfaire les points suivants:
 *  - compatibilité avec l'obfuscation ! Grace aux macros, on parvient à éviter les appels à Reflect, tout en simplifiant encore la synthaxe
 *  - souplesse : utilisation ala JQuery avec chaining des actions
 *  - performance : il y a toujours matière à faire mieux, notamment avec la gestion mémoire, mais on est loin devant les libs comme Actuate
 *
 * @usage pour flash
 * import mt.kiroukou.motion.Ease;
 * using mt.kiroukou.motion.Tween;
 *
 * monClipA.x = 230;
 * monClipA.y = 230;
 * monClipB.x = 400;
 * monClipB.y = 230;
 * monClipA.tween()
 *			.from( 1.0, x = 0, y = 0, alpha = 1 )
 *			.chain( monClipB ).delay(1)
 *			.to( 1.0, x=230, scaleX=2, scaleX=5).ease( Bounce.easeOut )
 *			.chain(monClipA)
 *			.to( 1, x = 400 ).ease( Quint.easeIn)
 *			.to( 1, x = 100, alpha = 0 ).loop(2).onComplete( function(t) { if( !t.backward ) t.reverse(); } );
 *
 * Visualisation des effets de tweens: http://hosted.zeh.com.br/tweener/docs/en-us/misc/transitions.html
 * TODO : 	components pour propriétés plus funky
 */

 enum TFx {
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
	TRand( proba : Int ); // progression chaotique de début -> fin. ATTENTION : la durée ne sera pas respectée (plus longue)
	TShake; // variation aléatoire de la valeur entre Début et Fin, puis s'arrête sur Début (départ rapide)
	TShakeBoth; // comme TShake, sauf que la valeur tremble aussi en négatif
	TJump; // saut de Début -> Fin
	TElasticEnd; // léger dépassement à la fin, puis réajustment
	TCustom(fn:Float->Float);
}

typedef Storage<T> = #if flash9 flash.Vector #else Array #end<T>;
class Tween<T>
{
	public static var ID = 0;
	#if !macro
	//STATICS
	static var tweens = new Storage<Tween<Dynamic>>();
	static var tweensCache = new Storage<Int>();

	inline public static function getStamp()
	{
		return 	#if nme
					nme.Lib.getTimer();
				#elseif flash
					flash.Lib.getTimer();
				#end
	}
		
	/**
	 * Method that actually update the tweens
	 * @param	time_s the time in second to use as update period for tweens
	 */
	public static function updateTweens( time_s:Float )
	{
		for( t in tweens )
			if( !t.disposed )
				t.update(time_s);
	}
	
	public static function purge()
	{
		var l = tweens.length;
		for ( i in 0...l )
		{
			if ( tweens[i].disposed )
			{
				tweens.splice(i, 1);
				l--;
			}
		}
		ID = 0;
		for( t in tweens )
			t.id = ID++;
		tweensCache = new Storage<Int>();
	}

	public static function pauseTweens():Void
	{
		for( t in tweens )
			if( !t.disposed )
				t.pause();
	}
	
	public static function resumeTweens():Void
	{
		for( t in tweens )
			if( !t.disposed )
				t.resume();
	}
	
	public static function removeTarget<T>(target:T, ?cb:Tween<T>->Void)
	{
		for( t in tweens )
		{
			if( t.target == target )
			{
				if( cb != null ) cb(cast t);
				t.stop();
				t.dispose();
			}
		}
	}
	
	private static function get() 
	{
		var t : Null<Tween<Dynamic>> = null;
		if ( tweensCache.length > 0 ) 
		{
			t = tweens[tweensCache.pop()];
		}
		return t;
	}
	
	public static function tween<T>( target:T, ?duration:Int, ?pfx : TFx, ?autoStart:Bool = true ):Tween<T> 
	{
		var t : Null<Tween<T>> = cast get();
		if ( t != null ) 
		{
			t.setup( target, duration, pfx, autoStart );
		} 
		else
		{
			t = new Tween( target, duration, pfx, autoStart );
			tweens.push(t);
		}
		return t;
	}
	
	/**** TOOLS ******/	
	static inline function bezier(t:Float, p0:Float, p1:Float, p2:Float, p3:Float) 
	{
		var dt = 1 - t; var dt2 = dt * dt; var dt3 = dt * dt2;
		var t2 = t * t; var t3 = t * t2;
		return	dt3*p0 + 3*t*dt2*p1 + 3*t2*dt*p2 + t3*p3;
	}
	
	//PUBLIC
	public var duration (default, null): Float;
	public var started  (default, null): Bool;
	public var finished (default, null): Bool;
	public var paused   (default, null): Bool;
	public var backward (default, null): Bool;// si le tween va en sens inverse de celui dans lequel il a été créé
	public var id(default, null):Int;
	//PRIVATES
	#if haxe3
	var properties : haxe.ds.GenericStack<Property>;
	#else
	var properties 	: haxe.FastList<Property>;
	#end
	public var target : T;
	
	var parent		: Null<Tween<Dynamic>>;
	var next 		: Null<Tween<Dynamic>>;
	var reversed (default, null): Bool;// logique inverse pour les propriété, utilisé pour le FROM par exemple
	var _locked 	 	: Bool;
	var initialized (default, null): Bool;
	var autoStart	: Bool;
	var time 		: Float;
	var timeScale 	: Float;
	var ke 			: Float;
	var loops		: Int;
	var _fx			: TFx;
	var _ease 		: Float->Float;
	var _onUpdate 	: Null<Tween<T> -> Float -> Void>;
	var _onStart 	: Null<Tween<T> -> Void>;
	var _onComplete : Null<Tween<T> -> Void> ;
	var _delay		: Float;
	var _canDispose : Bool;
	var disposed(default, null) : Bool;
	//TEMPORARIES
	//var ke:Float;
	var count		: Int;
	var _cachedDuration : Float;
	var _cachedDelay : Float;

	function new( t : T, ?duration:Float, ?pfx : TFx, ?autoStart:Bool = true ) 
	{
		id = ID++;
		setup( t, duration, pfx, autoStart);
	}
	
	public function clone() 
	{
		var t : Null<Tween<T>> = cast get();
		if(t != null)
			t.setup( target, duration, _fx, autoStart)
		else
			t = new Tween( target, duration, _fx, autoStart );
		
		for( p in properties )
			t.properties.add(p.clone());
		t.reversed = this.reversed;
		t._locked = this._locked;
		t._delay = this._delay;
		t.count = this.count;
		t.timeScale = this.timeScale;
		t.loops = this.loops;
		return t;
	}
	
	function setup( t : Dynamic, ?duration:Float, ?pfx : TFx, ?autoStart:Bool = true ) 
	{
		this.target = t;
		this.duration = (duration != null) ? duration : 0.0;
		this.fx( (pfx != null) ? pfx : TLinear );
		this.autoStart = autoStart;
		#if haxe3
		this.properties = new haxe.ds.GenericStack<Property>();
		#else
		this.properties = new haxe.FastList<Property>();
		#end
		started = finished = paused = _locked = initialized = false;
		timeScale = 1.0;
		loops = 1;
		_canDispose = true;
		disposed = false;
		_delay = 0.0;
		_onUpdate = null;
		_onStart = null;
		_onComplete = null;
		backward = false;
	}
	
	public function onComplete( cb : Tween<T> -> Void ) 
	{
		_onComplete = cb;
		return this;
	}
	
	public function onStart( cb : Tween<T> -> Void ) 
	{
		_onStart = cb;
		return this;
	}
	
	public function onUpdate( cb : Tween<T> -> Float -> Void ) 
	{
		_onUpdate = cb;
		return this;
	}
	
	public function loop( n : Int ) 
	{
		loops = n;
		return this;
	}

	public function delay( t : Float ) 
	{
		this._delay = t;
		return this;
	}
	
	public function scale( n : Float ) 
	{
		timeScale = n;
		_cachedDuration = (duration * timeScale);
		_cachedDelay = (_delay * timeScale);
		return this;
	}
		
	public function toComplex( inf : Array<Tween.Property>, ?t : Null<Float>  ) 
	{
		return add( inf, t == null ? duration : t );
	}
	
	public function fromComplex( inf : Array<Tween.Property>, ?t : Null<Float> ) 
	{
		return add( inf, t == null ? this.duration : t , true );
	}
	
	public function apply() 
	{
		init();
		return this;
	}
	
	//SOME EFFECTS SEEMS TO NEED TO TWEAKS, CHECK TWEENIE FOR THIS
	public function fx( e : TFx ) 
	{
		_fx = e;
		_ease = switch(e) {
			case TLinear		: function(v) return v;
			case TRand(proba)	: function(v) return if( v == 0 || v == 1 || Std.random(100) < proba) v else ke;
			case TEase			: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0, 0, 1, 1);
			case TEaseIn		: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	0, 0.5, 1);
			case TEaseOut		: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	0.5, 1,	1);
			case TBurn			: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	1, 0, 1);
			case TBurnIn		: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	1, 1, 1);
			case TBurnOut		: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	0, 0, 1);
			case TZigZag		: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	2.5, -1.5, 1);
			case TLoop			: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	1.33, 1.33,	0);
			case TLoopEaseIn	: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	0, 2.25, 0);
			case TLoopEaseOut	: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	2.25, 0, 0);
			case TShake			: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0.5, 1.22,	1.25, 0);
			case TShakeBoth		: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0.5, 1.22,	1.25, 0);
			case TJump			: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	2, 2.79, 1);
			case TElasticEnd	: #if haxe3 bezier.bind( #else callback(bezier,#end _, 0,	0.7, 1.5, 1);
			case TCustom(fn)	: fn;
		}
		return this;
	}
	
	public function ease( e : Float -> Float ) 
	{
		_fx = TCustom( e );
		_ease = callback(e,_);
		return this;
	}
	
	public function chain( ?target ) 
	{
		var t = (target == null) ? this.target : target;
		var tween = Tween.tween(t, false);
		this.next = tween;
		tween.parent = this;
		return tween;
	}
	
	public function start(offset = 0.0) 
	{
		if ( !started || finished ) 
		{
			started = true;
			finished = false;
			init();
			//
			time = 0;
			count = 0;
			ke = 0;
			_cachedDuration = (duration * timeScale);
			_cachedDelay = (_delay * timeScale);
			if( _onStart != null ) _onStart(this);
			disposed = false;
		}
		return this;
	}
	
	inline public function getInterpolation() { return ke; }
	
	public function stop() 
	{
		if ( started ) 
		{
			started = false;
			finished = true;
		}
		return this;
	}
	
	public function dispose() 
	{
		var tail : Tween<Dynamic> = this;
		while( tail.next != null )
			tail = tail.next;
		var n = tail;
		while ( n != null )
		{
			n.stop();
			if ( n.properties != null ) 
			{
				for( p in n.properties )
					p.free();
			}
			var p = n.parent;
			n.free();
			n = p;
		}
	}
	
	function free()
	{
		properties = null;
		_ease = null;
		target = null;
		next = null;
		parent = null;
		_onComplete = null;
		_onStart = null;
		_onUpdate = null;
		disposed = true;
		tweensCache.push(id);
	}
		
	public function replay()
	{
		this._canDispose = false;
		//
		var head : Tween<Dynamic> = this;
		while( head.parent != null )
			head = head.parent;
		//
		if ( finished )
		{
			head.start();
		} 
		else 
		{
			var me = delay(0);//hack
			me.onComplete( function(t) head.start() );
		}
	}
	
	public function reverse() 
	{
		_canDispose = false;
		//
		var isBackward = !backward;
		var n : Tween<Dynamic> = this;
		while ( n != null ) 
		{
			n.backward = !n.backward;
			if( isBackward ) n = n.parent;
			else n = n.next;
		}
		//
		return start();
	}
	
	public function pause() 
	{
		if ( !paused && !finished ) 
		{
			paused = true;
		}
		return this;
	}
	
	public function resume() 
	{
		if ( paused ) 
		{
			paused = false;
		}
		return this;
	}

	function init() 
	{
		if ( !initialized ) 
		{
			for( p in properties)
				p.init(this.reversed);
			initialized = true;
		}
	}
	
	public function reset() 
	{
		for( p in properties)
		{
			p.update(0., this._fx);
		}
	}
	
	function configure( inf : Array<Property>, duration : Float, reversed : Bool ) 
	{
		#if haxe3
		this.properties = new haxe.ds.GenericStack<Property>();
		#else
		this.properties = new haxe.FastList<Property>();
		#end
		for( f in inf )
			properties.add( f );
		this.duration = duration;
		this.reversed = reversed;
		this._locked = true;
	}
	
	function add( inf : Array<Property>, duration : Float, reverse = false )
	{
		if ( finished || _locked )
		{
			return chain().add( inf, duration, reverse );
		} 
		else 
		{
			configure(inf, duration, reverse);
			if( autoStart )
				start();
			return this;
		}
	}
	
	public function update( tickTime : Float )
	{
		if ( started && !finished && !paused ) 
		{
			time += tickTime;
			if ( time > _cachedDelay ) 
			{
				var realTime = this.time - _cachedDelay;
				var k = realTime / _cachedDuration;
				if ( k > 1.0 ) k = 1.0;
				else if ( k < 0.0 ) k = 0.0;
				
				if ( backward ) k = 1.0 - k;
				ke = _ease( k );
				for( p in properties )
					p.update(ke, _fx);
				if( _onUpdate != null ) _onUpdate(this, k);
				if ( (!backward && k == 1.0) || (backward && k == 0.0)) 
				{
					stop();
					if ( ++count < loops ) 
					{
						//hack
						var n = count;
						start(realTime - _cachedDuration);
						count = n;
					} 
					else
					{
						if( _onComplete != null ) _onComplete(this);
						// petit hack, mais si le onComplete relance le tween (replay, reverse) alors le flag started sera reinitialisé
						if( started ) return;
						// on lance le complete avant, pour permettre de faire un reverse, un replay etc. et ainsi couper le dispose automatique des ressources
						if ( backward ) 
						{
							if( parent != null  ) parent.start(realTime - _cachedDuration);
							else if( _canDispose ) this.dispose();
						} 
						else 
						{
							if( next != null ) next.start(realTime - _cachedDuration);
							else if( _canDispose ) this.dispose();
						}
					}
				}
			}
		}
	}
	
	#else
	//public static var locals = new Hash<{ type : Null<ComplexType>, name : String, expr : Null<Expr> }>();
	#end
	
	#if haxe3
	macro
	#else
	@:macro 
	#end
	public function to( ethis : Expr, time:Expr, exprs:Array<Expr> ) : Expr 
	{
		ID++;
		
		var vname = "_tweenToRef" + (ID);
		var vdecl = macro var $vname = $ethis;
		var v = { expr : EConst(CIdent(vname)), pos : haxe.macro.Context.currentPos() };
		
		var tname = "_tweenToRefTarget" + (ID);
		var tdecl = macro var $tname = $v.target;
		var t = { expr : EConst(CIdent(tname)), pos : haxe.macro.Context.currentPos() };
		
		//locals.set( vname, { name : vname, expr : v, type: mt.kiroukou.tools.macros.TypeTools.toComplex(haxe.macro.Context.typeof( $ethis.target )) } );
		
		var ret = mt.kiroukou.motion.macros.TweenBuilder.build(t, exprs);
		var eret = macro { $vdecl; $tdecl; $v.toComplex( $ret, $time ); };
		
		return eret;
	}
	
	#if haxe3
	macro
	#else
	@:macro 
	#end
	public function from( ethis : Expr, time:Expr, exprs:Array<Expr> ) : Expr 
	{
		ID++;
		var vname = "_tweenFromRef" + (ID);
		var vdecl = macro var $vname = $ethis;
		var v = { expr : EConst(CIdent(vname)), pos : haxe.macro.Context.currentPos() };
		
		var tname = "_tweenFromRefTarget" + (ID);
		var tdecl = macro var $tname = $v.target;
		var t = { expr : EConst(CIdent(tname)), pos : haxe.macro.Context.currentPos() };
		
		var ret = mt.kiroukou.motion.macros.TweenBuilder.build(t, exprs);
		var eret = macro { $vdecl; $tdecl; $v.fromComplex( $ret, $time ); };
		
		return eret;
	}
}

interface Property 
{
	function update( p : Float, fx:TFx ) : Void;
	function init( reversed : Bool ) : Void;
	function free() : Void;
	function clone() : Property;
}

class FloatProperty implements Property 
{
	var _get:Void->Float;
	var _set:Float->Float;
	
	var start : Float;
	var end : Float;
	var delta : Float;
	
	public static var cacheBuffer = new #if flash9 flash.Vector #else Array #end<FloatProperty>();
	static public function get( get:Void->Float, set:Float->Float, end : Float) 
	{
		var p : FloatProperty;
		if ( cacheBuffer.length != 0 ) 
		{
			p = cacheBuffer.pop();
			p.setup(get, set, end);
		}
		else 
		{
			p = new FloatProperty(get, set, end);
		}
		return p;
	}
	
	public function clone() 
	{
		return FloatProperty.get( _get, _set, end );
	}
	
	public function new( get:Void->Float, set:Float->Float, end : Float)
	{
		setup(get, set, end);
	}
	
	function setup( get:Void->Float, set:Float->Float, end : Float )
	{
		this._set = set;
		this._get = get;
		this.end = end;
	}
	
	public function free() 
	{
		_set = null;
		_get = null;
		cacheBuffer.push(this);
	}
	
	inline public function init( reversed : Bool ) 
	{
		if ( reversed ) 
		{
			start = end;
			end = _get();
			_set( start );
		} 
		else 
		{
			start = _get();
		}
		delta = end - start;
	}
	
	public function update(p:Float, fx : TFx) 
	{
		switch( fx ) 
		{
			case TShake: _set( start +  Std.int(Math.random() * p * delta));
			case TShakeBoth: _set( start + Std.int(Math.random() * p * delta)) * (Std.random(2) * 2 - 1);
			default : _set(start + delta * p);
		}
	}
}
