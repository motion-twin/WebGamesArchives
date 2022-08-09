package mt.heaps;

#if !heaps
#error "heaps is required for HParticle"
#end

import mt.MLib;
import h2d.Tile;
import h2d.SpriteBatch;
import mt.deepnight.Lib;


class ParticlePool {
	var all : haxe.ds.Vector<HParticle>;
	var nalloc : Int;
	public var size(get,never) : Int; inline function get_size() return all.length;

	public function new(tile:h2d.Tile, count:Int, fps:Int) {
		all = new haxe.ds.Vector(count);
		nalloc = 0;

		for(i in 0...count) {
			var p = @:privateAccess new HParticle(this, tile, fps);
			all[i] = p;
			p.kill();
		}
	}

	public inline function alloc(sb:SpriteBatch, t:h2d.Tile, ?x:Float, ?y:Float) : HParticle {
		return if( nalloc<all.length ) {
			// Use a killed part
			var p = all[nalloc];
			@:privateAccess p.reset(sb, t, x,y);
			@:privateAccess p.poolIdx = nalloc;
			nalloc++;
			p;
		}
		else {
			// Find oldest active part
			var best : HParticle = null;
			for(p in all)
				if( best==null || @:privateAccess p.stamp<=@:privateAccess best.stamp )
					best = p;

			if( best.onKill!=null )
				best.onKill();
			@:privateAccess best.reset(sb, t, x, y);
			best;
		}
	}

	function free(kp:HParticle) {
		if( nalloc>1 ) {
			var idx = @:privateAccess kp.poolIdx;
			var tmp = all[idx];
			all[idx] = all[nalloc-1];
			@:privateAccess all[idx].poolIdx = idx;
			all[nalloc-1] = tmp;
			nalloc--;
		}
		else {
			nalloc = 0;
		}
	}

	public inline function getAllocateds() return nalloc;

	public inline function killAll() {
		for( i in 0...nalloc) {
			var p = all[i];
			if( p.onKill!=null )
				p.onKill();
			@:privateAccess p.reset(null);
			p.visible = false;
		}
		nalloc = 0;
	}

	public function dispose() {
		for(p in all)
			@:privateAccess p.dispose();
		all = null;
	}

	public inline function update(dt:Float, ?updateCb:HParticle->Void) {
		for( i in 0...nalloc ) {
			@:privateAccess all[i].updatePart(dt);
			if( updateCb!=null )
				updateCb( @:privateAccess all[i] );
		}
	}
}


class Emitter {
	public static var ALL : Array<Emitter> = [];

	public var id : Null<String>;
	public var x : Float;
	public var y : Float;
	public var wid : Float;
	public var hei : Float;
	public var cd : mt.Cooldown;
	public var delayer : mt.Delayer;
	public var active(default,set) : Bool;
	public var dt : Float;
	public var destroyed(default,null) : Bool;
	public var tickS : Float;
	var permanent = true;

	public function new(?id:String, fps:Int) {
		ALL.push(this);

		tickS = 0;
		this.id = id;
		destroyed = false;
		x = y = 0;
		wid = hei = 0;
		active = true;

		delayer = new mt.Delayer(fps);
		cd = new mt.Cooldown(fps);
	}

	public inline function setPos(x,y, ?w, ?h) {
		this.x = x;
		this.y = y;
		if( w!=null ) wid = w;
		if( h!=null ) hei = h;
	}

	public inline function setSize(w, h) {
		wid = w;
		hei = h;
	}

	public inline function setDurationS(t:Float) {
		cd.setS("emitterLife", t);
		permanent = false;
	}

	public dynamic function onActivate() {}
	public dynamic function onDeactivate() {}
	public dynamic function onUpdate() {}
	public dynamic function onDispose() {}

	inline function set_active(v:Bool) {
		if( v==active || destroyed )
			return active;

		active = v;
		if( active )
			onActivate();
		else
			onDeactivate();
		return active;
	}

	public function dispose() {
		if( destroyed )
			return;

		destroyed = true;
		cd.destroy();
		delayer.destroy();
		onDispose();
	}

