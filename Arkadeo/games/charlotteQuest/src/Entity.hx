import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.flash.Volatile;
import mt.deepnight.Color;

enum KillCond {
	ReachLeft;
	ReachUp;
	ReachDown;
	ReachRight;
	LeaveScreen;
}

class Entity {
	public static var ANIM_CACHE : Hash< Hash<Array<BitmapData>> > = new Hash();

	var game				: Game;
	var fx					: Fx;
	public var uid			: Int;
	var rseed				: mt.Rand;

	public var spr			: Sprite;
	public var rx			: Float;
	public var ry			: Float;
	public var cx			: Int;
	public var cy			: Int;
	public var xr			: Float;
	public var yr			: Float;
	public var dx			: Float;
	public var dy			: Float;
	public var pullDx		: Float;
	public var pullDy		: Float;
	public var pullPower	: Float;
	public var gravity		: Volatile<Float>;
	public var speed		: Volatile<Float>;
	public var frictX		: Float;
	public var frictY		: Float;
	public var radius(default,setRadius): Volatile<Float>;

	public var deleted		: Bool;
	public var scrollBounce	: Bool;
	public var scrollBouncePow: Float;
	public var collides		: Bool;
	public var followScroll	: Bool;
	public var fixed		: Bool;
	public var pullable		: Bool;
	var cooldowns			: Hash<Volatile<Float>>;
	var blinkCpt			: Float;
	public var color		: Int;
	public var autoKill		: Null<KillCond>;
	var onScreen			: Bool;
	var hasBeenOnScreen		: Bool;
	var offScreenTimer		: Int;
	var autoKillOutsider	: Bool;

	public var life(default,setLife): Volatile<Float>;
	var maxLife				: Volatile<Float>;

	var anim				: String;
	var animLoop			: Bool;
	public var animMC		: Null<{ >flash.display.MovieClip, _smc:flash.display.MovieClip }>;
	var animCache			: Hash<Array<BitmapData>>;
	var cachedAnimMC		: Null<Bitmap>;
	var cachedAnimFrame		: Int;
	var animPaused			: Bool;
	var animSkipFrames		: Int;

	var outCursor			: Null<Bitmap>;
	var alertOutside(default,setAlertOutside)	: Bool;

	public function new() {
		uid = Game.uniq++;
		game = Game.ME;
		fx = game.fx;

		rseed = new mt.Rand(0);
		rseed.initSeed( game.seed + uid );

		autoKillOutsider = false;
		alertOutside = false;
		spr = new Sprite();
		animPaused = false;
		onScreen = false;
		hasBeenOnScreen = false;
		offScreenTimer = 0;
		blinkCpt = 0;
		fixed = false;
		pullable = true;
		speed = 0.02;
		frictX = frictY = 1;
		dx = dy = 0;
		pullDx = pullDy = 0;
		pullPower = 0.05;
		cx = cy = 5;
		gravity = 0;
		xr = yr = 0.5;
		radius = 10;
		followScroll = false;
		deleted = false;
		collides = false;
		cooldowns = new Hash();
		scrollBounce = false;
		scrollBouncePow = 0.2;
		initLife(1);
		color = 0xFF80FF;
		setCD("onScreenDelay", 1);
		animLoop = false;
		anim = "";
	}

	public function setRadius(v) {
		radius = v;
		#if dev
		spr.graphics.clear();
		spr.graphics.lineStyle(2, 0xFFFF00, 0.5);
		//spr.graphics.drawCircle(0,0,radius);
		#end
		return v;
	}

	function dropReward(type:Int) : Entity {
		if( game.isProgression() )
			return new it.Coin(this, type);
		else
			return new it.Score(this, type);
	}


	//function smcGotoAndStop(f:Int) {
		//if( mc!=null && mc._smc!=null )
			//mc._smc.gotoAndStop( f<1 ? 1 : f>mc._smc.totalFrames ? mc._smc.totalFrames : f );
	//}

