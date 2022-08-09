package mt.flash;
import flash.display.DisplayObject;


class ParticleEmitter 
{
	var particles : flash.Vector<mt.flash.Particle>;
	public var DEFAULT_BOUNDS : Null<flash.geom.Rectangle>;
	public var GX = 0;
	public var GY = 0.4;
	public var WINDX = 0.0;
	public var WINDY = 0.0;
	public var DEFAULT_SNAP_PIXELS = false;
	public var LIMIT : Int = 1000;
	
	public function new()
	{
		particles = new flash.Vector<mt.flash.Particle>();
	}
	
	public function addParticle( p:Particle )
	{
		if ( !isClearing ) 
		{
			p.emitter = this;
			particles.push(p);
		}
		return this;
	}
	
	public function makeParticle( x:Float, y:Float, vx:Float, vy:Float, life:Float):Particle
	{
		var p = new Particle(x, y);
		p.dx = vx;
		p.dy = vy;
		p.life = life;
		addParticle(p);		
		return p;
	}
		
	public function update() 
	{
		if ( isClearing ) return;
		//
		var i = 0, g = 0.;
		var wx = WINDX;
		var wy = WINDY;
		var limit = LIMIT;
		var count = particles.length;
		while (i < count)
		{
			var p = particles[i];
			var wind = (p.fl_wind?1:0);
			p.delay --;
			
			p.visible = p.delay <= 0;
			
			if ( p.delay > 0 )
			{
				i++;
			}
			else 
			{
				if ( p.onStart != null )
				{
					var cb = p.onStart;
					p.onStart = null;
					cb();
				}
				
				// gravité
				g = p.gx == null ? GX : p.gx;
				p.dx += g + wind * wx;
				g = p.gy == null ? GY : p.gy;
				p.dy += g + wind * wy;
				
				// friction
				p.dx *= p.frictX;
				p.dy *= p.frictY;
				
				// mouvement
				p.x += p.dx;
				p.y += p.dy;
				
				// ground collision
				if (p.groundY != null && p.dy > 0 && p.y >= p.groundY)
				{
					p.dy = -p.dy * p.bounce;
					p.y = p.groundY - 1;
					if( p.onBounce!=null )
						p.onBounce();
				}
				
				if ( p.pixel ) 
				{
					p.x = Std.int(p.x);
					p.y = Std.int(p.y);
				}
				
				p.rotation += p.dr;
				p.scaleX += p.ds + p.dsx;
				p.scaleY += p.ds + p.dsy;
				
				// fade in
				if ( p.rlife > 0 && p.da != 0 )
				{
					p.alpha += p.da;
					if ( p.alpha > 1 )
					{
						p.da = 0;
						p.alpha = 1;
					}
					if ( p.alpha < 0 )
					{
						p.da = 0;
						p.alpha = 0;
					}
				}
				
				p.rlife --;
				
				// fade out considering life
				if( p.rlife <= 0 || !p.ignoreLimit && Std.int(i) < cast(count-limit) )
					p.alpha -= p.fadeOutSpeed;
				
				// death of particle
				if ( p.rlife <= 0 && (p.alpha <= 0 || p.killOnLifeOut ) || p.bounds != null && !p.bounds.contains(p.x, p.y)  )
				{
					// Destruction
					if( p.onKill!=null )
						p.onKill();
					particles.splice(i, 1);
					count--;
				} 
				else 
				{
					if( p.onUpdate!=null )
						p.onUpdate();
					i++;
				}
			}
		}
	}
	
	var isClearing:Bool = false;
	public function clear() 
	{
		isClearing = true;
		for (p in particles) 
		{
			p.destroy();
			if( p.onKill != null )
				p.onKill();
		}
		particles = new flash.Vector<mt.flash.Particle>();
		isClearing = false;
	}
	
	inline public function sync( mc:DisplayObject, p:mt.flash.Particle )
	{
		mc.x = p.x;
		mc.y = p.y;
		mc.scaleX = p.scaleX;
		mc.scaleY = p.scaleY;
		mc.rotation = p.rotation;
		mc.visible = p.visible;
		mc.alpha = p.alpha;
	}
}

