package en;

import mt.deepnight.slb.BSprite;
import mt.deepnight.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.MLib;

enum BallMode {
	Normal;
	Rugby;
	Bowling;
	Electric;
}

class Ball extends Entity {
	static var ELECTRIC_FREQ = Const.seconds(8);
	static inline var WATER_FRICT = 0.95;
	static inline var SNOW_FRICT = 0.4;
	public static var RADIUS = 6;

	var phong				: BSprite;

	public var owner		: Null<Player>;
	public var lastOwner	: Null<Player>;
	var extraRotation		: Float;
	var dr					: Float;

	var outOfTheGame		: Bool;
	var mode				: BallMode;
	var electricCounter		: Int;
	var etf					: Null<flash.text.TextField>;

	var isLost				: Bool;
	var lostTimer			: Int;
	public var lastAng		: Float;

	public function new() {
		super();
		lostTimer = 0;
		canWarp = true;
		extraRotation = 0;
		dr = 0;
		isLost = true;
		mode = Normal;
		electricCounter = 0;
		lastAng = 0;

		phong = game.tiles.get("ballPhong");
		spr.addChild(phong);
		phong.setCenter(0.5, 0.5);

		spr.set(game.tiles);
		spr.a.setGeneralSpeed(0.6);
		spr.a.playAndLoop("ball");
		spr.setCenter(0.5, 0.5);

		outOfTheGame = false;
		frict = 0.985;
		zpriority = 5;
		zbounce = 0.85;
		if( game.hasLeather() )
			zbounce *= 3;
		cx = Const.FPADDING+1;
		cy = Std.int(Const.FPADDING+Const.FHEI*0.5);

		setShadow(14,7);
	}

	public function setRugby() {
		mode = Rugby;
		phong.visible = false;
		spr.a.playAndLoop("ballRugby");
		zbounce*=1.2;
		//zbounce = MLib.fmax(1.2, zbounce);
	}

	public function setBowling() {
		mode = Bowling;
		spr.a.playAndLoop("ballBowling");
		phong.set("ballBowling_Phong");
	}

	public function setElectric() {
		mode = Electric;

		spr.a.playAndLoop("ballElectric");
		phong.set("ballElectricPhong");
		zbounce*=1.5;

		etf = game.createField("99", FBig, true);
		game.sdm.add(etf, Const.DP_INTERF);
		etf.filters = [];
		etf.cacheAsBitmap = true;
		initElectricCounter();
	}


	public inline function makeUncatchable(side:Int, d:Float) {
		cd.set("uncatchable"+side, d);
	}

	public inline function makeUncatchableBoth(d:Float) {
		makeUncatchable(0, d);
		makeUncatchable(1, d);
	}


	public function loseElectricCounter() {
		if( mode!=Electric || cd.has("lostCounter") || cd.has("electroPause") )
			return true;

		cd.set("lostCounter", 5);
		fx.electricityBounce(xx,yy);
		electricCounter--;
		etf.text = Std.string(electricCounter);
		if( electricCounter<=0 ) {
			// Discharge!
			var r = 100;
			fx.electricExplosion(xx,yy, r);
			initElectricCounter();
			for(e in Player.ALL)
				if( distance(e)<=r ) {
					e.knock(xx,yy, rnd(0.5, 1));
					e.cd.set("electric", Const.seconds(2));
				}

			m.Global.SBANK.foudre(1);
			cd.set("electroPause", 99999);
			return false;
		}
		else
			return true;
	}

	public function getLostReachFactor() {
		return !isLost ? 1 : 1.5 + 0.2 * lostTimer/Const.FPS;
	}

	function initElectricCounter() {
		electricCounter = 6;
		etf.text = Std.string(electricCounter);
	}

	public override function unregister() {
		owner = null;
		game.ball = null;
		phong.dispose();

		if( etf!=null )
			etf.parent.removeChild(etf);


		super.unregister();
	}


	public function onNewRound() {
		switch( mode ) {
			case Electric :
				//electricCharge = 0;
				initElectricCounter();

			case Normal, Bowling, Rugby :
		}
	}

	override function onWallBounce() {
		super.onWallBounce();

		if( !cd.hasSet("bounceSfx", 3) )
			m.Global.SBANK.ballon_bord( getActualSpeed()/1.5 );

		if( !hasOwner() )
			game.fx.hit(cx*Const.GRID+xr*Const.GRID, cy*Const.GRID+yr*Const.GRID-z);

		if( collides(cx,cy) && game.stadium.getCollisionHeight(cx,cy)<=Const.OBSTACLE_HEIGHT )
			onBounceOverObstacle();

		if( !hasOwner() )
			loseElectricCounter();

		checkGoals();
	}

	function onBounceOverObstacle() {
		dz = rnd(4,5);
		dx = rnd(0.1, 0.3, true);
		dy = rnd(0.1, 0.3, true);
		loseElectricCounter();
	}