	function cacheAnims(key:String, ?scale=1.0) {
		var generated = false;
		var size = Math.ceil(120*scale);
		if( !ANIM_CACHE.exists(key) ) {
			var cachedAnims = new Hash();
			ANIM_CACHE.set(key, cachedAnims);
			var cache = new flash.display.MovieClip();
			#if dev
			var x = 0;
			var y = 0;
			#end
			for( f in animMC.currentLabels ) {
				cachedAnims.set(f.name, new Array());
				var clist = cachedAnims.get(f.name);
				animMC.gotoAndStop(f.frame);
				var m = new flash.geom.Matrix();
				m.scale(scale, scale);
				m.translate(size*0.5, size*0.5);
				for( af in 0...animMC._smc.totalFrames ) {
					animMC._smc.nextFrame();
					var bd = new BitmapData(size,size, true, 0x0);
					bd.draw( animMC, m );
					clist.push( bd );

					//#if dev
					//var bmp = new Bitmap( bd );
					//bmp.scaleX = bmp.scaleY = 0.5;
					//bmp.x += 30 + x*15;
					//bmp.y += 100 + y*50;
					//game.debug.addChild(bmp);
					//x++;
					//#end
				}
				#if dev
				x = 0;
				y++;
				#end
			}
			generated = true;
		}

		if( animMC.parent!=null )
			animMC.parent.removeChild(animMC);
		animMC = null;

		cachedAnimMC = new Bitmap( new BitmapData(size,size, true, 0x0) );
		cachedAnimMC.smoothing = false;
		cachedAnimMC.x = -cachedAnimMC.width*0.5;
		cachedAnimMC.y = -cachedAnimMC.height*0.5;
		spr.addChild(cachedAnimMC);
		//cachedAnimMC.addChildAt( new Sprite(), 0 );
		animCache = ANIM_CACHE.get(key);
		return generated;
	}

	public function setAnim(?a:String, ?loop=true) {
		if( a==null )
			a = "wait";
		anim = a;
		animLoop = loop;
		if( cachedAnimMC!=null )
			setAnimFrame(0);
		else {
			animMC.gotoAndStop(a);
			animMC._smc.stop();
		}
	}

	function setAnimFrame(f:Int) { // frame commence à 0
		if( cachedAnimMC!=null ) {
			var c = animCache.get(anim);

			if( f>=c.length )
				f = c.length-1;
			cachedAnimFrame = f;
			var bd = c[f];
			cachedAnimMC.bitmapData.lock();
			cachedAnimMC.bitmapData.fillRect( cachedAnimMC.bitmapData.rect, 0x0 );
			cachedAnimMC.bitmapData.copyPixels( bd, bd.rect, new flash.geom.Point(0,0) );
			cachedAnimMC.bitmapData.unlock();
		}
		else
			animMC.gotoAndStop(f+1);
	}

	inline function animDone() {
		return
			if(cachedAnimMC!=null)
				cachedAnimFrame==animCache.get(anim).length-1;
			else
				animMC!=null && animMC._smc.currentFrame==animMC._smc.totalFrames;
	}

	function setAlertOutside(v:Bool) {
		if( game.glevel>=5 )
			v = false;

		alertOutside = v;


		if( outCursor!=null ) {
			outCursor.parent.removeChild(outCursor);
			outCursor.bitmapData.dispose();
			outCursor = null;
		}

		if( v ) {
			var spr = new Sprite();
			spr.graphics.beginFill(0xffffff, 0.8);
			spr.graphics.moveTo(0,0);
			spr.graphics.lineTo(-12,-10);
			spr.graphics.lineTo(-12,10);
			spr.filters = [
				new flash.filters.GlowFilter(0xffffff,0.8, 8,8,2),
			];
			outCursor = mt.deepnight.Lib.flatten(spr, 2);
			game.dm.add(outCursor, Game.DP_INTERF);
			outCursor.x = outCursor.y = 100;
			outCursor.blendMode = flash.display.BlendMode.ADD;
			outCursor.visible = false;
		}

		return alertOutside;
	}

	function onAutoKill() {}

	public inline function getRoom() {
		var pt = getPoint();
		return game.getRoomAt(pt.x,pt.y);
	}

	inline function rnd(min, max, sign=false) {
		return rseed.range(min, max, sign);
	}
	inline function irnd(min,max, ?sign=false) {
		return rseed.irange(min, max, sign);
	}

	public function toString() {
		return "Entity#"+uid;
	}

	public function destroy() {
		if( deleted )
			return;
		game.killList.add(this);
		deleted = true;
		spr.parent.removeChild(spr);
		alertOutside = false; // appelle le setter & remove
	}

	public function unregister() { }
	public function onDie() {}

	public inline function dead() {
		return life<=0 || deleted;
	}

	public function initLife( v:Int ) {
		maxLife = v;
		life = v;
	}

	public function augmentLife(v:Int) {
		if( dead() )
			return;
		maxLife += v;
		life += v;
	}

	public inline function blink() {
		blinkCpt = 1;
	}

	public function setLife(v:Float) {
		if( v<0 )
			v = 0;
		life = v;
		return v;
	}

	public function hit(pow:Float, ?from:Entity) {
		if( dead() )
			return;
		life-=pow;
		blink();
		if( from!=null && pullable ) {
			var a = from.getAngleTo(this);
			var s = pullPower;
			pullDx = Math.cos(a)*s;
			pullDy = Math.sin(a)*s;
		}
		if( dead() )
			kill();
	}

	public function kill() {
		if( deleted )
			return;
		life = 0;
		onDie();
		destroy();
	}

	inline function timeOffset(spd:Float) {
		return uid + game.time * 3.14 * spd;
	}

