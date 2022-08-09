package mt.deepnight;

import flash.Vector;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.MLib;

//class FParticle #if !macro extends #if spriteParticles flash.display.Sprite #else flash.display.Shape #end #end{
class FParticle  extends flash.display.Sprite {
	//public static var ALL : Vector<FParticle> = new Vector();
	public static var DEFAULT_BOUNDS : flash.geom.Rectangle = null;
	public static var DEFAULT_SNAP_PIXELS = true;

	var stamp					: Float;
	var rx				: Float; // real x,y
	var ry				: Float;
	public var dx		: Float;
	public var dy		: Float;
	public var da		: Float; // alpha
	public var ds		: Float; // scale
	public var dsx		: Float; // scaleX
	public var dsy		: Float; // scaleY
	public var scaleMul	: Float;
	public var dr		: Float;
	public var frict(never,set)	: Float;
	public var frictX	: Float;
	public var frictY	: Float;
	public var gx		: Float;
	public var gy		: Float;
	public var bounceMul: Float;
	public var life(default,set)	: Float;
	var rlife			: Float;
	var maxLife			: Float;
	public var bounds	: Null<flash.geom.Rectangle>;
	public var groundY	: Null<Float>;
	public var groupId	: Null<String>;
	public var fadeOutSpeed	: Float;
	public var maxAlpha(default,set): Float;

	public var delay(default, set)	: Float;

	public var onStart	: Null<Void->Void>;
	public var onBounce	: Null<Void->Void>;
	public var onUpdate	: Null<Void->Void>;
	public var onKill	: Null<Void->Void>;

	var bmp				: Null<Bitmap>;
	var disposeBmpOnKill: Bool;

	public var pixel			: Bool;
	public var killOnLifeOut	: Bool;
	public var killed			: Bool;
	public var pooled			: Bool;

	public function new(?x:Float, ?y:Float, ?pt:{x:Float, y:Float}) {
		super();
		if( pt!=null ) {
			x = pt.x;
			y = pt.y;
		}
		reset();
		setPos(x,y);
		disposeBmpOnKill = false;
		killOnLifeOut = false;
		//ALL.push(this);


		#if spriteParticles
		this.mouseChildren = this.mouseEnabled = false;
		#end
	}


	function reset(?x=0., ?y=0.) {
		if( bmp!=null ) {
			if( disposeBmpOnKill )
				bmp.bitmapData.dispose();
			bmp.bitmapData = null;
			bmp = null;
		}

		graphics.clear();
		removeChildren();
		filters = null;
		blendMode = ADD;

		setPos(x,y);
		rotation = 0;
		scaleX = scaleY = 1;
		alpha = 1;
		visible = true;

		stamp = haxe.Timer.stamp();
		killed = false;
		maxAlpha = 1;
		dx = dy = da = dr = ds = dsx = dsy = 0;
		gx = gy = 0;
		frictX = frictY = 1;
		fadeOutSpeed = 0.1;
		bounceMul = 0.85;
		scaleMul = 1;
		delay = 0;
		life = 30;
		pixel = DEFAULT_SNAP_PIXELS;
		bounds = DEFAULT_BOUNDS;
		killOnLifeOut = false;
		groundY = null;
		groupId = null;

		onStart = null;
		onKill = null;
		onBounce = null;
		onUpdate = null;
	}


	public static function initPool(parent:flash.display.Sprite, count:Int) : Array<FParticle> {
		var pool = [];
		for(i in 0...count) {
			var p = new mt.deepnight.FParticle();
			parent.addChild(p);
			p.pooled = true;
			p.kill();
			pool.push(p);
		}
		return pool;
	}

