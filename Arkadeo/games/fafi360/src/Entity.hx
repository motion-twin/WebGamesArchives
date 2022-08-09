import flash.display.Sprite;
import mt.deepnight.deprecated.SpriteLibBitmap;

class Entity {
	static var UNIQ = 0;
	var uid				: Int;

	var game			: Game;
	var fx				: Fx;
	var seed			: Int;
	var rseed			: mt.Rand;
	public var spr		: Sprite;
	public var shadow	: Null<Sprite>;
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
	public var zbounce	: Float;
	public var zpriority: Int;
	//public var curSpeed	: Float;
	//public var maxSpeed	: Float;

	public function new() {
		game = Game.ME;
		uid = UNIQ++;
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

		spr = new Sprite();
		game.zsortLayer.addChild(spr);
		game.zsortables.push(this);

		//setShadow(14,6);
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
			shadow = null;
		}
	}

	function setShadow(w,h) {
		if( shadow!=null )
			removeShadow();
		shadow = new Sprite();
		game.sdm.add(shadow, Game.DP_BG2);
		shadow.graphics.clear();
		shadow.graphics.beginFill(0x0, 0.3);
		shadow.graphics.drawEllipse(-w*0.5,-h*0.5, w,h);
	}

	public function updateFromScreenCoords() {
		cx = Std.int(xx/Game.GRID);
		cy = Std.int(yy/Game.GRID);
		xr = (xx - cx*Game.GRID) / Game.GRID;
		yr = (yy - cy*Game.GRID) / Game.GRID;
	}

	public function unregister() {
		spr.parent.removeChild(spr);
		removeShadow();

		game.zsortables.remove(this);
	}

	public function destroy() {
		if( !fl_destroyed ) {
			game.killList.push(this);
			fl_destroyed = true;
		}
	}

	inline function moving() {
		return dx!=0 || dy!=0;
	}

	inline function irnd(min, max, ?sign) { return Math.round( rseed.range(min, max, sign) ); }
	inline function rnd(min, max, ?sign) { return rseed.range(min, max, sign); }

	inline function getActualSpeed() {
		return Math.sqrt(dx*dx + dy*dy);
	}

	inline function collides(x,y) {
		return game.getColHeight(x,y)>z;
	}

	function onWallBounce() {}

	function onGroundBounce() {}

	public inline function distance(e:Entity) {
		return mt.deepnight.Lib.distance(xx,yy, e.xx,e.yy);
	}

	public function explode(radius:Int) {
		if( fl_destroyed )
			return;

		var b = game.ball;
		fx.flashBang(0xFFFF00, 0.3, 600);
		fx.explosion(xx,yy, radius);
		for(p in game.allPlayers)
			if( distance(p)<=radius+5 ) {
				var a = Math.atan2(p.yy-yy, p.xx-xx);
				p.knock(a, 2);
			}

		if( distance(b)<=radius+5 ) {
			var a = Math.atan2(b.yy-yy, b.xx-xx);
			b.dx = Math.cos(a)*0.4;
			b.dy = Math.sin(a)*0.4;
			b.dz = 5;
		}

		destroy();
	}

	inline function onScreen() {
		return
			xx>=game.viewport.left-16 && xx<=game.viewport.right+16 &&
			yy>=game.viewport.top-4 && yy<=game.viewport.bottom+40;
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
						if( xr>=0.7 && d>0 && collides(cx+1,cy) ) {
							xr = 0.7;
							dy*=0.8;
							onWallBounce();
							if( colBounce==0 ) {
								d = dx = 0;
								break;
							}
							else {
								d*=-colBounce;
								dx*=-colBounce;
							}
						}
						if( xr<=0.3 && d<0 && collides(cx-1,cy) ) {
							xr = 0.3;
							dy*=0.8;
							onWallBounce();
							if( colBounce==0 ) {
								d = dx = 0;
								break;
							}
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
						if( yr>=0.7 && d>0 && collides(cx,cy+1) ) {
							yr = 0.7;
							dx*=0.8;
							onWallBounce();
							if( colBounce==0 ) {
								d = dy = 0;
								break;
							}
							else {
								d*=-colBounce;
								dy*=-colBounce;
							}
							break;
						}
						if( yr<=0.3 && d<0 && collides(cx,cy-1) ) {
							yr = 0.3;
							dx*=0.8;
							onWallBounce();
							if( colBounce==0 ) {
								d = dy = 0;
								break;
							}
							else {
								d*=-colBounce;
								dy*=-colBounce;
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

		xx = cx*Game.GRID + xr*Game.GRID;
		yy = cy*Game.GRID + yr*Game.GRID;
		if( !game.isChoosingPerk() ){
			spr.x = Std.int(xx);
			spr.y = Std.int(yy-z);
		}
		if( shadow!=null ) {
			shadow.x = Std.int(xx);
			shadow.y = Std.int(yy+1);
			shadow.scaleX = shadow.scaleY = 1 - Math.min(1,z/50)*0.5;
		}
	}
}