	public inline function update(dt:Float) {
		if( !active || destroyed )
			return;

		this.dt = dt;
		cd.update(dt);
		delayer.update(dt);

		if( tickS<=0 || !cd.hasSetS("emitterTick", tickS) )
			onUpdate();

		if( !permanent && !cd.has("emitterLife") )
			dispose();
	}
}




class HParticle extends BatchElement {
	public static var DEFAULT_BOUNDS : h2d.col.Bounds = null;

	var pool					: ParticlePool;
	public var poolIdx(default,null)	: Int;
	var stamp					: Float;
	public var dx				: Float;
	public var dy				: Float;
	public var da				: Float; // alpha
	public var ds				: Float; // scale
	public var dsFrict			: Float;
	public var scaleMul			: Float;
	public var scaleXMul		: Float;
	public var scaleYMul		: Float;
	public var dr				: Float;
	public var frict(never,set)	: Float;
	public var frictX			: Float;
	public var frictY			: Float;
	public var gx				: Float;
	public var gy				: Float;
	public var bounceMul		: Float;
	public var bounds			: Null<h2d.col.Bounds>;
	public var groundY			: Null<Float>;
	public var groupId			: Null<String>;
	public var fadeOutSpeed		: Float;
	public var maxAlpha(default,set): Float;
	public var alphaFlicker		: Float;

	public var lifeS(never,set)	: Float;
	public var lifeF(never,set)	: Float;
	var rLifeF					: Float;
	var maxLifeF				: Float;
	public var remainingLifeS(get,never)	: Float;
	public var curLifeRatio(get,never)		: Float; // 0(start) -> 1(end)

	public var delayS(get, set)		: Float;
	public var delayF(default, set)	: Float;

	public var onStart			: Null<Void->Void>;
	public var onBounce			: Null<Void->Void>;
	public var onUpdate			: Null<HParticle->Void>;
	public var onKill			: Null<Void->Void>;

	public var pixel			: Bool;
	public var killOnLifeOut	: Bool;
	public var killed			: Bool;

	public var data     : haxe.ds.Vector<Null<Float>>; // free data, helpers only available
	public var userData : Dynamic;
	//public var data0(get,set) : Null<Float>;
	//public var data1(get,never) : Null<Float>;
	//public var data2(get,never) : Null<Float>;
	//public var data3(get,never) : Null<Float>;

	var fps : Int;

	private function new(p:ParticlePool, tile:Tile, fps:Int, ?x:Float, ?y:Float) {
		super(tile);
		this.fps = fps;
		pool = p;
		poolIdx = -1;
		data = new haxe.ds.Vector(4);
		reset(null, x,y);
	}


	var animLib : Null<mt.heaps.slib.SpriteLib>;
	var animId : Null<String>;
	var animCursor : Float;
	var animXr : Float;
	var animYr : Float;
	var animLoop : Bool;
	public var animSpd : Float;
	public function playAnimAndKill(lib:mt.heaps.slib.SpriteLib, k:String, ?spd=1.0) {
		animLib = lib;
		animId = k;
		animCursor = 0;
		animLoop = false;
		animSpd = spd;
		applyAnimFrame();
	}
	public function playAnimLoop(lib:mt.heaps.slib.SpriteLib, k:String, ?spd=1.0) {
		animLib = lib;
		animId = k;
		animCursor = 0;
		animLoop = true;
		animSpd = spd;
		applyAnimFrame();
	}


	public inline function setScale(v:Float) scale = v;
	public inline function setPos(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}


	//inline function get_data0() return getData(0);
	//inline function set_data0(v) return setData(0, v);
	//inline function get_data1() return getData(1);
	//inline function set_data1(v) return setData(1, v);
	//inline function get_data2() return getData(2);
	//inline function set_data2(v) return setData(2, v);
	//inline function get_data3() return getData(3);
	//inline function set_data3(v) return setData(3, v);

