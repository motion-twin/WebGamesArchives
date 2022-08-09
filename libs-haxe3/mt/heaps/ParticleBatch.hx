package mt.heaps;

import mt.MLib;
import mt.deepnight.slb.BLib;

class ParticleBatch {
	public var ALL		: Array<ParticleBatchElement>;
	public var IDLE		: Array<ParticleBatchElement>;

	public var numMax	: Int;

	public var bm		: h2d.SpriteBatch;
	public var bLib		: BLib;

	public function new(bLib:BLib, ?parent:h2d.Sprite, ?newNumMax:Int = 200) {
		this.bLib = bLib;
		this.numMax = newNumMax;

		bm = new h2d.SpriteBatch(bLib.tile, parent);

		ALL = [];
		IDLE = [];

		for (i in 0...500) {
			var p = new ParticleBatchElement(this);
			IDLE.push(p);
		}
	}

	public function create(id:String, ?f:Int = 0, ?animated:Bool = true, ?x:Float, ?y:Float, ?pt: { x:Float, y:Float } ) {
		var idle = getIdle();
		ALL.push(idle);
		idle.init(id, f, animated, x, y, pt);
		return idle;
	}

	function getIdle() {
		if (IDLE.length > 0)
			return IDLE.shift();
		else
			return ALL.shift();
	}

	public function destroyAll() {
		for(p in ALL)
			p.destroy();

		for(p in IDLE)
			p.destroy();

		ALL = null;
		IDLE = null;
	}

	public function idleAll() {
		if (IDLE != null)
			for(p in IDLE)
				p.idle();
	}

	public function updateAll() {
		if (IDLE != null && ALL != null) {
			var i : #if openfl Int #else UInt #end = 0;
			var wx = ParticleBatchElement.WINDX;
			var wy = ParticleBatchElement.WINDY;
			var limit = ParticleBatchElement.LIMIT;

			var count : #if openfl Int #else UInt #end = ALL.length;
			while(i < count) {
				var p = ALL[i];
				var wind = (p.fl_wind?1:0);
				p.delay--;
				if( p.delay <= 0) {
					if( p.onStart!=null && !p.isIdle ) {
						var cb = p.onStart;
						p.onStart = null;
						cb();
					}

					var e = p.e;

					// gravité
					p.dx+= p.gx + wind*wx;
					p.dy+= p.gy + wind*wy;

					// friction
					p.dx *= p.frictX;
					p.dy *= p.frictY;

					// mouvement
					p.rx += p.dx;
					p.ry += p.dy;

					// Ground
					if( p.groundY!=null && p.dy>0 && p.ry>=p.groundY ) {
						p.dy = -p.dy*p.bounce;
						p.ry = p.groundY-1;
						if( p.onBounce!=null )
							p.onBounce();
					}

					// Display coords
					if( p.pixel ) {
						e.x = Std.int(p.rx);
						e.y = Std.int(p.ry);
					}
					else {
						e.x = p.rx;
						e.y = p.ry;
					}

					e.rotation += p.dr;
					e.scaleX += p.ds + p.dsx;
					e.scaleY += p.ds + p.dsy;

					// Fade in
					if( p.rlife>0 && p.da!=0 ) {
						e.alpha += p.da;
						if( e.alpha>1 ) {
							p.da = 0;
							e.alpha = 1;
						}
					}

					p.rlife--;

					// Fade out (life)
					if( p.rlife<=0 || !p.ignoreLimit && Std.int(i) < cast(ALL.length-limit) )
						e.alpha -= p.fadeOutSpeed;

					// Death
					if( p.rlife<=0 && (e.alpha<=0 || p.killOnLifeOut) || p.bounds!=null && !p.bounds.hasPoint(new h2d.col.Point(p.rx, p.ry))  ) {
						if( p.onKill!=null )
							p.onKill();
						p.idle();
						i--;
						count--;
					}
					else {
						if( p.onUpdate!=null )
							p.onUpdate();
					}
				}
				i++;
			}
		}
	}
}

class ParticleBatchElement {
	public static var DEFAULT_BOUNDS : h2d.col.Poly = null;
	public static var DEFAULT_BLENDMODE : h2d.BlendMode = Add;
	public static var AUTO_RESET_SETTINGS = true;
	public static var GX = 0;
	public static var GY = 0.4;
	public static var WINDX = 0.0;
	public static var WINDY = 0.0;
	public static var DEFAULT_SNAP_PIXELS = true;
	public static var LIMIT : Int = 1000;

