package mt.motion;

#if macro
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Printer;
#end

typedef EaseFunc = Float->Float->Float->Float->Float;

/**
 * Documentation : https://bible.motion-twin.com/dev/libs
 */
class Tween
{
	public static var ID = 0;
#if !macro	
	//PUBLIC
	public var duration (default, null): Float;
	public var started  (default, null): Bool;
	public var finished (default, null): Bool;
	public var paused   (default, null): Bool;
	public var backward (default, null): Bool;// si le tween va en sens inverse de celui dans lequel il a été créé
	public var id(default, null):Int;
	//PRIVATES
	var properties  : haxe.ds.GenericStack<Property>;
	var parent		: Null<Tween>;
	var next 		: Null<Tween>;
	var reversed (default, null): Bool;// logique inverse pour les propriété, utilisé pour le FROM par exemple
	var _locked 	: Bool;
	var initialized (default, null): Bool;
	var autoStart	: Bool;
	var time 		: Float;
	var timeScale 	: Float;
	var ke 			: Float;
	var loops		: Int;
	var waitFrame 	: Int;
	var _ease 		: EaseFunc;
	var _canDispose : Bool;
	public var disposed(default, null) : Bool;
	//TEMPORARIES
	var count		: Int;
	var _cachedDuration : Float;
	
	public var onComplete:Null<Void->Void>;
	public var onStart:Null<Void->Void>;
	public var onUpdate:Null < Float->Void > ;
	@:allow(mt.motion.Tweener) var tweener:Null<Tweener>;
	
	public function new( ?pEase:EaseFunc, ?autoStart:Bool = true ) 
	{
		id = ID++;
		setup( pEase, autoStart );
	}
	
	function setup( ?pfx : EaseFunc, ?autoStart:Bool = true ) 
	{
		this._ease = (pfx != null) ? pfx : Ease.linear;
		this.autoStart = autoStart;
		this.properties = new haxe.ds.GenericStack<Property>();
		
		next = null;
		parent = null;
		
		onUpdate = null;
		onComplete = onStart = null;
		started = finished = paused = _locked = initialized = false;
		
		duration = 0.0;
		time = 0.0;
		timeScale = 1.0;
		loops = 1;
		ke = 0.0;
		waitFrame = 0;
		
		_canDispose = true;
		_locked = false;
		disposed = false;
		reversed = false;
		backward = false;
	}
	
	public function loop( n : Int ) 
	{
		loops = n;
		return this;
	}

	public function delay( t : mt.motion.Duration ) 
	{
		return toComplex([], t);
	}
	
	public function scale( n : Float ) 
	{
		timeScale = n;
		_cachedDuration = (duration * timeScale);
		return this;
	}
		
	public function apply() 
	{
		init();
		return this;
	}
	
	public function ease( e : Float -> Float -> Float -> Float ->Float ) 
	{
		_ease = e;
		return this;
	}
	
	public function chain(?t) 
	{
		var tail = this;
		while ( tail.next != null ) 
			tail = tail.next;
		
		var tween = if( t != null ) t
					else if ( tweener != null ) tweener.create(false) 
					else new Tween(false);
		tail.next = tween;
		tween.parent = tail;
		tween.waitFrame = 1;
		return tween;
	}
	
	public function end(pAct:Void->Void)
	{
		onComplete = pAct;
		return this;
	}
	
	public function begin(pAct:Void->Void)
	{
		onStart = pAct;
		return this;
	}
	
	public function start(offset = 0.0) 
	{
		if ( !started || finished ) 
		{
			started = true;
			finished = false;
			init();
			//
			time = offset;
			count = 0;
			ke = 0;
			_cachedDuration = (duration * timeScale);
			if( onStart != null ) onStart();
			disposed = false;
		}
		return this;
	}
	
	inline public function getInterpolation() { return ke; }
	
	inline function finish()
	{
		started = false;
		finished = true;
		return this;
	}
	