	//public inline function setData(id:Int, v:Null<Float>) {
		//if( idValid(id) )
			//data.set(id, v);
	//}

	//public inline function incData(id:Int, v:Null<Float>) : Null<Float> {
		//if( idValid(id) )
			//data.set(id, getData(id,0) + v);
		//return getData(id);
	//}

	//public inline function mulData(id:Int, v:Null<Float>) : Null<Float> {
		//if( idValid(id) )
			//data.set(id, getData(id,0) * v);
		//return getData(id);
	//}

	//public inline function getData(id:Int, ?defValue:Null<Float>=null) : Null<Float> {
		//return idValid(id) ? data.get(id) :  defValue;
	//}

	//inline function idValid(id:Int) return id>=0 && id<data.length;

	function reset(sb:Null<SpriteBatch>, ?tile:Tile, ?x:Float, ?y:Float) {
		if( tile!=null )
			this.t = tile;

		if( x!=null && y!=null )
			setPos(x,y);

		if( batch!=sb ) {
			if( batch!=null )
				remove();
			if( sb!=null )
				sb.add(this);
		}

		for( i in 0...data.length )
			data.set(i,null);
		animId = null;
		animLib = null;
		uncolorize();
		visible = true;
		rotation = 0;
		scale = 1;
		alpha = 1;
		scaleMul = 1;
		scaleXMul = scaleYMul = 1;
		dsFrict = 1;
		alphaFlicker = 0;

		stamp = haxe.Timer.stamp();
		setCenterRatio(0.5, 0.5);
		killed = false;
		maxAlpha = 1;
		dx = dy = da = dr = ds = 0;
		gx = gy = 0;
		frictX = frictY = 1;
		fadeOutSpeed = 0.1;
		bounceMul = 0.85;
		delayS = 0;
		lifeS = 1;
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


	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);

	inline function set_maxAlpha(v) {
		if( alpha>v )
			alpha = v;
		maxAlpha = v;
		return v;
	}

	public inline function setCenterRatio(xr:Float, yr:Float) {
		t.setCenterRatio(xr,yr);
		animXr = xr;
		animYr = yr;
	}
	inline function set_frict(v) return frictX = frictY = v;


	public inline function uncolorize() r = g = b = 1;

	public inline function colorize(c:UInt, ?ratio=1.0) {
		var c = mt.deepnight.Color.intToRgb( mt.deepnight.Color.interpolateInt(0xFFFFFF, c, ratio) );
		r = c.r/255;
		g = c.g/255;
		b = c.b/255;
	}

	public function fade(targetAlpha:Float, fadeInSpd=1.0, fadeOutSpd=1.0) {
		this.alpha = 0;
		maxAlpha = targetAlpha;
		da = targetAlpha*0.1*fadeInSpd;
		fadeOutSpeed = targetAlpha*0.1*fadeOutSpd;
	}

	public function setFadeS(targetAlpha:Float, fadeInDurationS:Float, fadeOutDurationS:Float) {
		this.alpha = 0;
		maxAlpha = targetAlpha;
		if( fadeInDurationS<=0 )
			alpha = maxAlpha;
		else
			da = targetAlpha / (fadeInDurationS*fps);
		if( fadeOutDurationS<=0 )
			fadeOutSpeed = 99;
		else
			fadeOutSpeed = targetAlpha / (fadeOutDurationS*fps);
	}

	public function fadeIn(alpha:Float, spd:Float) {
		this.alpha = 0;
		maxAlpha = alpha;
		da = spd;
	}

	function toString() {
		return 'HPart@$x,$y (lifeS=$remainingLifeS)';
	}

	public function clone() : HParticle {
		var s = new haxe.Serializer();
		s.useCache = true;
		s.serialize(this);
		return haxe.Unserializer.run( s.toString() );
	}

	inline function set_delayS(d:Float):Float {
		delayF = d*fps;
		return d;
	}
	inline function get_delayS() return delayF/fps;

	inline function set_delayF(d:Float):Float {
		d = MLib.fmax(0,d);
		visible = d <= 0;
		return delayF = d;
	}

