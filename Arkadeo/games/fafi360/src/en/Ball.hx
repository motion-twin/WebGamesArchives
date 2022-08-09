package en;

import mt.flash.Volatile;
import flash.display.Bitmap;
import flash.display.BitmapData;

class Ball extends Entity {
	static inline var WATER_FRICT = 0.95;
	static inline var SNOW_FRICT = 0.7;
	public static var RADIUS = 6;
	//public var lastOwnerSide: Volatile<Int>;
	public var owner		: Null<Player>;
	public var reset		: Int;
	
	public var lastOwner	: Null<Player>;
	
	var texture				: BitmapData;
	var texX				: Float;
	var texY				: Float;
	var tmatrix				: flash.geom.Matrix;
	
	var snow				: Bool;
	var outOfTheGame		: Bool;
	
	public function new() {
		super();
		
		snow = game.oppTeam.hasPerk(_PSnowTerrain);
		
		outOfTheGame = false;
		frict = 0.985;
		reset = 0;
		//lastOwnerSide = 0;
		zpriority = 5;
		zbounce = 0.85;
		if( game.hasLeather() )
			zbounce = 2;
		texX = texY = 0;
		cx = Game.FPADDING+1;
		cy = Std.int(Game.FPADDING+Game.FHEI*0.5);
		
		texture = game.tiles.getBitmapData("ballTexture", snow ? 1 : 0);
		
		tmatrix = new flash.geom.Matrix();
		updateTexture();
		var dark = snow ? 0x3C1702 : 0x1E3909;
		spr.filters = [
			new flash.filters.GlowFilter(0x3D0B05,0.9, 2,2,3),
			new flash.filters.GlowFilter(dark,0.5, 4,4,1, 1,true),
			new flash.filters.DropShadowFilter(4,-120, dark,0.7, 4,4,1, 1,true),
		];
		var phong = new flash.display.Sprite();
		spr.addChild(phong);
		phong.graphics.beginFill(snow ? 0xFFD26A : 0xFFFFFF,0.5);
		phong.graphics.drawCircle(-2,-6,RADIUS*0.5);
		
		setShadow(14,7);
	}
	
	public override function unregister() {
		super.unregister();
		texture.dispose();
		owner = null;
		game.ball = null;
	}

	override function onWallBounce() {
		super.onWallBounce();
		if( !hasOwner() )
			game.fx.hit(cx*Game.GRID+xr*Game.GRID, cy*Game.GRID+yr*Game.GRID-z);
		checkGoals();
	}
	
	override function onGroundBounce() {
		super.onGroundBounce();
		
		if( dz>=1.5 )
			game.fx.smokeGroundHit(this);
			
		if( game.hasSnow() ) {
			game.snowHole(xx,yy, 0.5);
			dz*=0.6;
		}
		
		if( game.checkWaterPerlin(xx,yy) ) {
			dx*=WATER_FRICT*0.8;
			dy*=WATER_FRICT*0.8;
			fx.waterHit(xx,yy, 1);
			dz*=0.5;
		}
		checkGoals();
	}
	
	public inline function getLastOwnerSide() {
		return lastOwner!=null ? lastOwner.side : -1;
	}
	
	public function onKick() {
		reset = 0;
		lastOwner = owner;
		owner = null;
		game.resetCharge();
	}
	
	public function takenBy(p:Player) {
		reset = 0;
		owner = p;
		dx = dy = 0;
		dz *= 0.3;
		z *= 0.3;
		if( game.hasLeather() ) {
			z = 0;
			dz = 0;
		}
		backInGame();
	}
	
	public inline function hasOwner() {
		return owner!=null;
	}
	
	public inline function free() {
		return owner==null;
	}
	
	inline function inGoal(side:Int, ?always=false) {
		var r = game.getGoalRectangle(side);
		return
			!outOfTheGame &&
			( always || !game.matchEnded() ) &&
			cx>=r.x && cx<r.x+r.w && cy>=r.y && cy<r.y+r.h;
			//side==0 ? cx<=Game.FPADDING-1 : cx>=Game.FPADDING+Game.FWID;
	}
	
	function checkGoals() {
		if( game.matchEnded() || cd.has("goal") || !game.isPlaying() || outOfTheGame )
			return false;
			
		if( inGoal(1) ) {
			game.goal(true);
			cd.set("goal", 40);
			return true;
		}
		
		if( inGoal(0) ) {
			game.goal(false);
			cd.set("goal", 40);
			return true;
		}
		
		return false;
	}
	
	inline function updateTexture() {
		spr.graphics.clear();
		spr.graphics.beginBitmapFill(texture, tmatrix);
		spr.graphics.drawCircle(0, -4, RADIUS);
	}
	