	public inline function getPoint() {
		return {
			x	: cx*Room.GRID + xr*Room.GRID,
			y	: cy*Room.GRID + yr*Room.GRID
		}
	}

	//public inline function getPointInScroll() {
		//return { x:rx, y:ry }
	//}

	//public inline function getGlobalGridPoint() {
		//return { x:cx*Room.GRID+xr*Room.GRID, y:cy*Room.GRID+yr*Room.GRID }
	//}

	public function setPos(x:Int,y:Int, ?xrr=0.5, ?yrr=0.5) {
		cx = x;
		cy = y;
		xr = xrr;
		yr = yrr;
		updatePos();
	}

	public inline function copyPos(e:Entity) {
		setPos(e.cx, e.cy, e.xr, e.yr);
	}

	public function setPosInScroll(x:Float,y:Float) {
		var cx = Math.floor( x/Room.GRID );
		var cy = Math.floor( y/Room.GRID );
		setPos( cx, cy, x/Room.GRID - cx, y/Room.GRID - cy );
	}

	public function setPosScreen(x:Float,y:Float) {
		var x = (x+game.viewport.x) / Room.GRID;
		var y = (y+game.viewport.y) / Room.GRID;
		setPos( Math.floor(x), Math.floor(y), x-Math.floor(x), y-Math.floor(y) );
	}

	public function checkHit(e:Entity, precise:Bool) {
		if( game.ended || dead() || e.dead() )
			return false;
		var d = radius+e.radius;
		var pt1 = getPoint();
		var pt2 = e.getPoint();
		return
			if( precise )
				mt.deepnight.Lib.distance(pt1.x, pt1.y, pt2.x, pt2.y) <= d;
			else
				mt.deepnight.Lib.distanceSqr(pt1.x, pt1.y, pt2.x, pt2.y) <= d*d;
	}

	inline function waiting() {
		return hasCD("wait");
	}

	public inline function wait(d:Float) {
		setCD("wait", d);
	}

	public inline function getScreenPoint() {
		return {
			x	: rx + game.scroller.x,
			y	: ry + game.scroller.y,
		}
	}

	public inline function clearCD(k:String) {
		cooldowns.remove(k);
		onCD(k);
	}

	public function onCD(k:String) {}

	public inline function setCD(k:String, v:Float) {
		cooldowns.set(k,v);
	}

	public inline function hasCD(k:String) {
		return cooldowns.exists(k) && cooldowns.get(k)>0;
	}

	public inline function getCD(k:String) {
		return cooldowns.exists(k) ? cooldowns.get(k) : 0;
	}

	public inline function getCol(gx:Int,gy:Int) {
		var r = getRoom();
		if( r == null )
			return true;
		else {
			var pt = r.globalToLocal(gx,gy);
			return r.getCol(pt.cx, pt.cy);
		}
	}

	public function getAngleTo(to:Entity) {
		var pt1 = getPoint();
		var pt2 = to.getPoint();
		return Math.atan2(pt2.y-pt1.y, pt2.x-pt1.x);
	}

	public inline function updatePos() {
		rx = cx*Room.GRID + xr*Room.GRID;
		ry = cy*Room.GRID + yr*Room.GRID;
		rx = Std.int( rx*100 ) / 100;
		ry = Std.int( ry*100 ) / 100;
		if( game.rendering ) {
			spr.x = rx;
			spr.y = ry;
		}
	}

	inline function skipThisAnimFrame() {
		return animPaused || deleted || animSkipFrames!=0 && (game.time+uid)%animSkipFrames!=0;
	}