	function set_lifeS(v:Float) {
		rLifeF = maxLifeF = MLib.fmax(fps*v,0);
		return v;
	}

	function set_lifeF(v:Float) {
		rLifeF = maxLifeF = MLib.fmax(v,0);
		return v;
	}


	public inline function mulLife(f:Float) {
		rLifeF*=f;
	}

	inline function get_remainingLifeS() return rLifeF/fps;
	inline function get_curLifeRatio() return 1-rLifeF/maxLifeF; // 0(start) -> 1(end)

	public function kill() {
		if( onKill!=null ) {
			var cb = onKill;
			onKill = null;
			cb();
		}

		alpha = 0;
		lifeS = 0;
		delayS = 0;
		killed = true;
		visible = false;

		@:privateAccess pool.free(this);
	}

	function dispose() {
		remove();
		bounds = null;
	}

	public inline function isAlive() {
		return rLifeF>0;
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


	inline function applyAnimFrame() {
		var f = animLib.getAnim(animId)[Std.int(animCursor)];
		var fd = animLib.getFrameData(animId, f).realFrame;
		var tile = animLib.getTile( animId, f );
		t.setPos(tile.x, tile.y);
		t.setSize(tile.width, tile.height);
		t.dx = -Std.int(fd.realWid * animXr + fd.x);
		t.dy = -Std.int(fd.realHei * animYr + fd.y);
	}

	public inline function optimPow(v:Float, p:Float) {
		return (p==1||v==0||v==1) ? v : Math.pow(v,p);
	}

	inline function updatePart(dt:Float) {
		delayF -= dt;
		if( delayF<=0 && !killed ) {
			if( onStart!=null ) {
				var cb = onStart;
				onStart = null;
				cb();
			}

			// Anim
			if( animId!=null ) {
				applyAnimFrame();
				animCursor+=animSpd*dt;
				if( animCursor>=animLib.getAnim(animId).length ) {
					if( animLoop )
						animCursor-=animLib.getAnim(animId).length;
					else {
						animId = null;
						animLib = null;
						animCursor = 0;
						kill();
					}
				}
			}

			if( !killed ) {
				// gravité
				dx += gx * dt;
				dy += gy * dt;

				// mouvement
				x += dx * dt;
				y += dy * dt;

				// friction
				if( frictX==frictY ){
					var frictDT = optimPow(frictX, dt);
					dx *= frictDT;
					dy *= frictDT;
				}else{
					dx *= optimPow(frictX, dt);
					dy *= optimPow(frictY, dt);
				}

				// Ground
				if( groundY!=null && dy>0 && y>=groundY ) {
					dy = -dy*bounceMul;
					y = groundY-1;
					if( onBounce!=null )
						onBounce();
				}

				rotation += dr * dt;
				scaleX += ds * dt;
				scaleY += ds * dt;
				var scaleMulDT = optimPow(scaleMul, dt);
				scaleX *= scaleMulDT;
				scaleX *= optimPow(scaleXMul, dt);
				scaleY *= scaleMulDT;
				scaleY *= optimPow(scaleYMul, dt);
				ds     *= optimPow(dsFrict, dt);

				// Fade in
				if ( rLifeF > 0 && da != 0 ) {
					alpha += da * dt;
					if( alpha>maxAlpha ) {
						da = 0;
						alpha = maxAlpha;
					}
				}

				rLifeF -= dt;

				// Fade out (life)
				if( rLifeF <= 0 )
					alpha -= fadeOutSpeed * dt;
				else if( alphaFlicker>0 )
					alpha = MLib.fclamp( alpha + rnd(0, alphaFlicker, true), 0, maxAlpha );

				// Death
				if( rLifeF <= 0 && (alpha <= 0 || killOnLifeOut) ||
				  bounds != null && !(x >= bounds.xMin && x < bounds.xMax && y >= bounds.yMin && y < bounds.yMax) )
					kill();
				else if( onUpdate!=null )
					onUpdate(this);
			}
		}
	}
}