/**
 * Logic only particle class.
 * Sync with graphical object using onUpdate method !
 * 
 * p = new mt.flash.Particle(0,0);
 * p.onUpdate = function() {
 * 		mc.x = p.x;
 *		mc.y = p.y;
 *		mc.scaleX = p.scaleX;
 *		mc.scaleY = p.scaleY;
 *		mc.rotation = p.rotation;
 *		mc.visible = p.visible;
 *		mc.alpha = p.alpha;
 *	}
 */
class Particle {
	public var emitter(default, set)	: Null<ParticleEmitter>;	
	public var x		: Float;
	public var y		: Float;
	public var alpha	: Float;
	public var rotation	: Float;
	public var scale(default, set):Float;
	public var scaleX	: Float;
	public var scaleY	: Float;
	public var visible	: Bool;
	
	public var dx		: Float;
	public var dy		: Float;
	public var da		: Float; // alpha
	public var ds		: Float; // scale
	public var dsx		: Float; // scaleX
	public var dsy		: Float; // scaleY
	public var frictX	: Float;
	public var frictY	: Float;
	public var gx		: Null<Float>;
	public var gy		: Null<Float>;
	public var dr		: Float;
	public var fadeOutSpeed: Float;
	public var bounce	: Float;
	public var frict(never, set)	: Float;
	
	public var life(default,set_life)	: Float;
	@:allow(mt.flash.ParticleEmitter) var rlife			: Float;
	@:allow(mt.flash.ParticleEmitter) var maxLife			: Float;
	
	public var bounds	: Null<flash.geom.Rectangle>;
	public var groundY	: Null<Float>;
	public var groupId	: Null<String>;
	
	@:isVar public var delay(default, set_delay):Float;
	
	public var onStart	: Null<Void->Void>;
	public var onBounce	: Null<Void->Void>;
	public var onUpdate	: Null < Void->Void > ;
	public var onKill	: Null < Void->Void > ;
	
	public var fl_wind	: Bool;
	public var killOnLifeOut	: Bool;
	public var pixel	: Bool;	
	public var ignoreLimit	: Bool; // if TRUE, cannot be killed by the performance LIMIT
	
	public function new(x:Float, y:Float) 
	{
		setPos(x, y);
		scaleX = scaleY = 1.0;
		rotation = 0;
		alpha = 1.0;
		visible = true;
		
		dx = dy = da = ds = dsx = dsy = 0;
		gx = 0;
		gy = 0;
		fadeOutSpeed = 0.1;
		bounce = 0.85;
		dr = 0;
		frictX = 0.95+Std.random(40)/1000;
		frictY = 0.97;
		delay = 0;
		life = 32+Std.random(32);
		
		ignoreLimit = false;
		killOnLifeOut = false;
		fl_wind = false;
		
		reset();
	}
	
	function set_emitter(e) {
		emitter = e;
		if( e != null )
		{
			pixel = e.DEFAULT_SNAP_PIXELS;
			bounds = e.DEFAULT_BOUNDS; 
		}
		return e;
	}
	
	function set_scale(v) {
		scaleX = scaleY = v;
		return v;
	}
	
	function set_frict(v) {
		frictX = frictY = v;
		return v;
	}
	
	function set_delay(d:Float):Float {
		visible = d <= 0;
		return delay = d;
	}
	
	function set_life(l:Float):Float {
		if( l < 0 )
			l = 0;
		life = l;
		rlife = l;
		maxLife = l;
		return l;
	}
	
	public inline function time() {
		return 1 - (rlife + alpha)/(maxLife+1);
	}
	
	public inline function reset() {
		gx = gy = dx = dy = dr = 0;
		frictX = frictY = 1;
	}

	public function destroy() {
		alpha = 0;
		life = 0;
		emitter = null;
	}
	
	public inline function getSpeed() {
		return Math.sqrt( dx * dx + dy * dy );
	}
	
	public inline function moveAng(a:Float, spd:Float) {
		dx = Math.cos(a) * spd;
		dy = Math.sin(a) * spd;
	}
	
	public inline function setPos(x,y) {
		this.x = x;
		this.y = y;
	}
}

