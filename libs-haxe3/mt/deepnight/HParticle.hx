package mt.deepnight;

#if !h3d
#error "h3d is required for HParticle"
#end

import mt.MLib;
import h2d.Tile;
import h2d.SpriteBatch;

class HParticle extends BatchElement implements ParticleInterface {
	public static var DEFAULT_BOUNDS : flash.geom.Rectangle = null;

	var stamp					: Float;
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
	var rlife					: Float;
	var maxLife					: Float;
	public var bounds			: Null<flash.geom.Rectangle>;
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
	
	public var group			: Null<Int>;// useful to manage group of particles
	
	public function new(t:Tile, ?x:Float, ?y:Float) {
		super(t);
		
		pooled = false;
		reset(x,y);
	}

	public function reset(?t:Tile, ?x:Float, ?y:Float) {
		if( t!=null )
			tile = t;

		if( x!=null && y!=null )
			setPos(x,y);

		rotation = 0;
		scaleX = scaleY = 1;
		skewX = skewY = 0;
		color.set(1,1,1,1);
		alpha = 1;
		scaleMul = 1;
		visible = true;
		
		stamp = haxe.Timer.stamp();
		setCenterRatio(0.5, 0.5);
		killed = false;
		maxAlpha = 1;
		dx = dy = da = dr = ds = dsx = dsy = 0;
		gx = gy = 0;
		frictX = frictY = 1;
		fadeOutSpeed = 0.1;
		bounceMul = 0.85;
		delay = 0;
		life = 30;
		pixel = false;
		bounds = DEFAULT_BOUNDS;
		killOnLifeOut = false;
		groundY = null;
		groupId = null;

		onStart = null;
		onKill = null;
		onBounce = null;
		onUpdate = null;
	}

	public static function initPool(sb:SpriteBatch, count:Int) : Array<HParticle> {
		var pool = [];
		var t = sb.tile.clone().sub(0,0,2,2);
		for(i in 0...count) {
			var p = new mt.deepnight.HParticle(t);
			sb.add(p);
			p.pooled = true;
			p.kill();
			pool.push(p);
		}
		return pool;
	}
	
	public static function allocFromPool(pool:Array<HParticle>, t:h2d.Tile, ?x:Float, ?y:Float) {
		// TODO: find a faster way to retrieve destroyed particles
		var oldest : HParticle = null;
		for(p in pool) {
			if( p.killed ) {
				p.reset(t, x,y);
				return p;
			} else if( oldest==null || p.stamp<=oldest.stamp ) {
				oldest = p;
			}
		}
		oldest.reset(t, x, y);
		return oldest;
	}


	public inline function rnd(min,max,?sign) return mt.deepnight.Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return mt.deepnight.Lib.irnd(min,max,sign);

	inline function set_maxAlpha(v) {
		if( alpha>v )
			alpha = v;
		maxAlpha = v;
		return v;
	}

	//Real Setters/Getters that give access from hscript (getters/setters can't be used)
	public function setDelay(d:Float) { this.delay = d; }
	public function setLife(d:Float) { this.life = d; }
	public function getTime() { return this.time; }
	public function getWidth() { return this.width; }
	public function getHeight() { return this.height; }
	public function setWidth(v) { return this.width = v; }
	public function setHeight(v) { return this.height = v; }
	public function setFriction(v) { return this.frict = v; }
	
	//public function offsetPivot(dx:Float,dy:Float) {
		//tile.dx -= MLib.round(dx);
		//tile.dy -= MLib.round(dy);
	//}
//
	//public function offsetPivotRatio(xr:Float,yr:Float) {
		//tile.dx -= MLib.round(xr*tile.width);
		//tile.dy -= MLib.round(yr*tile.height);
	//}

	public inline function setCenterRatio(xr:Float, yr:Float) tile.setCenterRatio(xr,yr);
	public inline function setPivotCoord(x:Float,y:Float) tile.setCenter(Std.int(x), Std.int(y));
	inline function set_frict(v) return frictX = frictY = v;

	public function fadeIn(alpha:Float, spd:Float) {
		this.alpha = 0;
		maxAlpha = alpha;
		da = spd;
	}

	inline function set_delay(d:Float):Float {
		visible = d <= 0;
		return delay = d;
	}

