package mt.deepnight;
import flash.Vector;

class Particle extends #if spriteParticles flash.display.Sprite #else flash.display.Shape #end {
	public static var ALL : Vector<Particle> = new Vector();
	public static var DEFAULT_BOUNDS : flash.geom.Rectangle = null;
	public static var AUTO_RESET_SETTINGS = true;
	public static var GX = 0;
	public static var GY = 0.4;
	public static var WINDX = 0.0;
	public static var WINDY = 0.0;
	public static var DEFAULT_SNAP_PIXELS = true;
	public static var LIMIT : Int = 1000;
	
	var rx				: Float; // real x,y
	var ry				: Float;
	public var dx		: Float;
	public var dy		: Float;
	public var da		: Float; // alpha
	public var ds		: Float; // scale
	public var dsx		: Float; // scaleX
	public var dsy		: Float; // scaleY
	public var frictX	: Float;
	public var frictY	: Float;
	public var gx		: Float;
	public var gy		: Float;
	public var dr		: Float;
	public var bounce	: Float;
	@:isVar	public var life(default,set_life)	: Float;
	var rlife			: Float;
	var maxLife			: Float;
	public var bounds	: Null<flash.geom.Rectangle>;
	public var fl_wind	: Bool;
	public var groundY	: Null<Float>;
	public var groupId	: Null<String>;
	
	@:isVar public var delay(default, set_delay):Float;

	public var onStart	: Null<Void->Void>;
	public var onBounce	: Null<Void->Void>;
	public var onUpdate	: Null<Void->Void>;
	public var onKill	: Null<Void->Void>;
	
	public var pixel			: Bool;
	public var killOnLifeOut	: Bool;
	public var ignoreLimit		: Bool; // if TRUE, cannot be killed by the performance LIMIT
	
	public function new(?x:Float, ?y:Float, ?pt:{x:Float, y:Float}) {
		super();
		if( pt!=null ) {
			x = pt.x;
			y = pt.y;
		}
		setPos(x,y);
		dx = dy = da = ds = dsx = dsy = 0;
		gx = GX;
		gy = GY + Std.random(Std.int(GY*10))/10;
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
		ALL.push(this);
		if( AUTO_RESET_SETTINGS )
			reset();
		#if spriteParticles
		this.mouseChildren = this.mouseEnabled = false;
		#end
	}
	
	function set_delay(d:Float):Float {
		visible = d <= 0;
		return delay = d;
	}
	
	
	#if spriteParticles
	public function flatten(?padding=0.0) { // EXPERIMENTAL
		if( parent!=null )
			parent.removeChild(this);
			
		var bmp = mt.deepnight.Lib.flatten(this, padding);
		bmp.smoothing = false;
		graphics.clear();
		while( numChildren>0 )
			removeChildAt(0);
		addChild(bmp);
		
		for( f in filters )
			bmp.bitmapData.applyFilter(bmp.bitmapData, bmp.bitmapData.rect, new flash.geom.Point(0,0), f);
		filters = [];
	}
	#end
	
	public function clone() : Particle {
		var s = new haxe.Serializer();
		s.useCache = true;
		s.serialize(this);
		return haxe.Unserializer.run( s.toString() );
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
		return 1 - (rlife+alpha)/(maxLife+1);
	}
	
	public inline function drawBox(w:Float,h:Float, col:Int, ?a=1.0) {
		graphics.clear();
		graphics.beginFill(col, a);
		graphics.drawRect(-Std.int(w/2),-Std.int(h/2), w,h);
		graphics.endFill();
	}
	
	public inline function drawCircle(r:Float, col:Int, ?a=1.0) {
		graphics.clear();
		graphics.beginFill(col, a);
		graphics.drawCircle(0,0,r);
		graphics.endFill();
	}
	
	public inline function drawDot(w:Int, col:Int, ?a=1.0) {
		drawBox(w,w, col, a);
	}
	
	public inline function reset() {
		gx = gy = dx = dy = dr = 0;
		frictX = frictY = 1;
	}
	
	public static function makeExplosion(n:Int, x,y, powX:Int, ?powY:Int) {
		if(powY==null)
			powY = Math.round(powX*2);
		var list = new List();
		for(i in 0...n) {
			var p = new Particle(x+Std.random(700)/1000*sign(), y+Std.random(700)/1000*sign());
			p.dx = Std.random(powX*1000)/1000 * sign();
			p.dy = -Std.random(powY*1000)/1000;
			if(i<n*0.3)
				p.dy*=1+randFloat(2);
			if(i>=n*0.3 && i<n*0.6)
				p.dx*=1+randFloat(2);
			list.add(p);
		}
		return list;
	}
	
	public static function makeDust(n:Int, x,y) {
		var list = new List();
		for(i in 0...n) {
			var p = new Particle(x+randFloat(7)*sign(), y+randFloat(7)*sign());
			p.dx = randFloat(0.8)*sign();
			p.dy = -randFloat(0.8);
			p.gx = randFloat(0.02)*sign();
			p.gy = randFloat(0.02)*sign();
			list.add(p);
		}
		return list;
	}
	
	public function destroy() {
		alpha = 0;
		life = 0;
		if( parent!=null )
			parent.removeChild(this);
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
	
	public inline function setPos(x,y) {
		rx = this.x = x;
		ry = this.y = y;
	}
	
	public static function clearAll() {
		for(p in ALL)
			p.destroy();
		ALL = new flash.Vector();
	}
	
	public static function update(?tmod=1.0) {
		var i : #if nme Int #else UInt #end = 0;
		var all = ALL;
		var wx = WINDX;
		var wy = WINDY;
		var limit = LIMIT;
		
		var count : #if nme Int #else UInt #end = all.length;
		while(i < count) {
			var p = ALL[i];
			var wind = (p.fl_wind?1:0);
			//p.visible = p.delay<=0;
			p.delay-=tmod;
			if( p.delay>0 )
				i++;
			else {
				if( p.onStart!=null ) {
					var cb = p.onStart;
					p.onStart = null;
					cb();
				}
				
				// gravité
				p.dx+=tmod * (p.gx + wind*wx);
				p.dy+=tmod * (p.gy + wind*wy);
				
				// friction
				p.dx *= Math.pow(p.frictX, tmod);
				p.dy *= Math.pow(p.frictY, tmod);
				
				// mouvement
				p.rx+=tmod * p.dx;
				p.ry+=tmod * p.dy;
				
				if(p.groundY!=null && p.dy>0 && p.ry>=p.groundY) {
					p.dy = -p.dy*p.bounce;
					p.ry = p.groundY-1;
					if( p.onBounce!=null )
						p.onBounce();
				}
				
				if( p.pixel ) {
					p.x = Std.int(p.rx);
					p.y = Std.int(p.ry);
				}
				else {
					p.x = p.rx;
					p.y = p.ry;
				}
				
				p.rotation += p.dr * tmod;
				p.scaleX += (p.ds+p.dsx) * tmod;
				p.scaleY += (p.ds+p.dsy) * tmod;
				
				if( p.rlife>0 && p.da!=0 ) {
					p.alpha += p.da * tmod;
					if( p.alpha>1 ) {
						p.da = 0;
						p.alpha = 1;
					}
				}
				
				p.rlife -= tmod;
				
				if(p.rlife<=0 || !p.ignoreLimit && Std.int(i) < cast(all.length-limit))
					p.alpha -= 0.1 * tmod;
					
				if( p.rlife<=0 && (p.alpha<=0 || p.killOnLifeOut) || p.bounds!=null && !p.bounds.contains(p.rx, p.ry)  ) {
					// Destruction
					if( p.onKill!=null )
						p.onKill();
					if( p.parent!=null )
						p.parent.removeChild(p);
					all.splice(i, 1);
					count--;
				} else {
					if( p.onUpdate!=null )
						p.onUpdate();
					i++;
				}
			}
		}
	}
}
//
//@:build(mt.deepnight.ParticleBuilder.getFields())
//class ParticleSprite extends flash.display.Sprite {
	//public static var ALL : Vector<ParticleSprite> = new Vector();
//}
