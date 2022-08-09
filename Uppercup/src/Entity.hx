import flash.display.Sprite;
import flash.display.Bitmap;
import mt.deepnight.slb.BSprite;

class Entity {
	public static var ALL : Array<Entity> = [];
	public static var KILL_LIST : Array<Entity> = [];

	var uid				: Int;

	var game			: m.Game;
	var fx				: Fx;
	var seed			: Int;
	var rseed			: mt.Rand;
	public var spr		: BSprite;
	public var shadow	: Null<Bitmap>;
	var fl_destroyed	: Bool;
	var fl_collide		: Bool;

	public var cx		: Int;
	public var cy		: Int;
	public var xr		: Float;
	public var yr		: Float;
	public var xx		: Float;
	public var yy		: Float;
	public var z		: Float;
	public var dx		: Float;
	public var dy		: Float;
	public var dz		: Float;
	public var frict	: Float;
	public var cd		: mt.Cooldown;
	public var colBounce: Float;
	public var zbounce(default,set)	: Float;
	public var zpriority: Int;
	var canWarp			: Bool;
	//public var curSpeed	: Float;
	//public var maxSpeed	: Float;

	public function new() {
		ALL.push(this);
		canWarp = false;
		game = m.Game.ME;
		uid = game.getUniqId();
		rseed = new mt.Rand(0);
		seed = game.seed + uid;
		initSeed();
		fl_destroyed = false;
		fx = game.fx;
		cx = cy = 10;
		xr = yr = 0.5;
		xx = yy = 50;
		z = 0;
		colBounce = 1;
		zbounce = 0.3;
		frict = 0.99;
		dx = dy = dz = 0;
		cd = new mt.Cooldown();
		zpriority = 0;
		fl_collide = true;

		spr = new BSprite(game.tiles);
		spr.setCenter(0.5, 1);
		game.zsortLayer.addChild(spr);
		game.zsortables.push(this);

		setShadow(14,6);
	}

	inline function set_zbounce(v:Float) {
		zbounce = mt.MLib.fmin(2.2, v);
		return zbounce;
	}

	public function toString() {
		return "Entity"+[uid,cx,cy];
	}

	function initSeed(?inc=0) {
		rseed.initSeed(seed+inc*159);
	}

	function removeShadow() {
		if( shadow!=null ) {
			shadow.parent.removeChild(shadow);
			shadow.bitmapData.dispose();
			shadow.bitmapData = null;
			shadow = null;
		}
	}

	function setShadow(w,h) {
		if( shadow!=null )
			removeShadow();

		var s = new Sprite();
		s.graphics.clear();
		s.graphics.beginFill(0x0, 0.5);
		s.graphics.drawEllipse(0,0, w,h);

		shadow = mt.deepnight.Lib.flatten(s);
		game.sdm.add(shadow, Const.DP_BG2);
	}

	public function updateFromScreenCoords() {
		cx = Std.int(xx/Const.GRID);
		cy = Std.int(yy/Const.GRID);
		xr = (xx - cx*Const.GRID) / Const.GRID;
		yr = (yy - cy*Const.GRID) / Const.GRID;
	}

	public function setPos(cx,cy) {
		this.cx = cx;
		this.cy = cy;
		xr = yr = 0.5;
		xx = (cx+xr)*Const.GRID;
		yy = (cy+yr)*Const.GRID;
	}

	public function setPosFree(x,y) {
		xx = x;
		yy = y;
		updateFromScreenCoords();
	}

	public inline function getPositionRatio() {
		return {
			x : (cx-Const.FPADDING)/Const.FWID,
			y : (cy-Const.FPADDING)/Const.FHEI,
		}
	}


	public function unregister() {
		removeShadow();
		spr.dispose();
		cd.destroy();

		ALL.remove(this);
		KILL_LIST.remove(this);
		game.zsortables.remove(this);

		fx = null;
		game = null;
	}


	public static function garbageCollect() {
		while( KILL_LIST.length>0 )
			KILL_LIST[0].unregister();
	}

	public function destroy() {
		if( !fl_destroyed ) {
			KILL_LIST.push(this);
			fl_destroyed = true;
		}
	}


	inline function moving() {
		return dx!=0 || dy!=0;
	}

	inline function irnd(min, max, ?sign) { return rseed.irange(min, max, sign); }
	inline function rnd(min, max, ?sign) { return rseed.range(min, max, sign); }

	inline function getActualSpeed(?zWeight=0.0) {
		return Math.sqrt(dx*dx + dy*dy + dz*zWeight*dz*zWeight);
	}

	inline function collides(x,y) {
		return game.stadium.getCollisionHeight(x,y)>z;
	}

	function onWallBounce() {}

	function onGroundBounce() {}

	public inline function distance(e:Entity) {
		return mt.deepnight.Lib.distance(xx,yy, e.xx,e.yy);
	}
	public inline function distanceSqr(e:Entity) {
		return mt.deepnight.Lib.distanceSqr(xx,yy, e.xx,e.yy);
	}