	function toString() {
		return 'HPart@$x,$y(life=$rlife,pooled=$pooled)';
	}

	public function clone() : HParticle {
		var s = new haxe.Serializer();
		s.useCache = true;
		s.serialize(this);
		return haxe.Unserializer.run( s.toString() );
	}

	function set_life(l:Float):Float {
		if( l<0 )
			l = 0;
		rlife = l;
		maxLife = l;
		return l;
	}

	inline function get_time() {
		return 1 - (rlife+alpha)/(maxLife+1);
	}

	public function kill() {
		alpha = 0;
		life = 0;
		killed = true;

		if( pooled )
			visible = false;
		else
			dispose();
	}

	public function dispose() {
		remove();
		bounds = null;
	}

	public inline function isAlive() {
		return rlife>0;
	}

	public inline function getSpeed() {
		return Math.sqrt( dx*dx + dy*dy );
	}

	public inline function sign() {
		return Std.random(2)*2-1;
	}

	public inline function randFloat(f:Float) {
		return Std.random( Std.int(f*10000) ) / 10000;
	}

	public inline function moveAng(a:Float, spd:Float) {
		dx = Math.cos(a)*spd;
		dy = Math.sin(a)*spd;
	}

	public inline function moveTo(x:Float,y:Float, spd:Float) {
		var a = Math.atan2(y-this.y, x-this.x);
		dx = Math.cos(a)*spd;
		dy = Math.sin(a)*spd;
	}

	public inline function moveAwayFrom(x:Float,y:Float, spd:Float) {
		var a = Math.atan2(y-this.y, x-this.x);
		dx = -Math.cos(a)*spd;
		dy = -Math.sin(a)*spd;
	}

	public inline function getMoveAng() {
		return Math.atan2(dy,dx);
	}


	public function update(
		#if !HPartTMod
		rendering : Bool
		#else
		tmod : Float
		#end
	) {
		#if !HPartTMod
		delay--;
		#else
		delay -= tmod;
		#end
		if( delay>0 || killed )
			return;
		else {
			if( onStart!=null ) {
				var cb = onStart;
				onStart = null;
				cb();
			}

			// gravité
			#if !HPartTMod
			dx += gx;
			dy += gy;
			#else
			dx += gx * tmod;
			dy += gy * tmod;
			#end

			// friction
			#if !HPartTMod
			dx *= frictX;
			dy *= frictY;
			#else
			dx *= Math.pow(frictX, tmod);
			dy *= Math.pow(frictY, tmod);
			#end

			// mouvement
			#if !HPartTMod
			x += dx;
			y += dy;
			#else
			x += dx * tmod;
			y += dy * tmod;
			#end

			// Ground
			if( groundY!=null && dy>0 && y>=groundY ) {
				dy = -dy*bounceMul;
				y = groundY-1;
				if( onBounce!=null )
					onBounce();
			}

			#if !HPartTMod
			rotation += dr;
			scaleX += ds + dsx;
			scaleY += ds + dsy;
			scaleX *= scaleMul;
			scaleY *= scaleMul;
			#else
			rotation += dr * tmod;
			scaleX += (ds + dsx) * tmod;
			scaleY += (ds + dsy) * tmod;
			scaleX *= Math.pow(scaleMul, tmod);
			scaleY *= Math.pow(scaleMul, tmod);
			#end
			
			// Fade in
			if ( rlife > 0 && da != 0 ) {
				#if !HPartTMod
				alpha += da;
				#else
				alpha += da * tmod;
				#end
				if( alpha > maxAlpha ) {
					da = 0;
					alpha = maxAlpha;
				}
			}

			#if !HPartTMod
			rlife--;
			#else
			rlife -= tmod;
			#end

			// Fade out (life)
			if( rlife <= 0 )
				#if !HPartTMod
				alpha -= fadeOutSpeed;
				#else
				alpha -= fadeOutSpeed * tmod;
				#end

			// Death
			if( rlife<=0 && (alpha<=0 || killOnLifeOut) || bounds!=null && !bounds.contains(x, y)  ) {
				if( onKill!=null ) {
					var cb = onKill;
					onKill = null;
					cb();
				}
				kill();
			} else if ( onUpdate != null ) {
				onUpdate();
			}
		}
	}
}

