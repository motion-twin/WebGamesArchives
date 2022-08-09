import flash.display.Sprite;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Color;

class Entity {
	public static var ALL : Array<Entity> = new Array();
	public static var TOKILL : Array<Entity> = new Array();

	var mode				: Mode;
	var uid					: Int;
	var fx					: Fx;

	public var sprite		: BSprite;
	public var cd			: mt.Cooldown;
	public var rseed		: mt.Rand;

	public var cx			: Int;
	public var cy			: Int;
	public var xr			: Float;
	public var yr			: Float;
	public var dx			: Float;
	public var dy			: Float;
	public var xx			: Float;
	public var yy			: Float;
	public var frictX		: Float;
	public var frictY		: Float;
	public var radius		: Float;
	public var speed		: Float;
	public var dir			: Int;
	public var life			: Int;
	public var maxLife		: Int;
	public var weight		: Float;
	var gravity				: Float;

	public var fallUntil	: Int;
	public var killed		: Bool;
	public var stable		: Bool;
	public var repelOnHit	: Bool;
	public var climbing		: Bool;
	var collides			: Bool;
	var killOnBottom		: Bool;

	var bar					: flash.display.Bitmap;
	var barY				: Int;


	public function new() {
		mode = Mode.ME;
		climbing = false;
		fx = mode.fx;
		uid = Const.UID++;
		ALL.push(this);
		cd = new mt.Cooldown();

		rseed = new mt.Rand(0);
		rseed.initSeed(mode.seed + uid);

		stable = false;
		killed = false;
		collides = true;
		killOnBottom = true;
		repelOnHit = true;
		weight = 1;
		frictX = frictY = 0.85;
		barY = -45;
		dir = 1;
		cx = 5;
		cy = -1;
		xr = yr = 0.5;
		xx = yy = 0;
		dx = dy = 0;
		radius = Const.GRID*0.4;
		speed = 0.04;
		gravity = Const.GRAVITY;

		stopFall();

		sprite = new BSprite(mode.tiles);
		sprite.setCenter(0.5, 1);
		mode.dm.add(sprite, Const.DP_ENTITY);

		bar = new flash.display.Bitmap( new flash.display.BitmapData(20, 4, true, 0x0) );
		mode.dm.add(bar, Const.DP_ENTITY);
		bar.filters = [ new flash.filters.GlowFilter(0x000000,0.8, 2,2, 4) ];
		initLife(1);
	}

	public inline function isDead() {
		return life<=0;
	}

	public function getCenter() {
		return {x:xx, y:yy-radius};
	}

	public inline function atDistance(e:Entity, dist:Float) {
		var d = mt.deepnight.Lib.distanceSqr(xx,yy, e.xx,e.yy);
		if( d<=dist*dist )
			return Math.sqrt(d)<=dist;
		else
			return false;
	}

	public function getFloor() {
		return Level.getFloor(cy);
	}

	function updateLife() {
		if( life>maxLife )
			life = maxLife;
		if( life<0 )
			life = 0;
		var bd = bar.bitmapData;
		bd.fillRect( bd.rect, Color.addAlphaF(0x950000, 0.6) );
		bd.fillRect( new flash.geom.Rectangle(0, 0, bd.width*life/maxLife, bd.height), Color.addAlphaF(0xFFCC00) );
		bar.visible = life<maxLife;
	}

	public function initLife(l:Int) {
		life = maxLife = l;
		updateLife();
	}

	public inline function rnd(min,max,?sign) {
		return rseed.range(min,max,sign);
	}
	public inline function irnd(min,max,?sign) {
		return rseed.irange(min,max,sign);
	}

	public function destroy() {
		if( !killed )
			TOKILL.push(this);
		killed = true;
	}

	public function unregister() {
		ALL.remove(this);
		sprite.parent.removeChild(sprite);
		bar.parent.removeChild(bar);
		bar.bitmapData.dispose();
	}


	public function stopFall() {
		fallUntil = 999;
	}

	public function ignoreFloors(n:Int) {
		fallUntil = getFloor()-n;
		if( fallUntil<=0 )
			fallUntil = 0;
	}


	function onLand() {
		stopFall();
		stable = true;
	}


	function onDie() {
		updateLife();
	}

	public function hit(ox:Float,oy:Float, dmg:Int) {
		loseLife(dmg);

		if( repelOnHit ) {
			var a = Math.atan2(yy-oy, xx-ox);
			dx += Math.cos(a) * rnd(0.2, 0.35);
			dy = -0.15;
			stable = false;
		}

		climbing = false;
 		cd.set("stun", rnd(20,30));
		updateLife();
	}


	public function loseLife(dmg) {
		life-=dmg;
		if( life<=0 ) {
			life = 0;
			onDie();
		}
	}


	public function hasCollision(cx,cy) {
		return collides && mode.level.hasCollision(cx,cy);
	}

	public function setPos(x,y) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
		updateScreenCoords();
	}

	public function setPosPixel(x,y) {
		xx = x;
		yy = y;
		cx = Std.int(xx/Const.GRID);
		cy = Std.int(yy/Const.GRID);
		xr = (xx-cx*Const.GRID) / Const.GRID;
		yr = (yy-cy*Const.GRID) / Const.GRID;
	}

	public function onReachBottom() {
	}

	public function updateScreenCoords() {
		xx = (cx+xr)*Const.GRID;
		yy = (cy+yr)*Const.GRID;
	}


	public function preX() {
	}


	public function update() {
		cd.update();

		// Gravité
		if( !climbing ) {
			if( (yr<1 || !hasCollision(cx,cy+1)) )
				stable = false;
			if( !stable )
				dy += gravity;
		}

		// Recal échelle
		if( climbing )
			dx += (0.5-xr)*0.05;

		if( getFloor()==0 )
			fallUntil = 999;

		// X component
		xr+=dx;
		dx*=frictX;
		if( Math.abs(dx)<=0.001 )
			dx = 0;
		if( cx==0 && xr<=0.3 ) {
			dx = 0;
			xr = 0.3;
		}
		if( cx==Const.LWID-1 && xr>=0.7 ) {
			dx = 0;
			xr = 0.7;
		}
		preX();
		while( xr<0 ) {
			cx--;
			xr++;
		}
		while( xr>1 ) {
			cx++;
			xr--;
		}

		// Y component
		yr+=dy;
		dy*=frictY;
		var f = getFloor();
		if( hasCollision(cx,cy+1) && yr>=1 && f<=fallUntil && (f==0 || !cd.has("ignoreGround")) ) {
			yr = 1;
			if( !stable )
				onLand();
			dy = 0;
		}

		while( yr<0 ) {
			cy--;
			yr++;
		}
		while( yr>1 ) {
			cy++;
			yr--;
		}

		// Hors écran (haut)
		if( cy<0 && dy<0 )
			dy*=0.6;

		// Hors écran (bas)
		if( cy>=Const.LHEI+4 && killOnBottom )
			onReachBottom();

		updateScreenCoords();
		sprite.x = Std.int(xx);
		sprite.y = Std.int(yy);
		bar.visible = life<maxLife;
		bar.x = Std.int(sprite.x - bar.width*0.5);
		bar.y = Std.int(sprite.y + barY);
		if( dir==1 && sprite.scaleX<0 || dir==-1 && sprite.scaleX>0 )
			sprite.scaleX *= -1;
	}

}