	override function onGroundBounce() {
		super.onGroundBounce();

		if( outOfTheGame )
			onLeaveField();

		if( dz>=2 && !hasOwner() ) {
			var pow = MLib.fclamp((dz-2)/8, 0, 1);
			if( mode==Bowling )
				m.Global.SBANK.bowling_rebond(pow);
			else if( game.oppTeam.hasPerk(_PLeather) )
				m.Global.SBANK.boing(0.2+pow*0.6);
			else
				m.Global.SBANK.balle_rebond(pow);
		}

		switch( mode ) {
			case Normal, Electric :

			case Rugby :
				var s = getActualSpeed();
				var a = Math.atan2(dy,dx) + rnd(0,1.5,true);
				dx = Math.cos(a)*s;
				dy = Math.sin(a)*s;
				extraRotation = 0;
				dr = rnd(0, 15, true);

			case Bowling :
				if( MLib.fabs(dz) >= 1.6 ) {
					dx*=0.4;
					dy*=0.4;
					dz*=0.5;
					game.shake(0.1, 0.8);
				}
				else {
					dx*=0.75;
					dy*=0.75;
				}
		}

		if( dz>=0.5 && !hasOwner() )
			loseElectricCounter();

		if( dz>=1.5 )
			game.fx.smokeGroundHit(this);

		if( game.hasSnow() ) {
			game.stadium.snowHole(xx,yy);
			dz*=0.6;
		}

		if( dz>=1.5 && game.stadium.checkGluePerlin(xx,yy) ) {
			mt.flash.Sfx.playOne([
				m.Global.SBANK.ballon_flaque1,
				m.Global.SBANK.ballon_flaque2,
				m.Global.SBANK.ballon_flaque3,
			]);
		}

		if( game.stadium.checkWaterPerlin(xx,yy) ) {
			//dx*=WATER_FRICT*0.8;
			//dy*=WATER_FRICT*0.8;
			//fx.waterHit(xx,yy, 1);
			//dz*=0.5;
		}

		if( collides(cx,cy) )
			if( game.stadium.getCollisionHeight(cx,cy)<=Const.OBSTACLE_HEIGHT )
				onBounceOverObstacle();
			else if( !outOfTheGame )
				leaveGame(); // rebond à l'extérieur ??

		checkGoals();
	}


	public function bowlingHit(p:Player) {
		var a = Math.atan2(yy-p.yy, xx-p.xx) + rnd(0,1,true);
		var s = getActualSpeed() * rnd(0.6, 1);
		dx = Math.cos(a)*s;
		dy = Math.sin(a)*s;

		var pow = MLib.fclamp(getActualSpeed(0.1)*2, 0.3, 1);
		fx.bowlingHit(p.xx, p.yy, pow);
		p.knock(xx,yy, pow);
		m.Global.SBANK.bowling_rebond(1);
		game.shake(0.6, 0.9);
	}


	public function tryToCatch(p:Player) {
		if( outOfTheGame )
			return false;

		switch( mode ) {
			case Normal, Rugby, Electric :
				return true;

			case Bowling :
				if( getActualSpeed(0.1)>=0.44 ) {
					bowlingHit(p);
					return false;
				}
				else
					return true;
		}
	}



	public inline function getOwnerOrLastOwnerSide() {
		return hasOwner() ? owner.side : (lastOwner!=null ? lastOwner.side : -1);
	}


	public inline function getLastOwnerSide() {
		return lastOwner!=null ? lastOwner.side : -1;
	}

	public function onKick() {
		lastOwner = owner;
		owner = null;
		game.resetCharge();
		cd.set("teleport", 5);
	}

	function resetLost() {
		isLost = false;
		cd.set("lostImmune", Const.seconds(1.7));
	}