	public var rx		: Float; // real x,y
	public var ry		: Float;
	public var dx		: Float;
	public var dy		: Float;
	public var da		: Float; // alpha
	public var ds		: Float; // scale
	public var dsx		: Float; // scaleX
	public var dsy		: Float; // scaleY
	public var dr		: Float;
	public var frict(never,set)	: Float;
	public var frictX	: Float;
	public var frictY	: Float;
	public var gx		: Float;
	public var gy		: Float;
	public var bounce	: Float;
	public var life(default,set)	: Float;
	public var rlife	: Float;
	public var maxLife	: Float;
	public var bounds	: Null<h2d.col.Poly>;
	public var fl_wind	: Bool;
	public var groundY	: Null<Float>;
	public var groupId	: Null<String>;
	public var fadeOutSpeed	: Float;
	public var isIdle	: Bool;

	public var pb		: ParticleBatch;
	public var bm		: h2d.SpriteBatch;
	public var e		: h2d.SpriteBatch.BatchElement;
	public var bLib		: BLib;

	public var delay(default, set)	: Float;

	public var onStart	: Null<Void->Void>;
	public var onBounce	: Null<Void->Void>;
	public var onUpdate	: Null<Void->Void>;
	public var onKill	: Null<Void->Void>;

	public var pixel			: Bool;
	public var killOnLifeOut	: Bool;
	public var ignoreLimit		: Bool; // if TRUE, cannot be killed by the performance LIMIT

	/**
	 * MUST BE CREATE BY THE PARTICULEBATCH : pb.create();
	 * @param	pb
	 */
	public function new(pb:ParticleBatch) {
		this.pb = pb;
		bm = pb.bm;
		bLib = pb.bLib;
	}

	public function init(id:String, ?f:Int = 0, ?animated:Bool = true, ?x:Float, ?y:Float, ?pt: { x:Float, y:Float } ) {
		//if (hsBatch == null)
			//hsBatch = bLib.getBatchElementAnim(bm, f);
		//setAnim(id, f, animated);
		if (animated)
			e = bLib.hbe_get(bm, id);
		else
			e = bLib.getBatchElement(bm, id);
		e.alpha = 1;
		e.scaleX = e.scaleY = 1;
		e.rotation = 0;
		e.visible = true;

		if( pt!=null ) {
			x = pt.x;
			y = pt.y;
		}
		changePos(x,y);
		dx = dy = da = ds = dsx = dsy = 0;
		gx = GX;
		gy = GY + Std.random(Std.int(GY*10))/10;
		fadeOutSpeed = 0.1;
		ignoreLimit = false;
		bounce = 0.85;
		dr = 0;
		frictX = 0.95+Std.random(40)/1000;
		frictY = 0.97;
		delay = 0;
		life = 32+Std.random(32);
		pixel = DEFAULT_SNAP_PIXELS;
		bounds = DEFAULT_BOUNDS;
		killOnLifeOut = false;
		fl_wind = true;
		isIdle = false;

		if( AUTO_RESET_SETTINGS )
			reset();
	}

	function set_frict(v) {
		frictX = frictY = v;
		return v;
	}

	function set_delay(d:Float):Float {
		e.visible = d <= 0;
		return delay = d;
	}

	public function clone() : ParticleBatchElement {
		var s = new haxe.Serializer();
		s.useCache = true;
		s.serialize(this);
		return haxe.Unserializer.run( s.toString() );
	}

	public inline function setPivotCoord(x:Int, y:Int) {
		e.tile = e.tile.center(x, y);
	}

	public inline function setPivotFactor(xRatio:Float, yRatio:Float) {
		e.tile = e.tile.centerRatio(xRatio, yRatio);
	}

	function set_life(l:Float):Float {
		if( l<0 )
			l = 0;
		life = l;
		rlife = l;
		maxLife = l;
		return l;
	}

	public inline function time() {
		return 1 - (rlife+ e.alpha)/(maxLife+1);
	}

	public inline function reset() {
		gx = gy = dx = dy = dr = 0;
		frictX = frictY = 1;
	}

	public function idle() {
		e.visible = false;
		life = 0;

		isIdle = true;

		pb.ALL.remove(this);
		pb.IDLE.push(this);
	}

	public function destroy() {
		life = 0;

		if (e != null) {
			e.remove();
			e = null;
		}
	}

	public inline function getSpeed() {
		return Math.sqrt( dx*dx + dy*dy );
	}

	public static inline function sign() {
		return Std.random(2)*2-1;
	}

	public static inline function randFloat(f:Float) {
		return Std.random( Std.int(f*10000) ) / 10000;
	}

	public inline function moveAng(a:Float, spd:Float) {
		dx = Math.cos(a)*spd;
		dy = Math.sin(a)*spd;
	}

	public inline function getMoveAng() {
		return Math.atan2(dy,dx);
	}

	public inline function changePos(x, y) {
		rx = e.x = x;
		ry = e.y = y;
	}
}