	public function dispose() 
	{	
		if ( disposed ) return;
		var tail : Tween = this;
		while( tail.next != null )
			tail = tail.next;
		while ( tail != null )
		{
			tail.finish();
			if ( tail.properties != null ) 
				for( p in tail.properties )
					p.free();
			var p = tail.parent;
			tail.free();
			tail = p;
		}
	}
	
	function free()
	{
		properties = null;
		_ease = null;
		next = null;
		parent = null;
		disposed = true;
		onComplete = onStart = null;
		onUpdate = null;
		if ( tweener != null ) tweener.remove(this);
		tweener = null;
	}
		
	public function replay()
	{
		this._canDispose = false;
		//
		var head : Tween = this;
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
			me.onComplete = function() { head.start(); }
		}
	}
	
	public function on(label:String, pAct:Void->Void)
	{
		var cleanLabel = StringTools.trim(label.toLowerCase());
		switch( cleanLabel )
		{
			case "start", "begin" : onStart = pAct;
			case "end", "complete", "finish": onComplete = pAct;
			case "progress", "update": onUpdate = function(_) pAct();
			default: throw "invalid label";
		}
		return this;
	}
	
	public function reverse() 
	{
		_canDispose = false;
		//
		var isBackward = !backward;
		var n : Tween = this;
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
		if ( !paused ) 
			paused = true;
		return this;
	}
	
	public function resume() 
	{
		if ( paused ) 
			paused = false;
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
			p.update(0);
	}
	
	function configure( inf : Array<Property>, duration : Float, reversed : Bool ) 
	{
		this.properties = new haxe.ds.GenericStack<Property>();
		for( f in inf )
			properties.add( f );
		this.duration = duration;
		this.reversed = reversed;
		this._locked = true;
	}
	
	function add( inf : Array<Property>, duration : Float, reverse = false )
	{
		if( finished || _locked )
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
	
	public function update()
	{
		if( started && !finished && !paused ) 
		{
			if ( waitFrame > 0 ) 
			{
				waitFrame --;
				return;
			}
			time += 1;
			var k = time / _cachedDuration;
			if ( k > 1.0 ) k = 1.0;
			else if ( k < 0.0 ) k = 0.0;
			
			if ( backward ) k = 1.0 - k;
			ke = _ease( k, 0.0, 1.0, 1.0 );
			for( p in properties )
				p.update(ke);
				
			if( onUpdate != null ) onUpdate(k);
			
			if((!backward && k == 1.0) || (backward && k == 0.0)) 
			{
				finish();
				if ( ++count < loops ) 
				{
					//hack
					var n = count;
					start(time - _cachedDuration);
					count = n;
				}
				else
				{
					if( onComplete != null ) onComplete();
					// petit hack, mais si le onComplete relance le tween (replay, reverse) alors le flag started sera reinitialisé
					if( started || paused ) return;
					// on lance le complete avant, pour permettre de faire un reverse, un replay etc. et ainsi couper le dispose automatique des ressources
					if ( backward ) 
					{
						if( parent != null ) parent.start(time - _cachedDuration);
						else if( _canDispose ) this.dispose();
					} 
					else
					{
						if( next != null ) next.start(time - _cachedDuration);
						else if( _canDispose ) this.dispose();
					}
				}
			}
		}
	}
	
	public function toComplex( inf : Array<Tween.Property>, t : mt.motion.Duration  ) 
	{
		return add( inf, t );
	}
	
	public function fromComplex( inf : Array<Tween.Property>, t : mt.motion.Duration ) 
	{
		return add( inf, t , true );
	}
	
#end
	
	macro public function to( ethis : Expr, time:Expr, exprs:Array<Expr> )
	{
		var ret = if ( exprs.length > 0 ) mt.motion.macros.TweenBuilder.build(exprs) else macro [];
		return macro @:privateAccess { $ethis.toComplex( $ret, $time );}
	}
	
	macro public function from( ethis : Expr, time:Expr, exprs:Array<Expr> )
	{
		var ret = if ( exprs.length > 0 ) mt.motion.macros.TweenBuilder.build(exprs) else macro [];
		return macro  @:privateAccess { $ethis.fromComplex( $ret, $time );}
	}

#if hscript
	macro public function evalTo( ethis : Expr, time:Expr, eval:String )
	{
		var pos = haxe.macro.Context.currentPos();
		var parser = new hscript.Parser();
		var ast = parser.parseString(eval);
		var scriptExpr = new hscript.Macro(pos).convert(ast);
		var p = new haxe.macro.Printer();
		
		var exprs:Array<haxe.macro.Expr> = switch( scriptExpr.expr )
		{
			case EBlock(a): a;
			default : [scriptExpr];
		}
		
		var ret = mt.motion.macros.TweenBuilder.build(exprs);
		return macro  @:privateAccess { $ethis.toComplex( $ret, $time );}
	}
	
	macro public function evalFrom( ethis : Expr, time:Expr, eval:String )
	{
		var pos = haxe.macro.Context.currentPos();
		var parser = new hscript.Parser();
		var ast = parser.parseString(eval);
		var scriptExpr = new hscript.Macro(pos).convert(ast);
		var p = new haxe.macro.Printer();
		
		var exprs:Array<haxe.macro.Expr> = switch( scriptExpr.expr )
		{
			case EBlock(a): a;
			default : [scriptExpr];
		}
		
		var ret = mt.motion.macros.TweenBuilder.build(exprs);
		return macro  @:privateAccess { $ethis.fromComplex( $ret, $time );}
	}
#end
	
	static var tweeningProperties = new haxe.ds.StringMap<Array<Dynamic>>();
	public static function registerProperty(pField:String, pInst:Dynamic) 
	{
		var a = tweeningProperties.get(pField);
		if ( a == null ) {
			a = [];
			tweeningProperties.set(pField, a);
		}
		a.push(pInst);
	}
	
	public static function unregisterProperty(pField:String, pInst:Dynamic) 
	{
		var a = tweeningProperties.get(pField);
		if ( a == null ) return;
		a.remove(pInst);
	}
	
	public static function isTweening(pField:String, pInst:Dynamic)
	{
		var a = tweeningProperties.get(pField);
		if ( a == null ) return false;
		return a.indexOf(pInst) >= 0;
	}
}