	public function takenBy(p:Player) {
		resetLost();
		cd.unset("electroPause");
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

	inline function inGoal(side:Int, cx,cy, ?always=false) {
		var r = game.stadium.getGoalRectangle(side);
		return
			!outOfTheGame &&
			( always || !game.matchEnded() ) &&
			cx>=r.x && cx<r.x+r.w && cy>=r.y && cy<r.y+r.h;
	}

	function checkGoals() {
		if( cd.has("goalBounce") )
			return false;

		if( game.matchEnded() || cd.has("goal") || !game.isPlaying() || outOfTheGame )
			return false;

		if( inGoal(1, cx,cy) ) {
			game.goal(true);
			cd.set("goal", 40);
			return true;
		}

		if( hasOwner() && inGoal(1, owner.cx, owner.cy) ) {
			game.goal(true);
			cd.set("goal", 40);
			return true;
		}

		if( inGoal(0, cx,cy) ) {
			game.goal(false);
			cd.set("goal", 40);
			return true;
		}

		if( hasOwner() && inGoal(0, owner.cx, owner.cy) ) {
			game.goal(false);
			cd.set("goal", 40);
			return true;
		}

		return false;
	}



	public function leaveGame() {
		isLost = false;
		outOfTheGame = true;
		spr.parent.removeChild(spr);
		game.sdm.add(spr, Const.DP_GOAL_CAGE);
		game.zsortables.remove(this);
	}


	function onLeaveField() {
		if( !cd.has("out") ) {
			cd.set("out", 30);
			game.delayer.add( game.onLostBall, 10 );
		}
	}



	public function backInGame() {
		if( !outOfTheGame )
			return;

		outOfTheGame = false;
		spr.parent.removeChild(spr);
		game.zsortLayer.addChild(spr);
		game.zsortables.push(this);
		if( collides(cx,cy) && owner!=null ) {
			xx = owner.xx;
			yy = owner.yy;
			updateFromScreenCoords();
			z = 40;
		}
	}



	override public function update() {
		fl_collide = !outOfTheGame && !hasOwner();

		if( cx>=Const.FPADDING+Const.FWID*0.5 )
			game.tutorial.trigger(_PTuto1, 2);

		if( cx>=Const.FPADDING+Const.FWID*0.55 )
			game.tutorial.trigger(_PTuto2, 2);

		if( cx<0 || cx>=Const.FPADDING*2+Const.FWID || cy<0 || cy>=Const.FPADDING*2+Const.FHEI )
			onLeaveField();

		var wasInGoal = inGoal(0,cx,cy,true) || inGoal(1,cx,cy,true);
		colBounce = wasInGoal ? 0.2 : 1;
		if( !outOfTheGame && wasInGoal && z>30 && !cd.has("goalBounce") )
			z = 30;

		// Magnétisme
		//if( game.playerTeam.hasPerk(_PMagneticBall) )
			//if( game.isPlaying() && dx>0 && cx>=Const.FPADDING+Const.FWID*0.65 ) {
				//var r = game.stadium.getGoalRectangle(1);
				//var a = Math.atan2(r.y+r.h*0.5-cy, r.x-cx);
				//var s = 0.010;
				//dy+=Math.sin(a)*s;
			//}


		super.update();


		// Electric discharge
		if( mode==Electric && game.isPlaying() )
			fx.electricityBall(spr.x, spr.y, 1-electricCounter/5);


		// Wind
		if( !hasOwner() && !outOfTheGame ) {
			var a = Math.atan2(dy,dx);
			var s = (z>=5 ? 0.017 : 0.012) * game.windPower;
			dx += Math.cos(game.windAng)*s;
			dy += Math.sin(game.windAng)*s;
		}


		// Passe au dessus du but
		if( !wasInGoal && (inGoal(0,cx,cy,true) || inGoal(1,cx,cy,true)) )
			if( game.isPlaying() && !outOfTheGame && z>=33 ) {
				if( z<=36 ) {
					// Rebond dans la barre
					fx.flashBang(0xFF0000, 0.6, 1000);
					dx = -rnd(0.1, 0.3);
					dy += rnd(0, 0.3, true);
					dz += -rnd(2, 3);
					cd.set("goalBounce", 10);
					m.Crowd.ME.onGoalBarHit(getPositionRatio().x>0.5 ? 1 : 0);
					m.Global.SBANK.ballon_bord(1);
				}
				else {
					// Sortie
					leaveGame();
					m.Crowd.ME.onLeaveField(getPositionRatio().x>0.5 ? 1 : 0);
				}
			}


		// Lost balls
		if( hasOwner() )
			resetLost();

		if( !hasOwner() && !cd.has("lostImmune") ) {
			if( !isLost ) {
				isLost = true;
				lostTimer = 0;
			}
			else
				lostTimer++;
		}


		// Stick to feet
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

		// On ground
		var inWater = game.stadium.checkWaterPerlin(xx,yy);
		if( z<=1 ) {
			if( game.hasSnow() ) {
				dx*=SNOW_FRICT;
				dy*=SNOW_FRICT;
			}
			if( inWater ) {
				dx*=WATER_FRICT;
				dy*=WATER_FRICT;
			}
			if( mode==Bowling ) {
				dx*=0.95;
				dy*=0.95;
			}
			checkGoals();
		}

		if( free() ) {
			var s = getActualSpeed();
			if( !game.lowq ) {
				if( s>=0.15 )
					fx.ballTrail(this, Math.min(1, s/0.5));

				//if( s>=0.05 && z<=1 && inWater )
					//fx.waterHit(xx,yy, Math.min(1, s/0.8));

				if( s>=0.15 && z<=1 && inWater )
					fx.grass(xx, yy+3, 1);
			}
		}

		// Store last direction
		if( !hasOwner() && getActualSpeed()>0.05 )
			lastAng = Math.atan2(dy,dx);


		// Ball animation
		var s = getActualSpeed();
		spr.a.setGeneralSpeed(2 * s/0.5);
		extraRotation+=dr;
		if( hasOwner() )
			spr.rotation = 0;
		else if( MLib.fabs(dx)>0.1 || MLib.fabs(dy)>0.1 )
			spr.rotation = extraRotation + MLib.toDeg( Math.atan2(dy,dx) );
		spr.y-=4;
		spr.scaleX = spr.scaleY = 1.2 + (z/50)*(z/50);
		phong.rotation = -spr.rotation;

		if( etf!=null ) {
			etf.x = Std.int(spr.x-etf.textWidth*0.5);
			etf.y = spr.y-25;
			etf.visible = !cd.has("electroPause");
		}

		if( cd.has("teleportFadeOut") )
			spr.a.setGeneralSpeed(2);

		// Sprite offset
		if( mode==Bowling )
			spr.y -= 3;
	}
}