	public function explode(radius:Int) {
		if( fl_destroyed )
			return;

		var b = game.ball;
		fx.flashBang(0xFFFF00, 0.3, 600);
		fx.explosion(xx,yy, radius);
		m.Global.SBANK.mine_explose(1);
		for(p in en.Player.ALL)
			if( distance(p)<=radius+5 )
				p.knock(xx,yy, 2.5);

		if( distance(b)<=radius+5 ) {
			var a = Math.atan2(b.yy-yy, b.xx-xx);
			var s = rnd(0.6, 0.8);
			b.dx = Math.cos(a)*s;
			b.dy = Math.sin(a)*s;
			b.dz = rnd(4, 7);
			b.makeUncatchableBoth(10);
		}

		destroy();
	}

	inline function onScreen() {
		return
			xx>=game.viewport.x-16 && xx<=game.viewport.x+game.viewport.wid+16 &&
			yy>=game.viewport.y-4 && yy<=game.viewport.y+game.viewport.hei+40;
	}

	public function update() {
		cd.update();

		var maxStepLen = 0.2;

		if( dx!=0 || dy!=0 ) {
			//if( x<Game.FIELD.left && dx<0 ) {
				//x = Game.FIELD.left;
				//dx = -dx;
			//}
			//if( x>=Game.FIELD.right && dx>0 ) {
				//x = Game.FIELD.right;
				//dx = -dx;
			//}

			// Gestion X
			if( dx!=0 ) {
				var steps = Math.ceil( Math.abs(dx)>maxStepLen ? Math.abs(dx/maxStepLen) : Math.abs(dx) );
				var d = dx/steps;
				for(s in 0...steps) {
					if( fl_collide ) {
						// Collides right
						if( xr>=0.7 && d>0 && collides(cx+1,cy) ) {
							xr = 0.7;
							dy*=0.8;
							onWallBounce();
							if( colBounce==0 ) {
								d = dx = 0;
							}
							else {
								d*=-colBounce;
								dx*=-colBounce;
							}
							break;
						}

						// Collides left
						if( xr<=0.3 && d<0 && collides(cx-1,cy) ) {
							xr = 0.3;
							dy*=0.8;
							onWallBounce();
							if( colBounce==0 )
								d = dx = 0;
							else {
								d*=-colBounce;
								dx*=-colBounce;
							}
							break;
						}
					}
					xr+=d;
					while( xr<0 ) { xr++; cx--; }
					while( xr>=1 ) { xr--; cx++; }
				}
				dx*=frict;
				if( Math.abs(dx)<=0.01 )
					dx = 0;
			}

			// Gestion Y
			if( dy!=0 ) {
				var steps = Math.ceil( Math.abs(dy)>maxStepLen ? Math.abs(dy/maxStepLen) : Math.abs(dy) );
				var d = dy/steps;
				for(s in 0...steps) {
					if( fl_collide ) {
						// Collides below
						if( yr>=0.7 && d>0 && collides(cx,cy+1) ) {
							if( canWarp && cy==Const.FHEI+Const.FPADDING-1 && game.stadium.hasSideWarp ) {
								setPosFree(xx, Const.FPADDING*Const.GRID);
								m.Global.SBANK.teleport_out(1);
							}
							else {
								yr = 0.7;
								dx*=0.8;
								onWallBounce();
								if( colBounce==0 )
									d = dy = 0;
								else {
									d*=-colBounce;
									dy*=-colBounce;
								}
							}
							break;
						}

						// Collides above
						if( yr<=0.3 && d<0 && collides(cx,cy-1) ) {
							if( canWarp && cy==Const.FPADDING && game.stadium.hasSideWarp ) {
								setPosFree(xx, (Const.FPADDING+Const.FHEI-1)*Const.GRID);
								m.Global.SBANK.teleport_out(1);
							}
							else {
								yr = 0.3;
								dx*=0.8;
								onWallBounce();
								if( colBounce==0 )
									d = dy = 0;
								else {
									d*=-colBounce;
									dy*=-colBounce;
								}
							}
							break;
						}
					}
					yr+=d;
					while( yr<0 ) { yr++; cy--; }
					while( yr>=1 ) { yr--; cy++; }
				}
				dy*=frict;
				if( Math.abs(dy)<=0.01 )
					dy = 0;
			}

		}

		if( dz!=0 || z!=0 ) {
			z+=dz;
			dz-=0.31;
			dz*=0.94;
			if( z<=0 && dz<=0 ) {
				z = 0;
				dz = -dz*zbounce;
				if( Math.abs(dz)<=1.3 )
					dz = 0;
				onGroundBounce();
			}
			//if (dz>=-0.01 && dz<0)
				//dz = 0;
		}

		xx = cx*Const.GRID + xr*Const.GRID;
		yy = cy*Const.GRID + yr*Const.GRID;
		spr.x = Std.int(xx);
		spr.y = Std.int(yy-z*0.8);

		if( shadow!=null ) {
			shadow.x = Std.int(xx-shadow.width*0.5);
			shadow.y = Std.int(yy+1 - shadow.height*0.5);
			shadow.scaleX = shadow.scaleY = 1 - Math.min(1,z/50)*0.3;
		}
	}
}