	public static function allocFromPool(pool:Array<FParticle>, ?x:Float, ?y:Float) {
		var oldest : FParticle = null;
		for(p in pool)
			if( p.killed ) {
				p.reset(x,y);
				return p;
			}
			else if( oldest==null || p.stamp<=oldest.stamp )
				oldest = p;

		oldest.reset(x,y);
		return oldest;
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


	inline function set_maxAlpha(v) {
		if( alpha>v )
			alpha = v;
		maxAlpha = v;
		return v;
	}

	//#if !spriteParticles
	//public function addChild(e:Dynamic) {
		//mt.deepnight.Lib.macroError("You must add \"-D spriteParticles\" to your HXML to use addChild on a particle.");
	//}
	//#end

	function set_frict(v) {
		frictX = frictY = v;
		return v;
	}

	function set_delay(d:Float):Float {
		visible = d <= 0;
		return delay = d;
	}


	#if spriteParticles
	public function useBitmapData(bd:BitmapData, disposeOnKill:Bool, ?xr=0.5, ?yr=0.5) {
		if( bmp==null ) {
			bmp = new Bitmap(bd);
			addChild(bmp);
		}
		else
			bmp.bitmapData = bd;

		bmp.x = Std.int(-bmp.width*xr);
		bmp.y = Std.int(-bmp.height*yr);
		this.disposeBmpOnKill = disposeOnKill;
		return bmp;
	}
	#end

	public function clone() : FParticle {
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


	public function fadeIn(alpha:Float, spd:Float) {
		this.alpha = 0;
		maxAlpha = alpha;
		da = spd;
	}


	public inline function drawBox(w:Float,h:Float, col:Int, ?a=1.0, ?fill=true) {
		graphics.clear();
		if( fill )
			graphics.beginFill(col, a);
		else
			graphics.lineStyle(1, col, a);
		graphics.drawRect(-Std.int(w/2),-Std.int(h/2), w,h);
		graphics.endFill();
	}

	public inline function drawCircle(r:Float, col:Int, ?a=1.0, ?fill=true, ?lineThickness=1.0) {
		graphics.clear();
		if( fill )
			graphics.beginFill(col, a);
		else
			graphics.lineStyle(lineThickness, col, a, true, flash.display.LineScaleMode.NONE);
		graphics.drawCircle(0,0,r);
		graphics.endFill();
	}

	public inline function drawDot(w:Int, col:Int, ?a=1.0) {
		drawBox(w,w, col, a);
	}


	public function dispose() {
		reset();

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

	public inline function getMoveAng() {
		return Math.atan2(dy,dx);
	}

	public inline function setPos(x,y) {
		rx = this.x = x;
		ry = this.y = y;
	}


	public function update() {
		delay--;
		if( delay>0 || killed )
			return;
		else {
			if( onStart!=null ) {
				var cb = onStart;
				onStart = null;
				cb();
			}

			// gravité
			dx += gx;
			dy += gy;

			// friction
			dx *= frictX;
			dy *= frictY;

			// mouvement
			x += dx;
			y += dy;

			// Ground
			if( groundY!=null && dy>0 && y>=groundY ) {
				dy = -dy*bounceMul;
				y = groundY-1;
				if( onBounce!=null )
					onBounce();
			}

			rotation += dr;
			scaleX += ds + dsx;
			scaleY += ds + dsy;
			scaleX *= scaleMul;
			scaleY *= scaleMul;

			// Fade in
			if ( rlife > 0 && da != 0 ) {
				alpha += da;
				if( alpha>maxAlpha ) {
					da = 0;
					alpha = maxAlpha;
				}
			}

			rlife--;

			// Fade out (life)
			if( rlife <= 0 )
				alpha -= fadeOutSpeed;

			// Death
			if( rlife<=0 && (alpha<=0 || killOnLifeOut) || bounds!=null && !bounds.contains(x, y)  ) {
				if( onKill!=null ) {
					var cb = onKill;
					onKill = null;
					cb();
				}
				kill();
			}
			else if( onUpdate!=null )
				onUpdate();
		}
	}

	//public static function clearAll() {
		//for(p in ALL)
			//p.destroy();
		//ALL = new flash.Vector();
	//}

	//public static function update() {
		//var i : #if openfl Int #else UInt #end = 0;
//
		//var count : #if openfl Int #else UInt #end = all.length;
		//while(i < count) {
			//var p = ALL[i];
			//p.delay--;
			//if( p.delay>0 )
				//i++;
			//else {
				//if( p.onStart!=null ) {
					//var cb = p.onStart;
					//p.onStart = null;
					//cb();
				//}
//
				//// gravité
				//p.dx+= p.gx;
				//p.dy+= p.gy;
//
				//// friction
				//p.dx *= p.frictX;
				//p.dy *= p.frictY;
//
				//// mouvement
				//p.rx += p.dx;
				//p.ry += p.dy;
//
				//// Ground
				//if( p.groundY!=null && p.dy>0 && p.ry>=p.groundY ) {
					//p.dy = -p.dy*p.bounceMul;
					//p.ry = p.groundY-1;
					//if( p.onBounce!=null )
						//p.onBounce();
				//}
//
				//// Display coords
				//if( p.pixel ) {
					//p.x = Std.int(p.rx);
					//p.y = Std.int(p.ry);
				//}
				//else {
					//p.x = p.rx;
					//p.y = p.ry;
				//}
//
				//p.rotation += p.dr;
				//p.scaleX += p.ds + p.dsx;
				//p.scaleY += p.ds + p.dsy;
//
				//// Fade in
				//if( p.rlife>0 && p.da!=0 ) {
					//p.alpha += p.da;
					//if( p.alpha>p.maxAlpha ) {
						//p.da = 0;
						//p.alpha = p.maxAlpha;
					//}
				//}
//
				//p.rlife--;
//
				//// Fade out (life)
				//if( p.rlife<=0 || !p.ignoreLimit && Std.int(i) < cast(all.length-limit) )
					//p.alpha -= p.fadeOutSpeed;
//
				//// Death
				//if( p.rlife<=0 && (p.alpha<=0 || p.killOnLifeOut) || p.bounds!=null && !p.bounds.contains(p.rx, p.ry)  ) {
					//if( p.onKill!=null )
						//p.onKill();
//
					//if( p.parent!=null )
						//p.parent.removeChild(p);
//
					//if( p.bmp!=null ) {
						//if( p.disposeBmpOnKill )
							//p.bmp.bitmapData.dispose();
						//p.bmp.bitmapData = null;
					//}
//
					//all.splice(i, 1);
					//count--;
				//}
				//else {
					//if( p.onUpdate!=null )
						//p.onUpdate();
					//i++;
				//}
			//}
		//}
	//}
}