interface Property 
{
	function update( p : Float ) : Void;
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
	
	var o:Dynamic;
	var f:String;
	
	public static var cacheBuffer = new #if flash9 flash.Vector #else Array #end<FloatProperty>();
	static public function get( o:Null<Dynamic>, prop:String, get:Void->Float, set:Float->Float, end : Float) 
	{
		var p : FloatProperty;
		if ( cacheBuffer.length != 0 ) 
		{
			p = cacheBuffer.pop();
			p.setup(o, prop, get, set, end);
		}
		else 
		{
			p = new FloatProperty(o, prop, get, set, end);
		}
		return p;
	}
	
	public function clone() 
	{
		return FloatProperty.get(o, f, _get, _set, end );
	}
	
	public function new( o:Null<Dynamic>, prop:String, get:Void->Float, set:Float->Float, end : Float)
	{
		setup(o, prop,  get, set, end);
	}
	
	function setup( o:Null<Dynamic>, prop:String, get:Void->Float, set:Float->Float, end : Float )
	{
		this.o = o;
		this.f = prop;
		
		this._set = set;
		this._get = get;
		this.end = end;
	}
	
	public function free() 
	{
		_set = null;
		_get = null;
		cacheBuffer.push(this);
		if( o != null)
			mt.motion.Tween.unregisterProperty(f, o);
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
		if(o != null)
			mt.motion.Tween.registerProperty(f, o);
	}
	
	public function update(p:Float) 
	{
		_set(start + delta * p);
	}
}