	public function leaveGame() {
		outOfTheGame = true;
		spr.parent.removeChild(spr);
		game.sdm.add(spr, Game.DP_GOAL_CAGE);
		game.zsortables.remove(this);
	}
	
	public function backInGame() {
		if( !outOfTheGame )
			return;
		outOfTheGame = false;
		spr.parent.removeChild(spr);
		game.zsortLayer.addChild(spr);
		game.zsortables.push(this);
		if( collides(cx,cy) ) {
			xx = owner.xx;
			yy = owner.yy;
			updateFromScreenCoords();
			z = 40;
		}
	}
	
	override public function update() {
		fl_collide = !outOfTheGame && !hasOwner();
		
		if( cx<0 || cx>=Game.FPADDING*2+Game.FWID || cy<0 || cy>=Game.FPADDING*2+Game.FHEI ) {
			if( !cd.has("out") ) {
				cd.set("out", 10);
				cd.onComplete("out", game.onLostBall);
			}
		}
			
		var wasInGoal = inGoal(0,true) || inGoal(1,true);
		colBounce = wasInGoal ? 0.2 : 1;
		if( !outOfTheGame && wasInGoal && z>30 )
			z = 30;
			
		// Magnétisme
		if( game.playerTeam.hasPerk(_PMagneticBall) )
			if( game.isPlaying() && dx>0 && cx>=Game.FPADDING+Game.FWID*0.65 ) {
				var r = game.getGoalRectangle(1);
				var a = Math.atan2(r.y+r.h*0.5-cy, r.x-cx);
				var s = 0.010;
				dy+=Math.sin(a)*s;
			}
		
		super.update();
		
		// Passe au dessus du but
		if( !wasInGoal && (inGoal(0,true) || inGoal(1,true)) )
			if( game.isPlaying() && !outOfTheGame && z>=33 )
				leaveGame();
		
		
		if( reset>0 ) {
			if( reset<30 )
				spr.alpha = game.time%3==0 ? 0.7 : 0.3;
			else
				spr.alpha = game.time%4==0 ? 0.5 : 1;
			reset--;
			if( reset<=0 && game.isPlaying() ) {
				reset = 0;
				game.onLostBall();
			}
		}
		else
			spr.alpha = 1;
		
		if( hasOwner() ) {
			var tx = owner.xx+owner.dir*6;
			var ty = owner.yy+1;
			z = owner.z>0 ? owner.z+8 : 0;
			if( xx!=tx || yy!=ty ) {
				var d = mt.deepnight.Lib.distance(xx,yy, tx,ty);
				if( d>=1 ) {
					var a = Math.atan2(ty-yy, tx-xx);
					dx = Math.cos(a)*d*0.03;
					dy = Math.sin(a)*d*0.03;
				}
				else
					dx = dy = 0;
			}
		}
		
		var inWater = game.checkWaterPerlin(xx,yy);
		if( z<=1 ) {
			if( game.hasSnow() ) {
				dx*=SNOW_FRICT;
				dy*=SNOW_FRICT;
			}
			if( inWater ) {
				dx*=WATER_FRICT;
				dy*=WATER_FRICT;
			}
			checkGoals();
		}
			
		texX+=dx*5;
		texY+=dy*5;
		tmatrix.translate(dx*5, dy*5);
		
		// Clignotement "passes"
		if( game.pass>=Game.PASS_THRESHOLD ) {
			if( !cd.has("shine") ) {
				cd.set("shine", Game.FPS * 0.5);
				cd.onComplete("shine", function() {
					spr.transform.colorTransform = new flash.geom.ColorTransform();
				});
			}
			
			if( cd.has("shine") ) {
				var f = cd.get("shine") / (Game.FPS*0.5);
				//shine-=0.1;
				var ct = mt.deepnight.Color.getColorizeCT(0xFFFF00, f*0.8);
				spr.transform.colorTransform = ct;
			}
		}
		
		if( free() ) {
			var s = getActualSpeed();
			if( !game.lowq ) {
				if( s>=0.02 ) {
					fx.ballTrail(this, Math.min(1, s/0.5));
					if( game.pass>=Game.PASS_THRESHOLD )
						fx.fireTrail(this);
				}
				if( s>=0.05 && z<=1 && inWater )
					fx.waterHit(xx,yy, Math.min(1, s/0.8));
				if( s>=0.15 && z<=1 && inWater )
					fx.grass(xx, yy+3, 1);
			}
			if( reset==0 && s<=0.1 && Lambda.filter(game.allPlayers, function(p) return p.seekingBall).length<=1 )
				reset = 60;
		}
		
		updateTexture();
		
		//game.addBlurSpot( xx+game.scroller.x, yy+game.scroller.y-z, 0xFFFFFF, 5);
	}
}