	public function update() {
		var old = {cx:cx, cy:cy, xr:xr, yr:yr}
		var pt = getScreenPoint();

		// Optim
		var m = radius+5;
		onScreen = pt.x>-m && pt.x<Game.WID+m && pt.y>-m && pt.y<Game.HEI+m;
		spr.visible = onScreen;
		if( onScreen ) {
			if( !hasCD("onScreenDelay") && !hasBeenOnScreen ) {
				offScreenTimer = 0;
				hasBeenOnScreen = true;
			}
		}
		else
			offScreenTimer++;

		// Suppression auto
		if( autoKill!=null ) {
			var kill = switch(autoKill) {
				case ReachLeft : pt.x<-m;
				case ReachRight : pt.x>Game.WID+m;
				case ReachUp : pt.y<-m;
				case ReachDown : pt.y>Game.HEI+m;
				case LeaveScreen : !onScreen && hasBeenOnScreen;
			}

			if( kill ) {
				onAutoKill();
				destroy();
				return;
			}
		}

		if( autoKillOutsider && offScreenTimer>=30*10 ) {
			destroy();
			return;
		}

		// Cooldowns
		for(k in cooldowns.keys()) {
			cooldowns.set(k, cooldowns.get(k)-1);
			if( cooldowns.get(k)<=0 ) {
				cooldowns.remove(k);
				onCD(k);
			}
		}


		if( !waiting() && !fixed ) {

			var colRepel = 0.09;
			var wallPen = collides ? 0.45 * (1-radius*2/Room.GRID) : 0;
			if( wallPen<0 )
				wallPen = 0.1;

			// Gestion X
			xr+=dx+pullDx;
			if( followScroll )
				xr+=game.lastScroll.x;
			if( collides ) {
				if( xr<0.5-wallPen && getCol(cx-1,cy) ) {
					dx = pullDx = 0;
					xr += colRepel;
				}
				if( xr>0.5+wallPen && getCol(cx+1,cy) ) {
					dx = pullDx = 0;
					xr -= colRepel;
				}
			}
			while( xr>=1 ) {
				xr--;
				cx++;
			}
			while( xr<0 ) {
				xr++;
				cx--;
			}
			if( hasBeenOnScreen && scrollBounce ) {
				var x = cx*Room.GRID + xr*Room.GRID;
				if( x<game.viewport.x+radius && (!collides || !getCol(cx+1,cy)) )
					dx = scrollBouncePow;
				if( x>game.viewport.x+game.viewport.width-radius && (!collides || !getCol(cx-1,cy)) )
					dx = -scrollBouncePow;
			}

			// Gestion Y
			yr+=dy+pullDy;
			if( followScroll )
				yr+=game.lastScroll.y;
			if( collides ) {
				if( yr<0.5-wallPen && getCol(cx,cy-1) ) {
					dy = pullDy = 0;
					yr += colRepel;
				}
				if( yr>0.5+wallPen && getCol(cx,cy+1) ) {
					dy = pullDy = 0;
					yr -= colRepel;
				}
			}
			while( yr>=1 ) {
				yr--;
				cy++;
			}
			while( yr<0 ) {
				yr++;
				cy--;
			}
			if( hasBeenOnScreen && scrollBounce ) {
				var y = cy*Room.GRID + yr*Room.GRID;
				if( y<game.viewport.y+radius && (!collides || !getCol(cx,cy+1)) )
					dy = scrollBouncePow;
				if( y>game.viewport.y+game.viewport.height-radius && (!collides || !getCol(cx,cy-1)) )
					dy = -scrollBouncePow;
			}

			// Recal bug
			if( collides && getCol(cx,cy) )
				setPos(old.cx, old.cy, old.xr, old.yr);

			// Gravité
			dy+=gravity;

			// Friction
			dx = Math.round( dx*frictX*100000 )/100000;
			dy = Math.round( dy*frictY*100000 )/100000;
			if( dx>0 && dx<=0.0001 || dx<0 && dx>=-0.0001 ) dx = 0;
			if( dy>0 && dy<=0.0001 || dy<0 && dy>=-0.0001 ) dy = 0;
			//dy*=frictY;
			pullDx*=0.9;
			pullDy*=0.9;
		}

		// Clignotement
		if( blinkCpt>0 ) {
			var r = (blinkCpt-0.5)/0.5;
			if( r<0 )
				r = 0;
			spr.transform.colorTransform = Color.getColorizeCT( Color.interpolateInt(0xffffff,0xFF55FF,r), 0.7 );
			blinkCpt-=0.25;
			if( blinkCpt<=0 )
				spr.transform.colorTransform = new flash.geom.ColorTransform();
		}

		updatePos();

		// Pointeur "hors écran"
		if( alertOutside ) {
			var margin = 20;
			var pt = getScreenPoint();
			var m = new flash.geom.Matrix();
			var x = if( pt.x < margin ) margin else if( pt.x>=Game.WID-margin ) Game.WID-margin else pt.x;
			var y = if( pt.y < margin ) margin else if( pt.y>=Game.HEI-margin ) Game.HEI-margin else pt.y;
			m.translate(-outCursor.width*0.5, -outCursor.height*0.5);
			var ppt = game.player.getScreenPoint();
			var a =
				if( pt.x<margin ) 3.14
				else if( pt.x>=Game.WID-margin ) 0
				else if( pt.y<=margin ) -1.57
				else 1.57;
			m.rotate(a);
			//m.rotate( Math.atan2(y-ppt.y, x-ppt.x) );
			m.translate(x,y);
			outCursor.transform.matrix = m;
			outCursor.visible = true;

			if( onScreen )
				alertOutside = false;
		}

		// Animations
		animSkipFrames = game.perf<0.8 ? 4 : 1;
		if( !skipThisAnimFrame() )
			if ( anim!="" && (cachedAnimMC!=null || animMC!=null) ) {
				if( cachedAnimMC!=null )
					setAnimFrame(cachedAnimFrame+1);
				else
					animMC._smc.nextFrame();
				if( animLoop && animDone() )
					setAnimFrame(0);
			}
	}
}